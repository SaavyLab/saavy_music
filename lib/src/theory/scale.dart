import 'dart:math';

import 'package:saavy_music/src/models/note.dart';

const _scales = [
  Scale.major,
  Scale.naturalMinor,
  Scale.harmonicMinor,
  Scale.melodicMinor,
  Scale.majorPentatonic,
  Scale.minorPentatonic,
  Scale.blues,
  Scale.chromatic,

  // Modes (ionian and aeolion are ommitted as they are the same as major and natural minor)
  Scale.dorian,
  Scale.phrygian,
  Scale.lydian,
  Scale.mixolydian,
  Scale.locrian,
];

const _minorScales = [Scale.naturalMinor, Scale.harmonicMinor, Scale.melodicMinor, Scale.minorPentatonic, Scale.blues];

const _modes = [
  Scale.ionian, // I
  Scale.dorian, // Don't
  Scale.phrygian, // Particularly
  Scale.lydian, // Like
  Scale.mixolydian, // Modes
  Scale.aeolian, // A
  Scale.locrian, // Lot
];

/// represents a musical scale
class Scale {
  const Scale({required this.root, required this.intervals, required this.name});

  factory Scale.random(final Note root) {
    final randomIndex = Random().nextInt(_scales.length);
    return _scales[randomIndex](root);
  }

  factory Scale.randomMinor(final Note root) {
    final randomIndex = Random().nextInt(_minorScales.length);
    return _minorScales[randomIndex](root);
  }

  factory Scale.randomMode(final Note root) {
    final randomIndex = Random().nextInt(_modes.length);
    return _modes[randomIndex](root);
  }

  /// common scales
  factory Scale.major(final Note root) =>
      Scale(root: root, intervals: [2, 4, 5, 7, 9, 11, 12], name: '${root.name} major');

  factory Scale.naturalMinor(final Note root) =>
      Scale(root: root, intervals: [2, 3, 5, 7, 8, 10, 12], name: '${root.name} natural minor');

  factory Scale.harmonicMinor(final Note root) =>
      Scale(root: root, intervals: [2, 3, 5, 7, 8, 11, 12], name: '${root.name} harmonic minor');

  factory Scale.melodicMinor(final Note root) =>
      Scale(root: root, intervals: [2, 3, 5, 7, 9, 11, 12], name: '${root.name} melodic minor');

  factory Scale.majorPentatonic(final Note root) =>
      Scale(root: root, intervals: [2, 4, 7, 9, 12], name: '${root.name} major pentatonic');

  factory Scale.minorPentatonic(final Note root) =>
      Scale(root: root, intervals: [3, 5, 7, 10, 12], name: '${root.name} minor pentatonic');

  factory Scale.blues(final Note root) =>
      Scale(root: root, intervals: [3, 5, 6, 7, 10, 12], name: '${root.name} blues');

  factory Scale.chromatic(final Note root) =>
      Scale(root: root, intervals: List.generate(12, (final i) => i + 1), name: '${root.name} chromatic');

  factory Scale.ionian(final Note root) => Scale.major(root);

  factory Scale.dorian(final Note root) =>
      Scale(root: root, intervals: [2, 3, 5, 7, 9, 10, 12], name: '${root.name} dorian');

  factory Scale.phrygian(final Note root) =>
      Scale(root: root, intervals: [1, 3, 5, 7, 8, 10, 12], name: '${root.name} phrygian');

  factory Scale.lydian(final Note root) =>
      Scale(root: root, intervals: [2, 4, 6, 7, 9, 11, 12], name: '${root.name} lydian');

  factory Scale.mixolydian(final Note root) =>
      Scale(root: root, intervals: [2, 4, 5, 7, 9, 10, 12], name: '${root.name} mixolydian');

  factory Scale.aeolian(final Note root) => Scale.naturalMinor(root);

  factory Scale.locrian(final Note root) =>
      Scale(root: root, intervals: [1, 3, 5, 6, 8, 10, 12], name: '${root.name} locrian');

  /// root note of the scale
  final Note root;

  /// intervals from root (in semitones)
  final List<int> intervals;

  /// scale name
  final String name;

  /// get all notes in the scale
  List<Note> get notes => [
    root,
    ...intervals.map((final semitones) => Note(midiNumber: root.midiNumber + semitones, velocity: root.velocity)),
  ];
}
