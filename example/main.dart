import 'package:flutter/material.dart';
import 'package:liquid_segmented_bar/liquid_segmented_bar.dart';

void main() => runApp(const ExampleApp());

enum Grenade { all, smoke, flash, molotov, he }

const _segments = [
  LiquidSegment(value: Grenade.all, label: 'All', icon: Icons.apps),
  LiquidSegment(value: Grenade.smoke, label: 'Smoke', icon: Icons.cloud),
  LiquidSegment(value: Grenade.flash, label: 'Flash', icon: Icons.flash_on),
  LiquidSegment(
    value: Grenade.molotov,
    label: 'Molotov',
    icon: Icons.local_fire_department,
  ),
  LiquidSegment(value: Grenade.he, label: 'HE', icon: Icons.brightness_7),
];

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Grenade _selected = Grenade.all;

  Widget _bar(LiquidLabelBehavior behavior, {double iconSize = 20}) {
    return LiquidSegmentedBar<Grenade>(
      selected: _selected,
      onChanged: (g) => setState(() => _selected = g),
      labelBehavior: behavior,
      iconSize: iconSize,
      segments: _segments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7CF28F),
          brightness: Brightness.dark,
          primary: const Color(0xFF7CF28F),
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF0B0F0C),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('always'),
              const SizedBox(height: 8),
              _bar(LiquidLabelBehavior.always),
              const SizedBox(height: 24),
              const Text('selectedOnly'),
              const SizedBox(height: 8),
              _bar(LiquidLabelBehavior.selectedOnly),
              const SizedBox(height: 24),
              const Text('never (iconSize: 26)'),
              const SizedBox(height: 8),
              _bar(LiquidLabelBehavior.never, iconSize: 26),
            ],
          ),
        ),
      ),
    );
  }
}
