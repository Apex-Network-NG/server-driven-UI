import 'package:sdui/src/fields/default_country_field.dart';
import 'package:sdui/src/fields/default_date_field.dart';
import 'package:sdui/src/fields/default_email_field.dart';
import 'package:sdui/src/fields/default_file_field.dart';
import 'package:sdui/src/fields/default_number_field.dart';
import 'package:sdui/src/fields/default_password_field.dart';
import 'package:sdui/src/fields/default_phone_field.dart';
import 'package:sdui/src/fields/default_textfield.dart';
import 'package:sdui/src/fields/default_url_field.dart';
import 'package:sdui/src/fields/sdui_boolean_field.dart';
import 'package:sdui/src/fields/sdui_options_field.dart';
import 'package:sdui/src/fields/unknown.dart';
import 'package:sdui/src/renderer/registry.dart';
import 'package:sdui/src/util/enums.dart';

class SDUIInitializer {
  /// Initializes SDUI with default widgets
  static void initialize() {
    final registry = SDUIWidgetRegistry.instance;

    registry.register(
      SDUIFieldType.shortText,
      ({required field, required formManager, onChanged}) => SDUITextField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.mediumText,
      ({required field, required formManager, onChanged}) => SDUITextField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.longText,
      ({required field, required formManager, onChanged}) => SDUITextField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.text,
      ({required field, required formManager, onChanged}) => SDUITextField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.email,
      ({required field, required formManager, onChanged}) => SDUIEmailField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.url,
      ({required field, required formManager, onChanged}) => SDUIURLField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.number,
      ({required field, required formManager, onChanged}) => SDUINumberField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.password,
      ({required field, required formManager, onChanged}) => SDUIPasswordField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.phone,
      ({required field, required formManager, onChanged}) => SDUIPhoneField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.country,
      ({required field, required formManager, onChanged}) => SDUICountryField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.boolean,
      ({required field, required formManager, onChanged}) => SDUIBoolField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.options,
      ({required field, required formManager, onChanged}) => SDUIOptionsField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.date,
      ({required field, required formManager, onChanged}) => SDUIDateField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.datetime,
      ({required field, required formManager, onChanged}) => SDUIDateField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.file,
      ({required field, required formManager, onChanged}) => SDUIFileField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.image,
      ({required field, required formManager, onChanged}) => SDUIFileField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.video,
      ({required field, required formManager, onChanged}) => SDUIFileField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.document,
      ({required field, required formManager, onChanged}) => SDUIFileField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
    registry.register(
      SDUIFieldType.unknown,
      ({required field, required formManager, onChanged}) => SDUIUnknownField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      ),
    );
  }
}
