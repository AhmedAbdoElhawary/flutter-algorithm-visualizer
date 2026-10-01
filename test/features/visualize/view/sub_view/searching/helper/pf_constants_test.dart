import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('grid dimensions (FR-034)', () {
    test('the grid is 30 columns by 24 rows', () {
      expect(kPFCols, 30);
      expect(kPFRows, 24);
    });

    test('the aspect ratio is 0.8 so the grid is 0.8 of its own width', () {
      expect(kPFRows / kPFCols, closeTo(0.8, 1e-9));
    });

    test('both default markers sit inside the grid and differ', () {
      expect(kPFStartRow, inInclusiveRange(0, kPFRows - 1));
      expect(kPFStartCol, inInclusiveRange(0, kPFCols - 1));
      expect(kPFEndRow, inInclusiveRange(0, kPFRows - 1));
      expect(kPFEndCol, inInclusiveRange(0, kPFCols - 1));
      expect(pfEncode(kPFStartRow, kPFStartCol), isNot(pfEncode(kPFEndRow, kPFEndCol)));
    });
  });

  group('encoding uses the column count as stride (FR-037)', () {
    test('decode round-trips every cell', () {
      for (int r = 0; r < kPFRows; r++) {
        for (int c = 0; c < kPFCols; c++) {
          final encoded = pfEncode(r, c);
          expect(pfDecodeRow(encoded), r, reason: 'row of ($r, $c)');
          expect(pfDecodeCol(encoded), c, reason: 'col of ($r, $c)');
        }
      }
    });

    test('encoded values fill 0 .. kPFCols * kPFRows - 1 with no gaps', () {
      final encoded = <int>{};
      for (int r = 0; r < kPFRows; r++) {
        for (int c = 0; c < kPFCols; c++) {
          encoded.add(pfEncode(r, c));
        }
      }

      expect(encoded.length, kPFCols * kPFRows);
      expect(encoded, List.generate(kPFCols * kPFRows, (i) => i).toSet());
    });
  });
}
