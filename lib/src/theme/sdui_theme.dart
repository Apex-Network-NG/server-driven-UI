import 'package:flutter/material.dart';

/// SDUI Theme Extension - Automatically extracts styling from project's theme
class SDUITheme extends ThemeExtension<SDUITheme> {
  final InputDecoration? inputDecoration;
  final ButtonStyle? primaryButtonStyle;
  final ButtonStyle? secondaryButtonStyle;
  final TextStyle? errorTextStyle;
  final TextStyle? labelTextStyle;
  final TextStyle? helpTextStyle;
  final TextStyle? hintTextStyle;
  final BoxDecoration? fieldContainerDecoration;
  final BoxDecoration? modalDecoration;
  final EdgeInsets? fieldPadding;
  final double? fieldSpacing;
  final BorderRadius? borderRadius;

  const SDUITheme({
    this.inputDecoration,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.errorTextStyle,
    this.labelTextStyle,
    this.helpTextStyle,
    this.hintTextStyle,
    this.fieldContainerDecoration,
    this.modalDecoration,
    this.fieldPadding,
    this.fieldSpacing,
    this.borderRadius,
  });

  /// Auto-generate SDUI theme from project's ThemeData
  factory SDUITheme.fromTheme(ThemeData theme) {
    final borderRadius = BorderRadius.circular(12);

    return SDUITheme(
      inputDecoration: InputDecoration(
        filled: true,
        fillColor: theme.brightness == Brightness.light
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
      ),
      primaryButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return theme.colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
      secondaryButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
        foregroundColor: WidgetStateProperty.all(theme.colorScheme.onSurface),
        side: WidgetStateProperty.all(
          BorderSide(color: theme.colorScheme.outline),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
      errorTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
        fontSize: 12,
      ),
      labelTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: theme.colorScheme.onSurface,
      ),
      helpTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 12,
      ),
      hintTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      fieldContainerDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      modalDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      fieldPadding: const EdgeInsets.only(bottom: 16),
      fieldSpacing: 6,
      borderRadius: borderRadius,
    );
  }

  @override
  ThemeExtension<SDUITheme> copyWith({
    InputDecoration? inputDecoration,
    ButtonStyle? primaryButtonStyle,
    ButtonStyle? secondaryButtonStyle,
    TextStyle? errorTextStyle,
    TextStyle? labelTextStyle,
    TextStyle? helpTextStyle,
    TextStyle? hintTextStyle,
    BoxDecoration? fieldContainerDecoration,
    BoxDecoration? modalDecoration,
    EdgeInsets? fieldPadding,
    double? fieldSpacing,
    BorderRadius? borderRadius,
  }) {
    return SDUITheme(
      inputDecoration: inputDecoration ?? this.inputDecoration,
      primaryButtonStyle: primaryButtonStyle ?? this.primaryButtonStyle,
      secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      helpTextStyle: helpTextStyle ?? this.helpTextStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      fieldContainerDecoration:
          fieldContainerDecoration ?? this.fieldContainerDecoration,
      modalDecoration: modalDecoration ?? this.modalDecoration,
      fieldPadding: fieldPadding ?? this.fieldPadding,
      fieldSpacing: fieldSpacing ?? this.fieldSpacing,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  ThemeExtension<SDUITheme> lerp(ThemeExtension<SDUITheme>? other, double t) {
    if (other is! SDUITheme) return this;

    return SDUITheme(
      inputDecoration: t < 0.5 ? inputDecoration : other.inputDecoration,
      primaryButtonStyle: ButtonStyle.lerp(
        primaryButtonStyle,
        other.primaryButtonStyle,
        t,
      ),
      secondaryButtonStyle: ButtonStyle.lerp(
        secondaryButtonStyle,
        other.secondaryButtonStyle,
        t,
      ),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      labelTextStyle: TextStyle.lerp(labelTextStyle, other.labelTextStyle, t),
      helpTextStyle: TextStyle.lerp(helpTextStyle, other.helpTextStyle, t),
      hintTextStyle: TextStyle.lerp(hintTextStyle, other.hintTextStyle, t),
      fieldContainerDecoration: BoxDecoration.lerp(
        fieldContainerDecoration,
        other.fieldContainerDecoration,
        t,
      ),
      modalDecoration: BoxDecoration.lerp(
        modalDecoration,
        other.modalDecoration,
        t,
      ),
      fieldPadding: EdgeInsets.lerp(fieldPadding, other.fieldPadding, t),
      fieldSpacing: t < 0.5 ? fieldSpacing : other.fieldSpacing,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t),
    );
  }
}
