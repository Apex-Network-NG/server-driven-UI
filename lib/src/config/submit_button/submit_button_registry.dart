import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUISubmitButtonContext {
  final SDUIForm form;
  final FormManager formManager;
  final int currentPage;
  final int totalPages;
  final VoidCallback submitForm;

  const SDUISubmitButtonContext({
    required this.form,
    required this.formManager,
    required this.currentPage,
    required this.totalPages,
    required this.submitForm,
  });
}

typedef SDUISubmitButtonBuilder =
    Widget Function(
      BuildContext context,
      SDUISubmitButtonContext submitButtonContext,
    );

class SDUISubmitButtonRegistry {
  SDUISubmitButtonRegistry._();
  static final instance = SDUISubmitButtonRegistry._();

  SDUISubmitButtonBuilder? _builder;

  bool register(SDUISubmitButtonBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUISubmitButtonBuilder? get builder => _builder;

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
