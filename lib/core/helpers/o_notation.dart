class AlgorithmComplexity {
  final String name;
  final ONotationComplexity bestTimeComplexity;
  final ONotationComplexity averageTimeComplexity;
  final ONotationComplexity worstTimeComplexity;
  final ONotationComplexity spaceComplexity;
  AlgorithmComplexity({
    required this.name,
    required this.spaceComplexity,
    required this.averageTimeComplexity,
    required this.worstTimeComplexity,
    required this.bestTimeComplexity,
  });
}

enum ONotationComplexity {
  constant,
  logN,
  n,
  nLogN,
  n2,
  nk,
  nPlusK,
  k,

  vPlusE,
  eLogV,
}

extension ONotationComplexityExt on ONotationComplexity {
  String get getText {
    switch (this) {
      case ONotationComplexity.constant:
        return "O(1)";
      case ONotationComplexity.logN:
        return "O(log n)";
      case ONotationComplexity.n:
        return "O(n)";
      case ONotationComplexity.nLogN:
        return "O(n log n)";
      case ONotationComplexity.n2:
        return "O(n²)";
      case ONotationComplexity.nk:
        return "O(nk)";
      case ONotationComplexity.nPlusK:
        return "O(n + k)";
      case ONotationComplexity.k:
        return "O(k)";
      case ONotationComplexity.vPlusE:
        return "O(V + E)";
      case ONotationComplexity.eLogV:
        return "O(E log V)";
    }
  }
}