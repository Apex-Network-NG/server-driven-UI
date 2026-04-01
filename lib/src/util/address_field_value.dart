import 'package:sdui/src/util/sdui_form.dart';

const String sduiAddressLine1Key = 'address_line_1';
const String sduiAddressLine2Key = 'address_line_2';
const String sduiAddressStreetKey = 'street_address';
const String sduiAddressCityKey = 'city';
const String sduiAddressStateKey = 'state';
const String sduiAddressPostalCodeKey = 'postal_code';
const String sduiAddressCountryKey = 'country';

const Map<String, List<String>> _addressAliases = <String, List<String>>{
  sduiAddressLine1Key: <String>[
    'address_line_1',
    'address-line-1',
    'addressLine1',
    'address1',
    'address_1',
    'street_address',
    'street-address',
    'streetAddress',
    'street',
    'address',
    'line1',
    'line_1',
    'line-1',
  ],
  sduiAddressLine2Key: <String>[
    'address_line_2',
    'address-line-2',
    'addressLine2',
    'address2',
    'address_2',
    'street_address_2',
    'street-address-2',
    'streetAddress2',
    'line2',
    'line_2',
    'line-2',
    'apartment',
    'suite',
  ],
  sduiAddressStreetKey: <String>[
    'street_address',
    'street-address',
    'streetAddress',
    'street',
    'address',
    'address_line_1',
    'address-line-1',
    'addressLine1',
    'address1',
    'address_1',
    'line1',
    'line_1',
    'line-1',
  ],
  sduiAddressCityKey: <String>['city', 'town'],
  sduiAddressStateKey: <String>[
    'state',
    'province',
    'region',
    'state_province',
    'state-province',
    'stateProvince',
  ],
  sduiAddressPostalCodeKey: <String>[
    'postal_code',
    'postal-code',
    'postalCode',
    'zip',
    'zip_code',
    'zip-code',
    'zipCode',
    'postcode',
    'post_code',
    'post-code',
  ],
  sduiAddressCountryKey: <String>[
    'country',
    'country_code',
    'country-code',
    'countryCode',
    'country_name',
    'country-name',
    'countryName',
  ],
};

List<SDUIField> resolveAddressComponentFields(SDUIField field) {
  final addressProperties = field.addressProperties?.items;
  if (addressProperties != null && addressProperties.isNotEmpty) {
    return addressProperties.map((item) => item.field).toList(growable: false);
  }

  return <SDUIField>[
    _legacyAddressField(
      parent: field,
      key: sduiAddressStreetKey,
      label: field.placeholder?.trim().isNotEmpty == true
          ? field.placeholder!
          : 'Street Address',
      required: field.required,
    ),
    _legacyAddressField(
      parent: field,
      key: sduiAddressCityKey,
      label: 'City',
      required: field.required,
    ),
    _legacyAddressField(
      parent: field,
      key: sduiAddressStateKey,
      label: 'State/Province',
      required: field.required,
    ),
    _legacyAddressField(
      parent: field,
      key: sduiAddressPostalCodeKey,
      label: 'ZIP/Postal Code',
      required: field.required,
    ),
    _legacyAddressField(
      parent: field,
      key: sduiAddressCountryKey,
      label: 'Country',
      required: field.required,
      type: 'country',
    ),
  ];
}

Map<String, String> normalizeAddressValue(
  SDUIField field,
  Object? value, {
  bool includeDefaults = false,
}) {
  final componentFields = resolveAddressComponentFields(field);
  final normalized = <String, String>{
    for (final componentField in componentFields) componentField.key: '',
  };

  if (value is String) {
    if (componentFields.isNotEmpty) {
      normalized[componentFields.first.key] = value.trim();
    }
    return includeDefaults
        ? _applyAddressDefaults(componentFields, normalized)
        : normalized;
  }

  if (value is Map) {
    final source = <String, dynamic>{};
    value.forEach((key, entry) {
      source[key.toString().trim()] = entry;
    });

    for (final componentField in componentFields) {
      for (final alias in _aliasesFor(componentField.key)) {
        final resolved = source[alias];
        final text = resolved?.toString().trim() ?? '';
        if (text.isEmpty) continue;
        normalized[componentField.key] = text;
        break;
      }
    }
  }

  return includeDefaults
      ? _applyAddressDefaults(componentFields, normalized)
      : normalized;
}

