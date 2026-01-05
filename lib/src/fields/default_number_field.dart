import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';
import 'package:sdui/src/util/mask_input_formatter.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/validator.dart';

class SDUINumberField extends SDUIBaseStatefulWidget {
  const SDUINumberField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() =>
      _SDUINumberFieldState();
}

class _SDUINumberFieldState extends SDUIBaseState<SDUINumberField> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _ensureDefault();
    });
  }

  _ensureDefault() async {
    final defaultValue = widget.field.defaultValue;
    if (defaultValue == null) return;

    final controller = widget.formManager.getController(widget.field.key);
    if (controller.text.isNotEmpty) return;

    final ui = widget.field.ui;
    final mask = ui?.mask?.trim();
    final maskFormatter =
        mask?.isNotEmpty == true
            ? SDUIMaskTextInputFormatter(
              mask: mask!,
              maxLength: ui?.maxLength,
            )
            : null;
    final rawValue = defaultValue.toString();
    controller.text = maskFormatter?.format(rawValue) ?? rawValue;
    _syncValue(rawValue);
  }

  void _syncValue(String value) {
    if (value.isEmpty) {
      widget.formManager.setFieldValue(widget.field.key, null);
      return;
    }
    final parsed = num.tryParse(value);
    widget.formManager.setFieldValue(widget.field.key, parsed ?? value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final baseDecoration = sduiTheme?.inputDecoration ?? InputDecoration();
    final controller = widget.formManager.getController(widget.field.key);
    final focusNode = widget.formManager.getFocusNode(widget.field.key);
    final error = widget.formManager.getError(widget.field.key);
    final label = widget.field.label;
    final hintText = widget.field.placeholder ?? label;
    final helpText = widget.field.helpText;
    final regex = widget.field.constraints?.regex;
    final ui = widget.field.ui;
    final uiMaxLength = ui?.maxLength;
    final uiIcon = ui?.icon?.sduiIconData;
    final prefixText =
        ui?.prefix?.trim().isNotEmpty == true ? ui?.prefix : null;
    final suffixText =
        ui?.suffix?.trim().isNotEmpty == true ? ui?.suffix : null;
    final inputMode = ui?.inputMode?.trim().toLowerCase();
    final mask = ui?.mask?.trim();
    final maskFormatter =
        mask?.isNotEmpty == true
            ? SDUIMaskTextInputFormatter(mask: mask!, maxLength: uiMaxLength)
            : null;
    final keyboardType =
        ui?.inputMode?.uiTextInputType ?? widget.field.type.textInputType;
    final autofillHints = ui?.autocomplete?.uiAutofillHints;
    final allowDecimal = inputMode == 'decimal';
    final inputFormatters = <TextInputFormatter>[
      if (maskFormatter != null)
        maskFormatter
      else ...[
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
        if (regex != null) FilteringTextInputFormatter.allow(RegExp(regex)),
        if (uiMaxLength != null) LengthLimitingTextInputFormatter(uiMaxLength),
      ],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !widget.field.readonly,
          maxLines: widget.field.ui?.multilineRows,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          style: theme.textTheme.bodySmall,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          inputFormatters: inputFormatters,
          onChanged: (value) {
            final rawValue = maskFormatter?.unmask(value) ?? value;
            widget.onChanged?.call(widget.field.key, rawValue);
            _syncValue(rawValue);
            validateField(rawValue);
          },
          decoration: baseDecoration.copyWith(
            hintText: hintText,
            errorText: error,
            labelText: label,
            helperText: helpText,
            prefixText: prefixText,
            suffixText: suffixText,
            prefixIcon: uiIcon != null ? Icon(uiIcon) : null,
          ),
        ),
      ],
    );
  }

  @override
  String? validateField(value) {
    widget.formManager.clearError(widget.field.key);

    if (widget.field.required && (value == null || value.isEmpty)) {
      final error = '${widget.field.label} is required';
      widget.formManager.addError(widget.field.key, error);
      return error;
    }

    if (value != null && value.isNotEmpty) {
      final minLength = widget.field.constraints?.minLength;
      final maxLength = widget.field.constraints?.maxLength;
      if (minLength != null && value.length < minLength) {
        final error = 'Minimum length is $minLength';
        widget.formManager.addError(widget.field.key, error);
        return error;
      }

      if (maxLength != null && value.length > maxLength) {
        final error = 'Maximum length is $maxLength';
        widget.formManager.addError(widget.field.key, error);
        return error;
      }
    }

    for (final validation in widget.field.validations ?? []) {
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
      fieldType: widget.field.type,
    );
  }
}
