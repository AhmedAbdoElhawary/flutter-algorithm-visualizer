const int kPFCols = 50;
const int kPFRows = 50;

const int kPFStartRow = 20;
const int kPFStartCol = 5;
const int kPFEndRow = 20;
const int kPFEndCol = 35;

int pfEncode(int row, int col) => row * kPFCols + col;
int pfDecodeRow(int encoded) => encoded ~/ kPFCols;
int pfDecodeCol(int encoded) => encoded % kPFCols;