Map<String, String>? compactAddressValue(
  SDUIField field,
  Object? value, {
  bool includeDefaults = false,
}) {
  final normalized = normalizeAddressValue(
    field,
    value,
    includeDefaults: includeDefaults,
  );
  final compact = <String, String>{};

  for (final entry in normalized.entries) {
    final text = entry.value.trim();
    if (text.isEmpty) continue;
    compact[entry.key] = text;
  }

  return compact.isEmpty ? null : compact;
}

Map<String, String>? resolveAddressDefaultValue(
  SDUIField field,
  Object? value,
) {
  return compactAddressValue(field, value, includeDefaults: true);
}

bool hasAnyAddressValue(SDUIField field, Object? value) {
  return compactAddressValue(field, value) != null;
}

bool hasRequiredAddressValue(SDUIField field, Object? value) {
  final requiredFields = requiredAddressComponentFields(field);
  if (requiredFields.isEmpty) return true;

  final normalized = normalizeAddressValue(field, value);
  return requiredFields.every(
    (componentField) =>
        (normalized[componentField.key] ?? '').trim().isNotEmpty,
  );
}

List<SDUIField> requiredAddressComponentFields(SDUIField field) {
  final componentFields = resolveAddressComponentFields(field);
  final explicit = componentFields.where(_isComponentRequired).toList();
  if (explicit.isNotEmpty) return explicit;
  if (field.required) return componentFields;
  return const <SDUIField>[];
}

String addressRequiredErrorMessage(SDUIField field) {
  final requiredFields = requiredAddressComponentFields(field);
  if (requiredFields.isEmpty) return '${field.label} is required';

  final requiredField = requiredFields.first;
  final message = requiredField.validations
      ?.firstWhere(
        (validation) => validation.rule.toLowerCase() == 'required',
        orElse: () => SDUIValidation(rule: '', params: const []),
      )
      .message;

  if (message != null && message.trim().isNotEmpty) return message;
  return '${requiredField.label} is required';
}

String flattenAddressValue(SDUIField field, Object? value) {
  final normalized = normalizeAddressValue(field, value);
  return resolveAddressComponentFields(field)
      .map((componentField) => normalized[componentField.key] ?? '')
      .where((entry) => entry.trim().isNotEmpty)
      .join(', ');
}

SDUIField _legacyAddressField({
  required SDUIField parent,
  required String key,
  required String label,
  required bool required,
  String type = 'text',
}) {
  return SDUIField(
    id: '${parent.key}.$key',
    key: key,
    label: label,
    placeholder: label,
    type: type,
    visibleIf: null,
    readonly: parent.readonly,
    hiddenField: false,
    required: required,
    ui: type == 'text' ? parent.ui : null,
    autofill: null,
    validationResponse: null,
    constraints: null,
    validations: const <SDUIValidation>[],
    optionProperties: null,
    addressProperties: null,
    conditionals: const <SDUIConditional>[],
  );
}

Map<String, String> _applyAddressDefaults(
  List<SDUIField> componentFields,
  Map<String, String> value,
) {
  final merged = Map<String, String>.from(value);

  for (final componentField in componentFields) {
    if ((merged[componentField.key] ?? '').trim().isNotEmpty) continue;
    final defaultValue = componentField.defaultValue?.toString().trim();
    if (defaultValue == null || defaultValue.isEmpty) continue;
    merged[componentField.key] = defaultValue;
  }

  return merged;
}

List<String> _aliasesFor(String key) {
  return _addressAliases[key] ?? <String>[key];
}

bool _isComponentRequired(SDUIField field) {
  if (field.required) return true;
  return field.validations?.any(
        (validation) => validation.rule.toLowerCase() == 'required',
      ) ==
      true;
}
