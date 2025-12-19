import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart' show SDUIBaseStatefulWidget, SDUITheme;
import 'package:sdui/src/renderer/widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final baseDecoration = sduiTheme?.inputDecoration ?? InputDecoration();
    final controller = widget.formManager.getController(widget.field.key);
    final focusNode = widget.formManager.getFocusNode(widget.field.key);
    final error = widget.formManager.getError(widget.field.key);
    final label = widget.field.label;
    final hintText = widget.field.placeholder ?? label;
    final helpText = widget.field.helpText;
    return const Placeholder();
  }

  @override
  String? validateField(value) {
    return null;
  }
}
