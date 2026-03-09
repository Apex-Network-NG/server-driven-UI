import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sdui/src/config/autofill/autofill_api_config.dart';
import 'package:sdui/src/config/country/country_form.dart';
import 'package:sdui/src/config/options/options_ui_registry.dart';
import 'package:sdui/src/core/service/dio_service.dart';
import 'package:sdui/src/renderer/field_renderer.dart';
import 'package:sdui/src/util/data_enhance.dart';
import 'package:sdui/src/util/logger.dart';
import 'package:sdui/src/util/mask_input_formatter.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUIRenderer extends StatefulWidget {
  final SDUIForm form;
  final FormManager formManager;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function(String, dynamic)? onFieldChanged;
  final bool showNavigationButtons;
  final Widget Function(
    BuildContext,
    int,
    int,
    VoidCallback,
    VoidCallback,
    VoidCallback,
  )?
  navigationBuilder;

  const SDUIRenderer({
    super.key,
    required this.form,
    required this.formManager,
    this.onSubmit,
    this.onFieldChanged,
    this.showNavigationButtons = true,
    this.navigationBuilder,
  });

  @override
  State<SDUIRenderer> createState() => _SDUIRendererState();
}

class _SDUIRendererState extends State<SDUIRenderer> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  late final Map<String, SDUIField> _fieldIndex;
  late final Map<String, Set<String>> _autofillTargetsByDependencyKey;
  final Map<String, Object?> _resolvedDefaults = {};
  final Map<String, Timer> _autofillTimers = {};
  final Map<String, CancelToken> _autofillCancelTokens = {};
  final Map<String, int> _autofillRequestIds = {};
  final Set<String> _autofillLoading = {};
  int _autofillRequestSequence = 0;

  String _visKey(String type, String key) {
    // avoid collisions between field keys and section/page keys
    switch (type) {
      case 'field':
        return key;
      case 'section':
        return 'section:$key';
      case 'page':
        return 'page:$key';
      default:
        return '$type:$key';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disposeAutofillResources();
    super.dispose();
  }

  void _disposeAutofillResources() {
    for (final timer in _autofillTimers.values) {
      timer.cancel();
    }
    _autofillTimers.clear();

    for (final token in _autofillCancelTokens.values) {
      token.cancel();
    }
    _autofillCancelTokens.clear();
    _autofillRequestIds.clear();
    _autofillLoading.clear();
  }

  void _initializeFormFields() {
    _fieldIndex = {};
    for (final page in widget.form.form.pages) {
      widget.formManager.setHidden(_visKey('page', page.key), page.hidden);

      for (final section in page.sections) {
        widget.formManager.setHidden(
          _visKey('section', section.key),
          section.hidden,
        );

        for (final field in section.fields) {
          _fieldIndex[field.key] = field;
          _initializeField(field);
        }
      }
    }
    _autofillTargetsByDependencyKey = _buildAutofillTargetIndex();

    for (final field in _fieldIndex.values) {
      final resolvedDefault = _resolveDefaultValue(field);
      if (resolvedDefault != null) {
        _applyDefaultToField(field, resolvedDefault);
      }
    }

    for (final key in _fieldIndex.keys) {
      _evaluateConditionalsForChangedField(key);
      _handleAutofillForBlur(key);
    }
  }

  void _initializeField(SDUIField field) {
    widget.formManager.setHidden(field.key, field.hiddenField);
    if (_isTextField(field.type)) {
      widget.formManager.getController(field.key);
      widget.formManager.getFocusNode(field.key);
    }

    if (field.type == 'boolean') {
      widget.formManager.setBooleanValue(field.key, false);
    }
  }

  Object? _resolveDefaultValue(SDUIField field, {Set<String>? stack}) {
    if (_resolvedDefaults.containsKey(field.key)) {
      return _resolvedDefaults[field.key];
    }

    final visited = stack ?? <String>{};
    if (!visited.add(field.key)) return null; // circular

    final raw = field.defaultValue;
    if (raw == null) {
      _resolvedDefaults[field.key] = null;
      visited.remove(field.key);
      return null;
    }

    if (raw is String) {
      final match = RegExp(r'^\{field:(.+)\}$').firstMatch(raw.trim());
      if (match != null) {
        final refKey = match.group(1)?.trim();
        if (refKey == null || refKey.isEmpty) {
          visited.remove(field.key);
          return null;
        }
        final refField = _fieldIndex[refKey];
        if (refField == null) {
          visited.remove(field.key);
          return null;
        }
        final resolved = _resolveDefaultValue(refField, stack: visited);
        visited.remove(field.key);
        _resolvedDefaults[field.key] = resolved;
        return resolved;
      }
    }

    _resolvedDefaults[field.key] = raw;
    visited.remove(field.key);
    return raw;
  }

  void _applyDefaultToField(SDUIField field, Object? value) {
    switch (field.type) {
      case 'short-text':
      case 'medium-text':
      case 'long-text':
      case 'text':
      case 'email':
      case 'url':
      case 'password':
        _setControllerValue(field.key, value?.toString(), mask: field.ui?.mask);
        widget.formManager.setFieldValue(field.key, value?.toString());
        break;

      case 'number':
        final textValue = value?.toString();
        _setControllerValue(field.key, textValue, mask: field.ui?.mask);
        final parsed = textValue == null ? null : num.tryParse(textValue);
        widget.formManager.setFieldValue(
          field.key,
          parsed ?? value ?? textValue,
        );
        break;

      case 'phone':
        _setControllerValue(field.key, value?.toString(), mask: field.ui?.mask);
        widget.formManager.setFieldValue(field.key, value?.toString());
        break;

      case 'boolean':
        final boolValue = _toBool(value);
        if (boolValue != null) {
          widget.formManager.setBooleanValue(field.key, boolValue);
        }
        break;

      case 'country':
        final countryValue = value?.toString();
        if (countryValue != null && countryValue.isNotEmpty) {
          widget.formManager.updateSelectedCountry(
            field.key,
            CountryForm(countryCode: countryValue, countryName: countryValue),
          );
          widget.formManager.setFieldValue(field.key, countryValue);
        }
        break;

      case 'options':
        final options = _toStringList(value);
        if (options.isNotEmpty) {
          widget.formManager.setSelectedOption(field.key, options);
          widget.formManager.setFieldValue(
            field.key,
            _normalizeOptionsFieldValue(field, options),
          );
        }
        break;

      case 'date':
      case 'datetime':
        final dateValue = _toDateTime(value);
        if (dateValue != null) {
          if (field.type == 'datetime') {
            widget.formManager.setDateTimeValue(field.key, dateValue);
          } else {
            widget.formManager.setDateValue(field.key, dateValue);
          }
        }
        break;

      default:
        widget.formManager.setFieldValue(field.key, value);
    }
  }

  void _setControllerValue(String key, String? value, {String? mask}) {
    if (value == null) return;
    final controller = widget.formManager.getController(key);
    if (controller.text.isNotEmpty) return;
    controller.text = _formatMaskedValue(value, mask);
  }

  String _formatMaskedValue(String value, String? mask) {
    final trimmedMask = mask?.trim();
    if (trimmedMask == null || trimmedMask.isEmpty) return value;
    final formatter = SDUIMaskTextInputFormatter(mask: trimmedMask);
    return formatter.format(value);
  }

  bool? _toBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (const {'true', '1', 'yes', 'on', 'y'}.contains(normalized)) {
        return true;
      }
      if (const {'false', '0', 'no', 'off', 'n'}.contains(normalized)) {
        return false;
      }
    }
    return null;
  }

  List<String> _toStringList(Object? value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  dynamic _normalizeOptionsFieldValue(SDUIField field, List<String> values) {
    final optionsType = SDUIOptionsUiType.fromFieldType(
      field.optionProperties?.type,
    );
    return optionsType.isMulti ? values : values.firstOrNull;
  }

  DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  bool _isTextField(String type) {
    return [
      'short-text',
      'medium-text',
      'long-text',
      'text',
      'number',
      'email',
      'phone',
      'url',
      'password',
    ].contains(type);
  }

  void _onFieldChanged(String key, dynamic value) {
    widget.formManager.setFieldValue(key, value);
    _evaluateConditionalsForChangedField(key);
    _handleAutofillForChangedField(key);
    widget.onFieldChanged?.call(key, value);
    scheduleMicrotask(() {
      _clearDependentAutofillTargetsIfSourceHasError(key);
    });
  }

  void _handleAutofillForBlur(String changedKey) {
    final field = _fieldIndex[changedKey];
    if (field == null) return;
    final autofill = field.autofill;
    if (autofill == null || autofill.enabled != true) return;
    if (!_isBlurTrigger(autofill)) return;
    _executeAutofill(field);
  }

  void _handleAutofillForChangedField(String changedKey) {
    for (final field in _fieldIndex.values) {
      final autofill = field.autofill;
      if (autofill == null || autofill.enabled != true) continue;

      if (!_isDebounceTrigger(autofill)) continue;
      if (!_shouldConsiderAutofill(field, autofill, changedKey)) continue;
      _scheduleAutofill(field, autofill);
    }
  }

  bool _shouldConsiderAutofill(
    SDUIField field,
    SDUIAutofill autofill,
    String changedKey,
  ) {
    return _autofillDependencyKeys(field, autofill).contains(changedKey);
  }

  Set<String> _autofillDependencyKeys(SDUIField field, SDUIAutofill autofill) {
    final keys = <String>{};
    if (field.key.isNotEmpty) {
      keys.add(field.key);
    }

    final when = autofill.when;
    if (when != null) {
      keys.addAll(
        when.all.map((c) => c.key).where((key) => key.trim().isNotEmpty),
      );
      keys.addAll(
        when.any.map((c) => c.key).where((key) => key.trim().isNotEmpty),
      );
      keys.addAll(
        when.not.map((c) => c.key).where((key) => key.trim().isNotEmpty),
      );
    }

    for (final param in autofill.params) {
      final raw = param.value;
      if (raw is String) {
        keys.addAll(_extractFieldKeysFromTemplate(raw));
      }
    }

    return keys;
  }

  Map<String, Set<String>> _buildAutofillTargetIndex() {
    final index = <String, Set<String>>{};

    for (final field in _fieldIndex.values) {
      final autofill = field.autofill;
      if (autofill == null || autofill.enabled != true || autofill.map.isEmpty) {
        continue;
      }

      final targets = autofill.map
          .map((mapping) => mapping.target.trim())
          .where((key) => key.isNotEmpty)
          .toSet();
      if (targets.isEmpty) continue;

      final dependencyKeys = _autofillDependencyKeys(field, autofill);
      for (final dependencyKey in dependencyKeys) {
        index.putIfAbsent(dependencyKey, () => <String>{}).addAll(targets);
      }
    }

    return index;
  }

  void _clearDependentAutofillTargetsIfSourceHasError(String sourceKey) {
    if (!mounted) return;
    if (!widget.formManager.hasError(sourceKey)) return;

    _cancelAutofillRequestsDependingOn(sourceKey);

    final targets = _autofillTargetsByDependencyKey[sourceKey];
    if (targets == null || targets.isEmpty) return;

    for (final targetKey in targets) {
      if (targetKey == sourceKey) continue;
      final targetField = _fieldIndex[targetKey];
      if (targetField == null) continue;

      _clearFieldValue(targetField);
      _evaluateConditionalsForChangedField(targetField.key);
    }
  }

  void _cancelAutofillRequestsDependingOn(String sourceKey) {
    for (final field in _fieldIndex.values) {
      final autofill = field.autofill;
      if (autofill == null || autofill.enabled != true) continue;
      if (!_autofillDependencyKeys(field, autofill).contains(sourceKey)) {
        continue;
      }

      final requestKey = 'autofill:${field.key}';
      _autofillCancelTokens.remove(requestKey)?.cancel();
      _autofillRequestIds.remove(field.key);
      _setAutofillLoading(field.key, false);
    }
  }

  void _clearFieldValue(SDUIField field) {
    widget.formManager.clearError(field.key);

    switch (field.type) {
      case 'short-text':
      case 'medium-text':
      case 'long-text':
      case 'text':
      case 'email':
      case 'url':
      case 'password':
      case 'phone':
      case 'number':
        widget.formManager.getController(field.key).clear();
        widget.formManager.setFieldValue(field.key, null);
        break;
      case 'boolean':
        widget.formManager.setBooleanValue(field.key, false);
        widget.formManager.setFieldValue(field.key, null);
        break;
      case 'country':
        widget.formManager.updateSelectedCountry(field.key, null);
        widget.formManager.setFieldValue(field.key, null);
        break;
      case 'options':
        widget.formManager.setSelectedOption(field.key, const []);
        widget.formManager.setFieldValue(field.key, null);
        break;
      case 'date':
        widget.formManager.setDateValue(field.key, null);
        widget.formManager.setFieldValue(field.key, null);
        break;
      case 'datetime':
        widget.formManager.setDateTimeValue(field.key, null);
        widget.formManager.setFieldValue(field.key, null);
        break;
      case 'tag':
        widget.formManager.setTagValues(field.key, const []);
        widget.formManager.setFieldValue(field.key, const []);
        break;
      case 'file':
      case 'image':
      case 'video':
      case 'document':
        widget.formManager.setFileValue(field.key, null);
        widget.formManager.setFieldValue(field.key, null);
        break;
      default:
        widget.formManager.setFieldValue(field.key, null);
    }
  }

  Set<String> _extractFieldKeysFromTemplate(String template) {
    final matches = RegExp(r'\{field:([^}]+)\}').allMatches(template);
    return matches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((key) => key.isNotEmpty)
        .toSet();
  }

  void _scheduleAutofill(SDUIField field, SDUIAutofill autofill) {
    if (!_autofillConditionsMet(autofill)) {
      _autofillTimers[field.key]?.cancel();
      return;
    }

    if (_isBlurTrigger(autofill)) {
      _executeAutofill(field);
      return;
    }

    final delay = Duration(milliseconds: autofill.debounceMs);
    _autofillTimers[field.key]?.cancel();
    _autofillTimers[field.key] = Timer(delay, () {
      _executeAutofill(field);
    });
  }

  bool _isBlurTrigger(SDUIAutofill autofill) {
    return autofill.trigger.trim().toLowerCase() == 'blur';
  }

  bool _isDebounceTrigger(SDUIAutofill autofill) {
    final trigger = autofill.trigger.trim().toLowerCase();
    final triggers = ['debounce', 'blur'];
    return triggers.contains(trigger);
  }

  bool _isManualTrigger(SDUIAutofill autofill) {
    return autofill.trigger.trim().toLowerCase() == 'manual';
  }

  bool _isManualAutofillEnabled(SDUIField field) {
    final autofill = field.autofill;
    if (autofill == null || autofill.enabled != true) return false;
    if (!_isManualTrigger(autofill)) return false;
    return _autofillConditionsMet(autofill);
  }

  void _setAutofillLoading(String fieldKey, bool isLoading) {
    final currentlyLoading = _autofillLoading.contains(fieldKey);
    if (isLoading == currentlyLoading) return;
    if (isLoading) {
      _autofillLoading.add(fieldKey);
    } else {
      _autofillLoading.remove(fieldKey);
    }
    if (!mounted) return;
    setState(() {});
  }

  void _triggerManualAutofill(SDUIField field) {
    final autofill = field.autofill;
    if (autofill == null || autofill.enabled != true) return;
    if (!_isManualTrigger(autofill)) return;
    if (!_autofillConditionsMet(autofill)) return;

    _autofillTimers[field.key]?.cancel();
    _executeAutofill(field);
  }

  Future<void> _executeAutofill(SDUIField field) async {
    final autofill = field.autofill;
    if (autofill == null || autofill.enabled != true) return;
    if (!_autofillConditionsMet(autofill)) return;
    if (autofill.endpoint.trim().isEmpty) {
      return;
    }

    final requestKey = 'autofill:${field.key}';
    _autofillCancelTokens[requestKey]?.cancel();
    final cancelToken = CancelToken();
    _autofillCancelTokens[requestKey] = cancelToken;
    final requestId = ++_autofillRequestSequence;
    _autofillRequestIds[field.key] = requestId;
    _setAutofillLoading(field.key, true);

    try {
      final responseData = await _performAutofillRequest(autofill, cancelToken);
      if (responseData == null) return;
      _applyAutofillMappings(autofill, responseData);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      Logger.logError(
        'Autofill request failed for ${field.key}: ${e.message}',
        tag: 'Autofill',
      );
    } catch (e) {
      Logger.logError('Autofill failed for ${field.key}: $e', tag: 'Autofill');
    } finally {
      if (_autofillRequestIds[field.key] == requestId) {
        _setAutofillLoading(field.key, false);
      }
    }
  }

  Future<dynamic> _performAutofillRequest(
    SDUIAutofill autofill,
    CancelToken cancelToken,
  ) async {
    final apiConfig = SDUIAutofillApiRegistry.config;
    final dio = apiConfig.dio ?? DioService().dio;
    final headers = apiConfig.resolveHeaders(autofill.headers);
    final params = _resolveAutofillParams(autofill.params);
    final method = autofill.method.trim().toUpperCase();
    final endpoint = _resolveAutofillEndpoint(
      autofill.endpoint,
      apiConfig.baseUrl ?? dio.options.baseUrl,
    );

    final options = Options(method: method, headers: headers);
    final response = await dio.request(
      endpoint,
      data: method == 'GET' ? null : params,
      queryParameters: method == 'GET' ? params : null,
      options: options,
      cancelToken: cancelToken,
    );

    return response.data;
  }

  Map<String, dynamic> _resolveAutofillParams(List<SDUIAutofillParam> params) {
    if (params.isEmpty) return {};
    final values = widget.formManager.getAllFormData();
    final resolved = <String, dynamic>{};

    for (final param in params) {
      if (param.key.trim().isEmpty) continue;
      resolved[param.key] = _resolveParamValue(param.value, values);
    }

    return resolved;
  }

  dynamic _resolveParamValue(dynamic raw, Map<String, dynamic> values) {
    if (raw is String) {
      final trimmed = raw.trim();
      final exactMatch = RegExp(r'^\{field:([^}]+)\}$').firstMatch(trimmed);
      if (exactMatch != null) {
        final key = exactMatch.group(1)?.trim();
        if (key == null) return null;
        return _normalizeFieldTemplateValue(key, values[key]);
      }

      final matches = RegExp(r'\{field:([^}]+)\}').allMatches(raw);
      if (matches.isEmpty) return raw;

      var resolved = raw;
      for (final match in matches) {
        final key = match.group(1)?.trim();
        final value = key == null
            ? null
            : _normalizeFieldTemplateValue(key, values[key]);
        resolved = resolved.replaceAll(
          match.group(0)!,
          value?.toString() ?? '',
        );
      }
      return resolved;
    }

    return raw;
  }

  dynamic _normalizeFieldTemplateValue(String key, dynamic value) {
    final field = _fieldIndex[key];
    if (field == null) return value;
    if (field.type != 'options') return value;
    if (value is! List) return value;

    final optionsType = SDUIOptionsUiType.fromFieldType(
      field.optionProperties?.type,
    );
    if (optionsType.isMulti) return value;
    return value.firstOrNull;
  }

  String _resolveAutofillEndpoint(String endpoint, String? baseUrl) {
    final trimmed = endpoint.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (baseUrl == null || baseUrl.trim().isEmpty) return trimmed;

    final normalizedBase = baseUrl.trim().endsWith('/')
        ? baseUrl.trim()
        : '${baseUrl.trim()}/';
    final normalizedEndpoint = trimmed.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse(normalizedBase).resolve(normalizedEndpoint).toString();
  }

  bool _autofillConditionsMet(SDUIAutofill autofill) {
    final when = autofill.when;
    if (when == null) return true;

    final values = widget.formManager.getAllFormData();
    final allOk = when.all.every((c) => _evaluateAutofillCondition(c, values));
    final anyOk =
        when.any.isEmpty ||
        when.any.any((c) => _evaluateAutofillCondition(c, values));
    final notOk = when.not.isEmpty
        ? when.not.every((c) => !_evaluateAutofillCondition(c, values))
        : true;

    return allOk && anyOk && notOk;
  }

  bool _evaluateAutofillCondition(
    SDUIAutofillCondition condition,
    Map<String, dynamic> values,
  ) {
    final left = values[condition.key];
    final right = condition.value;
    final op = condition.operator.trim().toLowerCase();

    switch (op) {
      case 'is':
        return _isEqual(left, right);
      case 'is_not':
        return !_isEqual(left, right);
      case 'length_gt':
        return _lengthCompare(left, right, (l, r) => l > r);
      case 'length_gte':
        return _lengthCompare(left, right, (l, r) => l >= r);
      case 'length_lt':
        return _lengthCompare(left, right, (l, r) => l < r);
      case 'length_lte':
        return _lengthCompare(left, right, (l, r) => l <= r);
      case 'length_eq':
        return _lengthCompare(left, right, (l, r) => l == r);
      case 'gt':
        return _numericCompare(left, right, (l, r) => l > r);
      case 'gte':
        return _numericCompare(left, right, (l, r) => l >= r);
      case 'lt':
        return _numericCompare(left, right, (l, r) => l < r);
      case 'lte':
        return _numericCompare(left, right, (l, r) => l <= r);
      case 'contains':
        return _containsValue(left, right);
      case 'starts_with':
        return _startsWith(left, right);
      case 'ends_with':
        return _endsWith(left, right);
      case 'empty':
        return _isEmpty(left);
      case 'not_empty':
        return !_isEmpty(left);
      default:
        return false;
    }
  }

  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  bool _isEqual(dynamic left, dynamic right) {
    if (left == null && right == null) return true;
    if (left == null || right == null) return false;

    final leftNum = _toNum(left);
    final rightNum = _toNum(right);
    if (leftNum != null && rightNum != null) {
      return leftNum == rightNum;
    }

    return left.toString() == right.toString();
  }

  bool _lengthCompare(
    dynamic left,
    dynamic right,
    bool Function(int, int) compare,
  ) {
    final leftLength = _valueLength(left);
    final rightNum = _toNum(right)?.toInt();
    if (leftLength == null || rightNum == null) return false;
    return compare(leftLength, rightNum);
  }

  int? _valueLength(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.length;
    if (value is Iterable) return value.length;
    if (value is Map) return value.length;
    return value.toString().length;
  }

  bool _numericCompare(
    dynamic left,
    dynamic right,
    bool Function(num, num) compare,
  ) {
    final leftNum = _toNum(left);
    final rightNum = _toNum(right);
    if (leftNum == null || rightNum == null) return false;
    return compare(leftNum, rightNum);
  }

  num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  bool _containsValue(dynamic left, dynamic right) {
    if (left == null || right == null) return false;
    if (left is Iterable) {
      return left.map((e) => e.toString()).contains(right.toString());
    }
    return left.toString().contains(right.toString());
  }

  bool _startsWith(dynamic left, dynamic right) {
    if (left == null || right == null) return false;
    return left.toString().startsWith(right.toString());
  }

  bool _endsWith(dynamic left, dynamic right) {
    if (left == null || right == null) return false;
    return left.toString().endsWith(right.toString());
  }

  void _applyAutofillMappings(SDUIAutofill autofill, dynamic responseData) {
    if (autofill.map.isEmpty) return;
    final overwrite = autofill.overwrite.trim().toLowerCase() == 'always';

    for (final mapping in autofill.map) {
      if (mapping.target.trim().isEmpty || mapping.path.trim().isEmpty) {
        continue;
      }
      final targetField = _fieldIndex[mapping.target];
      if (targetField == null) continue;

      final value = dataGet(
        jsonEncode(responseData),
        mapping.path,
        defaultValue: null,
      );
      if (value == null) continue;

      _applyAutofillToField(targetField, value, overwrite: overwrite);
      _evaluateConditionalsForChangedField(targetField.key);
    }
  }

  void _applyAutofillToField(
    SDUIField field,
    Object? value, {
    required bool overwrite,
  }) {
    if (!overwrite && _fieldHasValue(field)) return;

    switch (field.type) {
      case 'short-text':
      case 'medium-text':
      case 'long-text':
      case 'text':
      case 'email':
      case 'url':
      case 'password':
      case 'phone':
        final textValue = value?.toString();
        if (textValue == null) return;
        final controller = widget.formManager.getController(field.key);
        controller.text = _formatMaskedValue(textValue, field.ui?.mask);
        widget.formManager.setFieldValue(field.key, textValue);
        break;

      case 'number':
        final textValue = value?.toString();
        if (textValue == null) return;
        final controller = widget.formManager.getController(field.key);
        controller.text = _formatMaskedValue(textValue, field.ui?.mask);
        final parsed = num.tryParse(textValue);
        widget.formManager.setFieldValue(
          field.key,
          parsed ?? value ?? textValue,
        );
        break;

      case 'boolean':
        final boolValue = _toBool(value);
        if (boolValue == null) return;
        widget.formManager.setBooleanValue(field.key, boolValue);
        widget.formManager.setFieldValue(field.key, boolValue);
        break;

      case 'country':
        final countryValue = value?.toString();
        if (countryValue == null || countryValue.isEmpty) return;
        widget.formManager.updateSelectedCountry(
          field.key,
          CountryForm(countryCode: countryValue, countryName: countryValue),
        );
        widget.formManager.setFieldValue(field.key, countryValue);
        break;

      case 'options':
        final options = _toStringList(value);
        if (options.isEmpty) return;
        widget.formManager.setSelectedOption(field.key, options);
        widget.formManager.setFieldValue(
          field.key,
          _normalizeOptionsFieldValue(field, options),
        );
        break;

      case 'date':
      case 'datetime':
        final dateValue = _toDateTime(value);
        if (dateValue == null) return;
        if (field.type == 'datetime') {
          widget.formManager.setDateTimeValue(field.key, dateValue);
        } else {
          widget.formManager.setDateValue(field.key, dateValue);
        }
        widget.formManager.setFieldValue(field.key, dateValue);
        break;

      case 'tag':
        final tags = _toStringList(value);
        if (tags.isEmpty) return;
        widget.formManager.setTagValues(field.key, tags);
        widget.formManager.setFieldValue(field.key, tags);
        break;

      case 'file':
      case 'image':
      case 'video':
      case 'document':
        final fileValue = value?.toString();
        if (fileValue == null) return;
        widget.formManager.setFileValue(field.key, fileValue);
        widget.formManager.setFieldValue(field.key, fileValue);
        break;

      default:
        widget.formManager.setFieldValue(field.key, value);
        break;
    }
  }

  bool _fieldHasValue(SDUIField field) {
    switch (field.type) {
      case 'short-text':
      case 'medium-text':
      case 'long-text':
      case 'text':
      case 'email':
      case 'url':
      case 'password':
      case 'phone':
      case 'number':
        return widget.formManager
            .getController(field.key)
            .text
            .trim()
            .isNotEmpty;
      case 'boolean':
        return widget.formManager.booleanValues.containsKey(field.key);
      case 'country':
        return ((widget.formManager.selectedCountries[field.key])
                    ?.countryCode ??
                "")
            .trim()
            .isNotEmpty;
      case 'options':
        return widget.formManager.selectedOptions[field.key]?.isNotEmpty ==
            true;
      case 'date':
        return widget.formManager.dateValues[field.key] != null;
      case 'datetime':
        return widget.formManager.datetimeValues[field.key] != null;
      case 'tag':
        return widget.formManager.tagValues[field.key]?.isNotEmpty == true;
      case 'file':
      case 'image':
      case 'video':
      case 'document':
        return (widget.formManager.fileValues[field.key] ?? '')
            .trim()
            .isNotEmpty;
      default:
        final value = widget.formManager.fieldValues[field.key];
        if (value == null) return false;
        if (value is String) return value.trim().isNotEmpty;
        if (value is Iterable) return value.isNotEmpty;
        return true;
    }
  }

  void _nextPage() {
    if (!_validateRequiredFieldsForCurrentPage()) return;
    if (_currentPageIndex < widget.form.form.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateRequiredFieldsForCurrentPage() {
    final pages = _visiblePages;
    if (_currentPageIndex < 0 || _currentPageIndex >= pages.length) {
      return true;
    }
    return _validateRequiredFieldsForPage(pages[_currentPageIndex]);
  }

  bool _validateRequiredFieldsForForm() {
    var isValid = true;
    for (final page in _visiblePages) {
      if (!_validateRequiredFieldsForPage(page)) {
        isValid = false;
      }
    }
    return isValid;
  }

  bool _validateRequiredFieldsForPage(SDUIPage page) {
    var isValid = true;

    for (final section in page.sections) {
      final sectionHidden = widget.formManager.isHidden(
        _visKey('section', section.key),
        fallback: section.hidden,
      );
      if (sectionHidden) continue;

      for (final field in section.fields) {
        if (!_isFieldRequired(field)) continue;
        if (_isFieldHidden(field)) continue;
        if (_fieldHasRequiredValue(field)) continue;

        widget.formManager.addError(field.key, _requiredErrorMessage(field));
        isValid = false;
      }
    }

    return isValid;
  }

  bool _isFieldHidden(SDUIField field) {
    if (const {'hidden', 'divider', 'spacing'}.contains(field.type)) {
      return true;
    }
    return widget.formManager.isHidden(field.key, fallback: field.hiddenField);
  }

  bool _isFieldRequired(SDUIField field) {
    if (field.required) return true;
    return field.validations?.any(
          (validation) => validation.rule.toLowerCase() == 'required',
        ) ==
        true;
  }

  String _requiredErrorMessage(SDUIField field) {
    final message = field.validations
        ?.firstWhere(
          (validation) => validation.rule.toLowerCase() == 'required',
          orElse: () => SDUIValidation(rule: '', params: const []),
        )
        .message;

    if (message != null && message.trim().isNotEmpty) return message;
    if (field.type == 'boolean') {
      return 'You must accept ${field.label.toLowerCase()}';
    }
    return '${field.label} is required';
  }

  bool _fieldHasRequiredValue(SDUIField field) {
    switch (field.type) {
      case 'short-text':
      case 'medium-text':
      case 'long-text':
      case 'text':
      case 'email':
      case 'url':
      case 'password':
      case 'number':
      case 'phone':
        return _getTextFieldValue(field).trim().isNotEmpty;

      case 'boolean':
        return widget.formManager.getBooleanValue(field.key) == true;

      case 'options':
        return widget.formManager.getSelectedOption(field.key)?.isNotEmpty ==
            true;

      case 'country':
        return ((widget.formManager.getSelectedCountry(
                      field.key,
                    ))?.countryCode ??
                    '')
                .trim()
                .isNotEmpty ==
            true;

      case 'date':
        return widget.formManager.getDateValue(field.key) != null;

      case 'datetime':
        return widget.formManager.getDateTimeValue(field.key) != null;

      case 'tag':
        return widget.formManager.getTagValues(field.key).isNotEmpty;

      case 'file':
      case 'image':
      case 'video':
      case 'document':
        return (widget.formManager.getFileValue(field.key) ?? '')
            .trim()
            .isNotEmpty;

      default:
        final value = widget.formManager.getFieldValue(field.key);
        if (value == null) return false;
        if (value is String) return value.trim().isNotEmpty;
        if (value is Iterable) return value.isNotEmpty;
        return true;
    }
  }

  String _getTextFieldValue(SDUIField field) {
    final controller = widget.formManager.getController(field.key);
    final value = controller.text;
    final mask = field.ui?.mask;
    if (mask == null || mask.trim().isEmpty) return value;
    final formatter = SDUIMaskTextInputFormatter(mask: mask.trim());
    return formatter.unmask(value);
  }

  void _evaluateConditionalsForChangedField(String changedKey) {
    final changedValue = widget.formManager.fieldValues[changedKey];

    bool matches(SDUIConditional c) {
      return _evaluateOperator(c.when.operator, changedValue, c.when.value);
    }

    void applyTargets(SDUIConditional c) {
      final ok = matches(c);

      for (final t in c.then.targets) {
        final targetKey = _visKey(t.type, t.key);

        if (c.then.action == 'show') {
          widget.formManager.setHidden(targetKey, !ok);
        } else if (c.then.action == 'hide') {
          widget.formManager.setHidden(targetKey, ok);
        }
      }
    }

    // Field-level conditionals
    for (final field in _fieldIndex.values) {
      for (final c in field.conditionals ?? const []) {
        if (c.when.field == changedKey) applyTargets(c);
      }
    }

    // Section-level conditionals
    for (final page in widget.form.form.pages) {
      for (final section in page.sections) {
        for (final c in section.conditionals ?? const []) {
          if (c.when.field == changedKey) applyTargets(c);
        }
      }
    }

    // Page-level conditionals
    for (final page in widget.form.form.pages) {
      for (final c in page.conditionals ?? const []) {
        if (c.when.field == changedKey) applyTargets(c);
      }
    }
  }

  bool _evaluateOperator(String op, dynamic left, dynamic right) {
    final normalizedOp = op.trim().toLowerCase();

    switch (normalizedOp) {
      case 'is':
        return _isEqual(left, right);
      case 'is_not':
        return !_isEqual(left, right);
      case 'length_gt':
        return _lengthCompare(left, right, (l, r) => l > r);
      case 'length_gte':
        return _lengthCompare(left, right, (l, r) => l >= r);
      case 'length_lt':
        return _lengthCompare(left, right, (l, r) => l < r);
      case 'length_lte':
        return _lengthCompare(left, right, (l, r) => l <= r);
      case 'length_eq':
        return _lengthCompare(left, right, (l, r) => l == r);
      case 'gt':
        return _numericCompare(left, right, (l, r) => l > r);
      case 'gte':
        return _numericCompare(left, right, (l, r) => l >= r);
      case 'lt':
        return _numericCompare(left, right, (l, r) => l < r);
      case 'lte':
        return _numericCompare(left, right, (l, r) => l <= r);
      case 'contains':
        return _containsValue(left, right);
      case 'starts_with':
        return _startsWith(left, right);
      case 'ends_with':
        return _endsWith(left, right);
      case 'empty':
        return _isEmpty(left);
      case 'not_empty':
        return !_isEmpty(left);
      default:
        return false;
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    if (!_validateRequiredFieldsForForm()) return;
    final formData = widget.formManager.getAllFormData();
    widget.onSubmit?.call(formData);
  }

  List<SDUIPage> get _visiblePages {
    return widget.form.form.pages.where((p) {
      return !widget.formManager.isHidden(
        _visKey('page', p.key),
        fallback: p.hidden,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages;

    if (_currentPageIndex >= pages.length && pages.isNotEmpty) {
      final newIndex = math.max(0, pages.length - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentPageIndex = newIndex);
        _pageController.jumpToPage(newIndex);
      });
    }
    return Column(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([_pageController, widget.formManager]),
            builder: (context, _) {
              return PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPageIndex = index),
                itemCount: pages.length,
                itemBuilder: (context, pageIndex) {
                  final page = pages[pageIndex];
                  return _buildPage(page);
                },
              );
            },
          ),
        ),
        if (widget.showNavigationButtons) ...[
          const SizedBox(height: 12),
          _buildNavigationButtons(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    // Use custom navigation builder if provided
    if (widget.navigationBuilder != null) {
      return widget.navigationBuilder!(
        context,
        _currentPageIndex,
        widget.form.form.pages.length,
        _previousPage,
        _nextPage,
        _submitForm,
      );
    }

    // Default navigation buttons
    final isLastPage = _currentPageIndex == widget.form.form.pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_currentPageIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentPageIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLastPage ? _submitForm : _nextPage,
              child: Text(isLastPage ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(SDUIPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...page.sections.map((section) => _buildSection(section))],
      ),
    );
  }

  Widget _buildSection(SDUISection section) {
    final theme = Theme.of(context);

    final hidden = widget.formManager.isHidden(
      _visKey('section', section.key),
      fallback: section.hidden,
    );
    if (hidden) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (section.label != null) ...[
          Text(section.label!, style: theme.textTheme.titleMedium),
        ],
        ...section.fields.map((field) => _buildField(field)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildField(SDUIField field) {
    final autofill = field.autofill;
    final isManual =
        autofill != null &&
        autofill.enabled == true &&
        _isManualTrigger(autofill);
    final isAutofillLoading = _autofillLoading.contains(field.key);

    return SDUIFieldRenderer(
      field: field,
      formManager: widget.formManager,
      onChanged: _onFieldChanged,
      onAutofillRequested: isManual
          ? () => _triggerManualAutofill(field)
          : null,
      isAutofillEnabled: isManual
          ? () => _isManualAutofillEnabled(field)
          : null,
      isAutofillLoading: isAutofillLoading,
    );
  }
}
