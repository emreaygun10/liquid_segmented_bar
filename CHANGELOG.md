## 0.1.1

- Docs: use an absolute URL for the README example GIF so it renders on pub.dev.

## 0.1.0

- Initial release: `LiquidSegmentedBar`, `LiquidSegment`, `LiquidLabelBehavior`.
- Configurable icon/image size and label font sizes.
- Auto height from content, clamped by `minHeight` / `maxHeight`.
- Overflow safe: labels ellipsize, content scales down when space is tight.
- Label modes: `always`, `selectedOnly`, `never`.
- Visuals: `icon`, `asset` (path or URL), `visual`, `visualBuilder`.
- No SVG dependency: plug in `flutter_svg` via `assetBuilder` or the
  app-wide `LiquidSegmentedBar.defaultAssetBuilder`.
