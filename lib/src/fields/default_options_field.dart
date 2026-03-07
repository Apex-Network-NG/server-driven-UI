import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/core/service/dio_service.dart';
import 'package:sdui/src/fields/field_modal.dart';
import 'package:sdui/src/fields/selector.dart';
import 'package:sdui/src/util/data_enhance.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIOptionsField extends SDUIBaseStatefulWidget {
  const SDUIOptionsField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() =>
      _SDUIOptionsFieldState();
}

class _SDUIOptionsFieldState extends SDUIBaseState<SDUIOptionsField> {
  @override
  Widget build(BuildContext context) {
    final properties = widget.field.optionProperties?.type;
    final isRadio = properties == 'radio';

    return _DynamicOptionsResolver(
      fieldWidget: widget,
      builder: (context, optionsData, isLoading) {
        if (isRadio) {
          return _BuildRadioOptions(
            widget: widget,
            optionsData: optionsData,
            isLoading: isLoading,
          );
        }
        return _BuildDropSelection(
          widget: widget,
          optionsData: optionsData,
          isLoading: isLoading,
        );
      },
    );
  }

  @override
  String? validateField(value) {
    return null;
  }
}

class _DynamicOptionsResolver extends StatefulWidget {
  final SDUIOptionsField fieldWidget;
  final Widget Function(BuildContext, List<SDUIOption>, bool) builder;

  const _DynamicOptionsResolver({
    required this.fieldWidget,
    required this.builder,
  });

  @override
  State<_DynamicOptionsResolver> createState() =>
      _DynamicOptionsResolverState();
}

class _DynamicOptionsResolverState extends State<_DynamicOptionsResolver> {
  final _deepEquality = const DeepCollectionEquality();
  final _cancelRequestToken = ValueNotifier<CancelToken?>(null);
  final _sourceDebounceTimers = <String, Timer>{};
  List<SDUIOption> _remoteOptions = const [];
  Map<String, dynamic> _dependencyState = const {};
  int _requestSequence = 0;
  bool _isLoading = false;
  bool _hasFetched = false;

  SDUIField get _field => widget.fieldWidget.field;
  FormManager get _formManager => widget.fieldWidget.formManager;

  SDUIOptionProperties? get _optionProperties => _field.optionProperties;
  SDUIOptionSource? get _source => _optionProperties?.source;
  bool get _hasRemoteSource => _source != null && _source!.enabled;

  @override
  void initState() {
    super.initState();
    _configureSource();
  }

