import 'package:saavy_music/saavy_music.dart';
import 'package:test/test.dart';

void main() {
  group('ScaleMode extension', () {
    test('display names are correct', () {
      expect(ScaleMode.ionian.displayName, 'Ionian');
      expect(ScaleMode.dorian.displayName, 'Dorian');
      expect(ScaleMode.phrygian.displayName, 'Phrygian');
      expect(ScaleMode.lydian.displayName, 'Lydian');
      expect(ScaleMode.mixolydian.displayName, 'Mixolydian');
      expect(ScaleMode.aeolian.displayName, 'Aeolian');
      expect(ScaleMode.locrian.displayName, 'Locrian');
    });

    test('semitone offsets are correct for major scale (Ionian)', () {
      final offsets = ScaleMode.ionian.semitoneOffsets;
      expect(offsets, [0, 2, 4, 5, 7, 9, 11]); // W-W-H-W-W-W-H pattern
    });

    test('semitone offsets are correct for natural minor (Aeolian)', () {
      final offsets = ScaleMode.aeolian.semitoneOffsets;
      expect(offsets, [0, 2, 3, 5, 7, 8, 10]); // W-H-W-W-H-W-W pattern
    });

    test('semitone offsets are correct for Dorian', () {
      final offsets = ScaleMode.dorian.semitoneOffsets;
      expect(offsets, [0, 2, 3, 5, 7, 9, 10]); // W-H-W-W-W-H-W pattern
    });

    test('semitone offsets are correct for Lydian', () {
      final offsets = ScaleMode.lydian.semitoneOffsets;
      expect(offsets, [0, 2, 4, 6, 7, 9, 11]); // W-W-W-H-W-W-H pattern
    });

    test('semitone offsets are correct for Mixolydian', () {
      final offsets = ScaleMode.mixolydian.semitoneOffsets;
      expect(offsets, [0, 2, 4, 5, 7, 9, 10]); // W-W-H-W-W-H-W pattern
    });
  });

  group('KeySignature', () {
    test('creates with default Ionian mode', () {
      final key = KeySignature(tonic: Note.c(4));
      expect(key.tonic.name, 'c4');
      expect(key.mode, ScaleMode.ionian);
    });

    test('creates with specified mode', () {
      final key = KeySignature(tonic: Note.a(3), mode: ScaleMode.aeolian);
      expect(key.tonic.name, 'a3');
      expect(key.mode, ScaleMode.aeolian);
    });

    test('generates correct label for major key', () {
      final key = KeySignature(tonic: Note.f(3, accidental: Accidental.sharp));
      expect(key.label, 'F# Ionian');
    });

    test('generates correct label for minor key', () {
      final key = KeySignature(tonic: Note.a(2), mode: ScaleMode.aeolian);
      expect(key.label, 'A Aeolian');
    });

    test('generates correct label removing octave from tonic', () {
      final key = KeySignature(tonic: Note.a(5, accidental: Accidental.sharp));
      expect(key.label, 'A# Ionian'); // Octave number removed
    });

    test('resolves scale degrees correctly in C major', () {
      final key = KeySignature(tonic: Note.c(4));

      expect(key.resolveDegree(Degrees.i).name, 'c4'); // C
      expect(key.resolveDegree(Degrees.ii).name, 'd4'); // D
      expect(key.resolveDegree(Degrees.iii).name, 'e4'); // E
      expect(key.resolveDegree(Degrees.iv).name, 'f4'); // F
      expect(key.resolveDegree(Degrees.v).name, 'g4'); // G
      expect(key.resolveDegree(Degrees.vi).name, 'a4'); // A
      expect(key.resolveDegree(Degrees.vii).name, 'b4'); // B
    });

    test('resolves scale degrees correctly in A minor (Aeolian)', () {
      final key = KeySignature(tonic: Note.a(3), mode: ScaleMode.aeolian);

      expect(key.resolveDegree(Degrees.i).name, 'a3'); // A
      expect(key.resolveDegree(Degrees.ii).name, 'b3'); // B
      expect(key.resolveDegree(Degrees.iii).name, 'c4'); // C
      expect(key.resolveDegree(Degrees.iv).name, 'd4'); // D
      expect(key.resolveDegree(Degrees.v).name, 'e4'); // E
      expect(key.resolveDegree(Degrees.vi).name, 'f4'); // F
      expect(key.resolveDegree(Degrees.vii).name, 'g4'); // G
    });

    test('resolves scale degrees correctly in C phrygian with proper spelling', () {
      final key = KeySignature(tonic: Note.c(4), mode: ScaleMode.phrygian);
      expect(key.resolveDegree(Degrees.i).name, 'c4'); // C
      expect(key.resolveDegree(Degrees.ii).name, 'db4'); // D flat (proper spelling!)
      expect(key.resolveDegree(Degrees.iii).name, 'eb4'); // E flat
      expect(key.resolveDegree(Degrees.iv).name, 'f4'); // F
      expect(key.resolveDegree(Degrees.v).name, 'g4'); // G
      expect(key.resolveDegree(Degrees.vi).name, 'ab4'); // A flat
      expect(key.resolveDegree(Degrees.vii).name, 'bb4'); // B flat
    });

    test('resolves scale degrees with accidentals using proper spelling', () {
      final key = KeySignature(tonic: Note.c(4));

      expect(key.resolveDegree(Degrees.ii.flat()).name, 'db4'); // bII -> D flat (proper spelling!)
      expect(key.resolveDegree(Degrees.v.sharp()).name, 'g#4'); // #V -> G sharp
    });

    test('resolves scale degrees with octave offset', () {
      final key = KeySignature(tonic: Note.c(4));

      expect(key.resolveDegree(Degrees.i, octaveOffset: 1).name, 'c5'); // Up one octave
      expect(key.resolveDegree(Degrees.v, octaveOffset: -1).name, 'g3'); // Down one octave
    });

    test('clamps MIDI values to valid range', () {
      final key = KeySignature(tonic: Note.c(0)); // Very low

      // Should not go below MIDI 0
      final lowNote = key.resolveDegree(Degrees.i, octaveOffset: -2);
      expect(lowNote.midiNumber, greaterThanOrEqualTo(0));

      final highKey = KeySignature(tonic: Note.c(8)); // Very high

      // Should not go above MIDI 127
      final highNote = highKey.resolveDegree(Degrees.vii, octaveOffset: 2);
      expect(highNote.midiNumber, lessThanOrEqualTo(127));
    });

    test('preserves velocity from tonic', () {
      final tonic = Note.c(4);
      final key = KeySignature(tonic: tonic);

      final resolvedNote = key.resolveDegree(Degrees.v);
      expect(resolvedNote.velocity, 80);
    });

    test('works with different modal scales', () {
      // Test Lydian mode (raised 4th)
      final lydianKey = KeySignature(tonic: Note.c(4), mode: ScaleMode.lydian);

      expect(lydianKey.resolveDegree(Degrees.iv).name, 'f#4'); // Raised 4th in Lydian

      // Test Mixolydian mode (lowered 7th)
      final mixolydianKey = KeySignature(tonic: Note.c(4), mode: ScaleMode.mixolydian);

      expect(mixolydianKey.resolveDegree(Degrees.vii).name, 'a#4'); // Lowered 7th in Mixolydian (B♭ shown as A#)
    });

    test('demonstrates key-aware enharmonic spelling', () {
      // E♭ major key
      final ebMajorKey = KeySignature(tonic: Note.e(4, accidental: Accidental.flat));

      // Should use proper letter names for scale degrees
      expect(ebMajorKey.resolveDegree(Degrees.i).name, 'eb4'); // E♭
      expect(ebMajorKey.resolveDegree(Degrees.ii).name, 'f4'); // F
      expect(ebMajorKey.resolveDegree(Degrees.iii).name, 'g4'); // G
      expect(ebMajorKey.resolveDegree(Degrees.iv).name, 'ab4'); // A♭
      expect(ebMajorKey.resolveDegree(Degrees.v).name, 'bb4'); // B♭

      // Compare with F# major which should use sharps
      final fSharpMajorKey = KeySignature(tonic: Note.f(4, accidental: Accidental.sharp));
      expect(fSharpMajorKey.resolveDegree(Degrees.i).name, 'f#4'); // F#
      expect(fSharpMajorKey.resolveDegree(Degrees.ii).name, 'g#4'); // G#
      expect(fSharpMajorKey.resolveDegree(Degrees.vii).name, 'e#4'); // E# (not F!)
    });

    test('handles double sharps in extreme sharp keys', () {
      // G# major has F## naturally
      final gSharpMajorKey = KeySignature(tonic: Note.g(4, accidental: Accidental.sharp));

      // Add a sharp to the already sharp VII degree for double sharp
      expect(gSharpMajorKey.resolveDegree(Degrees.vii).name, 'f##4'); // F𝄪 (double sharp)
    });

    test('handles double flats in extreme flat keys', () {
      // C♭ minor (dear god) has Bbb, Ebb, Abb naturally
      final cbMinorKey = KeySignature(
        tonic: Note.c(4, accidental: Accidental.flat),
        mode: ScaleMode.aeolian,
      );

      // In C♭ minor, the IV degree is Bbb
      expect(cbMinorKey.resolveDegree(Degrees.iii).name, 'ebb4'); // Ebb
      expect(cbMinorKey.resolveDegree(Degrees.vi).name, 'abb4'); // Abb
      expect(cbMinorKey.resolveDegree(Degrees.vii).name, 'bbb4'); // Bbb (double flat)
    });
  });
}
