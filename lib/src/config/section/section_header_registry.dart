import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUISectionHeaderContext {
  final SDUISection section;
  final FormManager formManager;
  final String? label;
  final String? description;
  final TextStyle? defaultLabelStyle;
  final TextStyle? defaultDescriptionStyle;

  const SDUISectionHeaderContext({
    required this.section,
    required this.formManager,
    required this.label,
    required this.description,
    required this.defaultLabelStyle,
    required this.defaultDescriptionStyle,
  });

  bool get hasLabel => label?.trim().isNotEmpty == true;

  bool get hasDescription => description?.trim().isNotEmpty == true;
}

typedef SDUISectionHeaderBuilder =
    Widget? Function(
      BuildContext context,
      SDUISectionHeaderContext sectionHeaderContext,
    );

class SDUISectionHeaderRegistry {
  SDUISectionHeaderRegistry._();
  static final instance = SDUISectionHeaderRegistry._();

  SDUISectionHeaderBuilder? _builder;

  bool register(SDUISectionHeaderBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUISectionHeaderBuilder? get builder => _builder;

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
