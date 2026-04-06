import 'package:sdui/src/util/data_enhance.dart';

class SDUIForm {
  final String name;
  final String? key;
  final String? description;
  final SDUIPages form;
  final SDUIMeta? meta;

  SDUIForm({
    required this.name,
    this.key,
    this.description,
    required this.form,
    this.meta,
  });

  factory SDUIForm.fromJson(Map<String, dynamic> json) {
    final pages = dataGet(
      json,
      'pages',
      defaultValue: dataGet(json, 'form.pages', defaultValue: const []),
    );
    final meta = dataGet(json, 'meta', defaultValue: null);

    return SDUIForm(
      name: json['name'],
      key: json['key'],
      description: json['description'],
      form: SDUIPages.fromJson(pages),
      meta: (meta != null && meta is Map)
          ? SDUIMeta.fromJson(Map<dynamic, dynamic>.from(meta))
          : null,
    );
  }

  factory SDUIForm.fromApiJson(Map<String, dynamic> json) {
    final name = dataGet(json, 'name', defaultValue: null);
    final key = dataGet(json, 'key', defaultValue: null);
    final description = dataGet(json, 'description', defaultValue: null);
    final pages = dataGet(
      json,
      'form.pages',
      defaultValue: dataGet(json, 'pages', defaultValue: null),
    );
    final meta = dataGet(json, 'meta', defaultValue: null);

    return SDUIForm(
      name: name,
      key: key,
      description: description,
      form: SDUIPages.fromJson(pages),
      meta: (meta != null && meta is Map<String, dynamic>)
          ? SDUIMeta.fromJson(meta)
          : null,
    );
  }
}

class SDUIMeta {
  final SDUIUi? ui;
  final SDUII18n? i18n;

  SDUIMeta({this.ui, this.i18n});

