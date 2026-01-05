import 'dart:convert';

typedef ObjectPropertyGetter = dynamic Function(Object object, String key);
typedef ObjectPropertySetter =
    bool Function(Object object, String key, dynamic value);

/// Laravel-like data_get for Dart.
/// Supports:
/// - Map / List traversal
/// - dot notation
/// - numeric indexes ("0", "1", ...)
/// - wildcard "*" (collects values)
/// - JSON string input (decoded automatically)
/// - escaping "\*" to mean literal "*" segment
/// - optional object property access via [objectGetter]
dynamic dataGet(
  dynamic target,
  dynamic key, {
  dynamic defaultValue,
  ObjectPropertyGetter? objectGetter,
}) {
  // Laravel: if key is null return the whole target
  if (key == null) return _normalizeJson(target);

  target = _normalizeJson(target);

  final List<String> segments = _normalizeKey(key);
  if (segments.isEmpty) return target;

  dynamic current = target;
  List<String> remaining = segments;

  while (remaining.isNotEmpty) {
    final segment = remaining.first;
    remaining = remaining.sublist(1);

    if (segment == '') continue;
    if (segment == '*') {
      if (current is Map) {
        final results = <dynamic>[];
        for (final value in current.values) {
          results.add(
            dataGet(
              value,
              remaining,
              defaultValue: defaultValue,
              objectGetter: objectGetter,
            ),
          );
        }
        // If there’s another '*' deeper, collapse one level (like Arr::collapse-ish).
        return remaining.contains('*') ? _collapse(results) : results;
      }

      if (current is Iterable) {
        final results = <dynamic>[];
        for (final item in current) {
          results.add(
            dataGet(
              item,
              remaining,
              defaultValue: defaultValue,
              objectGetter: objectGetter,
            ),
          );
        }
        return remaining.contains('*') ? _collapse(results) : results;
      }

      return defaultValue;
    }

    final seg = _unescapeSegment(segment);

    if (current is Map) {
      if (current.containsKey(seg)) {
        current = current[seg];
        continue;
      }

      // If segment is numeric and map keys are ints (rare but possible)
      final intKey = int.tryParse(seg);
      if (intKey != null && current.containsKey(intKey)) {
        current = current[intKey];
        continue;
      }

      return defaultValue;
    }

    if (current is List) {
      final idx = int.tryParse(seg);
      if (idx == null || idx < 0 || idx >= current.length) return defaultValue;
      current = current[idx];
      continue;
    }

    // Optional: allow access into custom objects (Dart classes)
    if (current is Object && objectGetter != null) {
      final value = objectGetter(current, seg);
      if (value != null) {
        current = value;
        continue;
      }
      return defaultValue;
    }

    // Nothing to traverse
    return defaultValue;
  }

  return current;
}

/// Laravel-like data_set for Dart.
/// Mutates Map/List structures where possible and returns the updated target.
/// Supports:
/// - Map / List traversal
/// - dot notation
/// - numeric indexes ("0", "1", ...)
/// - wildcard "*" (set across all children)
/// - JSON string input (decoded; returns Map/List, not a JSON string)
/// - optional object property set via [objectSetter] (returns true if set)
dynamic dataSet(
  dynamic target,
  dynamic key,
  dynamic value, {
  bool overwrite = true,
  ObjectPropertySetter? objectSetter,
}) {
  target = _normalizeJson(target);
  final segments = _normalizeKey(key);

  if (segments.isEmpty) return target;

  return _dataSetInternal(
    target,
    segments,
    value,
    overwrite: overwrite,
    objectSetter: objectSetter,
  );
}

