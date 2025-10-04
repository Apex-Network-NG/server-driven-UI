class SDUIForm {
  final String name;
  final String key;
  final String? title;
  final String? description;
  final int version;
  final SDUIMeta meta;
  final SDUIProperties properties;
  final SDUIFormData form;

  SDUIForm({
    required this.name,
    required this.key,
    this.title,
    this.description,
    required this.version,
    required this.meta,
    required this.properties,
    required this.form,
  });

  factory SDUIForm.fromJson(Map<String, dynamic> json) {
    return SDUIForm(
      name: json['name'],
      key: json['key'],
      title: json['title'],
      description: json['description'],
      version: json['version'],
      meta: SDUIMeta.fromJson(json['meta']),
      properties: SDUIProperties.fromJson(json['properties']),
      form: SDUIFormData.fromJson(json['form']),
    );
  }
}

class SDUIMeta {
  final SDUIUi ui;
  final SDUII18n i18n;

  SDUIMeta({required this.ui, required this.i18n});

  factory SDUIMeta.fromJson(Map<String, dynamic> json) {
    return SDUIMeta(
      ui: SDUIUi.fromJson(json['ui']),
      i18n: SDUII18n.fromJson(json['i18n']),
    );
  }
}

class SDUIUi {
  final String layout;
  final bool progress;

  SDUIUi({required this.layout, required this.progress});

  factory SDUIUi.fromJson(Map<String, dynamic> json) {
    return SDUIUi(layout: json['layout'], progress: json['progress']);
  }
}

class SDUII18n {
  final String defaultLocale;
  final List<dynamic> translations;

  SDUII18n({required this.defaultLocale, required this.translations});

  factory SDUII18n.fromJson(Map<String, dynamic> json) {
    return SDUII18n(
      defaultLocale: json['defaultLocale'],
      translations: json['translations'] ?? [],
    );
  }
}

class SDUIProperties {
  final String dateFormat;
  final String timeFormat;
  final String datetimeFormat;
  final SDUINumberFormat numberFormat;

  SDUIProperties({
    required this.dateFormat,
    required this.timeFormat,
    required this.datetimeFormat,
    required this.numberFormat,
  });

  factory SDUIProperties.fromJson(Map<String, dynamic> json) {
    return SDUIProperties(
      dateFormat: json['dateFormat'],
      timeFormat: json['timeFormat'],
      datetimeFormat: json['datetimeFormat'],
      numberFormat: SDUINumberFormat.fromJson(json['numberFormat']),
    );
  }
}

class SDUINumberFormat {
  final String decimal;
  final String thousand;

  SDUINumberFormat({required this.decimal, required this.thousand});

  factory SDUINumberFormat.fromJson(Map<String, dynamic> json) {
    return SDUINumberFormat(
      decimal: json['decimal'],
      thousand: json['thousand'],
    );
  }
}

class SDUIFormData {
  final List<SDUIPage> pages;
  final int pagesCount;

  SDUIFormData({required this.pages, required this.pagesCount});

  factory SDUIFormData.fromJson(Map<String, dynamic> json) {
    return SDUIFormData(
      pages: (json['pages'] as List<dynamic>)
          .map((page) => SDUIPage.fromJson(page))
          .toList(),
      pagesCount: json['pages_count'],
    );
  }
}

class SDUIPage {
  final String key;
  final String label;
  final String? description;
  final int order;
  final List<SDUISection> sections;

  SDUIPage({
    required this.key,
    required this.label,
    this.description,
    required this.order,
    required this.sections,
  });

  factory SDUIPage.fromJson(Map<String, dynamic> json) {
    return SDUIPage(
      key: json['key'],
      label: json['label'],
      description: json['description'],
      order: json['order'],
      sections: (json['sections'] as List<dynamic>)
          .map((section) => SDUISection.fromJson(section))
          .toList(),
    );
  }
}

class SDUISection {
  final String key;
  final String? label;
  final String? description;
  final int order;
  final List<SDUIField> fields;

  SDUISection({
    required this.key,
    this.label,
    this.description,
    required this.order,
    required this.fields,
  });

  factory SDUISection.fromJson(Map<String, dynamic> json) {
    return SDUISection(
      key: json['key'],
      label: json['label'],
      description: json['description'],
      order: json['order'],
      fields: (json['fields'] as List<dynamic>)
          .map((field) => SDUIField.fromJson(field))
          .toList(),
    );
  }
}

class SDUIField {
  final String key;
  final String label;
  final String? placeholder;
  final String? helpText;
  final dynamic defaultValue;
  final String type;
  final SDUIVisibleIf? visibleIf;
  final bool readonly;
  final bool hiddenField;
  final bool required;
  final SDUIFieldUi ui;
  final SDUIConstraints constraints;
  final List<SDUIValidation> validations;
  final SDUIOptionProperties? optionProperties;

  SDUIField({
    required this.key,
    required this.label,
    this.placeholder,
    this.helpText,
    this.defaultValue,
    required this.type,
    this.visibleIf,
    required this.readonly,
    required this.hiddenField,
    required this.required,
    required this.ui,
    required this.constraints,
    required this.validations,
    this.optionProperties,
  });

