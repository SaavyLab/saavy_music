import 'package:saavy_music/saavy_music.dart';
import 'package:test/test.dart';

void main() {
  group('Note', () {
    test('fromComponents midi mapping and name', () {
      final c4 = Note.fromComponents(noteName: NoteName.c, octave: 4);
      expect(c4.midiNumber, 60);
      expect(c4.name, 'c4');

      final fSharp5 = Note.fromComponents(noteName: NoteName.f, octave: 5, accidental: Accidental.sharp);
      expect(fSharp5.midiNumber, 78);
      expect(fSharp5.name, 'f#5');
    });

    test('components round trip for natural and sharp', () {
      final gSharp3 = Note.fromComponents(noteName: NoteName.g, octave: 3, accidental: Accidental.sharp);
      final (name, octave, acc) = gSharp3.components;
      expect(name, NoteName.g);
      expect(octave, 3);
      expect(acc, Accidental.sharp);
    });

    test('nameWithSpelling respects preference', () {
      final cSharp4 = Note.fromComponents(noteName: NoteName.c, octave: 4, accidental: Accidental.sharp);
      expect(cSharp4.nameWithSpelling(preferFlats: false), 'c#4');
      expect(cSharp4.nameWithSpelling(preferFlats: true), 'db4');
    });

    test('frequency matches a4=440 and c4 approx', () {
      final a4 = Note.a(4);
      expect((a4.frequency - 440.0).abs() < 1e-6, isTrue);

      final c4 = Note.c(4);
      // expected around 261.6256
      expect((c4.frequency - 261.6255653005986).abs() < 1e-6, isTrue);
    });

    test('random note within bounds', () {
      final n = Note.random(lowerLimit: 10, upperLimit: 20);
      expect(n.midiNumber >= 10 && n.midiNumber <= 20, isTrue);
    });
  });
}