  factory SDUIMeta.fromJson(Map<dynamic, dynamic> json) {
    return SDUIMeta(
      ui: json['ui'] != null ? SDUIUi.fromJson(json['ui']) : null,
      i18n: json['i18n'] != null ? SDUII18n.fromJson(json['i18n']) : null,
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

class SDUIPages {
  final List<SDUIPage> pages;
  final int pagesCount;

  SDUIPages({required this.pages, required this.pagesCount});

  factory SDUIPages.fromJson(dynamic json) {
    final pages = json as List<dynamic>;
    return SDUIPages(
      pages: pages.map((page) => SDUIPage.fromJson(page)).toList(),
      pagesCount: pages.length,
    );
  }
}

class SDUIPage {
  final String id;
  final String key;
  final String label;
  final List<SDUISection> sections;
  final bool hidden;
  final List<SDUIConditional>? conditionals;

  SDUIPage({
    required this.id,
    required this.key,
    required this.label,
    required this.sections,
    required this.hidden,
    required this.conditionals,
  });

  factory SDUIPage.fromJson(Map<String, dynamic> json) {
    final conditionals = dataGet(json, 'conditionals', defaultValue: const []);
    return SDUIPage(
      id: json['id'],
      key: json['key'],
      label: json['label'],
      sections: (json['sections'] as List<dynamic>)
          .map((section) => SDUISection.fromJson(section))
          .toList(),
      hidden: json['hidden'] ?? false,
      conditionals:
          conditionals
              .map<SDUIConditional>((e) => SDUIConditional.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SDUISection {
  final String id;
  final String key;
  final String? label;
  final String? description;
  final List<SDUIField> fields;
  final bool hidden;
  final List<SDUIConditional>? conditionals;

  SDUISection({
    required this.id,
    required this.key,
    this.label,
    this.description,
    required this.fields,
    required this.hidden,
    required this.conditionals,
  });

  factory SDUISection.fromJson(Map<String, dynamic> json) {
    final conditionals = dataGet(json, 'conditionals', defaultValue: const []);
    return SDUISection(
      id: json['id'],
      key: json['key'],
      label: json['label'],
      description: json['description'],
      fields: (json['fields'] as List<dynamic>)
          .map((field) => SDUIField.fromJson(field))
          .toList(),
      hidden: json['hidden'] ?? false,
      conditionals:
          conditionals
              .map<SDUIConditional>((e) => SDUIConditional.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SDUIField {
  final String id;
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
  final SDUIFieldUi? ui;
  final SDUIAutofill? autofill;
  final SDUIValidationResponse? validationResponse;
  final SDUIConstraints? constraints;
  final List<SDUIValidation>? validations;
  final SDUIOptionProperties? optionProperties;
  final SDUIAddressProperties? addressProperties;
  final List<SDUIConditional>? conditionals;
  final SDUITypeProperties? typeProperties;
  final SduiBannerProperties? bannerProperties;

  SDUIField({
    required this.id,
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
    this.ui,
    this.autofill,
    this.validationResponse,
    this.constraints,
    this.validations,
    this.optionProperties,
    this.addressProperties,
    this.conditionals,
    this.typeProperties,
    this.bannerProperties,
  });

  factory SDUIField.fromJson(Map<String, dynamic> json) {
    final conditionals = dataGet(json, 'conditionals', defaultValue: const []);
    final constraints = dataGet(json, 'constraints', defaultValue: null);
    final constraintType = constraints.runtimeType;

    return SDUIField(
      id: json['id'],
      key: json['key'],
      label: json['label'],
      placeholder: json['placeholder'],
      helpText: json['help_text'],
      defaultValue: json['default'] ?? json['value'],
      type: json['type'],
      visibleIf: json['visible_if'] != null
          ? SDUIVisibleIf.fromJson(json['visible_if'])
          : null,
      readonly: json['readonly'] ?? false,
      hiddenField:
          (json['hidden_field'] ??
                  (json['type'] == 'hidden' ? true : json['hidden']) ??
                  false)
              as bool,
      required: json['required'] ?? false,
      ui: json['ui'] != null ? SDUIFieldUi.fromJson(json['ui']) : null,
      autofill: json['autofill'] is Map<String, dynamic>
          ? SDUIAutofill.fromJson(Map<String, dynamic>.from(json['autofill']))
          : null,
      validationResponse: json['validation_response'] is Map<String, dynamic>
          ? SDUIValidationResponse.fromJson(
              Map<String, dynamic>.from(json['validation_response']),
            )
          : null,
      constraints: (constraints != null && constraintType != List<dynamic>)
          ? SDUIConstraints.fromJson(constraints)
          : null,
      typeProperties: json['type_properties'] != null
          ? SDUITypeProperties.fromJson(json['type_properties'])
          : null,
      validations: json['validations'] != null
          ? (json['validations'] as List<dynamic>)
                .map((validation) => SDUIValidation.fromJson(validation))
                .toList()
          : [],
      bannerProperties: json['banner_properties'] is Map<String, dynamic>
          ? SduiBannerProperties.fromJson(
              Map<String, dynamic>.from(json['banner_properties']),
            )
          : null,
      optionProperties: json['option_properties'] != null
          ? SDUIOptionProperties.fromJson(
              Map<String, dynamic>.from(json['option_properties']),
            )
          : null,
      addressProperties: json['address_properties'] is Map<String, dynamic>
          ? SDUIAddressProperties.fromJson(
              parentKey: json['key']?.toString() ?? '',
              json: Map<String, dynamic>.from(json['address_properties']),
            )
          : null,
      conditionals:
          conditionals
              .map<SDUIConditional>((e) => SDUIConditional.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SduiBannerProperties {
  final String? variant;
  final String? customVariant;
  final String? message;
  final String? icon;
  final bool? isHtml;
  final String? emphasis;
  final String? customEmphasis;
  final bool? dismissible;

  SduiBannerProperties({
    this.variant,
    this.customVariant,
    this.message,
    this.icon,
    this.isHtml,
    this.emphasis,
    this.customEmphasis,
    this.dismissible,
  });

  factory SduiBannerProperties.fromJson(Map<String, dynamic> json) =>
      SduiBannerProperties(
        variant: json["variant"],
        customVariant: json["custom_variant"],
        message: json["message"],
        icon: json["icon"],
        isHtml: json["is_html"],
        emphasis: json["emphasis"],
        customEmphasis: json["custom_emphasis"],
        dismissible: json["dismissible"],
      );

  Map<String, dynamic> toJson() => {
    "variant": variant,
    "custom_variant": customVariant,
    "message": message,
    "icon": icon,
    "is_html": isHtml,
    "emphasis": emphasis,
    "custom_emphasis": customEmphasis,
    "dismissible": dismissible,
  };
}

class SDUIAddressProperties {
  final List<SDUIAddressProperty> items;

  const SDUIAddressProperties({required this.items});

  factory SDUIAddressProperties.fromJson({
    required String parentKey,
    required Map<String, dynamic> json,
  }) {
    final items = <SDUIAddressProperty>[];

    json.forEach((schemaKey, value) {
      if (value is! Map) return;
      items.add(
        SDUIAddressProperty.fromJson(
          parentKey: parentKey,
          schemaKey: schemaKey,
          json: Map<String, dynamic>.from(value),
        ),
      );
    });

    return SDUIAddressProperties(items: items);
  }
}

class SDUIAddressProperty {
  final String schemaKey;
  final SDUIField field;

  const SDUIAddressProperty({required this.schemaKey, required this.field});

  factory SDUIAddressProperty.fromJson({
    required String parentKey,
    required String schemaKey,
    required Map<String, dynamic> json,
  }) {
    final childKey = json['key']?.toString().trim();
    final resolvedKey = childKey == null || childKey.isEmpty
        ? schemaKey.trim()
        : childKey;
    final resolvedLabel = json['label']?.toString().trim();

    return SDUIAddressProperty(
      schemaKey: schemaKey,
      field: SDUIField.fromJson({
        'id': json['id'] ?? '$parentKey.$resolvedKey',
        'key': resolvedKey,
        'label': resolvedLabel == null || resolvedLabel.isEmpty
            ? resolvedKey
            : resolvedLabel,
        'placeholder': json['placeholder'],
        'help_text': json['help_text'],
        'default': json['default'] ?? json['value'],
        'type': json['field_type'] ?? json['type'] ?? 'text',
        'hidden': false,
        'visible_if': const {'all': [], 'any': [], 'not': null},
        'conditionals': const [],
        'readonly': json['readonly'] ?? false,
        'required': json['required'] ?? false,
        'ui': json['ui'],
        'autofill': json['autofill'],
        'validation_response': json['validation_response'],
        'constraints': json['constraints'] ?? const <String, dynamic>{},
        'validations': json['validations'] ?? const <dynamic>[],
        'option_properties': json['option_properties'],
      }),
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

class SDUIAutofill {
  final List<SDUIAutofillMap> map;
  final SDUIAutofillWhen? when;
  final String method;
  final List<SDUIAutofillParam> params;
  final bool enabled;
  final List<String> headers;
  final String trigger;
  final String endpoint;
  final String overwrite;
  final int debounceMs;

  SDUIAutofill({
    required this.map,
    required this.when,
    required this.method,
    required this.params,
    required this.enabled,
    required this.headers,
    required this.trigger,
    required this.endpoint,
    required this.overwrite,
    required this.debounceMs,
  });

  factory SDUIAutofill.fromJson(Map<String, dynamic> json) {
    final rawDebounce = json['debounce_ms'];
    int parsedDebounce = 0;
    if (rawDebounce is num) {
      parsedDebounce = rawDebounce.toInt();
    } else if (rawDebounce is String) {
      parsedDebounce = int.tryParse(rawDebounce) ?? 0;
    }

    return SDUIAutofill(
      map:
          (json['map'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => SDUIAutofillMap.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      when: json['when'] is Map<String, dynamic>
          ? SDUIAutofillWhen.fromJson(Map<String, dynamic>.from(json['when']))
          : null,
      method: (json['method'] ?? 'GET').toString(),
      params:
          (json['params'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => SDUIAutofillParam.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      enabled: json['enabled'] ?? true,
      headers:
          (json['headers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      trigger: (json['trigger'] ?? 'debounce').toString(),
      endpoint: json['endpoint']?.toString() ?? '',
      overwrite: (json['overwrite'] ?? 'empty').toString(),
      debounceMs: parsedDebounce > 0 ? parsedDebounce : 500,
    );
  }
}

class SDUIValidationResponseHeader {
  final String key;
  final String value;

  const SDUIValidationResponseHeader({required this.key, required this.value});

  factory SDUIValidationResponseHeader.fromJson(Map<String, dynamic> json) {
    return SDUIValidationResponseHeader(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class SDUIValidationResponse {
  final bool enabled;
  final String trigger;
  final String endpoint;
  final String method;
  final int debounceMs;
  final List<SDUIValidationResponseHeader> headers;
  final List<SDUIAutofillParam> params;
  final List<SDUIAutofillMap> map;
  final String? validatedText;
  final SDUIAutofillWhen? when;

  const SDUIValidationResponse({
    required this.enabled,
    required this.trigger,
    required this.endpoint,
    required this.method,
    required this.debounceMs,
    required this.headers,
    required this.params,
    required this.map,
    this.validatedText,
    this.when,
  });

  factory SDUIValidationResponse.fromJson(Map<String, dynamic> json) {
    final parsedDebounce =
        int.tryParse(json['debounce_ms']?.toString() ?? '') ?? 0;

    return SDUIValidationResponse(
      enabled: json['enabled'] ?? true,
      trigger: (json['trigger'] ?? 'on_valid').toString().trim().toLowerCase(),
      endpoint: json['endpoint']?.toString() ?? '',
      method: (json['method'] ?? 'POST').toString(),
      debounceMs: parsedDebounce > 0 ? parsedDebounce : 0,
      headers:
          (json['headers'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => SDUIValidationResponseHeader.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      params:
          (json['params'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => SDUIAutofillParam.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      map:
          (json['map'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => SDUIAutofillMap.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      validatedText: json['validated_text']?.toString(),
      when: json['when'] is Map<String, dynamic>
          ? SDUIAutofillWhen.fromJson(Map<String, dynamic>.from(json['when']))
          : null,
    );
  }
}

class SDUIAutofillMap {
  final String path;
  final String target;

  SDUIAutofillMap({required this.path, required this.target});

  factory SDUIAutofillMap.fromJson(Map<String, dynamic> json) {
    return SDUIAutofillMap(
      path: json['path']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
    );
  }
}

class SDUIAutofillParam {
  final String key;
  final dynamic value;

  SDUIAutofillParam({required this.key, this.value});

  factory SDUIAutofillParam.fromJson(Map<String, dynamic> json) {
    return SDUIAutofillParam(
      key: json['key']?.toString() ?? '',
      value: json['value'],
    );
  }
}

class SDUIAutofillWhen {
  final List<SDUIAutofillCondition> all;
  final List<SDUIAutofillCondition> any;
  final List<SDUIAutofillCondition> not;

  SDUIAutofillWhen({required this.all, required this.any, required this.not});

  factory SDUIAutofillWhen.fromJson(Map<String, dynamic> json) {
    return SDUIAutofillWhen(
      all: _parseConditions(json['all']),
      any: _parseConditions(json['any']),
      not: _parseConditions(json['not']),
    );
  }

  static List<SDUIAutofillCondition> _parseConditions(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => SDUIAutofillCondition.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    if (raw is Map) {
      return [SDUIAutofillCondition.fromJson(Map<String, dynamic>.from(raw))];
    }
    return const [];
  }
}

class SDUIAutofillCondition {
  final String key;
  final String operator;
  final dynamic value;

  SDUIAutofillCondition({
    required this.key,
    required this.operator,
    required this.value,
  });

  factory SDUIAutofillCondition.fromJson(Map<String, dynamic> json) {
    return SDUIAutofillCondition(
      key: json['key']?.toString() ?? '',
      operator: json['operator']?.toString() ?? '',
      value: json['value'],
    );
  }
}

class SDUIFieldUi {
  final String? icon;
  final String? prefix;
  final String? suffix;
  final String? mask;
  final String? inputMode;
  final String? autocomplete;
  final int multilineRows;
  final int? maxLength;

  SDUIFieldUi({
    this.icon,
    this.prefix,
    this.suffix,
    this.mask,
    this.inputMode,
    this.autocomplete,
    required this.multilineRows,
    this.maxLength,
  });

  factory SDUIFieldUi.fromJson(Map<String, dynamic> json) {
    final rawMaxLength = json['max_length'];
    int? parsedMaxLength;
    if (rawMaxLength is num) {
      parsedMaxLength = rawMaxLength.toInt();
    } else if (rawMaxLength is String) {
      parsedMaxLength = int.tryParse(rawMaxLength);
    }

    return SDUIFieldUi(
      icon: json['icon'],
      prefix: json['prefix'],
      suffix: json['suffix'],
      mask: json['mask'],
      inputMode: json['input_mode'],
      autocomplete: json['autocomplete'],
      multilineRows: json['multiline_rows'] ?? 1,
      maxLength: parsedMaxLength,
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

  @override
  String toString() {
    return 'SDUIConstraints(min: $min, max: $max, minLength: $minLength, maxLength: $maxLength, maxFileSize: $maxFileSize, maxTotalSize: $maxTotalSize, accept: $accept, regex: $regex, maxSize: $maxSize, step: $step, codeType: $codeType, allowedDomains: $allowedDomains, disallowedDomains: $disallowedDomains, allowedCountries: $allowedCountries, disallowedCountries: $disallowedCountries, allowMultiple: $allowMultiple)';
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
  final SDUIOptionSource? source;

  SDUIOptionProperties({
    required this.type,
    required this.data,
    this.maxSelect,
    this.source,
  });

  factory SDUIOptionProperties.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return SDUIOptionProperties(
      type: json['type']?.toString() ?? 'select',
      data: (rawData is List ? rawData : const [])
          .whereType<Map>()
          .map(
            (option) => SDUIOption.fromJson(Map<String, dynamic>.from(option)),
          )
          .toList(),
      maxSelect: json['max_select'],
      source: json['source'] is Map<String, dynamic>
          ? SDUIOptionSource.fromJson(Map<String, dynamic>.from(json['source']))
          : null,
    );
  }
}

class SDUIOption {
  final String key;
  final String value;

  SDUIOption({required this.key, required this.value});

  factory SDUIOption.fromJson(Map<String, dynamic> json) {
    return SDUIOption(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'SDUIOption(key: $key, value: $value)';
  }
}

class SDUIOptionSource {
  final SDUIAutofillWhen? when;
  final String method;
  final List<SDUIAutofillParam> params;
  final bool enabled;
  final List<String> headers;
  final String endpoint;
  final String keyPath;
  final String valuePath;
  final String itemsPath;
  final List<String> triggers;
  final String transport;
  final List<String> dependsOn;

  SDUIOptionSource({
    required this.when,
    required this.method,
    required this.params,
    required this.enabled,
    required this.headers,
    required this.endpoint,
    required this.keyPath,
    required this.valuePath,
    required this.itemsPath,
    required this.triggers,
    required this.transport,
    required this.dependsOn,
  });

  factory SDUIOptionSource.fromJson(Map<String, dynamic> json) {
    return SDUIOptionSource(
      when: json['when'] is Map<String, dynamic>
          ? SDUIAutofillWhen.fromJson(Map<String, dynamic>.from(json['when']))
          : null,
      method: (json['method'] ?? 'GET').toString(),
      params:
          (json['params'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => SDUIAutofillParam.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      enabled: json['enabled'] ?? true,
      headers:
          (json['headers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      endpoint: json['endpoint']?.toString() ?? '',
      keyPath: json['key_path']?.toString() ?? '',
      valuePath: json['value_path']?.toString() ?? '',
      itemsPath: json['items_path']?.toString() ?? 'data',
      triggers:
          (json['triggers'] as List<dynamic>?)
              ?.map((e) => e.toString().trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      transport: json['transport']?.toString() ?? 'direct',
      dependsOn:
          (json['depends_on'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const [],
    );
  }
}

class SDUIConditional {
  final SDUIConditionalWhen when;
  final SDUIConditionalThen then;

  SDUIConditional({required this.when, required this.then});

  factory SDUIConditional.fromJson(Map<String, dynamic> json) {
    return SDUIConditional(
      when: SDUIConditionalWhen.fromJson(
        Map<String, dynamic>.from(json['when']),
      ),
      then: SDUIConditionalThen.fromJson(
        Map<String, dynamic>.from(json['then']),
      ),
    );
  }
}

class SDUITypeProperties {
  final String type;

  SDUITypeProperties({required this.type});

  factory SDUITypeProperties.fromJson(Map<String, dynamic> json) {
    return SDUITypeProperties(type: json['type'].toString());
  }
}

class SDUIConditionalWhen {
  final String field;
  final String operator;
  final dynamic value;

  SDUIConditionalWhen({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory SDUIConditionalWhen.fromJson(Map<String, dynamic> json) {
    return SDUIConditionalWhen(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }
}

class SDUIConditionalThen {
  final String action;
  final List<SDUIConditionalTarget> targets;

  SDUIConditionalThen({required this.action, required this.targets});

  factory SDUIConditionalThen.fromJson(Map<String, dynamic> json) {
    return SDUIConditionalThen(
      action: json['action'] as String,
      targets:
          (json['targets'] as List<dynamic>?)
              ?.map(
                (e) => SDUIConditionalTarget.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class SDUIConditionalTarget {
  final String type;
  final String key;

  SDUIConditionalTarget({required this.type, required this.key});

  factory SDUIConditionalTarget.fromJson(Map<String, dynamic> json) {
    return SDUIConditionalTarget(
      type: json['type'] as String,
      key: json['key'] as String,
    );
  }
}
