import 'package:flutter/services.dart';

class SDUIMaskTextInputFormatter extends TextInputFormatter {
  SDUIMaskTextInputFormatter({
    required this.mask,
    this.maxLength,
    Map<String, RegExp>? rules,
  }) : _rules =
           rules ??
           {
             '9': RegExp(r'[0-9]'),
             'A': RegExp(r'[A-Za-z]'),
             '*': RegExp(r'[A-Za-z0-9]'),
           };

  final String mask;
  final int? maxLength;
  final Map<String, RegExp> _rules;

  late final List<String> _maskChars = mask.split('');
  late final Set<String> _literals = _maskChars
      .where((char) => !_rules.containsKey(char))
      .toSet();

  String format(String value) {
    final raw = _applyMaxLength(_filterRaw(_stripLiterals(value)));
    return _applyMask(raw);
  }

  String unmask(String value) {
    return _applyMaxLength(_filterRaw(_stripLiterals(value)));
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = _applyMaxLength(_filterRaw(_stripLiterals(newValue.text)));
    final masked = _applyMask(raw);

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }

  String _stripLiterals(String value) {
    if (_literals.isEmpty || value.isEmpty) return value;
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      if (!_literals.contains(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String _filterRaw(String value) {
    if (value.isEmpty) return '';
    final buffer = StringBuffer();
    var valueIndex = 0;

    for (final maskChar in _maskChars) {
      final rule = _rules[maskChar];
      if (rule == null) continue;

      while (valueIndex < value.length) {
        final char = value[valueIndex];
        valueIndex += 1;
        if (rule.hasMatch(char)) {
          buffer.write(char);
          break;
        }
      }

      if (valueIndex >= value.length) {
        continue;
      }
    }

    return buffer.toString();
  }

  String _applyMask(String raw) {
    if (raw.isEmpty) return '';
    final buffer = StringBuffer();
    var rawIndex = 0;

    for (final maskChar in _maskChars) {
      final rule = _rules[maskChar];
      if (rule != null) {
        if (rawIndex >= raw.length) break;
        buffer.write(raw[rawIndex]);
        rawIndex += 1;
      } else {
        if (rawIndex >= raw.length) break;
        buffer.write(maskChar);
      }
    }

    return buffer.toString();
  }

  String _applyMaxLength(String raw) {
    if (maxLength == null || raw.length <= maxLength!) return raw;
    return raw.substring(0, maxLength);
  }
}
