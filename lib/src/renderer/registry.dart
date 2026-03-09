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

/// Factory function type that also receives field loading state.
typedef SDUIWidgetLoadingFactory =
    Widget Function({
      required SDUIField field,
      required FormManager formManager,
      Function(String, dynamic)? onChanged,
      required bool isLoading,
    });

/// Registry for 3rd party widgets
class SDUIWidgetRegistry {
  SDUIWidgetRegistry._internal();
  static final instance = SDUIWidgetRegistry._internal();

  final Map<SDUIFieldType, SDUIWidgetFactory> _factories = {};
  final Map<SDUIFieldType, SDUIWidgetLoadingFactory> _loadingFactories = {};

  bool register(
    SDUIFieldType type,
    SDUIWidgetFactory factory, {
    bool override = false,
  }) {
    if (isRegistered(type) && !override) return false;
    _loadingFactories.remove(type);
    _factories[type] = factory;
    return true;
  }

  bool registerWithLoading(
    SDUIFieldType type,
    SDUIWidgetLoadingFactory factory, {
    bool override = false,
  }) {
    if (isRegistered(type) && !override) return false;
    _factories.remove(type);
    _loadingFactories[type] = factory;
    return true;
  }

  Widget? create({
    required SDUIField field,
    required FormManager formManager,
    Function(String, dynamic)? onChanged,
    bool isLoading = false,
  }) {
    final type = SDUIFieldType.fromValue(field.type);
    if (_loadingFactories.containsKey(type)) {
      return _loadingFactories[type]!(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
        isLoading: isLoading,
      );
    }
    if (_factories.containsKey(type)) {
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
    return _factories.containsKey(fieldType) ||
        _loadingFactories.containsKey(fieldType);
  }

  /// Checks if a field type has a loading-aware widget factory.
  bool isLoadingAwareRegistered(SDUIFieldType fieldType) {
    return _loadingFactories.containsKey(fieldType);
  }

  /// Gets all registered field types
  List<String> getRegisteredTypes() {
    return _factories.keys.map((e) => e.value).toList();
  }

  /// Unregisters a field type
  bool unregister(SDUIFieldType fieldType) {
    bool removed = false;
    removed = _factories.remove(fieldType) != null || removed;
    removed = _loadingFactories.remove(fieldType) != null || removed;
    return removed;
  }

  /// Clears all registrations
  void clear() {
    _factories.clear();
    _loadingFactories.clear();
  }
}
