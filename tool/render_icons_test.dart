// Renders the Hushbug mascot into the app-icon PNGs in assets/icon/.
//
// Run:   flutter test tool/render_icons_test.dart
// Then:  dart run flutter_launcher_icons
//
// Kept under tool/ (not test/) so it never runs in the normal test suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/presentation/theme.dart';
import 'package:hushbug/presentation/widgets/mascot.dart';

const _size = 1024.0;
const bgTop = Color(0xFF5B45B0);
const bgBottom = Color(0xFF2B1F5C);

Widget _icon({required bool background, required double mascotScale}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.dark, 0),
      home: Center(
        child: RepaintBoundary(
          child: Container(
            width: _size,
            height: _size,
            decoration: background
                ? const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bgTop, bgBottom]),
                  )
                : null,
            alignment: Alignment.center,
            child: Stack(alignment: Alignment.center, children: [
              if (background)
                // Soft glow behind the bug.
                Container(
                  width: _size * 0.78,
                  height: _size * 0.78,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0),
                  ])),
                ),
              // The painter leaves headroom for the antennae; nudge down a bit.
              Transform.translate(
                offset: Offset(0, _size * 0.02),
                child: Mascot(size: _size * mascotScale),
              ),
            ]),
          ),
        ),
      ),
    );

Future<void> _render(WidgetTester tester, Widget w, String path) async {
  await tester.pumpWidget(w);
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).last);
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render app icons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(_size, _size));
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Full-bleed icon (Windows, macOS, legacy Android, Play Store).
    await _render(tester, _icon(background: true, mascotScale: 0.86), 'assets/icon/app_icon.png');
    // Android adaptive foreground: the body stays inside the central safe
    // zone; only leg/antenna tips may get trimmed by round masks.
    await _render(tester, _icon(background: false, mascotScale: 0.8), 'assets/icon/app_icon_foreground.png');
  });
}
