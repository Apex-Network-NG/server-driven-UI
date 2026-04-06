import 'package:flutter/material.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUIBannerResolvedIcon {
  final String? rawValue;
  final IconData? iconData;
  final String? networkUrl;
  final bool isSvg;

  const SDUIBannerResolvedIcon({
    required this.rawValue,
    required this.iconData,
    required this.networkUrl,
    required this.isSvg,
  });

  bool get hasIcon => iconData != null || networkUrl != null;
  bool get hasIconData => iconData != null;
  bool get hasNetworkIcon => networkUrl != null;
}

class SDUIBannerVisualStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const SDUIBannerVisualStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.borderRadius,
    required this.padding,
    required this.spacing,
  });
}

class SDUIBannerContext {
  final SDUIField field;
  final FormManager formManager;
  final SduiBannerProperties? properties;
  final String variant;
  final String? customVariant;
  final String emphasis;
  final String? customEmphasis;
  final String? rawMessage;
  final String message;
  final bool isHtml;
  final String? iconName;
  final IconData iconData;
  final String? iconUrl;
  final bool isSvgIcon;
  final SDUIBannerResolvedIcon resolvedIcon;
  final bool dismissible;
  final bool isDismissed;
  final VoidCallback dismiss;
  final VoidCallback show;
  final SDUIBannerVisualStyle visuals;
  final TextStyle? messageStyle;

  const SDUIBannerContext({
    required this.field,
    required this.formManager,
    required this.properties,
    required this.variant,
    required this.customVariant,
    required this.emphasis,
    required this.customEmphasis,
    required this.rawMessage,
    required this.message,
    required this.isHtml,
    required this.iconName,
    required this.iconData,
    required this.iconUrl,
    required this.isSvgIcon,
    required this.resolvedIcon,
    required this.dismissible,
    required this.isDismissed,
    required this.dismiss,
    required this.show,
    required this.visuals,
    required this.messageStyle,
  });

  bool get hasMessage => message.trim().isNotEmpty;
}

class SDUIBannerPaletteContext {
  final SDUIField field;
  final FormManager formManager;
  final SduiBannerProperties? properties;
  final String variant;
  final String? customVariant;
  final String emphasis;
  final String? customEmphasis;
  final String? iconName;
  final String? iconUrl;
  final bool isSvgIcon;
  final bool dismissible;
  final bool isHtml;
  final String? rawMessage;
  final String message;
  final BorderRadius borderRadius;
  final SDUIBannerVisualStyle defaultVisuals;

  const SDUIBannerPaletteContext({
    required this.field,
    required this.formManager,
    required this.properties,
    required this.variant,
    required this.customVariant,
    required this.emphasis,
    required this.customEmphasis,
    required this.iconName,
    required this.iconUrl,
    required this.isSvgIcon,
    required this.dismissible,
    required this.isHtml,
    required this.rawMessage,
    required this.message,
    required this.borderRadius,
    required this.defaultVisuals,
  });
}

typedef SDUIBannerBuilder =
    Widget? Function(BuildContext context, SDUIBannerContext bannerContext);

typedef SDUIBannerPaletteBuilder =
    SDUIBannerVisualStyle? Function(
      BuildContext context,
      SDUIBannerPaletteContext bannerPaletteContext,
    );

class SDUIBannerRegistry {
  SDUIBannerRegistry._();
  static final instance = SDUIBannerRegistry._();

  SDUIBannerBuilder? _builder;

  bool register(SDUIBannerBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUIBannerBuilder? get builder => _builder;

  bool get hasBuilder => _builder != null;

  bool unregister() {
    final existed = _builder != null;
    _builder = null;
    return existed;
  }

  void clear() {
    _builder = null;
  }
}

class SDUIBannerPaletteRegistry {
  SDUIBannerPaletteRegistry._();
  static final instance = SDUIBannerPaletteRegistry._();

  SDUIBannerPaletteBuilder? _builder;

  bool register(SDUIBannerPaletteBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUIBannerPaletteBuilder? get builder => _builder;

  bool get hasBuilder => _builder != null;

  bool unregister() {
    final existed = _builder != null;
    _builder = null;
    return existed;
  }

  void clear() {
    _builder = null;
  }
}
