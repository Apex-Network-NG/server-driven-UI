# SDUI - Server-Driven UI

[![pub package](https://img.shields.io/badge/Internal-v1.0.0-blue)](https://github.com/Apex-Network-NG/server-driven-UI)
[![License: APEX](https://img.shields.io/badge/License-APEX-red.svg)](https://github.com/Apex-Network-NG/server-driven-UI)

**SDUI** (Server-Driven UI) is a Flutter package that enables dynamic form rendering from JSON configurations. Build flexible, customizable forms that can be modified server-side without app updates.

## ✨ Features

- 🚀 **Dynamic Form Rendering** - Create forms from JSON configurations
- 📱 **Multiple Field Types** - Text, email, phone, date, file upload, and more
- 🎨 **Customizable Widgets** - Override any field type with your own widgets
- 📄 **Multi-Page Forms** - Support for paginated form experiences
- ✅ **Built-in Validation** - Comprehensive field validation with custom rules
- 🌍 **Internationalization** - Multi-language support ready
- 🔧 **Extensible Architecture** - Plugin system for custom field types
- 📱 **Responsive Design** - Works on all screen sizes
- 🎯 **Type Safety** - Full Dart type safety with comprehensive error handling

## 🚀 Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sdui:
    git:
      url: https://github.com/Apex-Network-NG/server-driven-UI.git
      ref: main
```

Then run:

```bash
flutter pub get
```

### Platform Configuration

#### Android Setup (Required for URL Launching)

If your form uses URL fields with clickable links (like terms and conditions), you need to add the following configuration to your `android/app/src/main/AndroidManifest.xml` file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- ... existing configuration ... -->

    <queries>
        <!-- Existing queries -->
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>

        <!-- Required for URL launcher to work on Android 11+ -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="http" />
        </intent>
    </queries>
</manifest>
```

**Important:** These `<queries>` entries are required for Android 11+ (API level 30+) to allow your app to launch HTTP and HTTPS URLs. Without this configuration, URL links in help text or other fields may not work properly.

#### iOS Setup

No additional configuration is required for iOS. URL launching works out of the box.

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Example',
      home: MyFormPage(),
    );
  }
}

class MyFormPage extends StatelessWidget {
  final Map<String, dynamic> formJson = {
    "name": "contact_form",
    "key": "contact_form_001",
    "title": "Contact Us",
    "description": "Get in touch with us",
    "version": 1,
    "meta": {
      "ui": {"layout": "vertical", "progress": true},
      "i18n": {"defaultLocale": "en", "translations": []}
    },
    "properties": {
      "dateFormat": "yyyy-MM-dd",
      "timeFormat": "HH:mm",
      "datetimeFormat": "yyyy-MM-dd HH:mm",
      "numberFormat": {"decimal": ".", "thousand": ","}
    },
    "form": {
      "pages": [
        {
          "key": "page_1",
          "label": "Personal Information",
          "order": 1,
          "sections": [
            {
              "key": "personal_section",
              "label": "Your Details",
              "order": 1,
              "fields": [
                {
                  "key": "full_name",
                  "label": "Full Name",
                  "type": "short-text",
                  "required": true,
                  "placeholder": "Enter your full name",
                  "ui": {"multilineRows": 1},
                  "constraints": {"minLength": 2, "maxLength": 50},
                  "validations": []
                },
                {
                  "key": "email",
                  "label": "Email Address",
                  "type": "email",
                  "required": true,
                  "placeholder": "your.email@example.com",
                  "ui": {"multilineRows": 1},
                  "constraints": {"allowedDomains": [], "disallowedDomains": []},
                  "validations": []
                },
                {
                  "key": "phone",
                  "label": "Phone Number",
                  "type": "phone",
                  "required": false,
                  "placeholder": "Enter your phone number",
                  "ui": {"multilineRows": 1},
                  "constraints": {},
                  "validations": []
                },
                {
                  "key": "terms_accepted",
                  "label": "Accept our terms and conditions",
                  "type": "boolean",
                  "required": true,
                  "help_text": "By continuing, you accept our [terms and conditions](https://example.com/privacy).",
                  "ui": {"multilineRows": 1},
                  "constraints": {},
                  "validations": []
                }
              ]
            }
          ]
        }
      ],
      "pages_count": 1
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SDUI Form'),
      ),
      body: SDUIFrame(
        formJson: formJson,
        onSubmit: (formData) {
          print('Form submitted with data: $formData');
          // Handle form submission
        },
        onFieldChanged: (key, value) {
          print('Field $key changed to: $value');
          // Handle field changes
        },
      ),
    );
  }
}
```

### Entry Points

SDUIFrame accepts three sources (priority is `formJson` > `formUrl` > `formId`).

```dart
// 1) Inline JSON
SDUIFrame(formJson: formJson);

