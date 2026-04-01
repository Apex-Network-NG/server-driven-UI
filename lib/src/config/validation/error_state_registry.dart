import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUIErrorStateContext {
  final SDUIField field;
  final FormManager formManager;
  final String? validatedText;
  final String errorText;
  final bool hasError;
  final bool isLoading;

  const SDUIErrorStateContext({
    required this.field,
    required this.formManager,
    required this.validatedText,
    required this.errorText,
    required this.hasError,
    required this.isLoading,
  });
}

typedef SDUIErrorStateBuilder =
    Widget? Function(
      BuildContext context,
      SDUIErrorStateContext errorStateContext,
    );

class SDUIErrorStateRegistry {
  SDUIErrorStateRegistry._();
  static final instance = SDUIErrorStateRegistry._();

  SDUIErrorStateBuilder? _builder;

  bool register(SDUIErrorStateBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUIErrorStateBuilder? get builder => _builder;

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