  @override
  void didUpdateWidget(covariant _DynamicOptionsResolver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldWidget.formManager != widget.fieldWidget.formManager) {
      oldWidget.fieldWidget.formManager.removeListener(_onFormManagerChanged);
    }
    final sourceChanged = !_deepEquality.equals(
      oldWidget.fieldWidget.field.optionProperties?.source,
      _source,
    );
    final fieldKeyChanged = oldWidget.fieldWidget.field.key != _field.key;
    if (sourceChanged || fieldKeyChanged) {
      _configureSource(forceReload: true);
    }
  }

  @override
  void dispose() {
    _formManager.removeListener(_onFormManagerChanged);
    for (final timer in _sourceDebounceTimers.values) {
      timer.cancel();
    }
    _sourceDebounceTimers.clear();
    _cancelRequestToken.value?.cancel();
    _cancelRequestToken.dispose();
    super.dispose();
  }

  void _configureSource({bool forceReload = false}) {
    _formManager.removeListener(_onFormManagerChanged);
    _formManager.addListener(_onFormManagerChanged);
    _dependencyState = _captureDependencyState();

    if (!_hasRemoteSource) {
      if (_remoteOptions.isNotEmpty || _hasFetched) {
        setState(() {
          _remoteOptions = const [];
          _hasFetched = false;
          _isLoading = false;
        });
      }
      return;
    }

    final source = _source!;
    final shouldInitLoad = forceReload || _shouldTriggerOnInit(source);
    if (shouldInitLoad) {
      _loadRemoteOptions(source);
    }
  }

  void _onFormManagerChanged() {
    final source = _source;
    if (source == null || source.enabled != true) return;
    if (!_shouldTriggerOnDependencyChange(source)) return;

    final currentState = _captureDependencyState();
    if (_deepEquality.equals(currentState, _dependencyState)) return;
    _dependencyState = currentState;

    final timerKey = _field.key;
    _sourceDebounceTimers[timerKey]?.cancel();
    _sourceDebounceTimers[timerKey] = Timer(
      const Duration(milliseconds: 200),
      () => _loadRemoteOptions(source),
    );
  }

  Map<String, dynamic> _captureDependencyState() {
    final source = _source;
    if (source == null) return const {};
    final values = _formManager.getAllFormData();
    final keys = _dependencyKeys(source);
    return {for (final key in keys) key: values[key]};
  }

  Set<String> _dependencyKeys(SDUIOptionSource source) {
    final keys = <String>{};
    keys.addAll(source.dependsOn.where((k) => k.trim().isNotEmpty));

    final when = source.when;
    if (when != null) {
      keys.addAll(when.all.map((c) => c.key).where((k) => k.trim().isNotEmpty));
      keys.addAll(when.any.map((c) => c.key).where((k) => k.trim().isNotEmpty));
      keys.addAll(when.not.map((c) => c.key).where((k) => k.trim().isNotEmpty));
    }

    for (final param in source.params) {
      final raw = param.value;
      if (raw is String) {
        keys.addAll(_extractFieldKeysFromTemplate(raw));
      }
    }

    return keys;
  }

  Set<String> _extractFieldKeysFromTemplate(String template) {
    final matches = RegExp(r'\{field:([^}]+)\}').allMatches(template);
    return matches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((key) => key.isNotEmpty)
        .toSet();
  }

  bool _shouldTriggerOnInit(SDUIOptionSource source) {
    if (source.triggers.isEmpty) return true;
    return source.triggers.contains('init');
  }

  bool _shouldTriggerOnDependencyChange(SDUIOptionSource source) {
    final triggers = source.triggers;
    if (triggers.isEmpty) return source.dependsOn.isNotEmpty;

    return triggers.contains('change') ||
        triggers.contains('depends_on') ||
        triggers.contains('dependency') ||
        triggers.contains('debounce') ||
        source.dependsOn.isNotEmpty;
  }

  Future<void> _loadRemoteOptions(SDUIOptionSource source) async {
    if (source.enabled != true) return;
    if (source.endpoint.trim().isEmpty) return;

    if (!_sourceConditionsMet(source)) {
      if (!mounted) return;
      setState(() {
        _remoteOptions = const [];
        _hasFetched = true;
        _isLoading = false;
      });
      return;
    }

    _cancelRequestToken.value?.cancel();
    final cancelToken = CancelToken();
    _cancelRequestToken.value = cancelToken;
    final requestId = ++_requestSequence;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final apiConfig = SDUIAutofillApiRegistry.config;
      final dio = apiConfig.dio ?? DioService().dio;
      final method = source.method.trim().toUpperCase();
      final endpoint = _resolveEndpoint(
        source.endpoint,
        apiConfig.baseUrl ?? dio.options.baseUrl,
      );
      final headers = apiConfig.resolveHeaders(source.headers);
      final params = _resolveSourceParams(source.params);
      final options = Options(method: method, headers: headers);

      final response = await dio.request(
        endpoint,
        options: options,
        cancelToken: cancelToken,
        queryParameters: method == 'GET' ? params : null,
        data: method == 'GET' ? null : params,
      );

      if (!mounted || requestId != _requestSequence) return;
      final resolvedOptions = _mapResponseToOptions(source, response.data);

      setState(() {
        _remoteOptions = resolvedOptions;
        _hasFetched = true;
      });
      _syncSelectedOptions(resolvedOptions);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      Logger.logError(
        'Failed to load dynamic options for ${_field.key}: ${e.message}',
        tag: 'OptionsSource',
      );
      if (!mounted || requestId != _requestSequence) return;
      setState(() {
        _remoteOptions = const [];
        _hasFetched = true;
      });
    } catch (e) {
      Logger.logError(
        'Failed to resolve dynamic options for ${_field.key}: $e',
        tag: 'OptionsSource',
      );
      if (!mounted || requestId != _requestSequence) return;
      setState(() {
        _remoteOptions = const [];
        _hasFetched = true;
      });
    } finally {
      if (mounted && requestId == _requestSequence) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _resolveSourceParams(List<SDUIAutofillParam> params) {
    if (params.isEmpty) return {};

    final values = _formManager.getAllFormData();
    final resolved = <String, dynamic>{};
    for (final param in params) {
      final key = param.key.trim();
      if (key.isEmpty) continue;
      resolved[key] = _resolveParamValue(param.value, values);
    }
    return resolved;
  }

  dynamic _resolveParamValue(dynamic raw, Map<String, dynamic> values) {
    if (raw is String) {
      final trimmed = raw.trim();
      final exactMatch = RegExp(r'^\{field:([^}]+)\}$').firstMatch(trimmed);
      if (exactMatch != null) {
        final key = exactMatch.group(1)?.trim();
        return key == null ? null : values[key];
      }

      final matches = RegExp(r'\{field:([^}]+)\}').allMatches(raw);
      if (matches.isEmpty) return raw;

      var resolved = raw;
      for (final match in matches) {
        final key = match.group(1)?.trim();
        final value = key == null ? null : values[key];
        resolved = resolved.replaceAll(
          match.group(0)!,
          value?.toString() ?? '',
        );
      }
      return resolved;
    }
    return raw;
  }

  String _resolveEndpoint(String endpoint, String? baseUrl) {
    final trimmed = endpoint.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (baseUrl == null || baseUrl.trim().isEmpty) return trimmed;

    final normalizedBase = baseUrl.trim().endsWith('/')
        ? baseUrl.trim()
        : '${baseUrl.trim()}/';
    final normalizedEndpoint = trimmed.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse(normalizedBase).resolve(normalizedEndpoint).toString();
  }

  bool _sourceConditionsMet(SDUIOptionSource source) {
    final when = source.when;
    if (when == null) return true;

    final values = _formManager.getAllFormData();
    final allOk = when.all.every((c) => _evaluateCondition(c, values));
    final anyOk =
        when.any.isEmpty || when.any.any((c) => _evaluateCondition(c, values));
    final notOk = when.not.isEmpty
        ? when.not.every((c) => !_evaluateCondition(c, values))
        : true;

    return allOk && anyOk && notOk;
  }

  bool _evaluateCondition(
    SDUIAutofillCondition condition,
    Map<String, dynamic> values,
  ) {
    final left = values[condition.key];
    final right = condition.value;
    final op = condition.operator.trim().toLowerCase();

    switch (op) {
      case 'is':
        return _isEqual(left, right);
      case 'is_not':
        return !_isEqual(left, right);
      case 'length_gt':
        return _lengthCompare(left, right, (l, r) => l > r);
      case 'length_gte':
        return _lengthCompare(left, right, (l, r) => l >= r);
      case 'length_lt':
        return _lengthCompare(left, right, (l, r) => l < r);
      case 'length_lte':
        return _lengthCompare(left, right, (l, r) => l <= r);
      case 'length_eq':
        return _lengthCompare(left, right, (l, r) => l == r);
      case 'gt':
        return _numericCompare(left, right, (l, r) => l > r);
      case 'gte':
        return _numericCompare(left, right, (l, r) => l >= r);
      case 'lt':
        return _numericCompare(left, right, (l, r) => l < r);
      case 'lte':
        return _numericCompare(left, right, (l, r) => l <= r);
      case 'contains':
        return _containsValue(left, right);
      case 'starts_with':
        return _startsWith(left, right);
      case 'ends_with':
        return _endsWith(left, right);
      case 'empty':
        return _isEmpty(left);
      case 'not_empty':
        return !_isEmpty(left);
      default:
        return false;
    }
  }

  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  bool _isEqual(dynamic left, dynamic right) {
    if (left == null && right == null) return true;
    if (left == null || right == null) return false;

    final leftNum = _toNum(left);
    final rightNum = _toNum(right);
    if (leftNum != null && rightNum != null) {
      return leftNum == rightNum;
    }

    return left.toString() == right.toString();
  }

  bool _lengthCompare(
    dynamic left,
    dynamic right,
    bool Function(int, int) compare,
  ) {
    final leftLength = _valueLength(left);
    final rightNum = _toNum(right)?.toInt();
    if (leftLength == null || rightNum == null) return false;
    return compare(leftLength, rightNum);
  }

  int? _valueLength(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.length;
    if (value is Iterable) return value.length;
    if (value is Map) return value.length;
    return value.toString().length;
  }

  bool _numericCompare(
    dynamic left,
    dynamic right,
    bool Function(num, num) compare,
  ) {
    final leftNum = _toNum(left);
    final rightNum = _toNum(right);
    if (leftNum == null || rightNum == null) return false;
    return compare(leftNum, rightNum);
  }

  num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  bool _containsValue(dynamic left, dynamic right) {
    if (left == null || right == null) return false;
    if (left is Iterable) {
      return left.map((e) => e.toString()).contains(right.toString());
    }
    return left.toString().contains(right.toString());
  }

  bool _startsWith(dynamic left, dynamic right) {
    if (left == null || right == null) return false;
    return left.toString().startsWith(right.toString());
  }

  bool _endsWith(dynamic left, dynamic right) {
    if (left == null || right == null) return false;
    return left.toString().endsWith(right.toString());
  }

  List<SDUIOption> _mapResponseToOptions(
    SDUIOptionSource source,
    dynamic responseData,
  ) {
    dynamic rawItems = responseData;
    final itemsPath = source.itemsPath.trim();
    if (itemsPath.isNotEmpty) {
      rawItems = dataGet(
        jsonEncode(responseData),
        itemsPath,
        defaultValue: null,
      );
    }

    final iterable = switch (rawItems) {
      Iterable _ => rawItems,
      null => const [],
      _ => [rawItems],
    };

    final options = <SDUIOption>[];
    final seen = <String>{};
    for (final item in iterable) {
      final key = _resolveOptionKey(source, item);
      if (key.isEmpty || seen.contains(key)) continue;
      final value = _resolveOptionLabel(source, item, fallback: key);
      options.add(SDUIOption(key: key, value: value));
      seen.add(key);
    }
    return options;
  }

  String _resolveOptionKey(SDUIOptionSource source, dynamic item) {
    final path = source.valuePath.trim();
    dynamic rawValue;
    if (path.isEmpty) {
      rawValue = _readDefaultKey(item);
    } else {
      rawValue = _readPath(item, path);
    }

    final parsed = _toNonEmptyString(rawValue);
    if (parsed != null) return parsed;
    return _toNonEmptyString(_readDefaultKey(item)) ?? '';
  }

  String _resolveOptionLabel(
    SDUIOptionSource source,
    dynamic item, {
    required String fallback,
  }) {
    final path = source.keyPath.trim();
    dynamic rawValue;
    if (path == '*') {
      rawValue = _pickMapLabel(item);
    } else if (path.isNotEmpty) {
      rawValue = _readPath(item, path);
    } else {
      rawValue = _pickMapLabel(item);
    }

    return _toNonEmptyString(rawValue) ??
        _toNonEmptyString(_pickMapLabel(item)) ??
        fallback;
  }

  dynamic _readPath(dynamic target, String path) {
    if (path.trim().isEmpty) return null;
    if (path.trim() == '*') return target;
    return dataGet(jsonEncode(target), path, defaultValue: null);
  }

  dynamic _readDefaultKey(dynamic item) {
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      return map['key'] ?? map['code'] ?? map['id'] ?? map['value'];
    }
    return item;
  }

  dynamic _pickMapLabel(dynamic item) {
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      return map['name'] ??
          map['label'] ??
          map['title'] ??
          map['display_name'] ??
          map['displayName'] ??
          map['bank_name'] ??
          map['bankName'] ??
          map['value'] ??
          map['key'] ??
          map['code'];
    }
    return item;
  }

  String? _toNonEmptyString(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is num || value is bool) return value.toString();
    if (value is Map || value is List) {
      final encoded = jsonEncode(value);
      return encoded.trim().isEmpty ? null : encoded;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  void _syncSelectedOptions(List<SDUIOption> options) {
    final selected = _formManager.getSelectedOption(_field.key);
    if (selected == null || selected.isEmpty) return;
    final allowedKeys = options.map((e) => e.key).toSet();
    final filtered = selected.where((v) => allowedKeys.contains(v)).toList();
    if (_deepEquality.equals(selected, filtered)) return;
    _formManager.setSelectedOption(_field.key, filtered);
    widget.fieldWidget.onChanged?.call(_field.key, filtered);
  }

  List<SDUIOption> get _effectiveOptions {
    final staticOptions = _optionProperties?.data ?? const [];
    if (!_hasRemoteSource) return staticOptions;
    if (_hasFetched) return _remoteOptions;
    return staticOptions;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _effectiveOptions, _isLoading);
  }
}

