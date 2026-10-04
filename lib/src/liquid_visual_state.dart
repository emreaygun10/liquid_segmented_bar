import 'package:flutter/widgets.dart';

/// Information passed to custom visual builders so they can react to the
/// segment state (e.g. tint an SVG with [color] when selected).
@immutable
class LiquidVisualState {
  const LiquidVisualState({
    required this.selected,
    required this.size,
    required this.color,
    required this.accent,
  });

  /// Whether the segment is currently selected.
  final bool selected;

  /// Box size the visual should fit in (`imageSize` of the bar).
  final double size;

  /// Suggested tint: [accent] when selected, a dimmed foreground otherwise.
  final Color color;

  /// The bar's accent color.
  final Color accent;
}

/// Builds a widget for a [LiquidSegment.asset] value (asset path or URL).
///
/// The package has no SVG dependency on purpose: add `flutter_svg` (or any
/// renderer) to your app and plug it in here.
typedef LiquidAssetBuilder = Widget Function(
  BuildContext context,
  String source,
  LiquidVisualState state,
);

/// Builds a fully custom visual for a single segment.
typedef LiquidVisualBuilder = Widget Function(
  BuildContext context,
  LiquidVisualState state,
);
