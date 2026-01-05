import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/fields/field_modal.dart';
import 'package:sdui/src/fields/selector.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIOptionsField extends SDUIBaseStatefulWidget {
  const SDUIOptionsField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() =>
      _SDUIOptionsFieldState();
}

class _SDUIOptionsFieldState extends SDUIBaseState<SDUIOptionsField> {
  @override
  Widget build(BuildContext context) {
    final properties = widget.field.optionProperties?.type;
    final isRadio = properties == 'radio';
    if (isRadio) {
      return _BuildRadioOptions(widget: widget);
    } else {
      return _BuildDropSelection(widget: widget);
    }
  }

  @override
  String? validateField(value) {
    return null;
  }
}

class _BuildDropSelection extends StatefulWidget {
  final SDUIOptionsField widget;

  const _BuildDropSelection({required this.widget});

  @override
  State<_BuildDropSelection> createState() => _BuildDropSelectionState();
}

class _BuildDropSelectionState extends State<_BuildDropSelection> {
  @override
  Widget build(BuildContext context) {
    final field = widget.widget.field;
    final hintText = field.placeholder ?? field.label;
    final headerText = field.label;
    final formManager = widget.widget.formManager;

    List<String>? selectedValue = formManager.getSelectedOption(field.key);
    final optionsData = field.optionProperties?.data ?? [];
    final optionsType = field.optionProperties?.type;
    final defaultValue = field.defaultValue;

    if ((selectedValue == null || selectedValue.isEmpty) &&
        defaultValue != null) {
      final defaults = defaultValue is List
          ? defaultValue.map((e) => e.toString()).toList()
          : [defaultValue.toString()];
      formManager.setSelectedOption(field.key, defaults);
      selectedValue = defaults;
    }

    final selectedOption = optionsData
        .where((option) => selectedValue?.contains(option.key) ?? false)
        .toList();
    final isMultiSelect = optionsType == 'multi-select';
    final theme = Theme.of(context);

    return Selector(
      hintText: hintText,
      header: headerText,
      titleWidget: isMultiSelect
          ? switch (selectedOption.isEmpty) {
              true => null,
              _ => SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: selectedOption.map((e) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: theme.colorScheme.onPrimary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Center(
                          child: Text(
                            e.value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            }
          : null,
      title: isMultiSelect ? null : selectedOption.firstOrNull?.value,
      errorText: formManager.getError(field.key),
      onTap: () async {
        final selectedOptions = formManager.getSelectedOption(field.key);
        final result = await BottomSheetService.showBottomSheet(
          context: context,
          child: BaseSDUIModals(
            selectedOptionsKeys: selectedOptions,
            headerText: headerText,
            field: field,
          ),
        );

        if (!context.mounted) return;
        if (result != null) {
          final options = List<String>.from(result.map((e) => e.key));
          formManager.setSelectedOption(field.key, options);
          widget.widget.onChanged?.call(field.key, options);
          if (mounted) setState(() {});
          for (var element in options) {
            _validateField(element);
          }
        }
      },
    );
  }

  void _validateField(String? value) {
    final formManager = widget.widget.formManager;
    final field = widget.widget.field;
    formManager.clearError(field.key);

    if (field.required && (value == null || value.isEmpty)) {
      final error = '${field.label} is required';
      formManager.addError(field.key, error);
    }

    if (value != null) {
      final allowedValues =
          field.optionProperties?.data.map((e) => e.key).toList() ?? [];
      if (!allowedValues.contains(value)) {
        final error =
            'The selected ${field.label.toLowerCase()} is not supported';
        formManager.addError(field.key, error);
      }
    }

    for (final validation in field.validations ?? []) {
      final result = _validateRule(validation, value);
      if (result != null) {
        formManager.addError(field.key, result);
      }
    }
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: widget.widget.formManager,
      textValue: value,
      fieldType: widget.widget.field.type,
    );
  }
}

class _BuildRadioOptions extends StatefulWidget {
  const _BuildRadioOptions({required this.widget});

  final SDUIOptionsField widget;

  @override
  State<_BuildRadioOptions> createState() => _BuildRadioOptionsState();
}

class _BuildRadioOptionsState extends State<_BuildRadioOptions> {
  @override
  Widget build(BuildContext context) {
    final optionsData = widget.widget.field.optionProperties?.data ?? [];
    final headerText = widget.widget.field.label;
    final theme = Theme.of(context);
    List<String>? value = widget.widget.formManager.getSelectedOption(
      widget.widget.field.key,
    );
    final formManager = widget.widget.formManager;
    final defaultValue = widget.widget.field.defaultValue;

    if ((value == null || value.isEmpty) && defaultValue != null) {
      final defaults = defaultValue is List
          ? defaultValue.map((e) => e.toString()).toList()
          : [defaultValue.toString()];
      formManager.setSelectedOption(widget.widget.field.key, defaults);
      value = defaults;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        RadioGroup<String>(
          groupValue: value?.first,
          onChanged: (value) {
            if (value == null) return;
            final fieldKey = widget.widget.field.key;
            formManager.setSelectedOption(fieldKey, [value]);
            widget.widget.onChanged?.call(fieldKey, value);
            _validateField(value);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final itemWidth = (maxWidth - 12) / 2;
              final formManager = widget.widget.formManager;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(optionsData.length, (index) {
                  final option = optionsData[index];
                  final selected = formManager.getSelectedOption(
                    widget.widget.field.key,
                  );
                  final isSelected = selected?.firstOrNull == option.key;

                  return InkWell(
                    onTap: () {
                      final fieldKey = widget.widget.field.key;
                      formManager.setSelectedOption(fieldKey, [option.key]);
                      widget.widget.onChanged?.call(fieldKey, option.key);
                      _validateField(option.key);
                    },
                    child: Container(
                      width: itemWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: switch (isSelected) {
                          true => Border.all(color: theme.colorScheme.primary),
                          _ => null,
                        },
                        color: theme.colorScheme.onPrimary,
                      ),
                      child: Row(
                        children: [
                          Radio<String>(value: option.key),
                          Text(
                            option.value,
                            maxLines: 1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: switch (isSelected) {
                                true => theme.colorScheme.primary,
                                _ => theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  void _validateField(String? value) {
    final formManager = widget.widget.formManager;
    final field = widget.widget.field;
    formManager.clearError(field.key);

    if (field.required && (value == null || value.isEmpty)) {
      final error = '${field.label} is required';
      formManager.addError(field.key, error);
    }

    if (value != null) {
      final allowedValues =
          field.optionProperties?.data.map((e) => e.key).toList() ?? [];
      if (!allowedValues.contains(value)) {
        final error =
            'The selected ${field.label.toLowerCase()} is not supported';
        formManager.addError(field.key, error);
      }
    }
  }
}
