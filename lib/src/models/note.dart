import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'package:saavy_music/src/theory/accidental.dart';

/// Note names (A through G)
enum NoteName { c, d, e, f, g, a, b }

/// represents a musical note with midi number and frequency
@immutable
class Note {
  const Note({required this.midiNumber, this.velocity = 80, this.explicitNoteName, this.explicitAccidental})
      : assert(midiNumber >= 0 && midiNumber <= 127),
        assert(velocity >= 0 && velocity <= 127),
        assert(
          (explicitNoteName == null) == (explicitAccidental == null),
          'explicitNoteName and explicitAccidental must either both be null or both be provided.',
        );

  /// Natural semitone offsets for note names.
  static const Map<NoteName, int> _naturalSemitoneOffsets = {
    NoteName.c: 0,
    NoteName.d: 2,
    NoteName.e: 4,
    NoteName.f: 5,
    NoteName.g: 7,
    NoteName.a: 9,
    NoteName.b: 11,
  };

  /// Create a note from name, octave, and accidental
  factory Note.fromComponents({
    required final NoteName noteName,
    required final int octave,
    final Accidental accidental = Accidental.natural,
    final int velocity = 80,
  }) {
    // Calculate MIDI: (octave + 1) * 12 + baseNote + accidental
    final midiNumber = (octave + 1) * 12 + _naturalSemitoneOffsets[noteName]! + accidentalOffset(accidental);

    // Clamp to valid MIDI range
    final int clampedMidi;
    bool wasClamped = false;
    if (midiNumber < 0) {
      clampedMidi = 0;
      wasClamped = true;
    } else if (midiNumber > 127) {
      clampedMidi = 127;
      wasClamped = true;
    } else {
      clampedMidi = midiNumber;
    }

    return Note(
      midiNumber: clampedMidi,
      velocity: velocity,
      explicitNoteName: wasClamped ? null : noteName,
      explicitAccidental: wasClamped ? null : accidental,
    );
  }

  /// Convenience factory constructors for common notes
  factory Note.c(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.c, octave: octave, accidental: accidental, velocity: velocity);
  factory Note.d(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.d, octave: octave, accidental: accidental, velocity: velocity);
  factory Note.e(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.e, octave: octave, accidental: accidental, velocity: velocity);
  factory Note.f(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.f, octave: octave, accidental: accidental, velocity: velocity);
  factory Note.g(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.g, octave: octave, accidental: accidental, velocity: velocity);
  factory Note.a(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.a, octave: octave, accidental: accidental, velocity: velocity);
  factory Note.b(final int octave, {final Accidental accidental = Accidental.natural, final int velocity = 80}) =>
      Note.fromComponents(noteName: NoteName.b, octave: octave, accidental: accidental, velocity: velocity);

  factory Note.random({final int upperLimit = 127, final int lowerLimit = 0}) {
    final randomMidi = math.Random().nextInt(upperLimit - lowerLimit + 1) + lowerLimit;
    return Note(midiNumber: randomMidi);
  }

  /// midi note number (0-127)
  /// middle c (c4) = 60
  final int midiNumber;

  /// velocity (0-127) - how hard the note is played
  final int velocity;

  /// Optional explicit spelling captured at construction time.
  final NoteName? explicitNoteName;
  final Accidental? explicitAccidental;

  /// get frequency in hz for this note
  double get frequency {
    // a4 (midi 69) = 440 hz
    return math.pow(2, (midiNumber - 69) / 12) * 440.0;
  }

  /// get note name (e.g., "c4", "f#5") - defaults to sharp spelling
  String get name {
    final explicit = _nameFromExplicitSpelling();
    if (explicit != null) {
      return explicit;
    }

    const noteNames = ['c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#', 'a', 'a#', 'b'];
    final octave = (midiNumber ~/ 12) - 1;
    final noteName = noteNames[midiNumber % 12];
    return '$noteName$octave';
  }

  String? _nameFromExplicitSpelling() {
    if (explicitNoteName == null || explicitAccidental == null) {
      return null;
    }

    final accidentalValue = accidentalOffset(explicitAccidental!);
    final baseOffset = _naturalSemitoneOffsets[explicitNoteName!]!;
    final baseMidi = midiNumber - accidentalValue;
    final difference = baseMidi - baseOffset;
    final octave = _octaveFromDifference(difference);
    final accidentalStr = _accidentalString(accidentalValue);
    return '${explicitNoteName!.name}$accidentalStr$octave';
  }

