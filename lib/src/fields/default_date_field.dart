import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/fields/selector.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIDateField extends SDUIBaseStatefulWidget {
  const SDUIDateField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIDateField> createState() => _SDUIDateFieldState();
}

class _SDUIDateFieldState extends SDUIBaseState<SDUIDateField> {
  @override
  void initState() {
    super.initState();
    final current = widget.formManager.getDateValue(widget.field.key);
    final defaultValue = widget.field.defaultValue;

    if (current == null && defaultValue != null) {
      DateTime? parsed;
      if (defaultValue is DateTime) {
        parsed = defaultValue;
      } else if (defaultValue is String) {
        parsed = DateTime.tryParse(defaultValue);
      }
      if (parsed != null) {
        widget.formManager.setDateValue(widget.field.key, parsed);
      }
    }
  }

  _handleDateSelection() async {
    DateTime? selectedDate;

    if (Platform.isIOS || Platform.isMacOS) {
      selectedDate = await _showCupertinoDatePicker();
    } else {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
    }

    if (!mounted || !context.mounted) return;
    if (selectedDate == null) return;

    widget.formManager.setDateValue(widget.field.key, selectedDate);
    widget.onChanged?.call(widget.field.key, selectedDate);
  }

  Future<DateTime?> _showCupertinoDatePicker() async {
    DateTime? selectedDate;
    final theme = Theme.of(context);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: theme.textTheme.bodySmall),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Done', style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = widget.formManager.getDateValue(widget.field.key);
    final parsed = DateFormat(
      "yyyy-MM-dd",
    ).format(selectedDate ?? DateTime.now());
    final header = widget.field.label;
    final hintText = widget.field.placeholder ?? header;
    final helpText = widget.field.helpText;

    return Selector(
      header: widget.field.label,
      helpText: helpText,
      title: switch (selectedDate == null) {
        true => null,
        _ => parsed,
      },
      hintText: hintText,
      onTap: _handleDateSelection,
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
