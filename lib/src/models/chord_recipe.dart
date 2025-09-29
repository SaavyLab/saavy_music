import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saavy_music/src/models/interval.dart';

/// The quality of a triad (three-note chord) that defines its basic harmonic character.
///
/// This enum represents the fundamental building blocks of chord harmony, focusing on
/// the intervallic relationships that create different chord qualities.
enum TriadQuality {
  /// Major triad: root + major third + perfect fifth
  major,

  /// Minor triad: root + minor third + perfect fifth
  minor,

  /// Diminished triad: root + minor third + diminished fifth
  diminished,

  /// Augmented triad: root + major third + augmented fifth
  augmented,

  /// Suspended second: root + major second + perfect fifth (replaces third)
  suspendedSecond,

  /// Suspended fourth: root + perfect fourth + perfect fifth (replaces third)
  suspendedFourth,
}

extension TriadQualityX on TriadQuality {
  List<Interval> get baseIntervals {
    switch (this) {
      case TriadQuality.major:
        return [Interval.majorThird(), Interval.perfectFifth()];
      case TriadQuality.minor:
        return [Interval.minorThird(), Interval.perfectFifth()];
      case TriadQuality.diminished:
        return [Interval.minorThird(), Interval.diminishedFifth()];
      case TriadQuality.augmented:
        return [Interval.majorThird(), Interval.augmentedFifth()];
      case TriadQuality.suspendedSecond:
        return [Interval.majorSecond(), Interval.perfectFifth()];
      case TriadQuality.suspendedFourth:
        return [Interval.perfectFourth(), Interval.perfectFifth()];
    }
  }

  String get suffix {
    switch (this) {
      case TriadQuality.major:
        return '';
      case TriadQuality.minor:
        return 'm';
      case TriadQuality.diminished:
        return 'dim';
      case TriadQuality.augmented:
        return 'aug';
      case TriadQuality.suspendedSecond:
        return 'sus2';
      case TriadQuality.suspendedFourth:
        return 'sus4';
    }
  }

  bool get isLowercaseLabel {
    switch (this) {
      case TriadQuality.augmented:
      case TriadQuality.suspendedSecond:
      case TriadQuality.suspendedFourth:
      case TriadQuality.major:
        return false;
      case TriadQuality.minor:
      case TriadQuality.diminished:
        return true;
    }
  }
}

extension ChordRecipeRomanLabelX on ChordRecipe {
  String get romanNumeralSuffix {
    final baseSymbol = switch (triadQuality) {
      TriadQuality.major => '',
      TriadQuality.minor => '',
      TriadQuality.diminished => '°',
      TriadQuality.augmented => '+',
      TriadQuality.suspendedSecond => 'sus2',
      TriadQuality.suspendedFourth => 'sus4',
    };

    if (extensions.isEmpty) {
      return baseSymbol;
    }

    if (triadQuality == TriadQuality.diminished) {
      final hasAddSixth = extensions.contains(ChordExtension.addSixth);
      final hasMinorSeventh = extensions.contains(ChordExtension.minorSeventh);

      if (hasMinorSeventh) {
        return '${baseSymbol}7';
      }

      if (hasAddSixth) {
        return baseSymbol;
      }
    }

    final suffixes = extensions.map((final extension) => extension.suffix).toList()
      ..sort((final a, final b) => a.compareTo(b));
    final combined = suffixes.join();

    return '$baseSymbol$combined';
  }
}

/// Extensions that can be added to a triad to create more complex harmonies.
///
/// Each extension represents an additional interval that can be added to a basic triad.
/// Extensions allow for flexible, programmatic chord construction without requiring
/// hardcoded chord types for every possible combination.
enum ChordExtension {
  /// Major sixth interval (9 semitones)
  addSixth,

  /// Minor seventh interval (10 semitones) - creates dominant and minor 7th chords
  minorSeventh,

  /// Major seventh interval (11 semitones) - creates major 7th chords
  majorSeventh,

  /// Minor ninth interval (13 semitones) - creates flat 9 chords
  minorNinth,

  /// Major ninth interval (14 semitones) - creates 9th and add9 chords
  majorNinth,

  /// Augmented ninth interval (15 semitones) - creates sharp 9 chords
  augmentedNinth,

  /// Perfect eleventh interval (17 semitones) - creates 11th chords
  perfectEleventh,

  /// Augmented eleventh interval (18 semitones) - creates sharp 11 chords
  augmentedEleventh,

  /// Minor thirteenth interval (20 semitones) - creates flat 13 chords
  minorThirteenth,

  /// Major thirteenth interval (21 semitones) - creates 13th chords
  majorThirteenth,
}

