import 'package:flutter/material.dart';
import 'package:sdui/src/config/banner/banner_registry.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/sdui_form.dart';

class SDUIBannerField extends SDUIBaseWidget {
  const SDUIBannerField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bannerContext = _buildBannerContext(context);
    if (!bannerContext.hasMessage) return const SizedBox.shrink();

    final customBuilder = SDUIBannerRegistry.instance.builder;
    if (customBuilder != null) {
      final customWidget = customBuilder(context, bannerContext);
      if (customWidget != null) return customWidget;
    }

    return Container(
      key: ValueKey('sdui_banner_${field.key}'),
      padding: bannerContext.visuals.padding,
      decoration: BoxDecoration(
        color: bannerContext.visuals.backgroundColor,
        borderRadius: bannerContext.visuals.borderRadius,
        border: Border.all(color: bannerContext.visuals.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconBubble(bannerContext),
          SizedBox(width: bannerContext.visuals.spacing),
          Expanded(
            child: Text(
              bannerContext.message,
              style: bannerContext.messageStyle?.copyWith(
                color: bannerContext.visuals.foregroundColor,
              ),
            ),
          ),
          if (bannerContext.dismissible) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: bannerContext.dismiss,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: bannerContext.visuals.iconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  SDUIBannerContext _buildBannerContext(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final properties = field.bannerProperties;
    final variant = _resolveVariant(properties);
    final emphasis = _resolveEmphasis(properties);
    final rawMessage = properties?.message?.trim();
    final isHtml = properties?.isHtml == true;
    final message = _resolveDisplayMessage(rawMessage, isHtml);
    final visuals = _resolveVisualStyle(
      theme,
      variant: variant,
      borderRadius: sduiTheme?.borderRadius ?? BorderRadius.circular(20),
    );
    final dismissible = properties?.dismissible == true;
    final iconName = properties?.icon?.trim();

    return SDUIBannerContext(
      field: field,
      formManager: formManager,
      properties: properties,
      variant: variant,
      customVariant: properties?.customVariant?.trim(),
      emphasis: emphasis,
      customEmphasis: properties?.customEmphasis?.trim(),
      rawMessage: rawMessage,
      message: message,
      isHtml: isHtml,
      iconName: iconName,
      iconData: _resolveBannerIcon(iconName, variant),
      dismissible: dismissible,
      isDismissed: formManager.isHidden(field.key, fallback: field.hiddenField),
      dismiss: () => formManager.setHidden(field.key, true),
      show: () => formManager.setHidden(field.key, false),
      visuals: visuals,
      messageStyle: _resolveMessageStyle(theme, emphasis),
    );
  }

  Widget _buildIconBubble(SDUIBannerContext bannerContext) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bannerContext.visuals.iconBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        bannerContext.iconData,
        color: bannerContext.visuals.iconColor,
        size: 12,
      ),
    );
  }

  String _resolveVariant(SduiBannerProperties? properties) {
    final variant = properties?.variant?.trim().toLowerCase();
    if (variant == null || variant.isEmpty) return 'info';
    return variant;
  }

  String _resolveEmphasis(SduiBannerProperties? properties) {
    final emphasis = properties?.emphasis?.trim().toLowerCase();
    if (emphasis == null || emphasis.isEmpty) return 'subtle';
    return emphasis;
  }

  String _resolveDisplayMessage(String? rawMessage, bool isHtml) {
    final fallback = rawMessage ?? field.helpText ?? field.label;
    if (!isHtml) return fallback;
    return fallback
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  SDUIBannerVisualStyle _resolveVisualStyle(
    ThemeData theme, {
    required String variant,
    required BorderRadius borderRadius,
  }) {
    final palette = _resolveVariantPalette(theme, variant);

    return SDUIBannerVisualStyle(
      backgroundColor: palette.backgroundColor,
      foregroundColor: palette.foregroundColor,
      borderColor: palette.borderColor,
      iconBackgroundColor: palette.iconBackgroundColor,
      iconColor: palette.iconColor,
      borderRadius: borderRadius,
      padding: const EdgeInsets.all(12),
      spacing: 12,
    );
  }

  TextStyle _resolveMessageStyle(ThemeData theme, String emphasis) {
    final normalizedEmphasis = emphasis.trim().toLowerCase();
    final fontWeight = switch (normalizedEmphasis) {
      'high' || 'strong' || 'bold' => FontWeight.w700,
      'medium' || 'semibold' => FontWeight.w600,
      _ => FontWeight.w400,
    };

    return theme.textTheme.bodyLarge?.copyWith(
          fontWeight: fontWeight,
          height: 1.3,
        ) ??
        TextStyle(fontSize: 16, height: 1.3, fontWeight: fontWeight);
  }

  _BannerPalette _resolveVariantPalette(ThemeData theme, String variant) {
    final scheme = theme.colorScheme;
    final surface = scheme.surfaceContainerHighest;

    switch (variant.trim().toLowerCase()) {
      case 'success':
        final accent = theme.brightness == Brightness.dark
            ? const Color(0xFF6EE7B7)
            : const Color(0xFF15803D);
        return _BannerPalette(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.22),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
        );
      case 'warning':
      case 'warn':
        final accent = theme.brightness == Brightness.dark
            ? const Color(0xFFFCD34D)
            : const Color(0xFFD97706);
        return _BannerPalette(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.22),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
        );
      case 'error':
      case 'danger':
        final accent = scheme.error;
        return _BannerPalette(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.22),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
        );
      case 'neutral':
      case 'default':
        final accent = scheme.onSurfaceVariant;
        return _BannerPalette(
          backgroundColor: scheme.surfaceContainerHigh,
          foregroundColor: scheme.onSurface,
          borderColor: scheme.outline.withValues(alpha: 0.18),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
        );
      case 'custom':
      case 'info':
      default:
        final accent = scheme.primary;
        return _BannerPalette(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.14),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.18),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
        );
    }
  }

  IconData _resolveBannerIcon(String? iconName, String variant) {
    final normalized = iconName?.trim().toLowerCase();
    if (normalized != null && normalized.isNotEmpty) {
      switch (normalized) {
        case 'info':
        case 'information':
          return Icons.info_outline_rounded;
        case 'warning':
        case 'warn':
        case 'alert':
          return Icons.warning_amber_rounded;
        case 'error':
        case 'danger':
          return Icons.error_outline_rounded;
        case 'success':
        case 'check':
        case 'verified':
          return Icons.check_circle_outline_rounded;
        case 'shield':
        case 'security':
          return Icons.shield_outlined;
        case 'bank':
          return Icons.account_balance_outlined;
        case 'money':
        case 'currency':
          return Icons.attach_money_rounded;
        case 'clock':
        case 'time':
          return Icons.schedule_rounded;
        case 'close':
          return Icons.close_rounded;
      }
    }

    switch (variant.trim().toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'warning':
      case 'warn':
        return Icons.warning_amber_rounded;
      case 'error':
      case 'danger':
        return Icons.error_outline_rounded;
      case 'neutral':
        return Icons.info_outline_rounded;
      case 'info':
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _BannerPalette {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;

  const _BannerPalette({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
  });
}