// 2) Form ID (uses the default baseUrl)
SDUIFrame(formId: 'form-id');

// 3) Hosted schema URL
SDUIFrame(formUrl: 'https://example.com/forms/form-id.json');
```

If multiple sources are provided, a runtime warning is logged and the priority
order is used.

## ⚡ Autofill (Field API Lookup)

SDUI can call an internal API when a field meets conditions and map response
data into other fields.

### 1) Register the API config (headers + optional base URL)

```dart
import 'package:sdui/sdui.dart';

SDUIAutofillApiRegistry.register(
  SDUIAutofillApiConfig(
    baseUrl: 'https://internal.api',
    // Optional: provide your own Dio client (interceptors, adapter, cert pinning, etc.)
    // dio: customDio,
    headers: {
      'auth': SDUIAutofillApiHeader(
        name: 'Authorization',
        resolver: () => 'Bearer $token',
      ),
      'ip': SDUIAutofillApiHeader(
        name: 'X-Client-IP',
        resolver: () => currentIpAddress,
      ),
      'geolocation': SDUIAutofillApiHeader(
        name: 'X-Geo',
        value: geoJson,
      ),
    },
  ),
);
```

This same config is also used when loading forms by `formId`/`formUrl`, so
custom `dio` and `baseUrl` apply there too.

### 2) Add `autofill` to any field in your JSON

```json
{
  "id": "019b75d5-210d-72fc-8041-344acc2b415e",
  "key": "wire_account_number",
  "label": "Account number",
  "placeholder": "Enter account number",
  "type": "short-text",
  "required": true,
  "autofill": {
    "map": [
      { "path": "data.accountDetails.name", "target": "account_holder_name" },
      { "path": "data.currency.code", "target": "currency" }
    ],
    "when": {
      "all": [
        { "key": "wire_account_number", "value": 10, "operator": "length_gte" }
      ]
    },
    "method": "POST",
    "params": [
      { "key": "account_number", "value": "{field:wire_account_number}" },
      { "key": "bank", "value": "{field:bank}" }
    ],
    "enabled": true,
    "headers": ["auth", "ip", "geolocation"],
    "trigger": "debounce",
    "endpoint": "/lookup/account",
    "overwrite": "empty",
    "debounce_ms": 600
  }
}
```

**Notes**

- `headers` are not real header values; they reference keys registered in
  `SDUIAutofillApiConfig`.
- `params` supports field references with `{field:field_key}`.
- `trigger` can be `debounce` (automatic) or `manual` (shows an Autofill button).
- `overwrite` can be `empty` (fill only empty fields) or `always`.

## 📋 Supported Field Types

| Field Type    | Description                           | Example              |
| ------------- | ------------------------------------- | -------------------- |
| `short-text`  | Single line text input                | Name, username       |
| `medium-text` | Medium length text                    | Address, description |
| `long-text`   | Multi-line text area                  | Comments, messages   |
| `email`       | Email input with validation           | user@example.com     |
| `phone`       | Phone number with country picker      | +1 (555) 123-4567    |
| `url`         | URL input with validation             | https://example.com  |
| `number`      | Numeric input                         | Age, quantity        |
| `password`    | Password input with visibility toggle | ••••••••             |
| `date`        | Date picker                           | 2024-01-15           |
| `datetime`    | Date and time picker                  | 2024-01-15 14:30     |
| `boolean`     | Checkbox/toggle                       | Terms acceptance     |
| `options`     | Radio buttons, dropdown, multi-select | Gender, interests    |
| `country`     | Country picker                        | United States        |
| `file`        | File upload                           | Documents, images    |

### Clickable Links in Help Text

SDUI supports clickable links in help text using Markdown-style syntax:

```json
{
  "help_text": "By continuing, you accept our [terms and conditions](https://example.com/privacy)."
}
```

This will render as clickable text that opens the URL in the default browser. **Note:** Ensure you've configured Android permissions as described in the Platform Configuration section above.

## 🎨 Custom Field Types

You can easily override built-in field types or add new ones:

```dart
import 'package:sdui/sdui.dart';

