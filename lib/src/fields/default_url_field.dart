import 'package:flutter/material.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';
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

    if (defaultValue != null && controller.text.isEmpty) {
      controller.text = defaultValue.toString();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !field.readonly,
          maxLength: field.constraints?.maxLength,
          maxLines: field.ui?.multilineRows,
          style: theme.textTheme.bodySmall,
          keyboardType: field.type.textInputType,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            onChanged?.call(field.key, value);
            validateField(value);
          },
          decoration: baseDecoration.copyWith(
            hintText: hintText,
            errorText: error,
            labelText: label,
            helperText: helpText,
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
