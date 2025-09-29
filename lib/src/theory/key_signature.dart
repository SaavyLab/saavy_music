import 'package:meta/meta.dart';
import 'package:saavy_music/src/models/chord_recipe.dart';
import 'package:saavy_music/src/models/note.dart';
import 'package:saavy_music/src/theory/accidental.dart';
import 'package:saavy_music/src/theory/scale_degree.dart';

/// Church modes (diatonic scale variants) ordered by scale degree alterations.
enum ScaleMode { ionian, dorian, phrygian, lydian, mixolydian, aeolian, locrian }

/// Base interval pattern for the major scale (Ionian mode).
/// This is the fundamental pattern from which all church modes are derived.
/// Pattern: Whole-Whole-Half-Whole-Whole-Whole-Half (W-W-H-W-W-W-H)
/// These are the intervals BETWEEN consecutive scale degrees.
const _majorScalePattern = [2, 2, 1, 2, 2, 2, 1];

/// Derives the interval pattern for a given church mode by rotating the major scale pattern.
List<int> _getModePattern(ScaleMode mode) {
  final rotation = mode.index;
  return [..._majorScalePattern.skip(rotation), ..._majorScalePattern.take(rotation)];
}

/// Converts an interval pattern (steps between degrees) to cumulative offsets from the root.
List<int> _patternToCumulativeOffsets(List<int> pattern) {
  final offsets = <int>[0]; // Start with root at 0
  var cumulative = 0;
  for (var i = 0; i < pattern.length - 1; i++) {
    cumulative += pattern[i];
    offsets.add(cumulative);
  }
  return offsets;
}

/// Lazy-computed cache of mode offsets derived from rotated patterns.
final Map<ScaleMode, List<int>> _modeOffsetsCache = {};

/// Gets the cumulative semitone offsets for a given mode, computing and caching on first access.
List<int> _getModeOffsets(ScaleMode mode) {
  return _modeOffsetsCache.putIfAbsent(mode, () {
    final pattern = _getModePattern(mode);
    return _patternToCumulativeOffsets(pattern);
  });
}

/// Derives a diatonic triad quality by stacking thirds from a scale pattern.
ChordRecipe _deriveTriad(List<int> pattern, int degreeIndex) {
  // In a scale, a triad is built by taking the root (degree), third (degree+2), and fifth (degree+4)
  // Calculate the intervals between these scale degrees
  final rootToThird = _intervalBetweenScaleDegrees(pattern, degreeIndex, degreeIndex + 2);
  final thirdToFifth = _intervalBetweenScaleDegrees(pattern, degreeIndex + 2, degreeIndex + 4);

  // Pattern matching: identify chord quality based on stacked thirds
  // Major third (4 semitones) + minor third (3 semitones) = Major triad
  // Minor third (3 semitones) + major third (4 semitones) = Minor triad
  // Minor third (3 semitones) + minor third (3 semitones) = Diminished triad
  // Major third (4 semitones) + major third (4 semitones) = Augmented triad
  if (rootToThird == 4 && thirdToFifth == 3) {
    return ChordRecipes.majorTriad;
  } else if (rootToThird == 3 && thirdToFifth == 4) {
    return ChordRecipes.minorTriad;
  } else if (rootToThird == 3 && thirdToFifth == 3) {
    return ChordRecipes.diminishedTriad;
  } else if (rootToThird == 4 && thirdToFifth == 4) {
    return ChordRecipes.augmentedTriad;
  }

  // Fallback (should never happen for diatonic scales)
  return ChordRecipes.majorTriad;
}

/// Derives a diatonic seventh chord quality by stacking thirds and a seventh.
ChordRecipe _deriveSeventh(List<int> pattern, int degreeIndex) {
  // A seventh chord adds one more third on top of the triad
  final rootToThird = _intervalBetweenScaleDegrees(pattern, degreeIndex, degreeIndex + 2);
  final thirdToFifth = _intervalBetweenScaleDegrees(pattern, degreeIndex + 2, degreeIndex + 4);
  final fifthToSeventh = _intervalBetweenScaleDegrees(pattern, degreeIndex + 4, degreeIndex + 6);

  // Major triad base (4-3)
  if (rootToThird == 4 && thirdToFifth == 3) {
    if (fifthToSeventh == 4) {
      return ChordRecipes.majorSeventh; // Major 7th
    } else if (fifthToSeventh == 3) {
      return ChordRecipes.dominantSeventh; // Dominant 7th
    }
  }

  // Minor triad base (3-4)
  if (rootToThird == 3 && thirdToFifth == 4) {
    if (fifthToSeventh == 3 || fifthToSeventh == 4) {
      return ChordRecipes.minorSeventh; // Minor 7th
    }
  }

  // Diminished triad base (3-3)
  if (rootToThird == 3 && thirdToFifth == 3) {
    if (fifthToSeventh == 4) {
      return ChordRecipes.halfDiminishedSeventh; // Half-diminished 7th (minor 7th on diminished triad)
    } else if (fifthToSeventh == 3) {
      return ChordRecipes.diminishedSeventh; // Diminished 7th (rare in diatonic harmony)
    }
  }

  // Fallback to dominant seventh (most common)
  return ChordRecipes.dominantSeventh;
}

