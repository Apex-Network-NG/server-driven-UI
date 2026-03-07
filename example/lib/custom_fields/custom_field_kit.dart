import 'package:sdui/sdui.dart';

import 'widgets/branded_text_field.dart';

/// Example pattern for custom field registration.
///
/// Add new custom widgets and a single register line here.
class ExampleCustomFieldKit {
  ExampleCustomFieldKit._();

  static bool _registered = false;

  static void register({bool overrideBuiltIns = true}) {
    if (_registered) return;

    void registerTextType(SDUIFieldType type) {
      SDUIWidgetRegistry.instance.register(type, ({
        required field,
        required formManager,
        onChanged,
      }) {
        return BrandedTextField(
          field: field,
          formManager: formManager,
          onChanged: onChanged,
        );
      }, override: overrideBuiltIns);
    }

    registerTextType(SDUIFieldType.shortText);
    registerTextType(SDUIFieldType.mediumText);
    registerTextType(SDUIFieldType.longText);
    registerTextType(SDUIFieldType.text);

    _registered = true;
  }
}