extension ChordExtensionX on ChordExtension {
  Interval get interval {
    switch (this) {
      case ChordExtension.addSixth:
        return Interval.majorSixth();
      case ChordExtension.minorSeventh:
        return Interval.minorSeventh();
      case ChordExtension.majorSeventh:
        return Interval.majorSeventh();
      case ChordExtension.minorNinth:
        return Interval.minorNinth();
      case ChordExtension.majorNinth:
        return Interval.majorNinth();
      case ChordExtension.augmentedNinth:
        return Interval.augmentedNinth();
      case ChordExtension.perfectEleventh:
        return Interval.perfectEleventh();
      case ChordExtension.augmentedEleventh:
        return Interval.augmentedEleventh();
      case ChordExtension.minorThirteenth:
        return Interval.minorThirteenth();
      case ChordExtension.majorThirteenth:
        return Interval.majorThirteenth();
    }
  }

  String get suffix {
    switch (this) {
      case ChordExtension.addSixth:
        return '6';
      case ChordExtension.minorSeventh:
        return '7';
      case ChordExtension.majorSeventh:
        return 'maj7';
      case ChordExtension.minorNinth:
        return 'b9';
      case ChordExtension.majorNinth:
        return '9';
      case ChordExtension.augmentedNinth:
        return '#9';
      case ChordExtension.perfectEleventh:
        return '11';
      case ChordExtension.augmentedEleventh:
        return '#11';
      case ChordExtension.minorThirteenth:
        return 'b13';
      case ChordExtension.majorThirteenth:
        return '13';
    }
  }
}

/// A recipe for constructing chords based on triad quality and extensions.
///
/// ChordRecipe represents a shape-based approach to chord modeling, focusing on
/// harmonic relationships rather than absolute pitches. This design supports the
/// core goal of ear training: users should learn chord qualities and relationships
/// (like "I-IV-V-I" and "maj7 vs m7") rather than absolute pitches.
///
/// Example usage:
/// ```dart
/// const recipe = ChordRecipe(
///   id: 'dominant_seventh',
///   displayLabel: '7',
///   triadQuality: TriadQuality.major,
///   extensions: {ChordExtension.minorSeventh},
/// );
///
/// final chord = Chord.fromRecipe(Note.fromName('g4'), recipe);
/// // Creates a G7 chord
/// ```
@immutable
class ChordRecipe {
  /// Creates a chord recipe with the specified quality and extensions.
  ///
  /// The [id] should be a unique identifier for this recipe type.
  /// The [displayLabel] is used in UI components and chord naming.
  /// The [triadQuality] defines the basic three-note structure.
  /// The [extensions] set adds additional intervals beyond the basic triad.
  const ChordRecipe({
    required this.id,
    required this.displayLabel,
    required this.fullName,
    required this.triadQuality,
    this.extensions = const <ChordExtension>{},
  });

  /// Unique identifier for this chord recipe (e.g., 'major_seventh', 'minor_triad').
  final String id;

  /// Display label used in UI and chord naming (e.g., 'maj7', 'm', 'dim').
  final String displayLabel;

  final String fullName;

  /// The basic triad quality that forms the foundation of this chord.
  final TriadQuality triadQuality;

  /// Set of extensions to add beyond the basic triad.
  final Set<ChordExtension> extensions;

  /// Builds the complete list of intervals for this chord recipe.
  ///
  /// Combines the base triad intervals with any extensions, ensuring no duplicate
  /// intervals (by semitone value) and sorting the result by ascending semitone count.
  ///
  /// Returns a list of intervals suitable for creating a [Chord] object.
  List<Interval> get intervals {
    final intervals = <Interval>[];
    intervals.addAll(triadQuality.baseIntervals);
    final seen = intervals.map((final interval) => interval.semitones).toSet();
    for (final extension in extensions) {
      final interval = extension.interval;
      if (seen.add(interval.semitones)) {
        intervals.add(interval);
      }
    }
    intervals.sort((final a, final b) => a.semitones.compareTo(b.semitones));
    return intervals;
  }

  @override
  String toString() => displayLabel;
}

/// Predefined chord recipes organized by difficulty and complexity.
///
/// This class provides a curated collection of chord recipes suitable for ear training.
/// Recipes are grouped into logical collections (triads, sevenths, extensions) that
/// correspond to progressive difficulty levels in harmonic ear training.
///
/// Example usage:
/// ```dart
/// // Use predefined recipes in UI
/// final triadOptions = ChordRecipes.triads;
///
/// // Create specific chord instances
/// final chord = Chord.fromRecipe(root, ChordRecipes.majorSeventh);
/// ```
class ChordRecipes {
  // ===== TRIADS =====
  static const majorTriad = ChordRecipe(
    id: 'major_triad',
    displayLabel: 'maj',
    fullName: 'Major Triad',
    triadQuality: TriadQuality.major,
  );

  static const minorTriad = ChordRecipe(
    id: 'minor_triad',
    displayLabel: 'm',
    fullName: 'Minor Triad',
    triadQuality: TriadQuality.minor,
  );

