import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdui/src/config/banner/banner_registry.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';
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
    final borderRadius = sduiTheme?.borderRadius ?? BorderRadius.circular(12);
    final visuals = _resolveVisualStyle(
      context,
      theme,
      properties: properties,
      variant: variant,
      emphasis: emphasis,
      rawMessage: rawMessage,
      message: message,
      isHtml: isHtml,
      iconName: properties?.icon?.trim(),
      dismissible: properties?.dismissible == true,
      borderRadius: borderRadius,
    );
    final dismissible = properties?.dismissible == true;
    final iconName = properties?.icon?.trim();
    final iconUrl = iconName?.isValidUrl == true ? iconName : null;
    final resolvedIcon = _resolveBannerIcon(iconName, variant);

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
      iconData: resolvedIcon.iconData ?? _resolveVariantIcon(variant),
      iconUrl: iconUrl,
      isSvgIcon: resolvedIcon.isSvg,
      resolvedIcon: resolvedIcon,
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
      child: Center(child: _buildResolvedIcon(bannerContext)),
    );
  }

  Widget _buildResolvedIcon(SDUIBannerContext bannerContext) {
    final iconUrl = bannerContext.iconUrl;
    if (iconUrl != null) {
      if (bannerContext.isSvgIcon) {
        return SvgPicture.network(
          iconUrl,
          key: ValueKey('sdui_banner_icon_svg_${field.key}'),
          width: 12,
          height: 12,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => _buildFallbackIcon(bannerContext),
          errorBuilder: (_, __, ___) => _buildFallbackIcon(bannerContext),
        );
      }

      return Image.network(
        iconUrl,
        key: ValueKey('sdui_banner_icon_image_${field.key}'),
        width: 12,
        height: 12,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(bannerContext),
      );
    }

    return _buildFallbackIcon(bannerContext);
  }

  Widget _buildFallbackIcon(SDUIBannerContext bannerContext) {
    return Icon(
      bannerContext.iconData,
      color: bannerContext.visuals.iconColor,
      size: 12,
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
    BuildContext context,
    ThemeData theme, {
    required SduiBannerProperties? properties,
    required String variant,
    required String emphasis,
    required String? rawMessage,
    required String message,
    required bool isHtml,
    required String? iconName,
    required bool dismissible,
    required BorderRadius borderRadius,
  }) {
    final iconUrl = iconName?.isValidUrl == true ? iconName : null;
    final defaultVisuals = _resolveVariantPalette(
      theme,
      variant,
      borderRadius: borderRadius,
    );
    final customBuilder = SDUIBannerPaletteRegistry.instance.builder;
    if (customBuilder != null) {
      final customVisuals = customBuilder(
        context,
        SDUIBannerPaletteContext(
          field: field,
          formManager: formManager,
          properties: properties,
          variant: variant,
          customVariant: properties?.customVariant?.trim(),
          emphasis: emphasis,
          customEmphasis: properties?.customEmphasis?.trim(),
          iconName: iconName,
          iconUrl: iconUrl,
          isSvgIcon: _isSvgUrl(iconUrl),
          dismissible: dismissible,
          isHtml: isHtml,
          rawMessage: rawMessage,
          message: message,
          borderRadius: borderRadius,
          defaultVisuals: defaultVisuals,
        ),
      );
      if (customVisuals != null) return customVisuals;
    }

    return defaultVisuals;
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

  SDUIBannerVisualStyle _resolveVariantPalette(
    ThemeData theme,
    String variant, {
    required BorderRadius borderRadius,
  }) {
    final scheme = theme.colorScheme;
    final surface = scheme.surfaceContainerHighest;

    switch (variant.trim().toLowerCase()) {
      case 'success':
        final accent = theme.brightness == Brightness.dark
            ? const Color(0xFF6EE7B7)
            : const Color(0xFF15803D);
        return SDUIBannerVisualStyle(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.22),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(12),
          spacing: 12,
        );
      case 'warning':
      case 'warn':
        final accent = theme.brightness == Brightness.dark
            ? const Color(0xFFFCD34D)
            : const Color(0xFFD97706);
        return SDUIBannerVisualStyle(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.22),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(12),
          spacing: 12,
        );
      case 'error':
      case 'danger':
        final accent = scheme.error;
        return SDUIBannerVisualStyle(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.22),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(12),
          spacing: 12,
        );
      case 'neutral':
      case 'default':
        final accent = scheme.onSurfaceVariant;
        return SDUIBannerVisualStyle(
          backgroundColor: scheme.surfaceContainerHigh,
          foregroundColor: scheme.onSurface,
          borderColor: scheme.outline.withValues(alpha: 0.18),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(12),
          spacing: 12,
        );
      case 'custom':
      case 'info':
      default:
        final accent = scheme.primary;
        return SDUIBannerVisualStyle(
          backgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.14),
            surface,
          ),
          foregroundColor: scheme.onSurface,
          borderColor: accent.withValues(alpha: 0.18),
          iconBackgroundColor: scheme.surface,
          iconColor: accent,
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(12),
          spacing: 12,
        );
    }
  }

  SDUIBannerResolvedIcon _resolveBannerIcon(String? iconName, String variant) {
    final normalized = iconName?.trim().toLowerCase();
    if (iconName?.isValidUrl == true) {
      return SDUIBannerResolvedIcon(
        rawValue: iconName,
        iconData: _resolveVariantIcon(variant),
        networkUrl: iconName,
        isSvg: _isSvgUrl(iconName),
      );
    }

    if (normalized != null && normalized.isNotEmpty) {
      final matchedIcon = _matchTextIcon(normalized);
      if (matchedIcon != null) {
        return SDUIBannerResolvedIcon(
          rawValue: iconName,
          iconData: matchedIcon,
          networkUrl: null,
          isSvg: false,
        );
      }
    }

    return SDUIBannerResolvedIcon(
      rawValue: iconName,
      iconData: _resolveVariantIcon(variant),
      networkUrl: null,
      isSvg: false,
    );
  }

  IconData? _matchTextIcon(String normalized) {
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

    final genericIcon = normalized.sduiIconData;
    if (genericIcon == Icons.settings) return null;
    return genericIcon;
  }

  IconData _resolveVariantIcon(String variant) {
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

  bool _isSvgUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    final path = (uri?.path ?? value).toLowerCase();
    return path.endsWith('.svg');
  }
}
