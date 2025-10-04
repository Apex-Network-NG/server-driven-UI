import 'package:flutter/material.dart';
import 'package:sdui/src/fields/country_picker_sheet.dart';

class FieldInfoModal extends StatelessWidget {
  final String text;
  const FieldInfoModal({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Topbar(title: "Info"),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
