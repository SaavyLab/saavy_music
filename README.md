# saavy_music

[![pub package](https://img.shields.io/pub/v/saavy_music.svg)](https://pub.dev/packages/saavy_music)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`saavy_music` is a dart library for representing and working with music theory concepts in code: notes, intervals, chords, scales, and key signatures. the library is immutable, compositional, and dependency-light, with utilities for midi numbers and frequencies.

new in 0.2.0: key-aware enharmonic spelling with octave-accurate `KeySignature.resolveDegree`.

## overview

- immutable value types
- chord construction via `ChordRecipe` (triad quality + optional extensions)
- key-aware enharmonic spelling with octave preservation
- midi number and frequency helpers
- core dart only (no flutter dependency)

## install

add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  saavy_music: ^0.2.0
```

## usage

### notes and intervals

```dart
import 'package:saavy_music/saavy_music.dart';

void main() {
  final c4 = Note.c(4);
  final fSharp5 = Note.f(5, accidental: Accidental.sharp);

  final note = Note.fromComponents(
    noteName: NoteName.c,
    octave: 4,
    accidental: Accidental.natural,
  );

  print(c4.frequency); // 261.6256
  print(c4.name);      // "c4"
  print(c4.midiNumber); // 60

  final perfectFifth = Interval.perfectFifth();
  print(perfectFifth.semitones); // 7
  print(perfectFifth.name);      // "Perfect Fifth"
}
```

### chord recipes

chords are constructed from a `ChordRecipe` that combines a triad quality with optional extensions.

```dart
final c4 = Note.c(4);

final cmaj7 = Chord.fromRecipe(c4, ChordRecipes.majorSeventh);
final dm = Chord.fromRecipe(Note.d(4), ChordRecipes.minorTriad);
final g7 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantSeventh);

print(cmaj7.notes); // [c4, e4, g4, b4]
print(cmaj7.name);  // "c4maj7"

// convenience constructors
final cMajor = Chord.major(c4);
final dMinor = Chord.minor(Note.d(4));
final g7Chord = Chord.dominantSeventh(Note.g(4));
```

### custom chord recipes

```dart
const myCustomChord = ChordRecipe(
  id: 'custom_add9',
  displayLabel: 'add9',
  fullName: 'Custom Add Nine',
  triadQuality: TriadQuality.major,
  extensions: {ChordExtension.majorNinth},
);

final customChord = Chord.fromRecipe(Note.c(4), myCustomChord);
print(customChord.notes); // [c4, e4, g4, d5]
```

### key signatures and scale degrees

```dart
final keyOfEbMajor = KeySignature(
  tonic: Note.e(4, accidental: Accidental.flat),
);

final tonic = keyOfEbMajor.resolveDegree(Degrees.i);
final dominant = keyOfEbMajor.resolveDegree(Degrees.v);
final subdominant = keyOfEbMajor.resolveDegree(Degrees.iv);

final I = Chord.major(tonic);
final IV = Chord.major(subdominant);
final V7 = Chord.dominantSeventh(dominant);

print('${I.name} - ${IV.name} - ${V7.name}');
```

### key-aware enharmonic spelling

`KeySignature.resolveDegree` returns `KeyAwareNote`s that are spelled according to the selected key and mode, including double sharps/flats when appropriate. octaves are preserved unless an `octaveOffset` is applied.

```dart
final fSharpMajor = KeySignature(tonic: Note.f(4, accidental: Accidental.sharp));

fSharpMajor.resolveDegree(Degrees.vii).name; // e#4
fSharpMajor.resolveDegree(Degrees.vii.sharp()).name; // e##4

final cbMinor = KeySignature(
  tonic: Note.c(4, accidental: Accidental.flat),
  mode: ScaleMode.aeolian,
);

cbMinor.resolveDegree(Degrees.iii).name; // ebb4
cbMinor.resolveDegree(Degrees.vi).name;  // abb4
```

### chord inversions

```dart
final cMajor = Chord.major(Note.c(4));

print(cMajor.notes);           // [c4, e4, g4]
print(cMajor.invert(1).notes); // [e4, g4, c5]
print(cMajor.invert(2).notes); // [g4, c5, e5]

print(cMajor.invert(1).name); // "c4maj/e4"
```

### additional chord types

```dart
final cmaj9 = Chord.fromRecipe(Note.c(4), ChordRecipes.majorNinth);
final dm11 = Chord.fromRecipe(Note.d(4), ChordRecipes.minorEleventh);

final g7b9 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantFlatNinth);
final g7sharp9 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantSharpNinth);

print('Triads: ${ChordRecipes.triads.length}');
print('Sevenths: ${ChordRecipes.sevenths.length}');
print('Extensions: ${ChordRecipes.extensions.length}');
```

### example: building simple progressions

```dart
final keys = [
  KeySignature(tonic: Note.c(4)),
  KeySignature(tonic: Note.g(4)),
  KeySignature(tonic: Note.f(4)),
];

final progressions = [
  [Degrees.i, Degrees.vi, Degrees.iv, Degrees.v],
  [Degrees.ii, Degrees.v, Degrees.i],
];

for (final key in keys) {
  for (final progression in progressions) {
    final chords = progression.map((degree) {
      final root = key.resolveDegree(degree);
      return Chord.major(root);
    }).toList();

    print('${key.label}: ${chords.map((c) => c.name).join(' - ')}');
  }
}
```

## api reference

- `Note`: musical note with midi number and velocity
- `Interval`: distance between two pitches
- `Chord`: collection of notes
- `ChordRecipe`: template for building chords
- `KeySignature`: musical key with tonic and mode
- `ScaleDegree`: roman numeral analysis utilities

## contributing

contributions are welcome via pull request. for major changes, open an issue first to discuss the approach.

## license

mit, see [LICENSE](LICENSE).
