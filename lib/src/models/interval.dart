import 'dart:math';

import 'package:meta/meta.dart';

const _intervals = [
  Interval.unison,
  Interval.minorSecond,
  Interval.majorSecond,
  Interval.minorThird,
  Interval.majorThird,
  Interval.perfectFourth,
  Interval.tritone,
  Interval.perfectFifth,
  Interval.minorSixth,
  Interval.majorSixth,
  Interval.minorSeventh,
  Interval.majorSeventh,
];

// ignore: unused_element
const _perfectIntervals = [Interval.unison, Interval.perfectFourth, Interval.perfectFifth, Interval.octave];

// ignore: unused_element
const _majorIntervals = [
  Interval.majorSecond,
  Interval.majorThird,
  Interval.perfectFourth,
  Interval.perfectFifth,
  Interval.majorSixth,
  Interval.majorSeventh,
];

// ignore: unused_element
const _minorIntervals = [
  Interval.minorSecond,
  Interval.minorThird,
  Interval.tritone,
  Interval.minorSixth,
  Interval.minorSeventh,
];

/// Represents a musical interval, defined by its semitone offset.
@immutable
class Interval {
  const Interval(this.semitones, this.name, this.shortName);

  // Common Intervals
  factory Interval.unison() => const Interval(0, "Unison", "P1");
  factory Interval.minorSecond() => const Interval(1, "Minor Second", "m2");
  factory Interval.majorSecond() => const Interval(2, "Major Second", "M2");
  factory Interval.minorThird() => const Interval(3, "Minor Third", "m3");
  factory Interval.majorThird() => const Interval(4, "Major Third", "M3");
  factory Interval.perfectFourth() => const Interval(5, "Perfect Fourth", "P4");
  factory Interval.tritone() => const Interval(6, "Tritone", "TT");
  factory Interval.diminishedFifth() => const Interval(6, "Diminished Fifth", "d5"); // Enharmonically same as tritone
  factory Interval.augmentedFourth() => const Interval(6, "Augmented Fourth", "A4"); // Enharmonically same as tritone
  factory Interval.perfectFifth() => const Interval(7, "Perfect Fifth", "P5");
  factory Interval.minorSixth() => const Interval(8, "Minor Sixth", "m6");
  factory Interval.augmentedFifth() => const Interval(8, "Augmented Fifth", "A5"); // Enharmonically same as minor sixth
  factory Interval.majorSixth() => const Interval(9, "Major Sixth", "M6");
  factory Interval.minorSeventh() => const Interval(10, "Minor Seventh", "m7");
  factory Interval.majorSeventh() => const Interval(11, "Major Seventh", "M7");
  factory Interval.octave() => const Interval(12, "Octave", "P8");
  factory Interval.minorNinth() => const Interval(13, "Minor Ninth", "m9");
  factory Interval.majorNinth() => const Interval(14, "Major Ninth", "M9");
  factory Interval.augmentedNinth() => const Interval(15, "Augmented Ninth", "A9");
  factory Interval.perfectEleventh() => const Interval(17, "Perfect Eleventh", "P11");
  factory Interval.augmentedEleventh() => const Interval(18, "Augmented Eleventh", "A11");
  factory Interval.minorThirteenth() => const Interval(20, "Minor Thirteenth", "m13");
  factory Interval.majorThirteenth() => const Interval(21, "Major Thirteenth", "M13");
  factory Interval.random() {
    final random = Random();
    return _intervals[random.nextInt(_intervals.length)]();
  }

  final int semitones;
  final String name; // e.g., "Major Third", "Perfect Fifth"
  final String shortName; // e.g., "M3", "P5"

  static final List<Interval> allIntervals = [
    Interval.unison(),
    Interval.minorSecond(),
    Interval.majorSecond(),
    Interval.minorThird(),
    Interval.majorThird(),
    Interval.perfectFourth(),
    Interval.tritone(),
    // diminishedFifth, // Often represented by tritone or specific chord context
    // augmentedFourth, // Often represented by tritone or specific chord context
    Interval.perfectFifth(),
    Interval.minorSixth(),
    // augmentedFifth, // Often represented by minorSixth or specific chord context
    Interval.majorSixth(),
    Interval.minorSeventh(),
    Interval.majorSeventh(),
    Interval.octave(),
    Interval.minorNinth(),
    Interval.majorNinth(),
    Interval.augmentedNinth(),
    Interval.perfectEleventh(),
    Interval.augmentedEleventh(),
    Interval.minorThirteenth(),
    Interval.majorThirteenth(),
  ];

  @override
  bool operator ==(final Object other) =>
      identical(this, other) || other is Interval && runtimeType == other.runtimeType && semitones == other.semitones;

  @override
  int get hashCode => semitones.hashCode;

  @override
  String toString() => name;

  /// Common intervals used for training exercises
  static List<Interval> get commonIntervals => [
        Interval.unison(),
        Interval.minorSecond(),
        Interval.majorSecond(),
        Interval.minorThird(),
        Interval.majorThird(),
        Interval.perfectFourth(),
        Interval.tritone(),
        Interval.perfectFifth(),
        Interval.minorSixth(),
        Interval.majorSixth(),
        Interval.minorSeventh(),
        Interval.majorSeventh(),
        Interval.octave(),
      ];
}
