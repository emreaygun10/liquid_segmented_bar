import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_label_behavior.dart';
import 'liquid_segment.dart';
import 'liquid_visual_state.dart';

/// Asset paths that already produced a debug warning (warn once per path).
final Set<String> _warnedAssets = <String>{};

/// iOS "liquid glass" style segmented control: a blurred glass capsule with
/// a glass bubble that slides to the selected item. All segments share the
/// same width, so it works best with 2–6 options.
///
/// Height is calculated from the content (visual size, font size, text
/// scale) unless [height] is given, and is always clamped between
/// [minHeight] and [maxHeight]. If the parent gives less room than needed,
/// segment content scales down instead of overflowing; long labels are
/// ellipsized.
///
/// ```dart
/// LiquidSegmentedBar<Side>(
///   selected: side,
///   onChanged: (s) => setState(() => side = s),
///   segments: const [
///     LiquidSegment(value: Side.t, label: 'T'),
///     LiquidSegment(value: Side.ct, label: 'CT'),
///   ],
/// )
/// ```
class LiquidSegmentedBar<T> extends StatelessWidget {
  const LiquidSegmentedBar({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.accent,
    this.foregroundColor = Colors.white,
    this.height,
    this.minHeight = 44,
    this.maxHeight = 120,
    this.labelBehavior = LiquidLabelBehavior.always,
    this.iconSize = 20,
    this.imageSize = 22,
    this.labelFontSize,
    this.selectedLabelFontSize,
    this.labelStyle,
    this.labelMaxLines = 1,
    this.labelSpacing = 3,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 8,
    ),
    this.assetBuilder,
    this.blurSigma = 20,
    this.haptics = true,
    this.animationDuration = const Duration(milliseconds: 380),
    this.animationCurve = Curves.easeOutBack,
  }) : assert(segments.length > 0, 'segments must not be empty'),
       assert(minHeight > 0, 'minHeight must be > 0'),
       assert(maxHeight >= minHeight, 'maxHeight must be >= minHeight'),
       assert(height == null || height > 0, 'height must be > 0'),
       assert(iconSize > 0 && imageSize > 0, 'visual sizes must be > 0'),
       assert(labelFontSize == null || labelFontSize > 0),
       assert(selectedLabelFontSize == null || selectedLabelFontSize > 0),
       assert(labelMaxLines >= 1, 'labelMaxLines must be >= 1'),
       assert(labelSpacing >= 0 && blurSigma >= 0);

  final List<LiquidSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Bubble / selected icon color. Defaults to `ColorScheme.primary`.
  final Color? accent;

  /// Label & icon color. Unselected items use it with reduced opacity.
  final Color foregroundColor;

  /// Fixed height. When null, height is calculated from the content.
  /// Either way the result is clamped to [minHeight]..[maxHeight].
  final double? height;

  /// Lower bound of the bar height (44 = minimum recommended touch target).
  final double minHeight;

  /// Upper bound of the bar height.
  final double maxHeight;

  /// When labels are visible. See [LiquidLabelBehavior].
  final LiquidLabelBehavior labelBehavior;

  /// Size of [LiquidSegment.icon].
  final double iconSize;

  /// Size of [LiquidSegment.asset] and [LiquidSegment.visual].
  final double imageSize;

  /// Label font size. Defaults to 10.5 with a visual, 13 without.
  final double? labelFontSize;

  /// Font size of the selected label. Defaults to [labelFontSize].
  final double? selectedLabelFontSize;

  /// Base label style. Defaults to `TextTheme.labelSmall`. Its color,
  /// weight and size are overridden by the parameters above.
  final TextStyle? labelStyle;

  /// Maximum label lines before ellipsis.
  final int labelMaxLines;

  /// Gap between visual and label.
  final double labelSpacing;

  /// Inner padding of each segment.
  final EdgeInsets contentPadding;

  /// Renderer for [LiquidSegment.asset] on this bar (e.g. SVG via
  /// flutter_svg). Falls back to [defaultAssetBuilder], then to
  /// `Image.asset` / `Image.network`.
  final LiquidAssetBuilder? assetBuilder;

  /// Backdrop blur strength of the glass capsule.
  final double blurSigma;

  /// Plays a selection click on tap.
  final bool haptics;

  /// Duration and curve of the sliding bubble.
  final Duration animationDuration;
  final Curve animationCurve;

  /// App-wide asset renderer, used when [assetBuilder] is null. Set it once
  /// (e.g. in `main()`) to enable SVG everywhere:
  ///
  /// ```dart
  /// LiquidSegmentedBar.defaultAssetBuilder = (context, source, state) =>
  ///     source.endsWith('.svg')
  ///         ? SvgPicture.asset(source, width: state.size, height: state.size)
  ///         : Image.asset(source, height: state.size);
  /// ```
  static LiquidAssetBuilder? defaultAssetBuilder;

  static const double _inset = 4;
  static const double _lineHeight = 1.3;
  static const _radius = BorderRadius.all(Radius.circular(999));

  double get _visualSlot => math.max(iconSize, imageSize);

  double _fontSizeFor(LiquidSegment<T> s, bool isSelected) {
    final base = labelFontSize ?? (s.hasVisual ? 10.5 : 13);
    return isSelected ? (selectedLabelFontSize ?? base) : base;
  }

  bool _showsLabel(LiquidSegment<T> s, bool isSelected) {
    if (!s.hasVisual) return true;
    return switch (labelBehavior) {
      LiquidLabelBehavior.always => true,
      LiquidLabelBehavior.selectedOnly => isSelected,
      LiquidLabelBehavior.never => false,
    };
  }

  /// Tallest segment content, assuming every segment could be selected.
  double _autoHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    var tallest = 0.0;
    for (final s in segments) {
      final visual = s.hasVisual ? _visualSlot : 0.0;
      final labelShown = _showsLabel(s, true);
      final fontSize = math.max(_fontSizeFor(s, true), _fontSizeFor(s, false));
      final label =
          labelShown
              ? scaler.scale(fontSize) * _lineHeight * labelMaxLines
              : 0.0;
      final gap = s.hasVisual && labelShown ? labelSpacing : 0.0;
      tallest = math.max(tallest, visual + gap + label);
    }
    return tallest + contentPadding.vertical + _inset * 2;
  }

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    final count = segments.length;
    final found = segments.indexWhere((s) => s.value == selected);
    final index = found < 0 ? 0 : found;
    final x = count <= 1 ? 0.0 : -1 + 2 * index / (count - 1);
    final resolvedHeight = (height ?? _autoHeight(context)).clamp(
      minHeight,
      maxHeight,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            height: resolvedHeight,
            padding: const EdgeInsets.all(_inset),
            decoration: BoxDecoration(
              borderRadius: _radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.09),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: Alignment(x, 0),
                  duration: animationDuration,
                  curve: animationCurve,
                  child: FractionallySizedBox(
                    widthFactor: 1 / count,
                    heightFactor: 1,
                    child: _GlassBubble(accent: color),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < count; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == index,
                          label: segments[i].label,
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (i == index) return;
                              if (haptics) HapticFeedback.selectionClick();
                              onChanged(segments[i].value);
                            },
                            child: _buildSegment(context, i, i == index, color),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    int i,
    bool isSelected,
    Color accent,
  ) {
    final segment = segments[i];
    final fg =
        isSelected ? foregroundColor : foregroundColor.withValues(alpha: 0.55);
    final showLabel = _showsLabel(segment, isSelected);

    final label = Text(
      segment.label,
      maxLines: labelMaxLines,
      softWrap: labelMaxLines > 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (segment.hasVisual)
          SizedBox(
            height: _visualSlot,
            child: AnimatedOpacity(
              opacity: isSelected ? 1 : 0.6,
              duration: const Duration(milliseconds: 220),
              child: Center(
                child: _buildVisual(context, segment, isSelected, accent, fg),
              ),
            ),
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder:
              (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  // ignore: deprecated_member_use
                  axisAlignment: -1,
                  child: child,
                ),
              ),
          child:
              showLabel
                  ? Padding(
                    key: const ValueKey('label'),
                    padding: EdgeInsets.only(
                      top: segment.hasVisual ? labelSpacing : 0,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: (labelStyle ??
                              Theme.of(context).textTheme.labelSmall ??
                              const TextStyle())
                          .copyWith(
                            fontSize: _fontSizeFor(segment, isSelected),
                            height: _lineHeight,
                            color: fg,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                      child: label,
                    ),
                  )
                  : const SizedBox.shrink(key: ValueKey('none')),
        ),
      ],
    );

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Padding(
        padding: contentPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.hasBoundedWidth) return Center(child: column);
            // Width is pinned to the segment so labels ellipsize; if the
            // content is still too tall/wide it scales down, never overflows.
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: constraints.maxWidth, child: column),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisual(
    BuildContext context,
    LiquidSegment<T> segment,
    bool isSelected,
    Color accent,
    Color fg,
  ) {
    final fallback =
        segment.icon == null
            ? const SizedBox.shrink()
            : Icon(
              segment.icon,
              size: iconSize,
              color: isSelected ? accent : fg,
            );
    final state = LiquidVisualState(
      selected: isSelected,
      size: imageSize,
      color: isSelected ? accent : fg,
      accent: accent,
    );

    final visualBuilder = segment.visualBuilder;
    if (visualBuilder != null) {
      return SizedBox.square(
        dimension: imageSize,
        child: visualBuilder(context, state),
      );
    }

    if (segment.visual != null) {
      return SizedBox.square(dimension: imageSize, child: segment.visual);
    }

    final source = segment.asset;
    if (source != null) {
      final builder = assetBuilder ?? defaultAssetBuilder;
      assert(_debugCheckAsset(source, hasBuilder: builder != null));
      if (builder != null) {
        return SizedBox.square(
          dimension: imageSize,
          child: builder(context, source, state),
        );
      }
      if (_isUrl(source)) {
        return Image.network(
          source,
          height: imageSize,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => fallback,
        );
      }
      return Image.asset(
        source,
        height: imageSize,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return fallback;
  }

  static bool _isUrl(String source) {
    final lower = source.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  /// Debug-only format check. Never blocks rendering.
  bool _debugCheckAsset(String asset, {required bool hasBuilder}) {
    final path = Uri.tryParse(asset)?.path ?? asset;
    final lower = path.toLowerCase();
    final isSvg = lower.endsWith('.svg');
    final isPng = lower.endsWith('.png');
    String? message;
    if (isSvg && !hasBuilder) {
      message =
          '"$asset" is an SVG, which Image.asset/Image.network cannot '
          'render. Add flutter_svg to your app and set `assetBuilder` or '
          '`LiquidSegmentedBar.defaultAssetBuilder`, or use '
          '`LiquidSegment.visual`. Falling back to `icon`.';
    } else if (!isSvg && !isPng) {
      message =
          '"$asset": recommended image formats are PNG (with '
          'transparency) or SVG. The image will still be rendered.';
    }
    if (message != null && _warnedAssets.add(asset)) {
      debugPrint('LiquidSegmentedBar warning: $message');
    }
    return true;
  }
}

class _GlassBubble extends StatelessWidget {
  const _GlassBubble({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(999));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.30),
            accent.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Thin glass highlight on the top edge.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
