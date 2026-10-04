/// Controls when segment labels are shown.
///
/// A segment without any visual (no `visual`, `asset` or `icon`) always shows
/// its label, regardless of this setting, so it never renders empty.
enum LiquidLabelBehavior {
  /// Every segment shows its label under the visual.
  always,

  /// Only the selected segment shows its label; others show just the visual.
  selectedOnly,

  /// Labels are hidden (still exposed to screen readers via semantics).
  never,
}
