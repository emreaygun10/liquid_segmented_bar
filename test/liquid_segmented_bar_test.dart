import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_segmented_bar/liquid_segmented_bar.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

const _iconSegments = [
  LiquidSegment(value: 'a', label: 'Alpha', icon: Icons.ac_unit),
  LiquidSegment(value: 'b', label: 'Bravo', icon: Icons.access_alarm),
  LiquidSegment(value: 'c', label: 'Charlie', icon: Icons.adb),
];

void main() {
  testWidgets('tapping a segment reports its value', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (v) => tapped = v,
          haptics: false,
          segments: _iconSegments,
        ),
      ),
    );

    await tester.tap(find.text('Bravo'));
    expect(tapped, 'b');
  });

  testWidgets('tapping the selected segment does nothing', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (_) => calls++,
          haptics: false,
          segments: _iconSegments,
        ),
      ),
    );

    await tester.tap(find.text('Alpha'));
    expect(calls, 0);
  });

  testWidgets('selectedOnly shows only the selected label', (tester) async {
    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'b',
          onChanged: (_) {},
          labelBehavior: LiquidLabelBehavior.selectedOnly,
          segments: _iconSegments,
        ),
      ),
    );

    expect(find.text('Bravo'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Charlie'), findsNothing);
  });

  testWidgets('never hides labels but keeps text-only segments readable',
      (tester) async {
    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (_) {},
          labelBehavior: LiquidLabelBehavior.never,
          segments: const [
            LiquidSegment(value: 'a', label: 'Alpha', icon: Icons.ac_unit),
            LiquidSegment(value: 'b', label: 'TextOnly'),
          ],
        ),
      ),
    );

    expect(find.text('Alpha'), findsNothing);
    expect(find.text('TextOnly'), findsOneWidget);
    expect(find.bySemanticsLabel('Alpha'), findsOneWidget);
  });

  testWidgets('height is clamped to min/max', (tester) async {
    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (_) {},
          height: 500,
          maxHeight: 80,
          segments: _iconSegments,
        ),
      ),
    );
    expect(tester.getSize(find.byType(LiquidSegmentedBar<String>)).height, 80);

    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (_) {},
          height: 10,
          minHeight: 50,
          segments: _iconSegments,
        ),
      ),
    );
    expect(tester.getSize(find.byType(LiquidSegmentedBar<String>)).height, 50);
  });

  testWidgets('does not overflow in a tiny box with big content',
      (tester) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 140,
          height: 30,
          child: LiquidSegmentedBar<int>(
            selected: 0,
            onChanged: (_) {},
            iconSize: 60,
            labelFontSize: 30,
            minHeight: 20,
            segments: [
              for (var i = 0; i < 6; i++)
                LiquidSegment(
                  value: i,
                  label: 'A very long label number $i',
                  icon: Icons.star,
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('visualBuilder receives selected state', (tester) async {
    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (_) {},
          segments: [
            for (final v in ['a', 'b'])
              LiquidSegment(
                value: v,
                label: v,
                visualBuilder: (context, state) =>
                    Text(state.selected ? 'ON-$v' : 'OFF-$v'),
              ),
          ],
        ),
      ),
    );
    expect(find.text('ON-a'), findsOneWidget);
    expect(find.text('OFF-b'), findsOneWidget);
  });

  testWidgets('defaultAssetBuilder renders assets app-wide', (tester) async {
    LiquidSegmentedBar.defaultAssetBuilder =
        (context, source, state) => Text('custom:$source');
    addTearDown(() => LiquidSegmentedBar.defaultAssetBuilder = null);

    await tester.pumpWidget(
      _host(
        LiquidSegmentedBar<String>(
          selected: 'a',
          onChanged: (_) {},
          segments: const [
            LiquidSegment(value: 'a', label: 'A', asset: 'x.svg'),
            LiquidSegment(value: 'b', label: 'B', asset: 'y.png'),
          ],
        ),
      ),
    );
    expect(find.text('custom:x.svg'), findsOneWidget);
    expect(find.text('custom:y.png'), findsOneWidget);
  });
}
