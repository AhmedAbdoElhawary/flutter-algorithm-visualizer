// Overlays a diagonal red "DEV" / "STAGING" ribbon on the base app icon and
// writes one 1024x1024 PNG per flavor into tool/flavor_icons/generated/.
//
// flutter_launcher_icons then turns each of those into the full mipmap-* /
// AppIcon.appiconset set (see flutter_launcher_icons-<flavor>.yaml).
//
// Run (from repo root):
//   dart run tool/flavor_icons/generate_ribbon_icons.dart
//   dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
//   dart run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
//   dart run flutter_launcher_icons -f flutter_launcher_icons-production.yaml
//
// If the base icon changes, replace tool/flavor_icons/base/app_icon.png with the
// new 1024x1024 artwork and re-run the commands above.

import 'dart:io';

import 'package:image/image.dart' as img;

const _basePath = 'tool/flavor_icons/base/app_icon.png';
const _outDir = 'tool/flavor_icons/generated';

/// (output filename, ribbon text). A null text means "clean icon, no ribbon".
const _flavors = <(String, String?)>[
  ('dev.png', 'DEV'),
  ('staging.png', 'STAGING'),
  ('production.png', null),
];

final _ribbonColor = img.ColorRgba8(0xD9, 0x2D, 0x20, 0xFF); // red
final _ribbonEdge = img.ColorRgba8(0xA5, 0x1B, 0x12, 0xFF); // darker edge
final _textColor = img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);

void main() {
  final baseFile = File(_basePath);
  if (!baseFile.existsSync()) {
    stderr.writeln('Base icon not found at $_basePath');
    exit(1);
  }
  final base = img.decodePng(baseFile.readAsBytesSync());
  if (base == null) {
    stderr.writeln('Could not decode $_basePath as PNG');
    exit(1);
  }

  Directory(_outDir).createSync(recursive: true);

  for (final (name, text) in _flavors) {
    final out = img.Image.from(base);
    if (text != null) _drawCornerRibbon(out, text);
    final path = '$_outDir/$name';
    File(path).writeAsBytesSync(img.encodePng(out));
    stdout.writeln('wrote $path${text == null ? ' (clean)' : ' [$text]'}');
  }
}

/// Draws a 45-degree ribbon across the top-right corner of [icon].
void _drawCornerRibbon(img.Image icon, String text) {
  final size = icon.width; // square icon
  final bandWidth = (size * 1.4).round();
  final bandHeight = (size * 0.17).round();

  // 1. Horizontal band with darker top/bottom edge lines.
  final band = img.Image(width: bandWidth, height: bandHeight, numChannels: 4);
  img.fill(band, color: img.ColorRgba8(0, 0, 0, 0));
  img.fillRect(band,
      x1: 0, y1: 0, x2: bandWidth - 1, y2: bandHeight - 1, color: _ribbonColor);
  final edge = (bandHeight * 0.09).round().clamp(2, 14);
  img.fillRect(band,
      x1: 0, y1: 0, x2: bandWidth - 1, y2: edge - 1, color: _ribbonEdge);
  img.fillRect(band,
      x1: 0,
      y1: bandHeight - edge,
      x2: bandWidth - 1,
      y2: bandHeight - 1,
      color: _ribbonEdge);

  // 2. Centered, letter-spaced label (arial48 is the largest bundled font).
  final label = text.toUpperCase().split('').join('  ');
  final font = img.arial48;
  final textWidth = label.length * 26;
  img.drawString(
    band,
    label,
    font: font,
    x: ((bandWidth - textWidth) / 2).round().clamp(0, bandWidth - 1),
    y: ((bandHeight - font.lineHeight) / 2 + bandHeight * 0.04)
        .round()
        .clamp(0, bandHeight - 1),
    color: _textColor,
  );

  // 3. Rotate +45 and composite so the band centre sits on the diagonal a
  //    little in from the top-right corner. Corner is (size, 0); the diagonal
  //    into the icon runs along (-1, 1)/sqrt2.
  final rotated = img.copyRotate(band, angle: 45);
  final d = size * 0.30 / 1.41421356; // component along each axis
  final centerX = size - d;
  final centerY = d;
  img.compositeImage(
    icon,
    rotated,
    dstX: (centerX - rotated.width / 2).round(),
    dstY: (centerY - rotated.height / 2).round(),
  );
}
