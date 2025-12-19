import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/fields/checkbox.dart';
import 'package:sdui/src/fields/clickable_text.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIBoolField extends SDUIBaseStatefulWidget {
  const SDUIBoolField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBoolField> createState() => _SDUIBoolFieldState();
}

class _SDUIBoolFieldState extends SDUIBaseState<SDUIBoolField> {
  @override
  Widget build(BuildContext context) {
    final isChecked = widget.formManager.getBooleanValue(widget.field.key);
    final helpText = widget.field.helpText;
    final label = widget.field.label;
    final text = helpText ?? label;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checklist(enabled: isChecked, onTap: _toggleChecker),
        const SizedBox(width: 8),
        Expanded(
          child: ClickableText(text: text, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  _toggleChecker() async {
    final isChecked = widget.formManager.getBooleanValue(widget.field.key);
    final newValue = !isChecked;
    widget.formManager.setBooleanValue(widget.field.key, newValue);
    widget.onChanged?.call(widget.field.key, newValue);
    validateField(newValue);
  }

  @override
  String? validateField(value) {
    widget.formManager.clearError(widget.field.key);

    if (widget.field.required && !value) {
      final error = 'You must accept ${widget.field.label.toLowerCase()}';
      widget.formManager.addError(widget.field.key, error);
    }

    for (final validation in widget.field.validations) {
      final result = _validateRule(validation, value);
      if (result != null) {
        widget.formManager.addError(widget.field.key, result);
        return result;
      }
    }

    return null;
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: widget.formManager,
      textValue: value,
    );
  }
}