  /// Get note name with specified enharmonic spelling preference
  String nameWithSpelling({required bool preferFlats}) {
    final octave = (midiNumber ~/ 12) - 1;
    final noteIndex = midiNumber % 12;

    if (preferFlats) {
      const flatNames = ['c', 'db', 'd', 'eb', 'e', 'f', 'gb', 'g', 'ab', 'a', 'bb', 'b'];
      return '${flatNames[noteIndex]}$octave';
    } else {
      const sharpNames = ['c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#', 'a', 'a#', 'b'];
      return '${sharpNames[noteIndex]}$octave';
    }
  }

  /// Get the components of this note
  (NoteName noteName, int octave, Accidental accidental) get components {
    if (explicitNoteName != null && explicitAccidental != null) {
      final accidentalValue = accidentalOffset(explicitAccidental!);
      final baseOffset = _naturalSemitoneOffsets[explicitNoteName!]!;
      final baseMidi = midiNumber - accidentalValue;
      final difference = baseMidi - baseOffset;
      final octave = _octaveFromDifference(difference);
      return (explicitNoteName!, octave, explicitAccidental!);
    }

    final octave = (midiNumber ~/ 12) - 1;
    final noteIndex = midiNumber % 12;

    // Map MIDI note to natural note names with appropriate accidentals
    final (noteName, accidental) = switch (noteIndex) {
      0 => (NoteName.c, Accidental.natural),
      1 => (NoteName.c, Accidental.sharp),
      2 => (NoteName.d, Accidental.natural),
      3 => (NoteName.d, Accidental.sharp),
      4 => (NoteName.e, Accidental.natural),
      5 => (NoteName.f, Accidental.natural),
      6 => (NoteName.f, Accidental.sharp),
      7 => (NoteName.g, Accidental.natural),
      8 => (NoteName.g, Accidental.sharp),
      9 => (NoteName.a, Accidental.natural),
      10 => (NoteName.a, Accidental.sharp),
      11 => (NoteName.b, Accidental.natural),
      _ => throw StateError('Invalid note index: $noteIndex'),
    };

    return (noteName, octave, accidental);
  }

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && midiNumber == other.midiNumber && velocity == other.velocity;

  @override
  int get hashCode => Object.hash(midiNumber, velocity);
}

/// A note that knows its context within a key signature for proper enharmonic spelling
@immutable
class KeyAwareNote extends Note {
  const KeyAwareNote({
    required super.midiNumber,
    super.velocity,
    required this.expectedNoteName,
    required this.expectedAccidentalOffset,
    required this.expectedOctave,
  });

  /// The expected note name based on key context (e.g., D in D♭ major)
  final NoteName expectedNoteName;

  /// Total accidental offset in semitones relative to the natural note.
  final int expectedAccidentalOffset;

  /// The diatonic octave to report for this note.
  final int expectedOctave;

  @override
  String get name {
    final accidentalStr = _accidentalString(expectedAccidentalOffset);
    return '${expectedNoteName.name}$accidentalStr$expectedOctave';
  }

  /// Get the components with key-aware spelling
  @override
  (NoteName noteName, int octave, Accidental accidental) get components {
    final accidental = _accidentalFromOffset(expectedAccidentalOffset);
    return (expectedNoteName, expectedOctave, accidental);
  }

  static Accidental _accidentalFromOffset(final int offset) {
    if (offset <= -2) {
      return Accidental.doubleFlat;
    }
    if (offset == -1) {
      return Accidental.flat;
    }
    if (offset == 0) {
      return Accidental.natural;
    }
    if (offset == 1) {
      return Accidental.sharp;
    }
    return Accidental.doubleSharp;
  }
}

int _octaveFromDifference(final int semitoneDifference) {
  assert(semitoneDifference >= 0, 'Expected non-negative semitone difference.');
  return (semitoneDifference ~/ 12) - 1;
}

String _accidentalString(final int offset) {
  if (offset == 0) {
    return '';
  }
  final symbol = offset < 0 ? 'b' : '#';
  return List.filled(offset.abs(), symbol).join();
}
