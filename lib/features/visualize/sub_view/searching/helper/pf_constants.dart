const int kPFCols = 30;
const int kPFRows = 24;

const int kPFStartRow = 12;
const int kPFStartCol = 5;
const int kPFEndRow = 12;
const int kPFEndCol = 25;

/// Milliseconds each successive path cell waits before it is revealed.
const int kPathStaggerMs = 25;

int pfEncode(int row, int col) => row * kPFCols + col;
int pfDecodeRow(int encoded) => encoded ~/ kPFCols;
int pfDecodeCol(int encoded) => encoded % kPFCols;
