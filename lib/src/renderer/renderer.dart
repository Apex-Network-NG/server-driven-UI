import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sdui/src/renderer/field_renderer.dart';
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
  final Map<String, Object?> _resolvedDefaults = {};

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
    super.dispose();
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

    for (final field in _fieldIndex.values) {
      final resolvedDefault = _resolveDefaultValue(field);
      if (resolvedDefault != null) {
        _applyDefaultToField(field, resolvedDefault);
      }
    }

    for (final key in _fieldIndex.keys) {
      _evaluateConditionalsForChangedField(key);
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
        _setControllerValue(field.key, value?.toString());
        widget.formManager.setFieldValue(field.key, value?.toString());
        break;

      case 'number':
        final textValue = value?.toString();
        _setControllerValue(field.key, textValue);
        final parsed = textValue == null ? null : num.tryParse(textValue);
        widget.formManager.setFieldValue(
          field.key,
          parsed ?? value ?? textValue,
        );
        break;

      case 'phone':
        _setControllerValue(field.key, value?.toString());
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
          widget.formManager.updateSelectedCountry(field.key, countryValue);
          widget.formManager.setFieldValue(field.key, countryValue);
        }
        break;

      case 'options':
        final options = _toStringList(value);
        if (options.isNotEmpty) {
          widget.formManager.setSelectedOption(field.key, options);
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

  void _setControllerValue(String key, String? value) {
    if (value == null) return;
    final controller = widget.formManager.getController(key);
    if (controller.text.isEmpty) controller.text = value;
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
    widget.onFieldChanged?.call(key, value);
  }

  void _nextPage() {
    if (_currentPageIndex < widget.form.form.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
    final l = left?.toString().trim() ?? '';
    final r = right?.toString().trim() ?? '';

    switch (normalizedOp) {
      case 'is':
        return l == r;
      case 'is_not':
        return l != r;
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
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPageIndex = index),
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final page = pages[pageIndex];
              return _buildPage(page);
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
          Text(
            section.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...section.fields.map((field) => _buildField(field)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildField(SDUIField field) {
    return SDUIFieldRenderer(
      field: field,
      formManager: widget.formManager,
      onChanged: _onFieldChanged,
    );
  }
}
