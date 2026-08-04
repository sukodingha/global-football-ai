import 'package:flutter/widgets.dart';

/// Breakpoint enums used across the app.
enum DeviceType { mobile, tablet, desktop }

/// Responsive layout helpers.
///
/// Provides a set of breakpoint constants and helper functions to build UIs
/// that adapt to mobile, tablet, and desktop screen sizes.
class Layout {
  Layout._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  /// Returns the [DeviceType] for a given screen [width].
  static DeviceType typeFor(double width) {
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Whether the given [width] corresponds to a mobile layout.
  static bool isMobile(double width) => typeFor(width) == DeviceType.mobile;

  /// Whether the given [width] corresponds to a tablet layout.
  static bool isTablet(double width) => typeFor(width) == DeviceType.tablet;

  /// Whether the given [width] corresponds to a desktop layout.
  static bool isDesktop(double width) => typeFor(width) == DeviceType.desktop;

  /// The max content width to constrain wide screens on (desktop/tablet),
  /// keeping content readable and centered.
  static const double maxContentWidth = 1080;
}

/// A convenience widget that rebuilds its child based on the current screen
/// size, providing the resolved [DeviceType] and screen [width].
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, DeviceType type, double width)
      builder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return builder(context, Layout.typeFor(width), width);
  }
}

/// Constrains its child to [Layout.maxContentWidth] and centers it on wide
/// screens, while keeping it full-width on mobile.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width.clamp(0.0, Layout.maxContentWidth);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
