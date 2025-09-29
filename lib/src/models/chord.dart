import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saavy_music/src/models/chord_recipe.dart';
import 'package:saavy_music/src/models/interval.dart';
import 'package:saavy_music/src/models/note.dart';

/// Represents a chord (multiple notes played together)
@immutable
class Chord {
  Chord({required this.root, required final List<Interval> intervals, this.inversion = 0, final String? name})
    : intervals = List<Interval>.unmodifiable(
        intervals..sort((final a, final b) => a.semitones.compareTo(b.semitones)),
      ),
      _name = name {
    if (inversion < 0 || inversion >= (intervals.length + 1)) {
      throw ArgumentError('Inversion level must be between 0 and ${intervals.length}');
    }
  }

  /// Creates a chord from a ChordRecipe
  factory Chord.fromRecipe(
    final Note root,
    final ChordRecipe recipe, {
    final int inversion = 0,
    final String? explicitName,
  }) {
    return Chord(
      root: root,
      intervals: recipe.intervals,
      inversion: inversion,
      name: explicitName ?? '${root.name}${recipe.displayLabel}',
    );
  }

  // Common chord type convenience constructors using ChordRecipe
  factory Chord.major(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.majorTriad, inversion: inversion);
  factory Chord.minor(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.minorTriad, inversion: inversion);
  factory Chord.diminished(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.diminishedTriad, inversion: inversion);
  factory Chord.augmented(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.augmentedTriad, inversion: inversion);
  factory Chord.majorSeventh(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.majorSeventh, inversion: inversion);
  factory Chord.minorSeventh(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.minorSeventh, inversion: inversion);
  factory Chord.dominantSeventh(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.dominantSeventh, inversion: inversion);
  factory Chord.susTwo(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.sus2, inversion: inversion);
  factory Chord.susFour(final Note root, {final int inversion = 0}) =>
      Chord.fromRecipe(root, ChordRecipes.sus4, inversion: inversion);
  final Note root;
  final List<Interval> intervals; // Intervals from the root
  final int inversion; // 0 for root position, 1 for first inversion, etc.
  final String? _name;

  /// Notes that make up this chord, considering inversion.
  List<Note> get notes {
    final baseNotes = [
      root,
      ...intervals.map(
        (final interval) => Note(
          midiNumber: root.midiNumber + interval.semitones,
          velocity: root.velocity, // Assuming same velocity for all notes for now
        ),
      ),
    ];

    if (inversion == 0 || baseNotes.length <= 1) {
      return baseNotes;
    }

    final numNotes = baseNotes.length;
    final actualInversion = inversion % numNotes;

    final List<Note> invertedNotes = [];
    for (int i = 0; i < numNotes; i++) {
      final Note originalNote = baseNotes[(i + actualInversion) % numNotes];
      final int octaveShift = (i + actualInversion) ~/ numNotes;
      invertedNotes.add(
        Note(midiNumber: originalNote.midiNumber + (octaveShift * 12), velocity: originalNote.velocity),
      );
    }
    return invertedNotes;
  }

  /// Optional chord name (e.g., "Cmaj7", "Dm/F#")
  String get name {
    if (_name != null) return _name;

    final String baseName = root.name;
    final String suffix = intervals.map((final i) => i.shortName).join('-'); // Simple default
    final name = '$baseName$suffix';
    if (inversion > 0 && notes.length > 1) {
      // Find the actual bass note after inversion
      final bassNote = notes.first; // After inversion, the first note is the bass
      return '$name/${bassNote.name}';
    }
    return name;
  }

  /// Returns a new Chord with the specified inversion.
  Chord invert(final int newInversion) {
    // Create a new name or clear the existing one so it gets re-calculated
    return Chord(root: root, intervals: intervals, inversion: newInversion);
  }

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Chord &&
          runtimeType == other.runtimeType &&
          root == other.root &&
          const ListEquality<Interval>().equals(intervals, other.intervals) &&
          inversion == other.inversion;

  @override
  int get hashCode => root.hashCode ^ const ListEquality<Interval>().hash(intervals) ^ inversion.hashCode;

  @override
  String toString() => name;
}
