import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saavy_music/src/theory/accidental.dart';

/// Diatonic scale degrees (1 through 7).
enum DiatonicDegree { one, two, three, four, five, six, seven }

String _romanNumeral(final DiatonicDegree degree) {
  switch (degree) {
    case DiatonicDegree.one:
      return 'I';
    case DiatonicDegree.two:
      return 'II';
    case DiatonicDegree.three:
      return 'III';
    case DiatonicDegree.four:
      return 'IV';
    case DiatonicDegree.five:
      return 'V';
    case DiatonicDegree.six:
      return 'VI';
    case DiatonicDegree.seven:
      return 'VII';
  }
}

/// Represents a scale degree (roman numeral) with optional accidental.
@immutable
class ScaleDegree {
  const ScaleDegree(this.degree, {this.accidental = Accidental.natural});

  final DiatonicDegree degree;
  final Accidental accidental;

  /// -1 for flat, 0 for natural, 1 for sharp.
  int get accidentalSemitones => accidentalOffset(accidental);

  String get _accidentalPrefix {
    return switch (accidental) {
      Accidental.doubleFlat => 'bb',
      Accidental.flat => 'b',
      Accidental.natural => '',
      Accidental.sharp => '#',
      Accidental.doubleSharp => '##',
    };
  }

  String romanNumeral({final bool lowercase = false}) {
    final numeral = _romanNumeral(degree);
    return lowercase ? numeral.toLowerCase() : numeral;
  }

  String formatLabel({final bool lowercase = false}) => '$_accidentalPrefix${romanNumeral(lowercase: lowercase)}';

  /// Returns a display label such as `bII`, `#IV`, or `V`.
  String get label => formatLabel();

  ScaleDegree withAccidental(final Accidental next) => ScaleDegree(degree, accidental: next);
  ScaleDegree flat() => withAccidental(Accidental.flat);
  ScaleDegree sharp() => withAccidental(Accidental.sharp);
  ScaleDegree doubleFlat() => withAccidental(Accidental.doubleFlat);
  ScaleDegree doubleSharp() => withAccidental(Accidental.doubleSharp);

  @override
  String toString() => 'ScaleDegree($label)';

  @override
  bool operator ==(covariant final ScaleDegree other) =>
      identical(this, other) || (degree == other.degree && accidental == other.accidental);

  @override
  int get hashCode => Object.hash(degree, accidental);
}

/// Convenience constructors for common roman numerals.
class Degrees {
  const Degrees._();

  static const ScaleDegree i = ScaleDegree(DiatonicDegree.one);
  static const ScaleDegree ii = ScaleDegree(DiatonicDegree.two);
  static const ScaleDegree iii = ScaleDegree(DiatonicDegree.three);
  static const ScaleDegree iv = ScaleDegree(DiatonicDegree.four);
  static const ScaleDegree v = ScaleDegree(DiatonicDegree.five);
  static const ScaleDegree vi = ScaleDegree(DiatonicDegree.six);
  static const ScaleDegree vii = ScaleDegree(DiatonicDegree.seven);
}
