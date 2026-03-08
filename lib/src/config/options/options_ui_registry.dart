import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

enum SDUIOptionsUiType {
  select('select'),
  radio('radio'),
  multiSelect('multi-select'),
  checkbox('checkbox');

  const SDUIOptionsUiType(this.value);
  final String value;

  bool get isMulti =>
      this == SDUIOptionsUiType.multiSelect ||
      this == SDUIOptionsUiType.checkbox;

  factory SDUIOptionsUiType.fromFieldType(String? rawType) {
    final normalized = rawType?.trim().toLowerCase() ?? 'select';
    for (final type in SDUIOptionsUiType.values) {
      if (type.value == normalized) return type;
    }
    return SDUIOptionsUiType.select;
  }
}

class SDUIOptionsUiContext {
  final SDUIField field;
  final FormManager formManager;
  final List<SDUIOption> options;
  final List<String> selectedKeys;
  final bool isLoading;
  final SDUIOptionsUiType uiType;
  final String? errorText;
  final int? maxSelect;
  final void Function(String key) selectSingle;
  final void Function(List<String> keys) selectMany;
  final void Function(String key) toggleMany;
  final bool readOnly;

  const SDUIOptionsUiContext({
    required this.field,
    required this.formManager,
    required this.options,
    required this.selectedKeys,
    required this.isLoading,
    required this.uiType,
    required this.errorText,
    required this.maxSelect,
    required this.selectSingle,
    required this.selectMany,
    required this.toggleMany,
    required this.readOnly,
  });
}

typedef SDUIOptionsUiBuilder =
    Widget Function(BuildContext context, SDUIOptionsUiContext optionsContext);

class SDUIOptionsUiRegistry {
  SDUIOptionsUiRegistry._();
  static final instance = SDUIOptionsUiRegistry._();

  final Map<SDUIOptionsUiType, SDUIOptionsUiBuilder> _builders = {};

  bool register(
    SDUIOptionsUiType type,
    SDUIOptionsUiBuilder builder, {
    bool override = false,
  }) {
    if (_builders.containsKey(type) && !override) return false;
    _builders[type] = builder;
    return true;
  }

  SDUIOptionsUiBuilder? builderFor(SDUIOptionsUiType type) {
    return _builders[type];
  }

  bool unregister(SDUIOptionsUiType type) {
    return _builders.remove(type) != null;
  }

  void clear() {
    _builders.clear();
  }
}
