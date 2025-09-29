import 'package:saavy_music/saavy_music.dart';
import 'package:test/test.dart';

void main() {
  group('Interval', () {
    test('named constructors have correct semitones', () {
      expect(Interval.unison().semitones, 0);
      expect(Interval.minorSecond().semitones, 1);
      expect(Interval.majorSecond().semitones, 2);
      expect(Interval.minorThird().semitones, 3);
      expect(Interval.majorThird().semitones, 4);
      expect(Interval.perfectFourth().semitones, 5);
      expect(Interval.tritone().semitones, 6);
      expect(Interval.diminishedFifth().semitones, 6);
      expect(Interval.augmentedFourth().semitones, 6);
      expect(Interval.perfectFifth().semitones, 7);
      expect(Interval.minorSixth().semitones, 8);
      expect(Interval.augmentedFifth().semitones, 8);
      expect(Interval.majorSixth().semitones, 9);
      expect(Interval.minorSeventh().semitones, 10);
      expect(Interval.majorSeventh().semitones, 11);
      expect(Interval.octave().semitones, 12);
      expect(Interval.minorNinth().semitones, 13);
      expect(Interval.majorNinth().semitones, 14);
      expect(Interval.augmentedNinth().semitones, 15);
      expect(Interval.perfectEleventh().semitones, 17);
      expect(Interval.augmentedEleventh().semitones, 18);
      expect(Interval.minorThirteenth().semitones, 20);
      expect(Interval.majorThirteenth().semitones, 21);
    });

    test('equality and hashCode based on semitones', () {
      expect(Interval.perfectFifth(), equals(Interval.perfectFifth()));
      expect(Interval.diminishedFifth(), equals(Interval.tritone()));
      expect(Interval.augmentedFourth(), equals(Interval.tritone()));
      expect(Interval.majorThird().hashCode, equals(4.hashCode));
    });

    test('random produces a known common interval', () {
      final rnd = Interval.random();
      expect(Interval.commonIntervals.any((i) => i.semitones == rnd.semitones), isTrue);
    });
  });
}
