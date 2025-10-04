import 'package:flutter/material.dart';
import 'package:sdui/src/renderer/widget.dart';

class SDUIUnknownField extends SDUIBaseWidget {
  const SDUIUnknownField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  String? validateField(value) {
    return null;
  }
}
