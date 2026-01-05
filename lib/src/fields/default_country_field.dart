import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/config/country/country_form.dart';
import 'package:sdui/src/fields/country_picker_sheet.dart';
import 'package:sdui/src/fields/selector.dart';
import 'package:sdui/src/util/validator.dart';

class SDUICountryField extends SDUIBaseStatefulWidget {
  const SDUICountryField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() =>
      _SDUICountryFieldState();
}

class _SDUICountryFieldState extends SDUIBaseState<SDUICountryField> {
  final countries = CountryService().getAll();

  @override
  void initState() {
    super.initState();
    final defaultValue = widget.field.defaultValue;
    final existing = widget.formManager.getSelectedCountry(widget.field.key);
    if (defaultValue != null &&
        (existing == null || existing.countryCode.isEmpty)) {
      widget.formManager.updateSelectedCountry(
        widget.field.key,
        CountryForm(
          countryCode: defaultValue.toString(),
          countryName: defaultValue.toString(),
        ),
      );
    }
  }

  _selectCountry() async {
    final country = widget.formManager.getSelectedCountry(widget.field.key);
    Country? selectedCountry;
    if (country != null) {
      final selectedCountryLowerCase = country.countryCode.toLowerCase();
      selectedCountry = countries.firstWhereOrNull(
        (c) => c.countryCode.toLowerCase() == selectedCountryLowerCase,
      );
    }
    final result = await BottomSheetService.showBottomSheet(
      context: context,
      child: CountryPickerSheet(
        field: widget.field,
        selectedCountry: selectedCountry,
      ),
    );

    if (!mounted || !context.mounted) return;
    if (result != null) {
      final resultCountry = result as Country;
      final countryForm = CountryForm(
        countryCode: resultCountry.countryCode,
        countryName: resultCountry.name,
      );
      widget.formManager.updateSelectedCountry(widget.field.key, countryForm);
      widget.onChanged?.call(widget.field.key, countryForm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.field.label;
    final helpText = widget.field.helpText;
    final hintText = widget.field.placeholder ?? "Select a country";
    final country = widget.formManager.getSelectedCountry(widget.field.key);

    return Selector(
      header: label,
      hintText: hintText,
      helpText: helpText,
      errorText: widget.formManager.getError(widget.field.key),
      title: country?.countryName,
      onTap: _selectCountry,
    );
  }

  @override
  String? validateField(value) {
    for (final validation in widget.field.validations ?? []) {
      final result = _validateRule(validation, value);
      if (result != null) {
        widget.formManager.addError(widget.field.key, result);
        return result;
      }
    }
    return null;
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: widget.formManager,
      textValue: value,
      fieldType: widget.field.type,
    );
  }
}
