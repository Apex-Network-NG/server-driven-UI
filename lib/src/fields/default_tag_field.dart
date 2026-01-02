import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart' show SDUIBaseStatefulWidget, SDUITheme;
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/validator.dart';

class SDUITagField extends SDUIBaseStatefulWidget {
  const SDUITagField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() => _SDUITagFieldState();
}

class _SDUITagFieldState extends SDUIBaseState<SDUITagField> {
  final selectedTags = ValueNotifier<List<String>>([]);
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final Listenable _listenable;

  static const _listValidationRules = {
    'required',
    'required_if',
    'required_unless',
    'required_with',
    'required_with_all',
    'required_without',
    'required_without_all',
    'required_if_accepted',
    'required_if_declined',
    'min',
    'max',
    'between',
    'not_between',
    'in',
    'not_in',
  };

  @override
  void initState() {
    super.initState();
    _controller = widget.formManager.getController(widget.field.key);
    _focusNode = widget.formManager.getFocusNode(widget.field.key);
    _listenable = Listenable.merge([selectedTags, _controller, _focusNode]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTags();
    });
  }

  @override
  void dispose() {
    selectedTags.dispose();
    super.dispose();
  }

  void _initializeTags() {
    final existing = widget.formManager.getTagValues(widget.field.key);
    if (existing.isNotEmpty) {
      _setTags(existing, notify: false);
      return;
    }

    final defaultValue = widget.field.defaultValue;
    if (defaultValue != null) {
      final defaults = _normalizeTags(
        defaultValue is Iterable && defaultValue is! String
            ? defaultValue
            : [defaultValue],
      );
      if (defaults.isNotEmpty) {
        _setTags(defaults, notify: false);
        return;
      }
    }

    _setTags(const [], notify: false);
  }

  void _addTag() {
    if (widget.field.readonly) return;
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    final tags = List<String>.from(selectedTags.value);
    if (!tags.contains(value)) {
      tags.add(value);
      _setTags(tags);
    } else {
      validateField(tags);
    }
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeTag(String tag) {
    if (widget.field.readonly) return;
    final tags = List<String>.from(selectedTags.value)..remove(tag);
    _setTags(tags);
  }

  void _setTags(List<String> tags, {bool notify = true}) {
    final normalized = _normalizeTags(tags);
    selectedTags.value = normalized;
    widget.formManager.setTagValues(widget.field.key, normalized);
    if (notify) {
      widget.onChanged?.call(widget.field.key, normalized);
      validateField(normalized);
    }
  }

  List<String> _normalizeTags(Iterable<dynamic> tags) {
    final normalized = <String>[];
    for (final item in tags) {
      final tag = item.toString().trim();
      if (tag.isEmpty) continue;
      if (normalized.contains(tag)) continue;
      normalized.add(tag);
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final baseDecoration = sduiTheme?.inputDecoration ?? InputDecoration();
    final error = widget.formManager.getError(widget.field.key);
    final label = widget.field.label;
    final hintText = widget.field.placeholder ?? label;
    final helpText = widget.field.helpText;

    return ListenableBuilder(
      listenable: _listenable,
      builder: (context, _) {
        final tags = selectedTags.value;
        final isEmpty = tags.isEmpty && _controller.text.trim().isEmpty;

        return InputDecorator(
          isFocused: _focusNode.hasFocus,
          isEmpty: isEmpty,
          decoration: baseDecoration.copyWith(
            hintText: hintText,
            errorText: error,
            labelText: label,
            helperText: helpText,
            helperMaxLines: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return InputChip(
                      label: Text(tag, style: theme.textTheme.bodySmall),
                      onDeleted: widget.field.readonly
                          ? null
                          : () => _removeTag(tag),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.field.readonly,
                      textInputAction: TextInputAction.done,
                      style: theme.textTheme.bodySmall,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      onSubmitted: (_) => _addTag(),
                      decoration: const InputDecoration.collapsed(hintText: ''),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.field.readonly ? null : _addTag,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  String? validateField(value) {
    widget.formManager.clearError(widget.field.key);

    final tags = _normalizeTags(
      value is Iterable && value is! String ? value : selectedTags.value,
    );

    if (widget.field.required && tags.isEmpty) {
      final error = '${widget.field.label} is required';
      widget.formManager.addError(widget.field.key, error);
      return error;
    }

    final minLength = widget.field.constraints?.minLength;
    final maxLength = widget.field.constraints?.maxLength;
    for (final tag in tags) {
      if (minLength != null && tag.length < minLength) {
        final error = 'Minimum length is $minLength';
        widget.formManager.addError(widget.field.key, error);
        return error;
      }

      if (maxLength != null && tag.length > maxLength) {
        final error = 'Maximum length is $maxLength';
        widget.formManager.addError(widget.field.key, error);
        return error;
      }
    }

    final validations = widget.field.validations ?? [];
    if (validations.isEmpty) return null;

    final allRules = validations.map((v) => v.rule).toList();
    for (final validation in validations) {
      final rule = validation.rule.toLowerCase();
      if (_listValidationRules.contains(rule)) {
        final result = _validateRule(
          validation,
          rawValue: tags,
          allRules: allRules,
        );
        if (result != null) {
          widget.formManager.addError(widget.field.key, result);
          return result;
        }
        continue;
      }

      for (final tag in tags) {
        final result = _validateRule(
          validation,
          textValue: tag,
          allRules: allRules,
        );
        if (result != null) {
          widget.formManager.addError(widget.field.key, result);
          return result;
        }
      }
    }

    return null;
  }

  String? _validateRule(
    SDUIValidation validation, {
    List<String>? rawValue,
    String? textValue,
    required List<String> allRules,
  }) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: widget.formManager,
      textValue: textValue,
      rawValue: rawValue,
      fieldType: widget.field.type,
      allRules: allRules,
    );
  }
}
