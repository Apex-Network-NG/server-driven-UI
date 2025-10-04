import 'package:flutter/material.dart';

class Checklist extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  const Checklist({super.key, required this.enabled, required this.onTap});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedContainer(
        height: 20,
        width: 20,
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: switch (widget.enabled) {
            true => theme.colorScheme.primary,
            _ => theme.colorScheme.surface,
          },
          borderRadius: BorderRadius.circular(4),
          border: switch (widget.enabled) {
            true => null,
            _ => Border.all(width: 1, color: theme.colorScheme.outline),
          },
        ),
        child: switch (widget.enabled) {
          true => const Icon(Icons.check, size: 16, color: Colors.white),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
