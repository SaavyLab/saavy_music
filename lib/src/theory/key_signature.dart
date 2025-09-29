import 'package:meta/meta.dart';
import 'package:saavy_music/src/models/note.dart';
import 'package:saavy_music/src/theory/accidental.dart';
import 'package:saavy_music/src/theory/scale_degree.dart';

/// Church modes (diatonic scale variants) ordered by scale degree alterations.
enum ScaleMode { ionian, dorian, phrygian, lydian, mixolydian, aeolian, locrian }

const Map<ScaleMode, List<int>> _modeOffsets = {
  ScaleMode.ionian: [0, 2, 4, 5, 7, 9, 11],
  ScaleMode.dorian: [0, 2, 3, 5, 7, 9, 10],
  ScaleMode.phrygian: [0, 1, 3, 5, 7, 8, 10],
  ScaleMode.lydian: [0, 2, 4, 6, 7, 9, 11],
  ScaleMode.mixolydian: [0, 2, 4, 5, 7, 9, 10],
  ScaleMode.aeolian: [0, 2, 3, 5, 7, 8, 10],
  ScaleMode.locrian: [0, 1, 3, 5, 6, 8, 10],
};

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

  List<int> get semitoneOffsets => _modeOffsets[this]!;
}

@immutable
class KeySignature {
  const KeySignature({required this.tonic, this.mode = ScaleMode.ionian});

  final Note tonic;
  final ScaleMode mode;

  List<int> get _scaleOffsets => mode.semitoneOffsets;

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
}