/// Calculates the interval (in semitones) between two scale degrees.
///
/// The pattern contains intervals BETWEEN consecutive degrees, so to go from
/// degree i to degree i+2, we sum pattern[i] + pattern[i+1].
int _intervalBetweenScaleDegrees(List<int> pattern, int fromDegree, int toDegree) {
  final patternLength = pattern.length;
  var semitones = 0;

  // Handle wrapping - always go forward from fromDegree to toDegree
  var currentDegree = fromDegree;

  while (currentDegree != toDegree) {
    // Add the interval from current degree to next degree
    semitones += pattern[currentDegree % patternLength];
    currentDegree++;

    // Safety check to prevent infinite loop
    if (currentDegree - fromDegree > patternLength * 2) {
      break;
    }
  }

  return semitones;
}

const List<NoteName> _noteOrder = [NoteName.c, NoteName.d, NoteName.e, NoteName.f, NoteName.g, NoteName.a, NoteName.b];

enum _AccidentalPreference { preferSharps, preferFlats, neutral }

class _SpellingCandidate {
  const _SpellingCandidate({
    required this.noteName,
    required this.accidentalOffset,
    required this.octave,
    required this.diatonicDistance,
  });

  final NoteName noteName;
  final int accidentalOffset;
  final int octave;
  final int diatonicDistance;

  _SpellingCandidate withAccidentalOffset(final int offset) => _SpellingCandidate(
        noteName: noteName,
        accidentalOffset: offset,
        octave: octave,
        diatonicDistance: diatonicDistance,
      );
}

extension ScaleModeX on ScaleMode {
  String get displayName {
    switch (this) {
      case ScaleMode.ionian:
        return 'Ionian';
      case ScaleMode.dorian:
        return 'Dorian';
      case ScaleMode.phrygian:
        return 'Phrygian';
      case ScaleMode.lydian:
        return 'Lydian';
      case ScaleMode.mixolydian:
        return 'Mixolydian';
      case ScaleMode.aeolian:
        return 'Aeolian';
      case ScaleMode.locrian:
        return 'Locrian';
    }
  }

  List<int> get semitoneOffsets => _getModeOffsets(this);
}

@immutable
class KeySignature {
  const KeySignature({required this.tonic, this.mode = ScaleMode.ionian});

  final Note tonic;
  final ScaleMode mode;

  List<int> get _scaleOffsets => _getModeOffsets(mode);

  String get label => '${_tonicLabel()} ${mode.displayName}';

  Note resolveDegree(final ScaleDegree degree, {final int octaveOffset = 0}) {
    final diatonic = _scaleOffsets[degree.degree.index];
    final semitones = diatonic + degree.accidentalSemitones + (octaveOffset * 12);
    final rawMidi = tonic.midiNumber + semitones;

    final (tonicNoteName, tonicOctave, tonicAccidental) = tonic.components;
    final (diatonicNoteName, octaveAdjust) = _noteNameAndOctaveAdjust(tonicNoteName, degree.degree);
    final expectedOctave = _displayOctaveForDegree(
      tonicOctave: tonicOctave,
      octaveAdjust: octaveAdjust,
      octaveOffset: octaveOffset,
      degree: degree.degree,
      semitones: semitones,
    );
    final normalizedMidi = _normalizeMidiToOctave(
      rawMidi: rawMidi,
      expectedOctave: expectedOctave,
      noteName: diatonicNoteName,
    );

    final preference = _resolveAccidentalPreference(tonicNoteName, tonicAccidental, mode);
    final spelling = _selectSpelling(
      midi: normalizedMidi,
      diatonicNoteName: diatonicNoteName,
      expectedOctave: expectedOctave,
      preference: preference,
    );
    final accidentalOffset = _clampAccidentalOffset(spelling.accidentalOffset);
    final baseMidi = _midiForNatural(spelling.noteName, spelling.octave);
    final midiFromSpelling = baseMidi + accidentalOffset;
    final midiNumber = _clampMidi(midiFromSpelling);

    return KeyAwareNote(
      midiNumber: midiNumber,
      velocity: tonic.velocity,
      expectedNoteName: spelling.noteName,
      expectedAccidentalOffset: accidentalOffset,
      expectedOctave: spelling.octave,
    );
  }

