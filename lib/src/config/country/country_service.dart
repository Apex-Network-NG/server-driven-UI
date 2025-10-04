import 'package:collection/collection.dart';
import 'package:sdui/src/config/country/country.dart';
import 'package:sdui/src/config/country/country_code.dart';

class CountryService {
  final List<Country> _countries;

  CountryService()
    : _countries = countryCodes
          .map((country) => Country.from(json: country))
          .toList();

  ///Return list with all countries
  List<Country> getAll() {
    return _countries;
  }

  ///Returns the first country that mach the given code.
  Country? findByCode(String? code) {
    final uppercaseCode = code?.toUpperCase();
    return _countries.firstWhereOrNull(
      (country) => country.countryCode == uppercaseCode,
    );
  }

  ///Returns the first country that mach the given name.
  Country? findByName(String? name) {
    return _countries.firstWhereOrNull((country) => country.name == name);
  }

  ///Returns a list with all the countries that mach the given codes list.
  List<Country> findCountriesByCode(List<String> codes) {
    final List<String> codes0 = codes
        .map((code) => code.toUpperCase())
        .toList();
    final List<Country> countries = [];
    for (final code in codes0) {
      final Country? country = findByCode(code);
      if (country != null) {
        countries.add(country);
      }
    }
    return countries;
  }
}