  factory SDUIField.fromJson(Map<String, dynamic> json) {
    return SDUIField(
      key: json['key'],
      label: json['label'],
      placeholder: json['placeholder'],
      helpText: json['help_text'],
      defaultValue: json['default'],
      type: json['type'],
      visibleIf: json['visible_if'] != null
          ? SDUIVisibleIf.fromJson(json['visible_if'])
          : null,
      readonly: json['readonly'] ?? false,
      hiddenField: json['hidden_field'] ?? false,
      required: json['required'] ?? false,
      ui: SDUIFieldUi.fromJson(json['ui']),
      constraints: SDUIConstraints.fromJson(
        Map<String, dynamic>.from(json['constraints']),
      ),
      validations:
          (json['validations'] as List<dynamic>?)
              ?.map((validation) => SDUIValidation.fromJson(validation))
              .toList() ??
          [],
      optionProperties: json['option_properties'] != null
          ? SDUIOptionProperties.fromJson(json['option_properties'])
          : null,
    );
  }
}

class SDUIVisibleIf {
  final List<dynamic> all;
  final List<dynamic> any;
  final dynamic not;

  SDUIVisibleIf({required this.all, required this.any, this.not});

  factory SDUIVisibleIf.fromJson(Map<String, dynamic> json) {
    return SDUIVisibleIf(
      all: json['all'] ?? [],
      any: json['any'] ?? [],
      not: json['not'],
    );
  }
}

class SDUIFieldUi {
  final String? icon;
  final String? prefix;
  final String? suffix;
  final String? mask;
  final int multilineRows;
  final int? maxLength;

  SDUIFieldUi({
    this.icon,
    this.prefix,
    this.suffix,
    this.mask,
    required this.multilineRows,
    this.maxLength,
  });

  factory SDUIFieldUi.fromJson(Map<String, dynamic> json) {
    return SDUIFieldUi(
      icon: json['icon'],
      prefix: json['prefix'],
      suffix: json['suffix'],
      mask: json['mask'],
      multilineRows: json['multiline_rows'] ?? 1,
      maxLength: json['max_length'],
    );
  }
}

class SDUIConstraints {
  final dynamic min;
  final dynamic max;
  final int? minLength;
  final int? maxLength;
  final num? maxFileSize;
  final num? maxTotalSize;
  final List<String> accept;
  final String? regex;
  final dynamic maxSize;
  final dynamic step;
  final String? codeType;
  final List<String> allowedDomains;
  final List<String> disallowedDomains;
  final List<String> allowedCountries;
  final List<String> disallowedCountries;
  final bool allowMultiple;

  SDUIConstraints({
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.maxFileSize,
    this.maxTotalSize,
    required this.accept,
    this.regex,
    this.maxSize,
    this.step,
    this.codeType,
    required this.allowedDomains,
    required this.disallowedDomains,
    required this.allowedCountries,
    required this.disallowedCountries,
    required this.allowMultiple,
  });

  factory SDUIConstraints.fromJson(Map<String, dynamic> json) {
    return SDUIConstraints(
      min: json['min'],
      max: json['max'],
      maxFileSize: json['max_file_size'],
      maxTotalSize: json['max_total_size'],
      minLength: json['min_length'],
      maxLength: json['max_length'],
      accept:
          (json['accept'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      regex: json['regex'],
      maxSize: json['max_size'],
      step: json['step'],
      codeType: json['code_type'],
      allowedDomains:
          (json['allowed_domains'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      disallowedDomains:
          (json['disallowed_domains'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allowedCountries:
          (json['allow_countries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      disallowedCountries:
          (json['exclude_countries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allowMultiple: json['allow_multiple'] ?? false,
    );
  }
}

class SDUIValidation {
  final String rule;
  final String? message;
  final List<dynamic> params;

  SDUIValidation({required this.rule, this.message, required this.params});

  factory SDUIValidation.fromJson(Map<String, dynamic> json) {
    return SDUIValidation(
      rule: json['rule'],
      message: json['message'],
      params: json['params'] ?? [],
    );
  }
}

class SDUIOptionProperties {
  final String type;
  final List<SDUIOption> data;
  final int? maxSelect;

  SDUIOptionProperties({
    required this.type,
    required this.data,
    this.maxSelect,
  });

  factory SDUIOptionProperties.fromJson(Map<String, dynamic> json) {
    return SDUIOptionProperties(
      type: json['type'],
      data: (json['data'] as List<dynamic>)
          .map((option) => SDUIOption.fromJson(option))
          .toList(),
      maxSelect: json['max_select'],
    );
  }
}

class SDUIOption {
  final String key;
  final String value;

  SDUIOption({required this.key, required this.value});

  factory SDUIOption.fromJson(Map<String, dynamic> json) {
    return SDUIOption(key: json['key'], value: json['value']);
  }

  @override
  String toString() {
    return 'SDUIOption(key: $key, value: $value)';
  }
}
