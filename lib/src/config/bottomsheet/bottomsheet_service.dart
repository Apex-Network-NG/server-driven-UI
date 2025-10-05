import 'package:flutter/material.dart';
import 'package:sdui/src/theme/sdui_theme.dart';

class BottomSheetService {
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    bool isDismissible = true,
    bool enableDrag = true,
    double? elevation,
    ShapeBorder? shape,
    bool isScrollControlled = true,
    bool isBordered = false,
    bool isKeepingInset = true,
    VoidCallback? onDismiss,
  }) async {
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: duration ?? const Duration(milliseconds: 300),
      reverseDuration: reverseDuration ?? const Duration(milliseconds: 100),
    )..drive(CurveTween(curve: curve ?? const Cubic(0.1, 1, 0.2, 1)));

    final response = await showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      elevation: elevation,
      shape: shape,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      barrierColor: Colors.black54,
      useRootNavigator: false,
      transitionAnimationController: controller,
      builder: (context) {
        return SingleChildScrollView(
          child: BottomSheetWidget(
            isKeepingInset: isKeepingInset,
            isBordered: isBordered,
            child: child,
          ),
        );
      },
    );

    await controller.reverse();
    controller.dispose();
    onDismiss?.call();
    return response;
  }
}

class BottomSheetWidget extends StatelessWidget {
  final Widget child;
  final bool isKeepingInset;
  final bool isBordered;
  final bool isFullScreen;

  const BottomSheetWidget({
    super.key,
    required this.child,
    required this.isKeepingInset,
    required this.isBordered,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final sduiTheme = theme.extension<SDUITheme>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      padding: switch (isKeepingInset) {
        true => EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        _ => null,
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Center(
            child: Container(
              height: 5,
              width: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 12),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
