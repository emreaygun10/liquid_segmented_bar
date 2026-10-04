import 'package:flutter/widgets.dart';

import 'liquid_visual_state.dart';

/// A single option inside a `LiquidSegmentedBar`.
///
/// The visual is resolved in this order:
/// [visualBuilder] → [visual] → [asset] → [icon].
/// [icon] is also the fallback when an [asset] fails to load.
@immutable
class LiquidSegment<T> {
  const LiquidSegment({
    required this.value,
    required this.label,
    this.icon,
    this.asset,
    this.visual,
    this.visualBuilder,
  });

  /// Value reported to `onChanged` when this segment is tapped.
  final T value;

  /// Text shown under the visual. Always used as the semantics label, even
  /// when hidden by `LiquidLabelBehavior`.
  final String label;

  /// Material/Cupertino/custom icon font glyph.
  final IconData? icon;

  /// Image asset path (`assets/smoke.png`) or URL (`https://…/smoke.png`).
  ///
  /// Without an asset builder, paths use `Image.asset` and `http(s)` URLs use
  /// `Image.network`. **Recommended formats: PNG (with transparency) or
  /// SVG.** Other formats still render, with a one-time debug warning.
  /// SVG needs an asset builder (`LiquidSegmentedBar.assetBuilder` or
  /// `LiquidSegmentedBar.defaultAssetBuilder`), e.g. with `flutter_svg`.
  final String? asset;

  /// Any widget: `SvgPicture`, `Lottie`, `CachedNetworkImage`, `Text('🔥')`…
  /// Laid out in an `imageSize` × `imageSize` box.
  final Widget? visual;

  /// Like [visual], but rebuilt with the segment state, so the widget can
  /// change when selected (tint, animation, different image…).
  final LiquidVisualBuilder? visualBuilder;

  /// Whether this segment has something to show besides its label.
  bool get hasVisual =>
      visualBuilder != null || visual != null || asset != null || icon != null;
}
