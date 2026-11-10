// Generates original sound effects used by the app as 16-bit PCM WAV files
// in assets/sounds/. Usage: dart run tool/gen_sounds.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const _rate = 22050;

Uint8List _wav(List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, _rate, Endian.little);
  data.setUint32(28, _rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  str(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32000).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}

List<double> _tone(List<(double freq, double dur)> notes, {double vol = 0.5}) {
  final out = <double>[];
  for (final (f, d) in notes) {
    final n = (d * _rate).round();
    for (var i = 0; i < n; i++) {
      final t = i / _rate;
      final env = min(1.0, i / 200) * exp(-3.8 * t / d);
      out.add(vol * env * (sin(2 * pi * f * t) + 0.25 * sin(4 * pi * f * t)));
    }
  }
  return out;
}

List<double> _click({double vol = 0.4}) {
  final out = <double>[];
  const dur = 0.025;
  final n = (dur * _rate).round();
  for (var i = 0; i < n; i++) {
    final t = i / _rate;
    final env = exp(-80.0 * t);
    out.add(vol * env * sin(2 * pi * 1600 * t));
  }
  return out;
}

List<double> _pop({double vol = 0.5}) {
  final out = <double>[];
  const dur = 0.06;
  final n = (dur * _rate).round();
  for (var i = 0; i < n; i++) {
    final t = i / _rate;
    final f = 400.0 + (800.0 * (t / dur));
    final env = sin(pi * (i / n));
    out.add(vol * env * sin(2 * pi * f * t));
  }
  return out;
}

List<double> _whoosh({double vol = 0.35}) {
  final out = <double>[];
  const dur = 0.14;
  final n = (dur * _rate).round();
  final rnd = Random(42);
  for (var i = 0; i < n; i++) {
    final t = i / _rate;
    final env = sin(pi * (i / n)) * exp(-1.5 * t);
    final noise = (rnd.nextDouble() * 2 - 1) * 0.4;
    final tone = sin(2 * pi * (300 - 150 * (t / dur)) * t);
    out.add(vol * env * (noise + tone));
  }
  return out;
}

List<double> _bell({double vol = 0.5}) {
  final out = <double>[];
  const dur = 0.5;
  final n = (dur * _rate).round();
  for (var i = 0; i < n; i++) {
    final t = i / _rate;
    final env = exp(-6.0 * t);
    final s = sin(2 * pi * 880 * t) * 0.6 + sin(2 * pi * 1760 * t) * 0.3 + sin(2 * pi * 2640 * t) * 0.1;
    out.add(vol * env * s);
  }
  return out;
}

List<double> _heartbeat({double vol = 0.65}) {
  final out = <double>[];
  void thump(double freq, double dur) {
    final n = (dur * _rate).round();
    for (var i = 0; i < n; i++) {
      final t = i / _rate;
      final env = sin(pi * (i / n)) * exp(-8.0 * t);
      out.add(vol * env * sin(2 * pi * freq * t));
    }
  }
  thump(85, 0.1);
  for (var i = 0; i < (0.08 * _rate).round(); i++) {
    out.add(0.0);
  }
  thump(65, 0.12);
  return out;
}

List<double> _impact({double vol = 0.7}) {
  final out = <double>[];
  const dur = 0.4;
  final n = (dur * _rate).round();
  for (var i = 0; i < n; i++) {
    final t = i / _rate;
    final env = exp(-7.0 * t);
    final s = sin(2 * pi * (120 - 40 * (t / dur)) * t) + 0.3 * sin(2 * pi * 55 * t);
    out.add(vol * env * s);
  }
  return out;
}

void main() {
  final dir = Directory('assets/sounds')..createSync(recursive: true);
  File('${dir.path}/click.wav').writeAsBytesSync(_wav(_click()));
  File('${dir.path}/pop.wav').writeAsBytesSync(_wav(_pop()));
  File('${dir.path}/whoosh.wav').writeAsBytesSync(_wav(_whoosh()));
  File('${dir.path}/bell.wav').writeAsBytesSync(_wav(_bell()));
  File('${dir.path}/heartbeat.wav').writeAsBytesSync(_wav(_heartbeat()));
  File('${dir.path}/impact.wav').writeAsBytesSync(_wav(_impact()));
  File('${dir.path}/tick.wav').writeAsBytesSync(_wav(_tone([(1200, 0.04)], vol: 0.35)));
  File('${dir.path}/suspense_tick.wav').writeAsBytesSync(_wav(_tone([(620, 0.05), (580, 0.04)], vol: 0.5)));
  File('${dir.path}/reveal.wav').writeAsBytesSync(_wav(_tone([
    (523.25, 0.06),
    (659.25, 0.06),
    (783.99, 0.08),
    (1046.5, 0.18),
  ], vol: 0.5)));
  File('${dir.path}/timeup.wav').writeAsBytesSync(
      _wav(_tone([(523, 0.16), (392, 0.16), (523, 0.16), (392, 0.35)], vol: 0.6)));
  File('${dir.path}/win.wav').writeAsBytesSync(
      _wav(_tone([(523, 0.1), (659, 0.1), (784, 0.1), (1047, 0.35)], vol: 0.55)));
  File('${dir.path}/lose.wav').writeAsBytesSync(
      _wav(_tone([(392, 0.18), (330, 0.18), (262, 0.4)], vol: 0.55)));
  File('${dir.path}/reward.wav').writeAsBytesSync(
      _wav(_tone([(587.33, 0.08), (739.99, 0.08), (880.0, 0.12), (1174.66, 0.35)], vol: 0.55)));
  stdout.writeln('Sounds generated successfully in ${dir.path}');
}
