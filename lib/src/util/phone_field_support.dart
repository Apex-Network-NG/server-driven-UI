import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:sdui/src/config/country/country.dart';
import 'package:sdui/src/config/country/country_form.dart';
import 'package:sdui/src/config/country/country_service.dart';
import 'package:sdui/src/util/mask_input_formatter.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

String normalizePhoneCodeType(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll('-', '_');
  switch (normalized) {
    case 'alpha_3':
    case 'alpha3':
    case 'iso3':
      return 'alpha_3';
    case 'alpha_2':
    case 'alpha2':
    case 'iso2':
    default:
      return 'alpha_2';
  }
}

String normalizePhoneFormat(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll('-', '_');
  switch (normalized) {
    case 'national':
      return 'national';
    case 'e164':
    case 'e_164':
      return 'e164';
    case 'raw':
    case 'local':
      return 'raw';
    case 'international':
    default:
      return 'international';
  }
}

String phoneCountryConstraintCode(Country country, String codeType) {
  return switch (normalizePhoneCodeType(codeType)) {
    'alpha_3' => country.iso3Code.toUpperCase(),
    _ => country.countryCode.toUpperCase(),
  };
}

List<Country> availablePhoneCountriesForField(
  SDUIField field, {
  CountryService? countryService,
}) {
  final service = countryService ?? CountryService();
  final codeType = normalizePhoneCodeType(field.constraints?.codeType);
  final allowed =
      field.constraints?.allowedCountries
          .map((code) => code.trim().toUpperCase())
          .where((code) => code.isNotEmpty)
          .toSet() ??
      const <String>{};
  final excluded =
      field.constraints?.disallowedCountries
          .map((code) => code.trim().toUpperCase())
          .where((code) => code.isNotEmpty)
          .toSet() ??
      const <String>{};

  return service.getAll().where((country) {
    final comparableCode = phoneCountryConstraintCode(country, codeType);
    if (allowed.isNotEmpty && !allowed.contains(comparableCode)) {
      return false;
    }
    if (excluded.contains(comparableCode)) {
      return false;
    }
    return true;
  }).toList();
}

Country? resolvePhoneCountryByCode(
  String? code, {
  String? codeType,
  CountryService? countryService,
  List<Country>? availableCountries,
}) {
  final normalizedCode = code?.trim().toUpperCase();
  if (normalizedCode == null || normalizedCode.isEmpty) return null;

  final countries =
      availableCountries ?? (countryService ?? CountryService()).getAll();
  final normalizedCodeType = normalizePhoneCodeType(codeType);

  final preferred = normalizedCodeType == 'alpha_3'
      ? countries.firstWhereOrNull(
          (country) => country.iso3Code.toUpperCase() == normalizedCode,
        )
      : countries.firstWhereOrNull(
          (country) => country.countryCode.toUpperCase() == normalizedCode,
        );
  if (preferred != null) return preferred;

  return countries.firstWhereOrNull(
    (country) =>
        country.countryCode.toUpperCase() == normalizedCode ||
        country.iso3Code.toUpperCase() == normalizedCode,
  );
}

Country? selectedPhoneCountryForField(
  SDUIField field,
  FormManager formManager, {
  CountryService? countryService,
}) {
  final selected = formManager.getSelectedCountry(field.key);
  if (selected == null) return null;

  final availableCountries = availablePhoneCountriesForField(
    field,
    countryService: countryService,
  );
  return resolvePhoneCountryByCode(
        selected.countryCode,
        codeType: field.constraints?.codeType,
        countryService: countryService,
        availableCountries: availableCountries,
      ) ??
      availableCountries.firstWhereOrNull(
        (country) => country.name == selected.countryName,
      );
}

