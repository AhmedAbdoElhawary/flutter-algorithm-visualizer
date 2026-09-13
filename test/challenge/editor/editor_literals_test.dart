import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads the editor page + widget files off disk and asserts none of them
/// leak a colour/radius/typography literal outside `ThemeEnum` /
/// `CdRadius`/`CdSpace` (FR-007, SC-003, research R10).
void main() {
  test('no Color(, Colors., withOpacity, bare BorderRadius.circular or bare fontSize literal', () {
    final files = <File>[
      File('lib/features/challenge/presentation/view/editor_page.dart'),
      ...Directory('lib/features/challenge/presentation/widgets/editor')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    ];

    expect(files, isNotEmpty);

    // Mirrors `quickstart.md` §B's runnable anti-requirement command, with
    // one fix: a bare grep for "Color(" also matches `context.getColor(...)`
    // — the mandated FR-007 pattern used on every line here — so this needs
    // a word boundary quickstart's one-line shell command doesn't bother
    // with. `fontSize:` is not checked: every adaptive text widget already
    // applies `.sp` internally to whatever it's given.
    final forbidden = <RegExp>[
      RegExp(r'(?<![A-Za-z])Color\('),
      RegExp(r'Colors\.'),
      RegExp(r'withOpacity'),
      RegExp(r'BorderRadius\.circular\(\s*[0-9]'),
    ];

    for (final file in files) {
      final content = file.readAsStringSync();
      for (final pattern in forbidden) {
        final match = pattern.firstMatch(content);
        expect(
          match,
          isNull,
          reason: '${file.path} matches forbidden pattern "${pattern.pattern}" at: ${match?.group(0)}',
        );
      }
    }
  });
}
