# liquid_segmented_bar

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-support-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/emtay70)

An iOS **"liquid glass"** style segmented control for Flutter: a frosted glass
capsule with a glossy bubble that springs to the selected segment.

<!-- IMAGE: doc/images/hero.gif
     Bar on a busy background, bubble sliding across 4–5 segments. -->

---

## Table of contents

- [Features](#features)
- [Installation](#installation)
- [Quick start](#quick-start)
  - [Text only](#text-only)
- [Label modes](#label-modes)
- [Visuals](#visuals)
  - [Icons](#icons)
  - [Image assets and URLs](#image-assets-and-urls)
  - [SVG: bring your own package](#svg-bring-your-own-package)
  - [Custom widgets](#custom-widgets)
  - [State-aware visuals](#state-aware-visuals)
- [Sizing](#sizing)
  - [Visual and text size](#visual-and-text-size)
  - [Height: auto, fixed, min and max](#height-auto-fixed-min-and-max)
  - [Overflow handling](#overflow-handling)
- [Styling](#styling)
- [Animation and haptics](#animation-and-haptics)
- [Accessibility](#accessibility)
- [API reference](#api-reference)
- [Tips and FAQ](#tips-and-faq)
- [Support](#support)
- [License](#license)

---

## Features

- **Liquid glass look:** backdrop blur, gradient glass capsule and an
  accent-tinted bubble with a top highlight.
- **Generic and type-safe:** `LiquidSegmentedBar<T>` works with enums,
  strings, ints, nullable values or your own classes.
- **Show anything:** icons, PNG/JPG/WebP/GIF assets, network images, SVG (via
  your own renderer), Lottie or any widget.
- **Three label modes:** `always`, `selectedOnly`, `never`.
- **Adjustable sizes:** icon size, image size, label and selected-label font
  size, spacing and padding.
- **Height that adapts:** calculated from the content and the device text
  scale, always clamped between `minHeight` and `maxHeight`.
- **No overflow errors:** labels are cut off with an ellipsis and content
  scales down when space is tight.
- **Accessible:** every segment is a semantic button with selected state;
  hidden labels are still read by screen readers.
- **Lightweight:** depends only on Flutter.

---

## Installation

```yaml
dependencies:
  liquid_segmented_bar: ^0.1.0
```

```dart
import 'package:liquid_segmented_bar/liquid_segmented_bar.dart';
```

Requires Dart `>=3.7.0` and Flutter `>=3.27.0`.

---

## Quick start

```dart
enum Side { t, ct }

class SidePicker extends StatefulWidget {
  const SidePicker({super.key});

  @override
  State<SidePicker> createState() => _SidePickerState();
}

class _SidePickerState extends State<SidePicker> {
  Side _side = Side.t;

  @override
  Widget build(BuildContext context) {
    return LiquidSegmentedBar<Side>(
      selected: _side,
      onChanged: (side) => setState(() => _side = side),
      segments: const [
        LiquidSegment(value: Side.t, label: 'Terrorists', icon: Icons.shield),
        LiquidSegment(value: Side.ct, label: 'Counter-T', icon: Icons.security),
      ],
    );
  }
}
```

<!-- IMAGE: doc/images/quick_start.png
     Result of the snippet above. -->

### Text only

Segments don't need a visual. Leave out `icon`, `asset` and `visual` for a
clean, text-only tab bar:

![Text-only segments](https://raw.githubusercontent.com/emreaygun10/liquid_segmented_bar/main/doc/images/text_only.gif)

```dart
enum Sort { hot, latest, top }

LiquidSegmentedBar<Sort>(
  selected: _sort,
  onChanged: (sort) => setState(() => _sort = sort),
  segments: const [
    LiquidSegment(value: Sort.hot, label: 'Hot'),
    LiquidSegment(value: Sort.latest, label: 'New'),
    LiquidSegment(value: Sort.top, label: 'Top'),
  ],
)
```

> The blur affects whatever is **behind** the bar. It looks best on top of
> images, gradients or scrolling content, for example in a `Stack`.

---

## Label modes

Choose when labels are visible with `labelBehavior`:

```dart
LiquidSegmentedBar<Grenade>(
  labelBehavior: LiquidLabelBehavior.selectedOnly,
  // ...
)
```

| Value          | Behavior                                                         |
| -------------- | ---------------------------------------------------------------- |
| `always`       | Every segment shows its label under the visual. **Default.**     |
| `selectedOnly` | Only the selected segment shows its label, with a fade and size animation. |
| `never`        | Only visuals are shown. Labels are still read by screen readers. |

<!-- IMAGE: doc/images/label_always.png      Mode: always -->
<!-- IMAGE: doc/images/label_selected_only.gif  Mode: selectedOnly (switching segments) -->
<!-- IMAGE: doc/images/label_never.png       Mode: never -->

> A segment **without any visual** always shows its label, whatever the mode,
> so it never renders empty.

---

## Visuals

Every segment can show one visual above its label. If several are set, the
first one in this order wins:

```
visualBuilder  →  visual  →  asset  →  icon
```

`icon` is also the **fallback** when an `asset` fails to load.

| Field           | Use it for                                                        |
| --------------- | ----------------------------------------------------------------- |
| `icon`          | `Icons.*`, `CupertinoIcons.*`, custom icon fonts                  |
| `asset`         | Asset path or `http(s)` URL; PNG/JPG/WebP/GIF work out of the box |
| `visual`        | Any widget: `SvgPicture`, `Lottie`, `CachedNetworkImage`, emoji…  |
| `visualBuilder` | A widget that changes with the selection state                    |

> **Recommended image formats: PNG (with transparency) or SVG.**
> Other formats still render; in debug mode a one-time warning is printed
> for each such asset. Nothing is ever blocked.

<!-- IMAGE: doc/images/visual_types.png
     One bar mixing icon, PNG, SVG, network image and emoji. -->

### Icons

```dart
LiquidSegment(value: Mode.grid, label: 'Grid', icon: Icons.grid_view_rounded)
```

Selected icons use the `accent` color; unselected icons use a dimmed
`foregroundColor`.

### Image assets and URLs

```dart
// Local asset (remember to declare it in pubspec.yaml)
LiquidSegment(value: Grenade.smoke, label: 'Smoke', asset: 'assets/smoke.png')

// Network image
LiquidSegment(value: Grenade.flash, label: 'Flash', asset: 'https://example.com/flash.png')

// With a fallback icon if loading fails
LiquidSegment(
  value: Grenade.he,
  label: 'HE',
  asset: 'assets/he.png',
  icon: Icons.flare,
)
```

Without a custom builder, paths use `Image.asset` and `http(s)` URLs use
`Image.network`.

### SVG: bring your own package

This package has **no SVG dependency** to stay small. Add
[`flutter_svg`](https://pub.dev/packages/flutter_svg) (or any renderer) to
**your app** and register it once, for example in `main()`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_segmented_bar/liquid_segmented_bar.dart';

void main() {
  LiquidSegmentedBar.defaultAssetBuilder = (context, source, state) {
    final isNetwork = source.startsWith('http');

    if (source.endsWith('.svg')) {
      final tint = ColorFilter.mode(state.color, BlendMode.srcIn);
      return isNetwork
          ? SvgPicture.network(source, width: state.size, colorFilter: tint)
          : SvgPicture.asset(source, width: state.size, colorFilter: tint);
    }

    return isNetwork
        ? Image.network(source, height: state.size)
        : Image.asset(source, height: state.size);
  };

  runApp(const MyApp());
}
```

Now any segment can simply use an SVG path:

```dart
LiquidSegment(value: Grenade.smoke, label: 'Smoke', asset: 'assets/smoke.svg')
```

To use a different renderer for **one bar only**, pass `assetBuilder:` to that
bar; it overrides `defaultAssetBuilder`.

> If an `.svg` is used and no builder is registered, the segment falls back to
> its `icon` and a debug message explains how to enable SVG.

<!-- IMAGE: doc/images/svg_tinted.gif
     SVG icons switching from dimmed to accent color when selected. -->

### Custom widgets

Pass any widget with `visual`. It is laid out in an `imageSize` × `imageSize`
box.

```dart
LiquidSegment(value: Rank.gold, label: 'Gold', visual: Text('🏆', style: TextStyle(fontSize: 18)))

LiquidSegment(value: Map.mirage, label: 'Mirage', visual: CachedNetworkImage(imageUrl: url))
```

### State-aware visuals

Use `visualBuilder` when the visual should change with the selection:

```dart
LiquidSegment(
  value: Grenade.molotov,
  label: 'Molotov',
  visualBuilder: (context, state) => Lottie.asset(
    'assets/fire.json',
    animate: state.selected, // plays only while selected
  ),
)
```

The builder receives a `LiquidVisualState`:

| Property   | Description                                               |
| ---------- | --------------------------------------------------------- |
| `selected` | Whether the segment is selected                           |
| `size`     | Box size for the visual (the bar's `imageSize`)           |
| `color`    | Suggested tint: `accent` if selected, dimmed foreground otherwise |
| `accent`   | The bar's accent color                                    |

<!-- IMAGE: doc/images/state_aware.gif
     Lottie animation playing only on the selected segment. -->

---

## Sizing

### Visual and text size

```dart
LiquidSegmentedBar<Grenade>(
  iconSize: 24,               // icons
  imageSize: 28,              // assets, `visual`, `visualBuilder`
  labelFontSize: 11,          // all labels
  selectedLabelFontSize: 12,  // selected label only
  labelSpacing: 4,            // gap between visual and label
  labelAlign: TextAlign.start, // default: TextAlign.center
  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
  // ...
)
```

By default labels are `10.5` when the segment has a visual and `13` when it
is text-only.

<!-- IMAGE: doc/images/sizes.png
     Same bar in small / default / large sizes. -->

### Height: auto, fixed, min and max

| Setup                 | Result                                               |
| --------------------- | ---------------------------------------------------- |
| `height: null` (default) | Calculated from visual size, font size, `labelMaxLines`, spacing, padding and the device text scale |
| `height: 64`          | Fixed height                                         |
| Any of the above      | **Always clamped** to `minHeight`..`maxHeight`       |

```dart
LiquidSegmentedBar<Grenade>(
  minHeight: 48,   // default 44, the recommended minimum touch target
  maxHeight: 80,   // default 120
  // ...
)
```

The auto height reserves room for the tallest possible segment, so the bar
**does not jump** when the selection changes, even in `selectedOnly` mode.

### Overflow handling

The bar is built not to throw `RenderFlex overflowed` errors:

- **Long labels** are cut off with an ellipsis at the segment width. Allow
  more lines with `labelMaxLines`.
- **Too little height or width** (a tight parent, large text scale, big
  icons): the segment content **scales down** to fit.
- **Wide images** are fitted inside the visual box with `BoxFit.contain`.

<!-- IMAGE: doc/images/overflow.png
     Narrow bar with long labels and large text scale, still rendering cleanly. -->

---

## Styling

```dart
LiquidSegmentedBar<Grenade>(
  accent: const Color(0xFF7CF28F),          // bubble + selected icon
  foregroundColor: Colors.white,             // labels/icons (unselected = 55% opacity)
  labelStyle: GoogleFonts.poppins(),          // base text style (font family etc.)
  blurSigma: 24,                              // glass blur strength
  // ...
)
```

- `accent` defaults to `Theme.of(context).colorScheme.primary`, so the bar
  follows your theme automatically.
- `labelStyle` is a base style; its color, weight and size are set by the bar
  (use `foregroundColor`, `labelFontSize`, `selectedLabelFontSize`).

<!-- IMAGE: doc/images/accents.png
     The same bar with 3–4 different accent colors. -->

---

## Animation and haptics

```dart
LiquidSegmentedBar<Grenade>(
  animationDuration: const Duration(milliseconds: 300),
  animationCurve: Curves.easeOutCubic,  // default: Curves.easeOutBack (springy)
  haptics: false,                       // default: true (selection click)
  // ...
)
```

Segments also scale slightly and fade when they lose selection; tapping the
already selected segment does nothing and does not call `onChanged`.

---

## Accessibility

- Each segment is exposed as a **button** with its `label` and **selected**
  state.
- Labels hidden by `selectedOnly` or `never` are **still announced** by
  screen readers.
- Auto height follows the system **text scale**.
- `minHeight` defaults to **44**, the recommended minimum touch target.

---

## API reference

### `LiquidSegmentedBar<T>`

| Parameter               | Type                        | Default                  | Description                                  |
| ----------------------- | --------------------------- | ------------------------ | -------------------------------------------- |
| `segments`              | `List<LiquidSegment<T>>`    | **required**             | Options, at least one                        |
| `selected`              | `T`                         | **required**             | Currently selected value                     |
| `onChanged`             | `ValueChanged<T>`           | **required**             | Called with the tapped value                 |
| `accent`                | `Color?`                    | `ColorScheme.primary`    | Bubble and selected icon color               |
| `foregroundColor`       | `Color`                     | `Colors.white`           | Label/icon color (unselected = 55% opacity)  |
| `height`                | `double?`                   | `null` (auto)            | Fixed height, still clamped                  |
| `minHeight`             | `double`                    | `44`                     | Minimum height                               |
| `maxHeight`             | `double`                    | `120`                    | Maximum height                               |
| `labelBehavior`         | `LiquidLabelBehavior`       | `always`                 | When labels are shown                        |
| `iconSize`              | `double`                    | `20`                     | Size of `icon`                               |
| `imageSize`             | `double`                    | `22`                     | Size of `asset` / `visual` / `visualBuilder` |
| `labelFontSize`         | `double?`                   | `10.5` / `13`            | Label font size                              |
| `selectedLabelFontSize` | `double?`                   | `labelFontSize`          | Selected label font size                     |
| `labelStyle`            | `TextStyle?`                | `TextTheme.labelSmall`   | Base text style                              |
| `labelMaxLines`         | `int`                       | `1`                      | Lines before ellipsis                        |
| `labelAlign`            | `TextAlign`                 | `TextAlign.center`       | Horizontal label alignment                   |
| `labelSpacing`          | `double`                    | `3`                      | Gap between visual and label                 |
| `contentPadding`        | `EdgeInsets`                | `h: 4, v: 8`             | Inner padding of each segment                |
| `assetBuilder`          | `LiquidAssetBuilder?`       | `defaultAssetBuilder`    | Asset renderer for this bar                  |
| `blurSigma`             | `double`                    | `20`                     | Backdrop blur strength                       |
| `haptics`               | `bool`                      | `true`                   | Selection click on tap                       |
| `animationDuration`     | `Duration`                  | `380ms`                  | Bubble slide duration                        |
| `animationCurve`        | `Curve`                     | `Curves.easeOutBack`     | Bubble slide curve                           |

**Static**

| Member                | Type                  | Description                                    |
| --------------------- | --------------------- | ---------------------------------------------- |
| `defaultAssetBuilder` | `LiquidAssetBuilder?` | App-wide asset renderer (e.g. for SVG support) |

### `LiquidSegment<T>`

| Field           | Type                   | Description                                  |
| --------------- | ---------------------- | -------------------------------------------- |
| `value`         | `T`                    | **Required.** Value passed to `onChanged`    |
| `label`         | `String`               | **Required.** Label and semantics text       |
| `icon`          | `IconData?`            | Icon, also the fallback for failed assets    |
| `asset`         | `String?`              | Asset path or `http(s)` URL                  |
| `visual`        | `Widget?`              | Any custom widget                            |
| `visualBuilder` | `LiquidVisualBuilder?` | Custom widget that reacts to selection state |

### `LiquidLabelBehavior`

`always` · `selectedOnly` · `never`

### Typedefs

```dart
typedef LiquidAssetBuilder =
    Widget Function(BuildContext context, String source, LiquidVisualState state);

typedef LiquidVisualBuilder =
    Widget Function(BuildContext context, LiquidVisualState state);
```

---

## Tips and FAQ

**How many segments should I use?**
All segments share the same width, so 2–6 options work best. For more
options, consider a scrollable chip list.

**Can the selected value be nullable (for an "All" option)?**
Yes, use a nullable type such as `LiquidSegmentedBar<Category?>` with a
segment whose `value` is `null`.

**What if `selected` matches no segment?**
The bubble rests on the first segment.

**Why don't I see the blur?**
There is nothing behind the bar. Place it over an image, gradient or list
(e.g. in a `Stack`).

**My SVG shows an icon instead.**
No asset builder is registered. See
[SVG: bring your own package](#svg-bring-your-own-package).

**I get "recommended image formats" in the console.**
It is only a debug hint for formats other than PNG/SVG. The image still
renders and the message is not shown in release builds.

---

## Support

If this package saves you time, you can support its development:

<a href="https://buymeacoffee.com/emtay70" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="50">
</a>

Stars, issues and pull requests are also very welcome.

---

## License

MIT. See [LICENSE](LICENSE).