dynamic _dataSetInternal(
  dynamic target,
  List<String> segments,
  dynamic value, {
  required bool overwrite,
  ObjectPropertySetter? objectSetter,
}) {
  if (segments.isEmpty) return target;

  final seg = _unescapeSegment(segments.first);
  final rest = segments.sublist(1);

  // Wildcard: apply to all children
  if (seg == '*') {
    if (target is Map) {
      if (rest.isNotEmpty) {
        for (final k in target.keys.toList()) {
          target[k] = _dataSetInternal(
            target[k],
            rest,
            value,
            overwrite: overwrite,
            objectSetter: objectSetter,
          );
        }
      } else if (overwrite) {
        for (final k in target.keys.toList()) {
          target[k] = value;
        }
      }
      return target;
    }

    if (target is List) {
      if (rest.isNotEmpty) {
        for (var i = 0; i < target.length; i++) {
          target[i] = _dataSetInternal(
            target[i],
            rest,
            value,
            overwrite: overwrite,
            objectSetter: objectSetter,
          );
        }
      } else if (overwrite) {
        for (var i = 0; i < target.length; i++) {
          target[i] = value;
        }
      }
      return target;
    }

    // If target isn't iterable, create a list (closest Dart analogue to Laravel behavior)
    final newList = <dynamic>[];
    return _dataSetInternal(
      newList,
      segments, // retry with same segments on new container
      value,
      overwrite: overwrite,
      objectSetter: objectSetter,
    );
  }

  // Map
  if (target is Map) {
    if (rest.isEmpty) {
      if (overwrite || !target.containsKey(seg)) {
        target[seg] = value;
      }
      return target;
    }

    if (!target.containsKey(seg) || target[seg] == null) {
      // decide container type based on next segment
      target[seg] = _containerFor(rest.first);
    }

    target[seg] = _dataSetInternal(
      target[seg],
      rest,
      value,
      overwrite: overwrite,
      objectSetter: objectSetter,
    );

    return target;
  }

  // List
  if (target is List) {
    final idx = int.tryParse(seg);
    if (idx == null || idx < 0) {
      // If not numeric, we can’t index a list by string segment.
      // Convert to map-like structure (best effort).
      final map = <String, dynamic>{};
      return _dataSetInternal(
        map,
        segments,
        value,
        overwrite: overwrite,
        objectSetter: objectSetter,
      );
    }

    // Expand list to fit index
    while (target.length <= idx) {
      target.add(null);
    }

    if (rest.isEmpty) {
      if (overwrite || target[idx] == null) {
        target[idx] = value;
      }
      return target;
    }

    if (target[idx] == null) {
      target[idx] = _containerFor(rest.first);
    }

    target[idx] = _dataSetInternal(
      target[idx],
      rest,
      value,
      overwrite: overwrite,
      objectSetter: objectSetter,
    );

    return target;
  }

  // Object (optional)
  if (target is Object && objectSetter != null) {
    if (rest.isEmpty) {
      final ok = objectSetter(target, seg, value);
      return ok ? target : target;
    }

    // If you want deeper object traversal, you’d also need an objectGetter
    // to fetch/set intermediate values; keeping it conservative here.
    return target;
  }

  // If target is primitive/null -> create a container and retry
  final container = _containerFor(
    seg.isEmpty ? '' : (rest.isEmpty ? '' : rest.first),
  );
  return _dataSetInternal(
    container,
    segments,
    value,
    overwrite: overwrite,
    objectSetter: objectSetter,
  );
}

dynamic _normalizeJson(dynamic target) {
  if (target is String) {
    final s = target.trim();
    if (s.startsWith('{') || s.startsWith('[')) {
      try {
        return jsonDecode(s);
      } catch (_) {
        // not valid JSON, keep string
        return target;
      }
    }
  }
  return target;
}

List<String> _normalizeKey(dynamic key) {
  if (key is List<String>) return key;
  if (key is List) return key.map((e) => e.toString()).toList();
  if (key is int) return [key.toString()];
  if (key is String) return key.split('.');
  return [key.toString()];
}

String _unescapeSegment(String segment) {
  // Laravel allows '\*' to mean '*'
  if (segment == r'\*') return '*';
  return segment;
}

dynamic _containerFor(String nextSegment) {
  final s = _unescapeSegment(nextSegment);
  if (s == '*') return <dynamic>[];
  final idx = int.tryParse(s);
  if (idx != null) return <dynamic>[];
  return <String, dynamic>{};
}

List<dynamic> _collapse(List<dynamic> items) {
  // Flatten 1 level if children are lists; keep non-lists as-is
  final out = <dynamic>[];
  for (final item in items) {
    if (item is List) {
      out.addAll(item);
    } else {
      out.add(item);
    }
  }
  return out;
}
