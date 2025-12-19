import 'package:flutter/material.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIPasswordField extends SDUIBaseStatefulWidget {
  const SDUIPasswordField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() =>
      _SDUIPasswordFieldState();
}

class _SDUIPasswordFieldState extends SDUIBaseState<SDUIPasswordField> {
  @override
  String? validateField(dynamic value) {
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
    );
  }

  bool _obscurePassword = true;

  _toggleObsucre() {
    setState(() => _obscurePassword = !_obscurePassword);
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !widget.field.readonly,
          maxLength: widget.field.constraints?.maxLength,
          maxLines: widget.field.ui?.multilineRows,
          keyboardType: widget.field.type.textInputType,
          obscureText: _obscurePassword,
          style: theme.textTheme.bodySmall,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            widget.onChanged?.call(widget.field.key, value);
            validateField(value);
          },
          decoration: baseDecoration.copyWith(
            hintText: hintText,
            errorText: error,
            labelText: label,
            helperText: helpText,
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: InkWell(
                onTap: _toggleObsucre,
                child: Icon(switch (_obscurePassword) {
                  true => Icons.visibility_off,
                  _ => Icons.visibility,
                }, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
