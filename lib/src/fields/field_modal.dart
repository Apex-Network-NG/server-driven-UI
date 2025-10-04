import 'package:flutter/material.dart';
import 'package:sdui/src/fields/country_picker_sheet.dart';
import 'package:sdui/src/util/sdui_form.dart';

class BaseSDUIModals extends StatefulWidget {
  final List<String>? selectedOptionsKeys;
  final String? headerText;
  final SDUIField? field;

  const BaseSDUIModals({
    super.key,
    this.selectedOptionsKeys,
    this.headerText,
    this.field,
  });

  @override
  State<BaseSDUIModals> createState() => _BaseSDUIModalsState();
}

class _BaseSDUIModalsState extends State<BaseSDUIModals> {
  final selectedOptions = ValueNotifier<List<SDUIOption>>([]);

  @override
  void initState() {
    super.initState();
    if (widget.selectedOptionsKeys != null) {
      final options = widget.field?.optionProperties?.data ?? [];
      for (var key in widget.selectedOptionsKeys!) {
        final option = options.where((option) => option.key == key);
        if (option.isNotEmpty) {
          selectedOptions.value.add(option.first);
        }
      }
    }
  }

  bool _validation(SDUIOption option) {
    final theme = Theme.of(context);
    final validations = widget.field?.validations;
    for (var validation in validations ?? []) {
      final result = _validateRule(validation, option.key);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result, style: theme.textTheme.bodySmall)),
        );
        return false;
      }
    }
    return true;
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    switch (validation.rule) {
      case 'in':
        final params = validation.params;
        if (params.isNotEmpty) {
          final allowedValues = params.map((e) => e.toString()).toList();
          if (!allowedValues.contains(value)) {
            return validation.message ?? 'The selected value is not allowed';
          }
        }
        return null;

      default:
        return null;
    }
  }

  _selectOption(SDUIOption option) {
    final optionsType = widget.field?.optionProperties?.type;
    final optionProperties = widget.field?.optionProperties;
    final validation = _validation(option);
    if (!validation) return;

    if (optionsType == 'multi-select') {
      final maxSelect = optionProperties?.maxSelect;
      if (maxSelect != null && selectedOptions.value.length > maxSelect) return;

      final check = selectedOptions.value.any((x) => x.key == option.key);
      if (check) {
        final options = List<SDUIOption>.from(selectedOptions.value);
        options.removeWhere((x) => x.key == option.key);
        selectedOptions.value = options;
      } else {
        final options = List<SDUIOption>.from(selectedOptions.value);
        options.add(option);
        selectedOptions.value = options;
      }
    } else {
      Navigator.pop(context, [option]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.field?.optionProperties?.data ?? [];
    final optionsType = widget.field?.optionProperties?.type;
    final isMultiSelect = optionsType == 'multi-select';
    final theme = Theme.of(context);

    return SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([selectedOptions]),
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Topbar(title: widget.headerText ?? ''),
                SingleChildScrollView(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([selectedOptions]),
                    builder: (context, _) {
                      return Column(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(options.length, (index) {
                          final option = options[index];
                          final isSelected = selectedOptions.value.any(
                            (x) => x.key == option.key,
                          );
                          return InkWell(
                            onTap: () => _selectOption(option),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option.value,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 24,
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                if (isMultiSelect) ...[
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                    ),
                    onPressed: () {
                      final initList = widget.selectedOptionsKeys ?? [];
                      final hasValue = initList.isNotEmpty;

                      if (hasValue && selectedOptions.value.isEmpty) {
                        Navigator.pop(context, selectedOptions.value);
                        return;
                      }
                      if (selectedOptions.value.isEmpty) return;
                      Navigator.pop(context, selectedOptions.value);
                    },
                    child: Text('Select'),
                  ),
                ],
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
