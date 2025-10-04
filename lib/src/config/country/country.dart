class Country {
  static Country worldWide = Country(
    phoneCode: '',
    countryCode: 'WW',
    e164Sc: -1,
    geographic: false,
    level: -1,
    name: 'World Wide',
    example: '',
    displayName: 'World Wide (WW)',
    displayNameNoCountryCode: 'World Wide',
    e164Key: '',
    flagColorCode: "",
    iso3Code: '',
  );

  final String phoneCode;
  final String countryCode;
  final int e164Sc;
  final bool geographic;
  final int level;
  final String name;
  late String? nameLocalized;
  final String example;
  final String? flagColorCode;
  final String displayName;
  final String? fullExampleWithPlusSign;
  final String displayNameNoCountryCode;
  final String e164Key;
  final String iso3Code;
  String get displayNameNoE164Cc => displayNameNoCountryCode;

  Country({
    this.flagColorCode,
    required this.phoneCode,
    required this.countryCode,
    required this.e164Sc,
    required this.geographic,
    required this.level,
    required this.name,
    this.nameLocalized = '',
    required this.example,
    required this.displayName,
    required this.displayNameNoCountryCode,
    required this.e164Key,
    this.fullExampleWithPlusSign,
    required this.iso3Code,
  });

  Country.from({required Map<String, dynamic> json})
    : phoneCode = json['e164_cc'],
      countryCode = json['iso2_cc'],
      e164Sc = json['e164_sc'],
      geographic = json['geographic'],
      level = json['level'],
      name = json['name'],
      example = json['example'],
      displayName = json['display_name'],
      fullExampleWithPlusSign = json['full_example_with_plus_sign'],
      displayNameNoCountryCode = json['display_name_no_e164_cc'],
      flagColorCode = json['flag_color_code'] ?? "0xFF000000",
      e164Key = json['e164_key'],
      iso3Code = json['iso3_cc'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['e164_cc'] = phoneCode;
    data['iso2_cc'] = countryCode;
    data['e164_sc'] = e164Sc;
    data['geographic'] = geographic;
    data['level'] = level;
    data['name'] = name;
    data['example'] = example;
    data['display_name'] = displayName;
    data['full_example_with_plus_sign'] = fullExampleWithPlusSign;
    data['display_name_no_e164_cc'] = displayNameNoCountryCode;
    data['e164_key'] = e164Key;
    data['flag_color_code'] = flagColorCode;
    data['iso3_cc'] = iso3Code;
    return data;
  }

  bool get iswWorldWide => countryCode == Country.worldWide.countryCode;

  @override
  String toString() => 'Country(countryCode: $countryCode, name: $name)';

  @override
  bool operator ==(Object other) {
    if (other is Country) {
      return other.countryCode == countryCode;
    }

    return super == other;
  }

  @override
  int get hashCode => countryCode.hashCode;
}