  /// Get semitone offset for natural note names
  int _getNaturalNoteOffset(NoteName noteName) {
    const offsets = {
      NoteName.c: 0,
      NoteName.d: 2,
      NoteName.e: 4,
      NoteName.f: 5,
      NoteName.g: 7,
      NoteName.a: 9,
      NoteName.b: 11,
    };
    return offsets[noteName]!;
  }

  (NoteName, int) _noteNameAndOctaveAdjust(NoteName tonicName, DiatonicDegree degree) {
    final tonicIndex = _noteOrder.indexOf(tonicName);
    final steps = degree.index;
    final absoluteIndex = tonicIndex + steps;
    final noteName = _noteOrder[absoluteIndex % 7];
    final octaveAdjust = absoluteIndex ~/ 7;
    return (noteName, octaveAdjust);
  }

  int _displayOctaveForDegree({
    required final int tonicOctave,
    required final int octaveAdjust,
    required final int octaveOffset,
    required final DiatonicDegree degree,
    required final int semitones,
  }) {
    final intervalWithinOctave = (semitones % 12 + 12) % 12;
    if (degree == DiatonicDegree.seven && octaveAdjust > 0 && intervalWithinOctave == 11) {
      return tonicOctave + octaveOffset;
    }
    return tonicOctave + octaveAdjust + octaveOffset;
  }

  int _normalizeMidiToOctave({
    required final int rawMidi,
    required final int expectedOctave,
    required final NoteName noteName,
  }) {
    final baseMidi = _midiForNatural(noteName, expectedOctave);
    var normalized = rawMidi;
    while (normalized - baseMidi > 6) {
      normalized -= 12;
    }
    while (normalized - baseMidi < -6) {
      normalized += 12;
    }
    return normalized;
  }

  int _clampAccidentalOffset(final int offset) {
    if (offset < -2) {
      return -2;
    }
    if (offset > 2) {
      return 2;
    }
    return offset;
  }

  int _clampMidi(final int midi) {
    if (midi < 0) {
      return 0;
    }
    if (midi > 127) {
      return 127;
    }
    return midi;
  }

  _SpellingCandidate _selectSpelling({
    required int midi,
    required NoteName diatonicNoteName,
    required int expectedOctave,
    required _AccidentalPreference preference,
  }) {
    final baseMidi = _midiForNatural(diatonicNoteName, expectedOctave);
    final diatonicOffset = midi - baseMidi;
    final diatonicCandidate = _SpellingCandidate(
      noteName: diatonicNoteName,
      accidentalOffset: diatonicOffset,
      octave: expectedOctave,
      diatonicDistance: 0,
    );

    if (diatonicOffset >= -2 && diatonicOffset <= 2) {
      if (_shouldSearchAlternate(preference, diatonicOffset)) {
        final alternate = _findAlternateForPreference(
          midi: midi,
          expectedOctave: expectedOctave,
          diatonicNoteName: diatonicNoteName,
          maxMagnitude: diatonicOffset.abs(),
          preference: preference,
        );
        if (alternate != null) {
          return alternate;
        }
      }
      return diatonicCandidate;
    }

    final bestWithinRange = _findBestCandidateWithinRange(
      midi: midi,
      expectedOctave: expectedOctave,
      diatonicNoteName: diatonicNoteName,
      preference: preference,
    );
    if (bestWithinRange != null) {
      return bestWithinRange;
    }

    final clampedOffset = _clampAccidentalOffset(diatonicOffset);
    return diatonicCandidate.withAccidentalOffset(clampedOffset);
  }