  static const diminishedTriad = ChordRecipe(
    id: 'diminished_triad',
    displayLabel: 'dim',
    fullName: 'Diminished Triad',
    triadQuality: TriadQuality.diminished,
  );

  static const augmentedTriad = ChordRecipe(
    id: 'augmented_triad',
    displayLabel: 'aug',
    fullName: 'Augmented Triad',
    triadQuality: TriadQuality.augmented,
  );

  static const sus2 = ChordRecipe(
    id: 'sus2',
    displayLabel: 'sus2',
    fullName: 'Suspended Second',
    triadQuality: TriadQuality.suspendedSecond,
  );

  static const sus4 = ChordRecipe(
    id: 'sus4',
    displayLabel: 'sus4',
    fullName: 'Suspended Fourth',
    triadQuality: TriadQuality.suspendedFourth,
  );

  // ===== SEVENTHS =====
  static const majorSeventh = ChordRecipe(
    id: 'major_seventh',
    displayLabel: 'maj7',
    fullName: 'Major Seventh',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.majorSeventh},
  );

  static const minorSeventh = ChordRecipe(
    id: 'minor_seventh',
    displayLabel: 'm7',
    fullName: 'Minor Seventh',
    triadQuality: TriadQuality.minor,
    extensions: {ChordExtension.minorSeventh},
  );

  static const dominantSeventh = ChordRecipe(
    id: 'dominant_seventh',
    displayLabel: '7',
    fullName: 'Dominant Seventh',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.minorSeventh},
  );

  static const diminishedSeventh = ChordRecipe(
    id: 'diminished_seventh',
    displayLabel: 'dim7',
    fullName: 'Diminished Seventh',
    triadQuality: TriadQuality.diminished,
    extensions: {ChordExtension.addSixth}, // dim7 uses major 6th interval (enharmonic with dim7)
  );

  static const halfDiminishedSeventh = ChordRecipe(
    id: 'half_diminished_seventh',
    displayLabel: 'm7♭5',
    fullName: 'Half Diminished Seventh',
    triadQuality: TriadQuality.diminished,
    extensions: {ChordExtension.minorSeventh},
  );

  static const majorSixth = ChordRecipe(
    id: 'major_sixth',
    displayLabel: '6',
    fullName: 'Major Sixth',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.addSixth},
  );

  static const minorSixth = ChordRecipe(
    id: 'minor_sixth',
    displayLabel: 'm6',
    fullName: 'Minor Sixth',
    triadQuality: TriadQuality.minor,
    extensions: {ChordExtension.addSixth},
  );

  // ===== EXTENSIONS =====
  static const majorNinth = ChordRecipe(
    id: 'major_ninth',
    displayLabel: 'maj9',
    fullName: 'Major Ninth',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.majorSeventh, ChordExtension.majorNinth},
  );

  static const minorNinth = ChordRecipe(
    id: 'minor_ninth',
    displayLabel: 'm9',
    fullName: 'Minor Ninth',
    triadQuality: TriadQuality.minor,
    extensions: {ChordExtension.minorSeventh, ChordExtension.majorNinth},
  );

  static const dominantNinth = ChordRecipe(
    id: 'dominant_ninth',
    displayLabel: '9',
    fullName: 'Dominant Ninth',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.minorSeventh, ChordExtension.majorNinth},
  );

  static const dominantFlatNinth = ChordRecipe(
    id: 'dominant_flat_ninth',
    displayLabel: '7♭9',
    fullName: 'Dominant Flat Ninth',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.minorSeventh, ChordExtension.minorNinth},
  );

  static const dominantSharpNinth = ChordRecipe(
    id: 'dominant_sharp_ninth',
    displayLabel: '7♯9',
    fullName: 'Dominant Sharp Ninth',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.minorSeventh, ChordExtension.augmentedNinth},
  );

  static const addNine = ChordRecipe(
    id: 'add_nine',
    displayLabel: 'add9',
    fullName: 'Add Nine',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.majorNinth},
  );

  static const minorAddNine = ChordRecipe(
    id: 'minor_add_nine',
    displayLabel: 'madd9',
    fullName: 'Minor Add Nine',
    triadQuality: TriadQuality.minor,
    extensions: {ChordExtension.majorNinth},
  );

  // ===== COLLECTIONS FOR UI =====
  static const List<ChordRecipe> triads = [majorTriad, minorTriad, diminishedTriad, augmentedTriad, sus2, sus4];

  static const List<ChordRecipe> sevenths = [
    majorSeventh,
    minorSeventh,
    dominantSeventh,
    diminishedSeventh,
    halfDiminishedSeventh,
    majorSixth,
    minorSixth,
  ];

  static const List<ChordRecipe> extensions = [
    majorNinth,
    minorNinth,
    dominantNinth,
    dominantFlatNinth,
    dominantSharpNinth,
    addNine,
    minorAddNine,
  ];

  static const List<ChordRecipe> all = [...triads, ...sevenths, ...extensions];
}
