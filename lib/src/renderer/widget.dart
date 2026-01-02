import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';
import 'package:sdui/src/util/validator.dart';

/// Abstract base class for all SDUI widget components
/// Provides common functionality for form field widgets
abstract class SDUIBaseWidget extends StatelessWidget {
  final SDUIField field;
  final FormManager formManager;
  final Function(String, dynamic)? onChanged;

  const SDUIBaseWidget({
    super.key,
    required this.field,
    required this.formManager,
    this.onChanged,
  });

  /// Build the widget UI - must be implemented by subclasses
  @override
  Widget build(BuildContext context);

  /// Validate the field value.
  /// Subclasses can override to customize validation.
  String? validateField(dynamic value) {
    formManager.clearError(field.key);
    final error = FieldValidator.instance.validateField(
      field: field,
      formManager: formManager,
      value: value,
    );
    if (error != null) {
      formManager.addError(field.key, error);
    }
    return error;
  }

  /// Handle field value changes - can be overridden by subclasses
  void onFieldChanged(dynamic value) {
    onChanged?.call(field.key, value);
    validateField(value);
  }

  /// Get the error message for this field
  String? getError() {
    return formManager.getError(field.key);
  }

  /// Clear the error for this field
  void clearError() {
    formManager.clearError(field.key);
  }

  /// Check if field is enabled (not readonly)
  bool get isEnabled => !field.readonly;

  /// Get the field label
  String get label => field.label;

  /// Get the field placeholder or fallback to label
  String get placeholder => field.placeholder ?? field.label;

  /// Get the field help text
  String? get helpText => field.helpText;

  /// Get the field type
  String get type => field.type;

  /// Check if field is required
  bool get isRequired => field.required;
}

/// Abstract base class for stateful SDUI widgets
abstract class SDUIBaseStatefulWidget extends StatefulWidget {
  final SDUIField field;
  final FormManager formManager;
  final Function(String, dynamic)? onChanged;

  const SDUIBaseStatefulWidget({
    super.key,
    required this.field,
    required this.formManager,
    this.onChanged,
  });

  @override
  SDUIBaseState createState();
}

/// Base state class with shared logic
abstract class SDUIBaseState<T extends SDUIBaseStatefulWidget>
    extends State<T> {
  String? validateField(dynamic value) {
    widget.formManager.clearError(widget.field.key);
    final error = FieldValidator.instance.validateField(
      field: widget.field,
      formManager: widget.formManager,
      value: value,
    );
    if (error != null) {
      widget.formManager.addError(widget.field.key, error);
    }
    return error;
  }

  void onFieldChanged(dynamic value) {
    widget.onChanged?.call(widget.field.key, value);
    validateField(value);
  }

  String? getError() => widget.formManager.getError(widget.field.key);
  void clearError() => widget.formManager.clearError(widget.field.key);
  bool get isEnabled => !widget.field.readonly;
  String get label => widget.field.label;
  String get placeholder => widget.field.placeholder ?? widget.field.label;
  String? get helpText => widget.field.helpText;
  String get type => widget.field.type;
  bool get isRequired => widget.field.required;
}
