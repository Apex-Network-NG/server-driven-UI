import 'package:flutter/widgets.dart';
import 'package:sdui/src/util/enums.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

/// Factory function type for creating SDUI widgets
typedef SDUIWidgetFactory =
    Widget Function({
      required SDUIField field,
      required FormManager formManager,
      Function(String, dynamic)? onChanged,
    });

/// Registry for 3rd party widgets
class SDUIWidgetRegistry {
  SDUIWidgetRegistry._internal();
  static final instance = SDUIWidgetRegistry._internal();

  final Map<SDUIFieldType, SDUIWidgetFactory> _factories = {};

  bool register(
    SDUIFieldType type,
    SDUIWidgetFactory factory, {
    bool override = false,
  }) {
    if (isRegistered(type) && !override) return false;
    _factories[type] = factory;
    return true;
  }

  Widget? create({
    required SDUIField field,
    required FormManager formManager,
    Function(String, dynamic)? onChanged,
  }) {
    final type = SDUIFieldType.fromValue(field.type);
    if (isRegistered(type)) {
      return _factories[type]!(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      );
    }
    return null;
  }

  /// Checks if a field type is registered
  bool isRegistered(SDUIFieldType fieldType) {
    return _factories.containsKey(fieldType);
  }

  /// Gets all registered field types
  List<String> getRegisteredTypes() {
    return _factories.keys.map((e) => e.value).toList();
  }

  /// Unregisters a field type
  bool unregister(SDUIFieldType fieldType) {
    bool removed = false;
    if (isRegistered(fieldType)) {
      _factories.remove(fieldType);
      removed = true;
    }
    return removed;
  }

  /// Clears all registrations
  void clear() {
    _factories.clear();
  }
}