class _BuildDropSelection extends StatefulWidget {
  final SDUIOptionsField widget;
  final List<SDUIOption> optionsData;
  final bool isLoading;

  const _BuildDropSelection({
    required this.widget,
    required this.optionsData,
    required this.isLoading,
  });

  @override
  State<_BuildDropSelection> createState() => _BuildDropSelectionState();
}

class _BuildDropSelectionState extends State<_BuildDropSelection> {
  @override
  Widget build(BuildContext context) {
    final field = widget.widget.field;
    final hintText = field.placeholder ?? field.label;
    final headerText = field.label;
    final formManager = widget.widget.formManager;

    List<String>? selectedValue = formManager.getSelectedOption(field.key);
    final optionsData = widget.optionsData;
    final optionsType = field.optionProperties?.type;
    final defaultValue = field.defaultValue;

    if ((selectedValue == null || selectedValue.isEmpty) &&
        defaultValue != null) {
      final defaults = defaultValue is List
          ? defaultValue.map((e) => e.toString()).toList()
          : [defaultValue.toString()];
      formManager.setSelectedOption(field.key, defaults);
      selectedValue = defaults;
    }

    final selectedOption = optionsData
        .where((option) => selectedValue?.contains(option.key) ?? false)
        .toList();
    final isMultiSelect = optionsType == 'multi-select';
    final theme = Theme.of(context);
    final loadingHint = widget.isLoading && optionsData.isEmpty
        ? 'Loading options...'
        : hintText;

    return Selector(
      hintText: loadingHint,
      header: headerText,
      titleWidget: isMultiSelect
          ? switch (selectedOption.isEmpty) {
              true => null,
              _ => SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: selectedOption.map((e) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: theme.colorScheme.onPrimary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Center(
                          child: Text(
                            e.value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            }
          : null,
      title: isMultiSelect ? null : selectedOption.firstOrNull?.value,
      errorText: formManager.getError(field.key),
      onTap: () async {
        if (widget.isLoading || optionsData.isEmpty) return;
        final selectedOptions = formManager.getSelectedOption(field.key);
        final result = await BottomSheetService.showBottomSheet(
          context: context,
          child: BaseSDUIModals(
            selectedOptionsKeys: selectedOptions,
            headerText: headerText,
            field: field,
            optionsData: optionsData,
          ),
        );

        if (!context.mounted) return;
        if (result != null) {
          final options = List<String>.from(result.map((e) => e.key));
          formManager.setSelectedOption(field.key, options);
          widget.widget.onChanged?.call(field.key, options);
          if (mounted) setState(() {});
          for (final element in options) {
            _validateField(element, optionsData);
          }
        }
      },
    );
  }

  void _validateField(String? value, List<SDUIOption> optionsData) {
    final formManager = widget.widget.formManager;
    final field = widget.widget.field;
    formManager.clearError(field.key);

    if (field.required && (value == null || value.isEmpty)) {
      final error = '${field.label} is required';
      formManager.addError(field.key, error);
    }

    if (value != null) {
      final allowedValues = optionsData.map((e) => e.key).toList();
      if (!allowedValues.contains(value)) {
        final error =
            'The selected ${field.label.toLowerCase()} is not supported';
        formManager.addError(field.key, error);
      }
    }

    for (final validation in field.validations ?? []) {
      final result = _validateRule(validation, value);
      if (result != null) {
        formManager.addError(field.key, result);
      }
    }
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: widget.widget.formManager,
      textValue: value,
      fieldType: widget.widget.field.type,
    );
  }
}

class _BuildRadioOptions extends StatefulWidget {
  const _BuildRadioOptions({
    required this.widget,
    required this.optionsData,
    required this.isLoading,
  });

  final SDUIOptionsField widget;
  final List<SDUIOption> optionsData;
  final bool isLoading;

  @override
  State<_BuildRadioOptions> createState() => _BuildRadioOptionsState();
}

class _BuildRadioOptionsState extends State<_BuildRadioOptions> {
  @override
  Widget build(BuildContext context) {
    final optionsData = widget.optionsData;
    final headerText = widget.widget.field.label;
    final theme = Theme.of(context);
    List<String>? value = widget.widget.formManager.getSelectedOption(
      widget.widget.field.key,
    );
    final formManager = widget.widget.formManager;
    final defaultValue = widget.widget.field.defaultValue;

    if ((value == null || value.isEmpty) && defaultValue != null) {
      final defaults = defaultValue is List
          ? defaultValue.map((e) => e.toString()).toList()
          : [defaultValue.toString()];
      formManager.setSelectedOption(widget.widget.field.key, defaults);
      value = defaults;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        if (widget.isLoading && optionsData.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        RadioGroup<String>(
          groupValue: value?.first,
          onChanged: (value) {
            if (value == null) return;
            final fieldKey = widget.widget.field.key;
            formManager.setSelectedOption(fieldKey, [value]);
            widget.widget.onChanged?.call(fieldKey, value);
            _validateField(value, optionsData);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final itemWidth = (maxWidth - 12) / 2;
              final formManager = widget.widget.formManager;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(optionsData.length, (index) {
                  final option = optionsData[index];
                  final selected = formManager.getSelectedOption(
                    widget.widget.field.key,
                  );
                  final isSelected = selected?.firstOrNull == option.key;

                  return InkWell(
                    onTap: () {
                      final fieldKey = widget.widget.field.key;
                      formManager.setSelectedOption(fieldKey, [option.key]);
                      widget.widget.onChanged?.call(fieldKey, option.key);
                      _validateField(option.key, optionsData);
                    },
                    child: Container(
                      width: itemWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: switch (isSelected) {
                          true => Border.all(color: theme.colorScheme.primary),
                          _ => null,
                        },
                        color: theme.colorScheme.onPrimary,
                      ),
                      child: Row(
                        children: [
                          Radio<String>(value: option.key),
                          Text(
                            option.value,
                            maxLines: 1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: switch (isSelected) {
                                true => theme.colorScheme.primary,
                                _ => theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  void _validateField(String? value, List<SDUIOption> optionsData) {
    final formManager = widget.widget.formManager;
    final field = widget.widget.field;
    formManager.clearError(field.key);

    if (field.required && (value == null || value.isEmpty)) {
      final error = '${field.label} is required';
      formManager.addError(field.key, error);
    }

    if (value != null) {
      final allowedValues = optionsData.map((e) => e.key).toList();
      if (!allowedValues.contains(value)) {
        final error =
            'The selected ${field.label.toLowerCase()} is not supported';
        formManager.addError(field.key, error);
      }
    }
  }
}