  _SpellingCandidate? _findAlternateForPreference({
    required int midi,
    required int expectedOctave,
    required NoteName diatonicNoteName,
    required int maxMagnitude,
    required _AccidentalPreference preference,
  }) {
    if (maxMagnitude == 0) {
      return null;
    }

    final desiredSign = preference == _AccidentalPreference.preferSharps ? 1 : -1;
    _SpellingCandidate? best;
    int? bestDistance;

    for (final candidateName in NoteName.values) {
      if (candidateName == diatonicNoteName) {
        continue;
      }
      final baseMidi = _midiForNatural(candidateName, expectedOctave);
      final offset = midi - baseMidi;
      if (offset == 0) {
        continue;
      }
      final offsetSign = offset > 0 ? 1 : -1;
      if (offsetSign != desiredSign) {
        continue;
      }
      final magnitude = offset.abs();
      if (magnitude > 2 || magnitude > maxMagnitude) {
        continue;
      }

      final distance = _diatonicDistance(diatonicNoteName, candidateName);

      if (best == null) {
        best = _SpellingCandidate(
          noteName: candidateName,
          accidentalOffset: offset,
          octave: expectedOctave,
          diatonicDistance: distance,
        );
        bestDistance = distance;
        continue;
      }

      final bestMagnitude = best.accidentalOffset.abs();
      if (magnitude < bestMagnitude || (magnitude == bestMagnitude && distance < bestDistance!)) {
        best = _SpellingCandidate(
          noteName: candidateName,
          accidentalOffset: offset,
          octave: expectedOctave,
          diatonicDistance: distance,
        );
        bestDistance = distance;
      }
    }

    return best;
  }

  _SpellingCandidate? _findBestCandidateWithinRange({
    required int midi,
    required int expectedOctave,
    required NoteName diatonicNoteName,
    required _AccidentalPreference preference,
  }) {
    _SpellingCandidate? best;
    double? bestScore;

    for (final candidateName in NoteName.values) {
      final baseMidi = _midiForNatural(candidateName, expectedOctave);
      final offset = midi - baseMidi;
      if (offset < -2 || offset > 2) {
        continue;
      }
      final distance = _diatonicDistance(diatonicNoteName, candidateName);
      final candidate = _SpellingCandidate(
        noteName: candidateName,
        accidentalOffset: offset,
        octave: expectedOctave,
        diatonicDistance: distance,
      );
      final score = _candidateScore(candidate, preference);
      if (best == null || score < bestScore!) {
        best = candidate;
        bestScore = score;
      } else if (score == bestScore) {
        if (candidate.diatonicDistance < best.diatonicDistance) {
          best = candidate;
          bestScore = score;
        }
      }
    }

    return best;
  }

  double _candidateScore(final _SpellingCandidate candidate, final _AccidentalPreference preference) {
    final base = candidate.accidentalOffset.abs().toDouble();
    final diatonicPenalty = candidate.diatonicDistance * 2.0;
    final orientationPenalty = _orientationPenalty(preference, candidate.accidentalOffset);
    return base + diatonicPenalty + orientationPenalty;
  }

  bool _shouldSearchAlternate(final _AccidentalPreference preference, final int diatonicOffset) {
    if (diatonicOffset == 0 || preference == _AccidentalPreference.neutral) {
      return false;
    }
    if (preference == _AccidentalPreference.preferSharps) {
      return diatonicOffset < 0;
    }
    if (preference == _AccidentalPreference.preferFlats) {
      return diatonicOffset > 0;
    }
    return false;
  }

  double _orientationPenalty(final _AccidentalPreference preference, final int offset) {
    if (offset == 0 || preference == _AccidentalPreference.neutral) {
      return 0;
    }
    if (preference == _AccidentalPreference.preferSharps && offset < 0) {
      return 3;
    }
    if (preference == _AccidentalPreference.preferFlats && offset > 0) {
      return 3;
    }
    return 0;
  }

  _AccidentalPreference _resolveAccidentalPreference(
    final NoteName tonicName,
    final Accidental tonicAccidental,
    final ScaleMode mode,
  ) {
    if (tonicAccidental == Accidental.doubleSharp || tonicAccidental == Accidental.sharp) {
      return _AccidentalPreference.preferSharps;
    }
    if (tonicAccidental == Accidental.doubleFlat || tonicAccidental == Accidental.flat) {
      return _AccidentalPreference.preferFlats;
    }

    switch (mode) {
      case ScaleMode.lydian:
      case ScaleMode.mixolydian:
        return _AccidentalPreference.preferSharps;
      case ScaleMode.phrygian:
      case ScaleMode.locrian:
      case ScaleMode.aeolian:
        return _AccidentalPreference.preferFlats;
      case ScaleMode.dorian:
        return _AccidentalPreference.neutral;
      case ScaleMode.ionian:
        return _preferenceForIonianNaturalTonic(tonicName);
    }
  }