void main() {
  // Register custom widget before running the app
  SDUIWidgetRegistry.instance.register(
    SDUIFieldType.shortText,
    ({required field, required formManager, onChanged}) {
      return MyCustomTextField(
        field: field,
        formManager: formManager,
        onChanged: onChanged,
      );
    },
    override: true, // Override built-in short-text widget
  );

  runApp(MyApp());
}

class MyCustomTextField extends SDUIBaseWidget {
  const MyCustomTextField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final error = formManager.getError(field.key);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: formManager.getController(field.key),
            style: TextStyle(fontSize: 18, color: Colors.purple.shade900),
            decoration: InputDecoration(
              hintText: field.placeholder ?? field.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.purple, width: 2),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) => onFieldChanged(value),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
```

Calling `onFieldChanged` updates the value and triggers SDK validation. The SDK
validates:

- required (from `field.required` or a `required` rule)
- constraints (`min`, `max`, `regex`, etc.)
- `validations` rules (email, between, gt, and more)
- url/phone formats for `url` and `phone` field types

Use `formManager.getError(field.key)` to render the error however you want.
Override `validateField` only if you need custom behavior.

## 🔧 Advanced Configuration

### Custom Navigation

```dart
SDUIFrame(
  formJson: formJson,
  showNavigationButtons: false, // Hide default buttons
  navigationBuilder: (context, currentPage, totalPages, previousPage, nextPage, submitForm) {
    return CustomNavigationBar(
      currentPage: currentPage,
      totalPages: totalPages,
      onPrevious: previousPage,
      onNext: nextPage,
      onSubmit: submitForm,
    );
  },
  onSubmit: (data) => handleSubmission(data),
)
```

### Form Validation

```dart
// In your field validation
@override
String? validateField(value) {
  formManager.clearError(field.key);

  // Custom validation rules
  if (field.required && (value == null || value.isEmpty)) {
    final error = '${field.label} is required';
    formManager.addError(field.key, error);
    return error;
  }

  // Email domain validation
  if (field.type == 'email' && value != null) {
    final domain = value.split('@').last;
    if (!allowedDomains.contains(domain)) {
      formManager.addError(field.key, 'Email domain not allowed');
      return 'Email domain not allowed';
    }
  }

  return null;
}
```

### Form Manager Integration

```dart
class MyFormPage extends StatefulWidget {
  @override
  _MyFormPageState createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  final formManager = FormManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SDUIFrame(
        formJson: formJson,
        onSubmit: (data) => handleSubmission(data),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Access form data
          final allData = formManager.getAllFormData();
          final specificField = formManager.getFieldValue('email');

          // Validate form
          final isValid = formManager.validateForm();

          if (isValid) {
            submitForm(allData);
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
```

## 📱 Complete Form Example

```json
{
  "name": "user_registration",
  "key": "reg_form_001",
  "title": "User Registration",
  "version": 1,
  "meta": {
    "ui": { "layout": "vertical", "progress": true },
    "i18n": { "defaultLocale": "en", "translations": [] }
  },
  "properties": {
    "dateFormat": "yyyy-MM-dd",
    "timeFormat": "HH:mm",
    "datetimeFormat": "yyyy-MM-dd HH:mm",
    "numberFormat": { "decimal": ".", "thousand": "," }
  },
  "form": {
    "pages": [
      {
        "key": "personal_info",
        "label": "Personal Information",
        "order": 1,
        "sections": [
          {
            "key": "basic_info",
            "label": "Basic Information",
            "order": 1,
            "fields": [
              {
                "key": "first_name",
                "label": "First Name",
                "type": "short-text",
                "required": true,
                "placeholder": "Enter your first name",
                "ui": { "multilineRows": 1 },
                "constraints": { "minLength": 2, "maxLength": 30 },
                "validations": []
              },
              {
                "key": "last_name",
                "label": "Last Name",
                "type": "short-text",
                "required": true,
                "placeholder": "Enter your last name",
                "ui": { "multilineRows": 1 },
                "constraints": { "minLength": 2, "maxLength": 30 },
                "validations": []
              },
              {
                "key": "email",
                "label": "Email Address",
                "type": "email",
                "required": true,
                "placeholder": "your.email@example.com",
                "ui": { "multilineRows": 1 },
                "constraints": {
                  "allowedDomains": [],
                  "disallowedDomains": []
                },
                "validations": []
              },
              {
                "key": "phone",
                "label": "Phone Number",
                "type": "phone",
                "required": false,
                "placeholder": "Enter your phone number",
                "ui": { "multilineRows": 1 },
                "constraints": {},
                "validations": []
              },
              {
                "key": "birth_date",
                "label": "Date of Birth",
                "type": "date",
                "required": true,
                "placeholder": "Select your birth date",
                "ui": { "multilineRows": 1 },
                "constraints": {},
                "validations": []
              },
              {
                "key": "country",
                "label": "Country",
                "type": "country",
                "required": true,
                "placeholder": "Select your country",
                "ui": { "multilineRows": 1 },
                "constraints": {
                  "allowedCountries": [],
                  "disallowedCountries": []
                },
                "validations": []
              },
              {
                "key": "gender",
                "label": "Gender",
                "type": "options",
                "required": true,
                "placeholder": "Select your gender",
                "ui": { "multilineRows": 1 },
                "constraints": {},
                "validations": [],
                "option_properties": {
                  "type": "radio",
                  "data": [
                    { "key": "male", "value": "Male" },
                    { "key": "female", "value": "Female" },
                    { "key": "other", "value": "Other" },
                    { "key": "prefer_not_to_say", "value": "Prefer not to say" }
                  ]
                }
              },
              {
                "key": "profile_picture",
                "label": "Profile Picture",
                "type": "image",
                "required": false,
                "placeholder": "Upload your profile picture",
                "ui": { "multilineRows": 1 },
                "constraints": {
                  "accept": ["image/jpeg", "image/png"],
                  "maxFileSize": 5242880,
                  "allowMultiple": false
                },
                "validations": []
              },
              {
                "key": "terms_accepted",
                "label": "I accept the Terms and Conditions",
                "type": "boolean",
                "required": true,
                "help_text": "By continuing, you accept our [terms and conditions](https://example.com/privacy).",
                "ui": { "multilineRows": 1 },
                "constraints": {},
                "validations": []
              }
            ]
          }
        ]
      }
    ],
    "pages_count": 1
  }
}
```

## 🛠️ API Reference

### SDUIFrame

The main widget for rendering SDUI forms.

**Constructor:**

```dart
SDUIFrame({
  required Map<String, dynamic> formJson,
  Function(Map<String, dynamic>)? onSubmit,
  Function(String key, dynamic value)? onFieldChanged,
  bool showNavigationButtons = true,
  Widget Function(BuildContext, int, int, VoidCallback, VoidCallback, VoidCallback)? navigationBuilder,
})
```

### FormManager

Manages form state, validation, and data.

**Key Methods:**

- `getFieldValue(String key)` - Get field value
- `setFieldValue(String key, dynamic value)` - Set field value
- `getAllFormData()` - Get all form data
- `validateForm()` - Validate entire form
- `getError(String key)` - Get field error
- `addError(String key, String error)` - Add field error
- `clearError(String key)` - Clear field error

### SDUIWidgetRegistry

Registry for custom field widgets.

**Key Methods:**

- `register(SDUIFieldType type, SDUIWidgetFactory factory, {bool override})` - Register custom widget
- `unregister(SDUIFieldType fieldType)` - Unregister widget
- `isRegistered(SDUIFieldType fieldType)` - Check if type is registered
- `getRegisteredTypes()` - Get all registered types

## 🚨 Troubleshooting

### URL Links Not Working on Android

If clickable links in help text aren't working on Android, ensure you've added the required `<queries>` configuration to your `AndroidManifest.xml` as described in the Platform Configuration section above.

**Error symptoms:**

- Links don't respond to taps
- Log messages like "component name for https://example.com is null"

**Solution:**
Add the Android queries configuration and rebuild your app:

```bash
flutter clean && flutter build apk
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under Apex group of companies

## 🆘 Support

- 📖 [Documentation](https://github.com/yourusername/sdui/wiki)
- 🐛 [Issue Tracker](https://github.com/yourusername/sdui/issues)
- 💬 [Discussions](https://github.com/yourusername/sdui/discussions)
- 📧 [Email Support](mailto:support@example.com)

## 🙏 Acknowledgments

- Built with ❤️ using Flutter - (Oladips, Orpheus)
- Inspired by modern form builders and dynamic UI frameworks

---

**Made with Flutter** 🚀
