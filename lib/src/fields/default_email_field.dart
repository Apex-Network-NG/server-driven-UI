import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';

class SDUIEmailField extends SDUIBaseWidget {
  const SDUIEmailField({
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !field.readonly,
          maxLength: field.constraints.maxLength,
          maxLines: field.ui.multilineRows,
          keyboardType: field.type.textInputType,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          style: theme.textTheme.bodySmall,
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

  bool _isValidEmail(String email) => EmailValidator.validate(email);

  @override
  String? validateField(value) {
    formManager.clearError(field.key);

    if (field.required && (value == null || value.isEmpty)) {
      final error = '${field.label} is required';
      formManager.addError(field.key, error);
      return error;
    }

    if (value != null && value.isNotEmpty) {
      final minLength = field.constraints.minLength;
      final maxLength = field.constraints.maxLength;
      if (minLength != null && value.length < minLength) {
        final error = 'Minimum length is $minLength';
        formManager.addError(field.key, error);
        return error;
      }

      if (maxLength != null && value.length > maxLength) {
        final error = 'Maximum length is $maxLength';
        formManager.addError(field.key, error);
        return error;
      }
    }

    if (value != null && value.isNotEmpty) {
      if (!_isValidEmail(value)) {
        const error = 'Please enter a valid email address';
        formManager.addError(field.key, error);
        return error;
      }

      final allowedDomains = field.constraints.allowedDomains;
      final disallowedDomains = field.constraints.disallowedDomains;

      if (allowedDomains.isNotEmpty || disallowedDomains.isNotEmpty) {
        final domain = value.split('@').last;

        if (disallowedDomains.isNotEmpty &&
            disallowedDomains.any((d) => d.toLowerCase() == domain)) {
          const error = 'This email domain is not allowed';
          formManager.addError(field.key, error);
          return error;
        }

        if (allowedDomains.isNotEmpty &&
            !allowedDomains.any((d) => d.toLowerCase() == domain)) {
          const error = 'This email domain is not allowed';
          formManager.addError(field.key, error);
          return error;
        }
      }
    }

    return null;
  }
}