  _AccidentalPreference _preferenceForIonianNaturalTonic(final NoteName tonicName) {
    switch (tonicName) {
      case NoteName.f:
        return _AccidentalPreference.preferFlats;
      case NoteName.c:
        return _AccidentalPreference.neutral;
      case NoteName.g:
      case NoteName.d:
      case NoteName.a:
      case NoteName.e:
      case NoteName.b:
        return _AccidentalPreference.preferSharps;
    }
  }

  int _diatonicDistance(final NoteName a, final NoteName b) {
    final aIndex = _noteOrder.indexOf(a);
    final bIndex = _noteOrder.indexOf(b);
    final diff = (aIndex - bIndex).abs();
    return diff <= 3 ? diff : 7 - diff;
  }

  int _midiForNatural(final NoteName noteName, final int octave) =>
      ((octave + 1) * 12) + _getNaturalNoteOffset(noteName);

  String _tonicLabel() {
    final raw = tonic.name;
    final withoutOctave = raw.replaceAll(RegExp(r'-?\d'), '');
    return withoutOctave.toUpperCase();
  }

  /// Returns the diatonic triad quality for the given scale degree in this key.
  ///
  /// Derives the chord quality algorithmically by analyzing the intervals
  /// formed when stacking thirds from the scale pattern. This works for any
  /// scale mode without requiring hardcoded lookup tables.
  ///
  /// Only works for natural scale degrees (no accidentals). Throws [ArgumentError]
  /// if the degree has an accidental, since altered degrees are by definition
  /// not diatonic.
  ///
  /// Example:
  /// ```dart
  /// final key = KeySignature(tonic: Note.fromName('c4'), mode: ScaleMode.ionian);
  /// final recipe = key.getDiatonicTriad(Degrees.v); // Returns ChordRecipes.majorTriad (V)
  /// ```
  ChordRecipe getDiatonicTriad(ScaleDegree degree) {
    if (degree.accidental != Accidental.natural) {
      throw ArgumentError(
        'getDiatonicTriad only works for natural scale degrees. '
        'The degree ${degree.label} has an accidental and is not diatonic.',
      );
    }

    final pattern = _getModePattern(mode);
    return _deriveTriad(pattern, degree.degree.index);
  }

  /// Returns the diatonic seventh chord quality for the given scale degree in this key.
  ///
  /// Derives the chord quality algorithmically by analyzing the intervals
  /// formed when stacking thirds up to the seventh from the scale pattern.
  ///
  /// Only works for natural scale degrees (no accidentals). Throws [ArgumentError]
  /// if the degree has an accidental, since altered degrees are by definition
  /// not diatonic.
  ///
  /// Example:
  /// ```dart
  /// final key = KeySignature(tonic: Note.fromName('c4'), mode: ScaleMode.ionian);
  /// final recipe = key.getDiatonicSeventh(Degrees.v); // Returns ChordRecipes.dominantSeventh (V7)
  /// ```
  ChordRecipe getDiatonicSeventh(ScaleDegree degree) {
    if (degree.accidental != Accidental.natural) {
      throw ArgumentError(
        'getDiatonicSeventh only works for natural scale degrees. '
        'The degree ${degree.label} has an accidental and is not diatonic.',
      );
    }

    final pattern = _getModePattern(mode);
    return _deriveSeventh(pattern, degree.degree.index);
  }

  /// Checks if the given chord recipe is diatonic at the specified scale degree.
  ///
  /// A chord is considered diatonic if:
  /// 1. The scale degree is natural (no accidentals), AND
  /// 2. The recipe matches either the diatonic triad OR diatonic seventh for that degree
  ///
  /// Returns `false` for any degree with an accidental, since altered degrees are
  /// borrowed/chromatic by definition.
  ///
  /// Example:
  /// ```dart
  /// final key = KeySignature(tonic: Note.fromName('c4'), mode: ScaleMode.ionian);
  /// key.isDiatonic(Degrees.v, ChordRecipes.majorTriad);      // true (V)
  /// key.isDiatonic(Degrees.v, ChordRecipes.dominantSeventh); // true (V7)
  /// key.isDiatonic(Degrees.v, ChordRecipes.minorTriad);      // false (v is borrowed)
  /// key.isDiatonic(Degrees.ii.flat(), ChordRecipes.majorTriad); // false (♭II has accidental)
  /// ```
  bool isDiatonic(ScaleDegree degree, ChordRecipe recipe) {
    // Altered degrees are never diatonic
    if (degree.accidental != Accidental.natural) {
      return false;
    }

    final diatonicTriad = getDiatonicTriad(degree);
    final diatonicSeventh = getDiatonicSeventh(degree);

    return recipe == diatonicTriad || recipe == diatonicSeventh;
  }
}
