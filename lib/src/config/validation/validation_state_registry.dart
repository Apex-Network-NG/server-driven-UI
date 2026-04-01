import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUIValidationStateContext {
  final SDUIField field;
  final FormManager formManager;
  final String? validatedText;
  final String? errorText;
  final bool hasError;
  final bool isLoading;

  const SDUIValidationStateContext({
    required this.field,
    required this.formManager,
    required this.validatedText,
    required this.errorText,
    required this.hasError,
    required this.isLoading,
  });
}

typedef SDUIValidationStateBuilder =
    Widget? Function(
      BuildContext context,
      SDUIValidationStateContext validationStateContext,
    );

class SDUIValidationStateRegistry {
  SDUIValidationStateRegistry._();
  static final instance = SDUIValidationStateRegistry._();

  SDUIValidationStateBuilder? _builder;

  bool register(SDUIValidationStateBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUIValidationStateBuilder? get builder => _builder;

  bool get hasBuilder => _builder != null;

  bool unregister() {
    final existed = _builder != null;
    _builder = null;
    return existed;
  }

  void clear() {
    _builder = null;
  }
}
