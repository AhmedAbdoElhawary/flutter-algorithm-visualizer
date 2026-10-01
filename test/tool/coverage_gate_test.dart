import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage_gate.dart' as gate;

void main() {
  late Directory root;
  late List<String> output;

  String record(String path, {required int hit, int found = 10}) => 'SF:$path\n${[
        for (var i = 1; i <= found; i++) 'DA:$i,${i <= hit ? 1 : 0}'
      ].join('\n')}\nend_of_record\n';

  void writeLcov(List<String> records) => File('${root.path}/lcov.info').writeAsStringSync(records.join());

  void writeTest(String path) => File('${root.path}/test/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync('');

  void writeConfig({bool homeGated = true, bool overallGated = false}) {
    File('${root.path}/config.json').writeAsStringSync(
      jsonEncode({
        'overallMin': 80,
        'overallGated': overallGated,
        'logicMin': 90,
        'areaMin': 80,
        'logicFolders': ['view_model'],
        'exclude': ['**/*.g.dart', 'lib/bootstrap.dart'],
        'areas': {
          'home': {'path': 'lib/features/home/', 'gated': homeGated},
          'engine': {'path': 'lib/core/engine/', 'gated': true, 'min': 50, 'logicMin': 50},
          'core': {'path': 'lib/core/', 'gated': false},
        },
      }),
    );
  }

  int check() => gate.check(
        lcovPath: '${root.path}/lcov.info',
        configPath: '${root.path}/config.json',
        testRoot: '${root.path}/test',
        output: output.add,
      );

  setUp(() {
    root = Directory.systemTemp.createTempSync('coverage_gate_test');
    output = [];
    writeConfig();
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('passes when every gated file is tested and covered', () {
    writeLcov([record('lib/features/home/view/home_page.dart', hit: 10)]);
    writeTest('features/home/view/home_page_test.dart');

    expect(check(), 0);
  });

  group('R1', () {
    test('flags a gated file with no mirrored test', () {
      writeLcov([record('lib/features/home/view/home_page.dart', hit: 10)]);

      expect(check(), 1);
      expect(output, contains('R1 home: lib/features/home/view/home_page.dart has no test'));
    });

    test('accepts a <source>_<topic>_test.dart file', () {
      writeLcov([record('lib/features/home/view/home_page.dart', hit: 10)]);
      writeTest('features/home/view/home_page_layout_test.dart');

      expect(check(), 0);
    });

    test('does not accept a test for a different file with the same prefix folder', () {
      writeLcov([record('lib/features/home/view/home_page.dart', hit: 10)]);
      writeTest('features/home/view/home_test.dart');

      expect(check(), 1);
    });
  });

  group('R2', () {
    test('fails an area below its minimum and prints the percentage', () {
      writeLcov([record('lib/features/home/view/home_page.dart', hit: 7)]);
      writeTest('features/home/view/home_page_test.dart');

      expect(check(), 1);
      expect(output, contains('R2 home: coverage 70.0% is below 80.0%'));
    });

    test('passes an area exactly at its minimum', () {
      writeLcov([record('lib/features/home/view/home_page.dart', hit: 8)]);
      writeTest('features/home/view/home_page_test.dart');

      expect(check(), 0);
    });

    test('uses the area\'s own min, and the most specific area wins', () {
      writeLcov([record('lib/core/engine/vm.dart', hit: 5)]);
      writeTest('core/engine/vm_test.dart');

      expect(check(), 0);
    });
  });

  test('R3 fails logic files below 90% even when the area is above 80%', () {
    writeLcov([
      record('lib/features/home/view/home_page.dart', hit: 10),
      record('lib/features/home/view_model/home_provider.dart', hit: 8),
    ]);
    writeTest('features/home/view/home_page_test.dart');
    writeTest('features/home/view_model/home_provider_test.dart');

    expect(check(), 1);
    expect(output, contains('R3 home: logic coverage 80.0% is below 90.0%'));
    expect(output.where((line) => line.startsWith('R2')), isEmpty);
  });

  test('R4 fails the overall number only once overallGated is on', () {
    writeLcov([record('lib/core/theme.dart', hit: 0)]);

    expect(check(), 0);

    writeConfig(overallGated: true);
    expect(check(), 1);
    expect(output, contains('R4 overall: coverage 0.0% is below 80.0%'));
  });

  test('an ungated area never fails', () {
    writeConfig(homeGated: false);
    writeLcov([record('lib/features/home/view/home_page.dart', hit: 0)]);

    expect(check(), 0);
  });

  test('an excluded file is ignored', () {
    writeLcov([record('lib/features/home/home.g.dart', hit: 0), record('lib/bootstrap.dart', hit: 0)]);

    expect(check(), 0);
  });

  test('reads absolute paths the same as relative ones', () {
    writeLcov([record('/Users/someone/app/lib/features/home/view/home_page.dart', hit: 10)]);

    expect(check(), 1);
    expect(output, contains('R1 home: lib/features/home/view/home_page.dart has no test'));
  });

  test('exits 2 when lcov.info is missing', () {
    expect(check(), 2);
  });

  test('exits 2 when the config is not valid JSON', () {
    writeLcov([]);
    File('${root.path}/config.json').writeAsStringSync('{');

    expect(check(), 2);
  });
}
