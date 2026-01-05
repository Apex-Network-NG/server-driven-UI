import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';
import 'package:sdui/src/util/mask_input_formatter.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIURLField extends SDUIBaseWidget {
  const SDUIURLField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final baseDecoration = sduiTheme?.inputDecoration ?? InputDecoration();
    final controller = formManager.getController(field.key);
    final focusNode = formManager.getFocusNode(field.key);
    final error = formManager.getError(field.key);
    final label = field.label;
    final hintText = field.placeholder ?? label;
    final helpText = field.helpText;
    final defaultValue = field.defaultValue;
    final ui = field.ui;
    final uiMaxLength = ui?.maxLength;
    final uiIcon = ui?.icon?.sduiIconData;
    final prefixText =
        ui?.prefix?.trim().isNotEmpty == true ? ui?.prefix : null;
    final suffixText =
        ui?.suffix?.trim().isNotEmpty == true ? ui?.suffix : null;
    final mask = ui?.mask?.trim();
    final maskFormatter =
        mask?.isNotEmpty == true
            ? SDUIMaskTextInputFormatter(mask: mask!, maxLength: uiMaxLength)
            : null;
    final keyboardType =
        ui?.inputMode?.uiTextInputType ?? field.type.textInputType;
    final autofillHints = ui?.autocomplete?.uiAutofillHints;
    final inputFormatters = <TextInputFormatter>[
      if (maskFormatter != null) maskFormatter,
      if (maskFormatter == null && uiMaxLength != null)
        LengthLimitingTextInputFormatter(uiMaxLength),
    ];

    if (defaultValue != null && controller.text.isEmpty) {
      final rawValue = defaultValue.toString();
      controller.text = maskFormatter?.format(rawValue) ?? rawValue;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !field.readonly,
          maxLines: field.ui?.multilineRows,
          style: theme.textTheme.bodySmall,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            final rawValue = maskFormatter?.unmask(value) ?? value;
            onChanged?.call(field.key, rawValue);
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
    formManager.clearError(field.key);

    if (field.required && (value == null || value.isEmpty)) {
      final error = '${field.label} is required';
      formManager.addError(field.key, error);
      return error;
    }

    if (value != null && value.isNotEmpty) {
      if (!value.isValidUrl) {
        const error = 'Please enter a valid URL';
        formManager.addError(field.key, error);
        return error;
      }
    }

    for (final validation in field.validations ?? []) {
      final result = _validateRule(validation, value);
      if (result != null) {
        formManager.addError(field.key, result);
        return result;
      }
    }

    return null;
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: formManager,
      textValue: value,
      fieldType: field.type,
    );
  }
}
