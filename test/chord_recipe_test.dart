import 'package:saavy_music/saavy_music.dart';
import 'package:test/test.dart';

void main() {
  group('ChordRecipe', () {
    test('builds intervals correctly for major triad', () {
      const recipe = ChordRecipe(
        id: 'test_major',
        displayLabel: 'maj',
        fullName: 'Major Triad',
        triadQuality: TriadQuality.major,
      );

      final intervals = recipe.intervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 4); // Major third
      expect(intervals[1].semitones, 7); // Perfect fifth
    });

    test('builds intervals correctly for minor seventh', () {
      const recipe = ChordRecipe(
        id: 'test_minor_seventh',
        displayLabel: 'm7',
        fullName: 'Minor Seventh',
        triadQuality: TriadQuality.minor,
        extensions: {ChordExtension.minorSeventh},
      );

      final intervals = recipe.intervals;
      expect(intervals.length, 3);
      expect(intervals[0].semitones, 3); // Minor third
      expect(intervals[1].semitones, 7); // Perfect fifth
      expect(intervals[2].semitones, 10); // Minor seventh
    });

    test('sorts intervals by semitone value', () {
      const recipe = ChordRecipe(
        id: 'test_sorting',
        displayLabel: 'maj9',
        fullName: 'Major Ninth',
        triadQuality: TriadQuality.major,
        extensions: {ChordExtension.majorNinth, ChordExtension.majorSeventh}, // Added out of order
      );

      final intervals = recipe.intervals;
      final semitones = intervals.map((final i) => i.semitones).toList();
      expect(semitones, [4, 7, 11, 14]); // Sorted: M3, P5, M7, M9
    });

    test('equality works correctly', () {
      const recipe1 = ChordRecipe(
        id: 'test1',
        displayLabel: 'maj7',
        fullName: 'Major Seventh',
        triadQuality: TriadQuality.major,
        extensions: {ChordExtension.majorSeventh},
      );

      const recipe2 = ChordRecipe(
        id: 'test1',
        displayLabel: 'maj7',
        fullName: 'Major Seventh',
        triadQuality: TriadQuality.major,
        extensions: {ChordExtension.majorSeventh},
      );

      const recipe3 = ChordRecipe(
        id: 'test2', // Different ID
        displayLabel: 'maj7',
        fullName: 'Major Seventh',
        triadQuality: TriadQuality.major,
        extensions: {ChordExtension.majorSeventh},
      );

      expect(recipe1, equals(recipe2));
      expect(recipe1, isNot(equals(recipe3)));
    });

    test('toString returns display label', () {
      const recipe = ChordRecipe(
        id: 'test',
        displayLabel: 'dim7',
        fullName: 'Diminished Seventh',
        triadQuality: TriadQuality.diminished,
        extensions: {ChordExtension.addSixth},
      );

      expect(recipe.toString(), 'dim7');
    });
  });

  group('TriadQuality extension', () {
    test('major triad has correct intervals', () {
      final intervals = TriadQuality.major.baseIntervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 4); // Major third
      expect(intervals[1].semitones, 7); // Perfect fifth
    });

    test('minor triad has correct intervals', () {
      final intervals = TriadQuality.minor.baseIntervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 3); // Minor third
      expect(intervals[1].semitones, 7); // Perfect fifth
    });

    test('diminished triad has correct intervals', () {
      final intervals = TriadQuality.diminished.baseIntervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 3); // Minor third
      expect(intervals[1].semitones, 6); // Diminished fifth
    });

    test('augmented triad has correct intervals', () {
      final intervals = TriadQuality.augmented.baseIntervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 4); // Major third
      expect(intervals[1].semitones, 8); // Augmented fifth
    });

    test('sus2 has correct intervals', () {
      final intervals = TriadQuality.suspendedSecond.baseIntervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 2); // Major second
      expect(intervals[1].semitones, 7); // Perfect fifth
    });

    test('sus4 has correct intervals', () {
      final intervals = TriadQuality.suspendedFourth.baseIntervals;
      expect(intervals.length, 2);
      expect(intervals[0].semitones, 5); // Perfect fourth
      expect(intervals[1].semitones, 7); // Perfect fifth
    });

    test('suffix labels are correct', () {
      expect(TriadQuality.major.suffix, '');
      expect(TriadQuality.minor.suffix, 'm');
      expect(TriadQuality.diminished.suffix, 'dim');
      expect(TriadQuality.augmented.suffix, 'aug');
      expect(TriadQuality.suspendedSecond.suffix, 'sus2');
      expect(TriadQuality.suspendedFourth.suffix, 'sus4');
    });
  });

  group('ChordExtension extension', () {
    test('extension intervals are correct', () {
      expect(ChordExtension.addSixth.interval.semitones, 9); // Major sixth
      expect(ChordExtension.minorSeventh.interval.semitones, 10);
      expect(ChordExtension.majorSeventh.interval.semitones, 11);
      expect(ChordExtension.minorNinth.interval.semitones, 13);
      expect(ChordExtension.majorNinth.interval.semitones, 14);
      expect(ChordExtension.augmentedNinth.interval.semitones, 15);
      expect(ChordExtension.perfectEleventh.interval.semitones, 17);
      expect(ChordExtension.augmentedEleventh.interval.semitones, 18);
      expect(ChordExtension.minorThirteenth.interval.semitones, 20);
      expect(ChordExtension.majorThirteenth.interval.semitones, 21);
    });

    test('extension suffixes are correct', () {
      expect(ChordExtension.addSixth.suffix, '6');
      expect(ChordExtension.minorSeventh.suffix, '7');
      expect(ChordExtension.majorSeventh.suffix, 'maj7');
      expect(ChordExtension.minorNinth.suffix, 'b9');
      expect(ChordExtension.majorNinth.suffix, '9');
      expect(ChordExtension.augmentedNinth.suffix, '#9');
      expect(ChordExtension.perfectEleventh.suffix, '11');
      expect(ChordExtension.augmentedEleventh.suffix, '#11');
      expect(ChordExtension.minorThirteenth.suffix, 'b13');
      expect(ChordExtension.majorThirteenth.suffix, '13');
    });
  });

  group('ChordRecipes predefined constants', () {
    test('triads collection contains basic triads', () {
      expect(ChordRecipes.triads.length, 6);
      expect(ChordRecipes.triads, contains(ChordRecipes.majorTriad));
      expect(ChordRecipes.triads, contains(ChordRecipes.minorTriad));
      expect(ChordRecipes.triads, contains(ChordRecipes.diminishedTriad));
      expect(ChordRecipes.triads, contains(ChordRecipes.augmentedTriad));
      expect(ChordRecipes.triads, contains(ChordRecipes.sus2));
      expect(ChordRecipes.triads, contains(ChordRecipes.sus4));
    });

    test('sevenths collection contains seventh chords', () {
      expect(ChordRecipes.sevenths.length, 7);
      expect(ChordRecipes.sevenths, contains(ChordRecipes.majorSeventh));
      expect(ChordRecipes.sevenths, contains(ChordRecipes.minorSeventh));
      expect(ChordRecipes.sevenths, contains(ChordRecipes.dominantSeventh));
      expect(ChordRecipes.sevenths, contains(ChordRecipes.diminishedSeventh));
      expect(ChordRecipes.sevenths, contains(ChordRecipes.halfDiminishedSeventh));
      expect(ChordRecipes.sevenths, contains(ChordRecipes.majorSixth));
      expect(ChordRecipes.sevenths, contains(ChordRecipes.minorSixth));
    });

    test('extensions collection contains extended chords', () {
      expect(ChordRecipes.extensions.length, 7);
      expect(ChordRecipes.extensions, contains(ChordRecipes.majorNinth));
      expect(ChordRecipes.extensions, contains(ChordRecipes.minorNinth));
      expect(ChordRecipes.extensions, contains(ChordRecipes.dominantNinth));
      expect(ChordRecipes.extensions, contains(ChordRecipes.dominantFlatNinth));
      expect(ChordRecipes.extensions, contains(ChordRecipes.dominantSharpNinth));
      expect(ChordRecipes.extensions, contains(ChordRecipes.addNine));
      expect(ChordRecipes.extensions, contains(ChordRecipes.minorAddNine));
    });

    test('all collection contains everything', () {
      final expectedTotal = ChordRecipes.triads.length + ChordRecipes.sevenths.length + ChordRecipes.extensions.length;
      expect(ChordRecipes.all.length, expectedTotal);
    });

    test('predefined recipes have correct properties', () {
      // Test a few key examples
      expect(ChordRecipes.majorTriad.id, 'major_triad');
      expect(ChordRecipes.majorTriad.displayLabel, 'maj');
      expect(ChordRecipes.majorTriad.triadQuality, TriadQuality.major);
      expect(ChordRecipes.majorTriad.extensions, isEmpty);

      expect(ChordRecipes.dominantSeventh.id, 'dominant_seventh');
      expect(ChordRecipes.dominantSeventh.displayLabel, '7');
      expect(ChordRecipes.dominantSeventh.triadQuality, TriadQuality.major);
      expect(ChordRecipes.dominantSeventh.extensions, {ChordExtension.minorSeventh});

      expect(ChordRecipes.addNine.id, 'add_nine');
      expect(ChordRecipes.addNine.displayLabel, 'add9');
      expect(ChordRecipes.addNine.triadQuality, TriadQuality.major);
      expect(ChordRecipes.addNine.extensions, {ChordExtension.majorNinth});
    });
  });
}
