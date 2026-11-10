import 'dart:math';

/// Chi-square goodness-of-fit statistic.
double chiSquare(List<int> observed, List<double> expected) {
  var s = 0.0;
  for (var i = 0; i < observed.length; i++) {
    final d = observed[i] - expected[i];
    s += d * d / expected[i];
  }
  return s;
}

/// Upper-tail p-value of the chi-square distribution: Q(df/2, x/2).
double chiSquarePValue(double x, int df) => _gammaQ(df / 2.0, x / 2.0);

double _gammaQ(double a, double x) {
  if (x < 0 || a <= 0) throw ArgumentError();
  if (x == 0) return 1.0;
  if (x < a + 1) return 1.0 - _gser(a, x);
  return _gcf(a, x);
}

double _lnGamma(double xx) {
  const cof = [
    76.18009172947146, -86.50532032941677, 24.01409824083091,
    -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5,
  ];
  var x = xx, y = xx;
  var tmp = x + 5.5;
  tmp -= (x + 0.5) * log(tmp);
  var ser = 1.000000000190015;
  for (final c in cof) {
    ser += c / ++y;
  }
  return -tmp + log(2.5066282746310005 * ser / x);
}

double _gser(double a, double x) {
  var ap = a, sum = 1.0 / a, del = sum;
  for (var n = 0; n < 1000; n++) {
    ap += 1;
    del *= x / ap;
    sum += del;
    if (del.abs() < sum.abs() * 1e-14) break;
  }
  return sum * exp(-x + a * log(x) - _lnGamma(a));
}

double _gcf(double a, double x) {
  const fpmin = 1e-300;
  var b = x + 1 - a, c = 1 / fpmin, d = 1 / b, h = d;
  for (var i = 1; i < 1000; i++) {
    final an = -i * (i - a);
    b += 2;
    d = an * d + b;
    if (d.abs() < fpmin) d = fpmin;
    c = b + an / c;
    if (c.abs() < fpmin) c = fpmin;
    d = 1 / d;
    final del = d * c;
    h *= del;
    if ((del - 1).abs() < 1e-14) break;
  }
  return exp(-x + a * log(x) - _lnGamma(a)) * h;
}

/// Chi-square test of independence for an r x c contingency table.
({double stat, int df, double p}) independence(List<List<int>> table) {
  final r = table.length, c = table.first.length;
  final rowSums = [for (final row in table) row.fold<int>(0, (a, b) => a + b)];
  final colSums = [for (var j = 0; j < c; j++) table.fold<int>(0, (a, row) => a + row[j])];
  final total = rowSums.fold<int>(0, (a, b) => a + b);
  var stat = 0.0;
  for (var i = 0; i < r; i++) {
    for (var j = 0; j < c; j++) {
      final e = rowSums[i] * colSums[j] / total;
      if (e == 0) continue;
      final d = table[i][j] - e;
      stat += d * d / e;
    }
  }
  final df = (r - 1) * (c - 1);
  return (stat: stat, df: df, p: chiSquarePValue(stat, df));
}
