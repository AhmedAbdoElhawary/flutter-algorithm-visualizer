const int kPFCells = 30;

const int kPFStartRow = 15;
const int kPFStartCol = 5;
const int kPFEndRow = 15;
const int kPFEndCol = 25;

int pfEncode(int row, int col) => row * kPFCells + col;
int pfDecodeRow(int encoded) => encoded ~/ kPFCells;
int pfDecodeCol(int encoded) => encoded % kPFCells;
