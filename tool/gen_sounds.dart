// Generates the tiny original sound effects used by the app as 16-bit PCM
// WAV files in assets/sounds/. Usage: dart run tool/gen_sounds.dart
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
      final env = min(1.0, i / 300) * exp(-3.5 * t / d);
      out.add(vol * env * (sin(2 * pi * f * t) + 0.3 * sin(4 * pi * f * t)));
    }
  }
  return out;
}

void main() {
  final dir = Directory('assets/sounds')..createSync(recursive: true);
  File('${dir.path}/tick.wav').writeAsBytesSync(_wav(_tone([(1200, 0.05)], vol: 0.35)));
  File('${dir.path}/reveal.wav').writeAsBytesSync(_wav(_tone([(660, 0.08), (880, 0.12)])));
  File('${dir.path}/timeup.wav').writeAsBytesSync(
      _wav(_tone([(523, 0.18), (392, 0.18), (523, 0.18), (392, 0.35)], vol: 0.6)));
  File('${dir.path}/win.wav').writeAsBytesSync(
      _wav(_tone([(523, 0.12), (659, 0.12), (784, 0.12), (1047, 0.4)], vol: 0.55)));
  File('${dir.path}/lose.wav').writeAsBytesSync(
      _wav(_tone([(392, 0.2), (330, 0.2), (262, 0.45)], vol: 0.55)));
  stdout.writeln('Sounds written to ${dir.path}');
}