Country? initialPhoneCountryForField(
  SDUIField field,
  FormManager formManager, {
  CountryService? countryService,
}) {
  final existing = selectedPhoneCountryForField(
    field,
    formManager,
    countryService: countryService,
  );
  if (existing != null) return existing;

  final availableCountries = availablePhoneCountriesForField(
    field,
    countryService: countryService,
  );
  if (availableCountries.length == 1) return availableCountries.first;
  return null;
}

CountryForm? countryFormForPhoneCountry(Country? country) {
  if (country == null) return null;
  return CountryForm(
    countryCode: country.countryCode,
    countryName: country.name,
  );
}

List<TextInputFormatter> phoneInputFormattersForField(SDUIField field) {
  final ui = field.ui;
  final mask = ui?.mask?.trim();
  final uiMaxLength = ui?.maxLength;
  final maskFormatter = mask?.isNotEmpty == true
      ? SDUIMaskTextInputFormatter(mask: mask!, maxLength: uiMaxLength)
      : null;

  return <TextInputFormatter>[
    if (maskFormatter != null) maskFormatter,
    if (maskFormatter == null && uiMaxLength != null)
      LengthLimitingTextInputFormatter(uiMaxLength),
  ];
}

String unmaskPhoneValueForField(SDUIField field, String? value) {
  if (value == null) return '';
  final mask = field.ui?.mask?.trim();
  if (mask == null || mask.isEmpty) return value.trim();
  final formatter = SDUIMaskTextInputFormatter(
    mask: mask,
    maxLength: field.ui?.maxLength,
  );
  return formatter.unmask(value).trim();
}

String formatPhoneDisplayValueForField(SDUIField field, String value) {
  final mask = field.ui?.mask?.trim();
  if (mask == null || mask.isEmpty) return value;
  final formatter = SDUIMaskTextInputFormatter(
    mask: mask,
    maxLength: field.ui?.maxLength,
  );
  return formatter.format(value);
}

PhoneNumber? parsePhoneValueForField(
  SDUIField field,
  String? value, {
  String? selectedCountryCode,
}) {
  final rawValue = value?.trim();
  final selectedCode = selectedCountryCode?.trim().toUpperCase();
  if (rawValue == null || rawValue.isEmpty) return null;
  if (selectedCode == null || selectedCode.isEmpty) return null;

  try {
    final isoCode = IsoCode.fromJson(selectedCode);
    return PhoneNumber.parse(rawValue, destinationCountry: isoCode);
  } catch (_) {
    return null;
  }
}

String? internationalPhoneValueForField(
  SDUIField field,
  String? value, {
  String? selectedCountryCode,
}) {
  final phone = parsePhoneValueForField(
    field,
    value,
    selectedCountryCode: selectedCountryCode,
  );
  if (phone == null || !phone.isValid()) return null;
  return phone.international;
}

String? nationalPhoneValueForField(
  SDUIField field,
  String? value, {
  String? selectedCountryCode,
}) {
  final phone = parsePhoneValueForField(
    field,
    value,
    selectedCountryCode: selectedCountryCode,
  );
  if (phone == null || !phone.isValid()) return null;
  return phone.formatNsn();
}

String? normalizedPhoneValueForField(
  SDUIField field,
  String? value, {
  String? selectedCountryCode,
}) {
  final rawValue = value?.trim();
  if (rawValue == null || rawValue.isEmpty) return rawValue;

  switch (normalizePhoneFormat(field.constraints?.format)) {
    case 'national':
      return nationalPhoneValueForField(
            field,
            rawValue,
            selectedCountryCode: selectedCountryCode,
          ) ??
          rawValue;
    case 'e164':
    case 'international':
      return internationalPhoneValueForField(
            field,
            rawValue,
            selectedCountryCode: selectedCountryCode,
          ) ??
          rawValue;
    case 'raw':
      return rawValue;
  }

  return rawValue;
}

bool isAllowedPhoneCountryForField(SDUIField field, Country country) {
  final availableCountries = availablePhoneCountriesForField(field);
  return availableCountries.any(
    (candidate) => candidate.countryCode == country.countryCode,
  );
}
