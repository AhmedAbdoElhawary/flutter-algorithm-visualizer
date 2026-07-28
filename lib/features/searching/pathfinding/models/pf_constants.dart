const int kPFCols = 30;
const int kPFRows = 30;

const int kPFStartRow = 15;
const int kPFStartCol = 5;
const int kPFEndRow = 15;
const int kPFEndCol = 25;

int pfEncode(int row, int col) => row * kPFCols + col;
int pfDecodeRow(int encoded) => encoded ~/ kPFCols;
int pfDecodeCol(int encoded) => encoded % kPFCols;
