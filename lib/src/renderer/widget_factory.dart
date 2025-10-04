import 'package:sdui/src/renderer/registry.dart';
import 'package:sdui/src/renderer/widget.dart';

import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

/// Factory class for creating SDUI widgets
class SDUIFactory {
  static final SDUIWidgetRegistry _registry = SDUIWidgetRegistry.instance;

  /// Creates a widget for the given field
  static SDUIBaseWidget? createWidget({
    required SDUIField field,
    required FormManager formManager,
    Function(String, dynamic)? onChanged,
  }) {
    final widget = _registry.create(
      field: field,
      formManager: formManager,
      onChanged: onChanged,
    );

    return widget;
  }
}
