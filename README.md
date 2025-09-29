# 🎵 saavy_music

[![pub package](https://img.shields.io/pub/v/saavy_music.svg)](https://pub.dev/packages/saavy_music)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An opinionated, compositional, and immutable music theory library for Dart, designed for developers who think about harmony in terms of shapes and relationships.

This package provides a set of core, dependency-light models for notes, intervals, chords, scales, and keys. It is designed with a **shape-based** philosophy, prioritizing harmonic relationships over absolute pitches. This makes it ideal for analysis, procedural generation, and educational applications where the *function* of a chord is more important than its specific notes.

New in 0.2.0: key-aware enharmonic spelling with octave-accurate `KeySignature.resolveDegree` responses, so complex tonalities (think C♭ minor or G♯ major) now render exactly the spellings a trained musician expects.

---

## 🎯 Core Philosophy: Harmonic Shapes, Not Static Chords

Unlike other libraries that might provide a long enum of every possible chord, `saavy_music` treats harmony as a compositional system. Chords are built dynamically using **`ChordRecipe`** objects.

A `ChordRecipe` defines the intervallic structure of a chord by combining a `TriadQuality` (like major, minor, or diminished) with a set of `ChordExtension`s (like a major or minor seventh).

This approach allows you to think about harmony the way a musician does:
- "I need a dominant seventh chord." → `ChordRecipes.dominantSeventh`
- "Now I need a minor triad." → `ChordRecipes.minorTriad`

You define the *shape* you need, then apply it to any `Note` to create a concrete `Chord`. This is a more flexible and expressive way to model music theory.

## ✨ Features

- 🔒 **Immutable by Design**: All models are immutable, making them predictable and safe
- 🎵 **Compositional Harmony**: Build ANY chord from triad qualities and extensions
- 🎹 **Key-Aware Resolution**: `KeySignature` and `ScaleDegree` now return fully key-aware `KeyAwareNote`s with the correct letter name, accidental (including double sharps/flats), and octave for the selected mode
- 🚀 **Lightweight & Focused**: No dependencies on Flutter or anything outside of core Dart
- 🎓 **Educational Focus**: Perfect for ear training and music theory applications
- 📱 **MIDI Integration**: Built-in MIDI number support with frequency calculation

## 🚀 Quick Start

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  saavy_music: ^0.2.0
```

## 📖 Usage Examples

### Basic Notes and Intervals

```dart
import 'package:saavy_music/saavy_music.dart';

void main() {
  // Create notes using factory constructors
  final c4 = Note.c(4);
  final fSharp5 = Note.f(5, accidental: Accidental.sharp);

  // Or create from components
  final note = Note.fromComponents(
    noteName: NoteName.c,
    octave: 4,
    accidental: Accidental.natural,
  );

  print(c4.frequency); // 261.6256 Hz
  print(c4.name);      // "c4"
  print(c4.midiNumber); // 60

  // Work with intervals
  final perfectFifth = Interval.perfectFifth();
  print(perfectFifth.semitones); // 7
  print(perfectFifth.name);      // "Perfect Fifth"
}
```

### The ChordRecipe System

```dart
// Use pre-defined recipes for common chords
final c4 = Note.c(4);

// Create chords using recipes
final cmaj7 = Chord.fromRecipe(c4, ChordRecipes.majorSeventh);
final dm = Chord.fromRecipe(Note.d(4), ChordRecipes.minorTriad);
final g7 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantSeventh);

print(cmaj7.notes); // [c4, e4, g4, b4]
print(cmaj7.name);  // "c4maj7"

// Or use convenience constructors
final cMajor = Chord.major(c4);
final dMinor = Chord.minor(Note.d(4));
final g7Chord = Chord.dominantSeventh(Note.g(4));
```

### Custom Chord Recipes

```dart
// Build your own chord recipes
const myCustomChord = ChordRecipe(
  id: 'custom_add9',
  displayLabel: 'add9',
  fullName: 'Custom Add Nine',
  triadQuality: TriadQuality.major,
  extensions: {ChordExtension.majorNinth},
);

final customChord = Chord.fromRecipe(Note.c(4), myCustomChord);
print(customChord.notes); // [c4, e4, g4, d5] (add9 without the 7th)
```

### Working with Key Signatures

```dart
// Define a key signature
final keyOfEbMajor = KeySignature(
  tonic: Note.e(4, accidental: Accidental.flat)
);

// Resolve scale degrees within the key
final tonic = keyOfEbMajor.resolveDegree(Degrees.i);     // Eb4
final dominant = keyOfEbMajor.resolveDegree(Degrees.v);   // Bb4
final subdominant = keyOfEbMajor.resolveDegree(Degrees.iv); // Ab4

// Build chord progressions
final I = Chord.major(tonic);
final IV = Chord.major(subdominant);
final V7 = Chord.dominantSeventh(dominant);

print('${I.name} - ${IV.name} - ${V7.name}'); // "eb4maj - ab4maj - bb47"

// Work with different modes
final aMinor = KeySignature(
  tonic: Note.a(3),
  mode: ScaleMode.aeolian
);
```

### Key-Aware Enharmonic Spelling

`KeySignature.resolveDegree` now produces `KeyAwareNote`s that understand their tonal context. That means the same MIDI pitch can be spelled as `bb4`, `a#4`, or even `f##4` depending on the key and requested scale degree.

```dart
final fSharpMajor = KeySignature(tonic: Note.f(4, accidental: Accidental.sharp));

fSharpMajor.resolveDegree(Degrees.vii).name; // e#4 (not f4!)
fSharpMajor.resolveDegree(Degrees.vii.sharp()).name; // e##4

final cbMinor = KeySignature(
  tonic: Note.c(4, accidental: Accidental.flat),
  mode: ScaleMode.aeolian,
);

cbMinor.resolveDegree(Degrees.iii).name; // ebb4
cbMinor.resolveDegree(Degrees.vi).name;  // abb4
```

Octaves are preserved too—altered sevenths remain in the same register unless you explicitly jump by `octaveOffset`.

### Chord Inversions

```dart
final cMajor = Chord.major(Note.c(4));

print(cMajor.notes);           // [c4, e4, g4] (root position)
print(cMajor.invert(1).notes); // [e4, g4, c5] (first inversion)
print(cMajor.invert(2).notes); // [g4, c5, e5] (second inversion)

// Inversion names are automatically generated
print(cMajor.invert(1).name); // "c4maj/e4"
```

### Advanced Harmony

```dart
// Extended chords
final cmaj9 = Chord.fromRecipe(Note.c(4), ChordRecipes.majorNinth);
final dm11 = Chord.fromRecipe(Note.d(4), ChordRecipes.perfectEleventh);

// Altered dominants
final g7b9 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantFlatNinth);
final g7sharp9 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantSharpNinth);

// Explore all available recipes
print('Triads: ${ChordRecipes.triads.length}');
print('Sevenths: ${ChordRecipes.sevenths.length}');
print('Extensions: ${ChordRecipes.extensions.length}');
```

## 🎓 Perfect for Ear Training

This library was specifically designed for ear training applications. The compositional approach mirrors how musicians think about harmony:

```dart
// Generate random chord progressions for practice
final keys = [
  KeySignature(tonic: Note.c(4)),
  KeySignature(tonic: Note.g(4)),
  KeySignature(tonic: Note.f(4)),
];

final progressions = [
  [Degrees.i, Degrees.vi, Degrees.iv, Degrees.v], // vi-IV-I-V
  [Degrees.ii, Degrees.v, Degrees.i],              // ii-V-I
];

// Build practice exercises programmatically
for (final key in keys) {
  for (final progression in progressions) {
    final chords = progression.map((degree) {
      final root = key.resolveDegree(degree);
      return Chord.major(root); // or choose appropriate quality
    }).toList();

    // Use these chords in your ear training app
    print('${key.label}: ${chords.map((c) => c.name).join(' - ')}');
  }
}
```

## 🏗️ API Reference

### Core Classes

- **`Note`**: Represents a musical note with MIDI number and velocity
- **`Interval`**: Represents the distance between two pitches
- **`Chord`**: A collection of notes played together
- **`ChordRecipe`**: A template for building chords with specific qualities
- **`KeySignature`**: Represents a musical key with tonic and mode
- **`ScaleDegree`**: Roman numeral analysis for chord functions

### Pre-defined Collections

- **`ChordRecipes.triads`**: Major, minor, diminished, augmented, sus2, sus4
- **`ChordRecipes.sevenths`**: Major 7th, minor 7th, dominant 7th, etc.
- **`ChordRecipes.extensions`**: 9ths, 11ths, 13ths, and altered chords

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need for better music theory tools in Dart/Flutter
- Built with love for musicians and developers who think in harmonies
- Part of the larger [Saavy](https://github.com/SaavyLab) ecosystem of music education tools

---

**Made with 🎵 by the Saavy team**
