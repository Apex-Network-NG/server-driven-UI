import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:sdui/src/theme/sdui_theme.dart';

class Selector extends StatefulWidget {
  final String? header;
  final String? helpText;
  final String? title;
  final String hintText;
  final VoidCallback onTap;
  final Widget? suffix;
  final bool? disabled;
  final Widget? titleWidget;
  final Color? backgroundDisabledColor;
  final String? errorText;
  final Widget? headerWidget;

  const Selector({
    super.key,
    this.header,
    this.title,
    required this.hintText,
    required this.onTap,
    this.suffix,
    this.disabled,
    this.titleWidget,
    this.backgroundDisabledColor,
    this.errorText,
    this.headerWidget,
    this.helpText,
  });

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final errorText = widget.errorText;
    final hasError = errorText != null && errorText.trim().isNotEmpty;
    final helpText = widget.helpText;
    final hasHelpText = helpText != null && helpText.trim().isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) ...[
          Text(
            widget.header!,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
        ],
        InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sduiTheme?.fieldContainerDecoration?.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 1,
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.titleWidget != null) ...[
                  widget.titleWidget!,
                ] else ...[
                  Expanded(
                    child: switch (widget.title != null) {
                      true => Text(
                        widget.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall,
                      ),
                      _ => Text(
                        widget.hintText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall,
                      ),
                    },
                  ),
                ],
                const SizedBox(width: 8),
                switch (widget.suffix != null) {
                  true => widget.suffix!,
                  _ => Transform.rotate(
                    angle: -math.pi / 2,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                },
              ],
            ),
          ),
        ),
        if (hasHelpText) ...[
          const SizedBox(height: 6),
          Text(
            helpText,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall,
          ),
        ],
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
