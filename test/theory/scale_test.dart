import 'package:saavy_music/saavy_music.dart';
import 'package:test/test.dart';

void main() {
  group('Scale factories', () {
    test('major intervals and notes', () {
      final c4 = Note.c(4);
      final scale = Scale.major(c4);
      expect(scale.intervals, [2, 4, 5, 7, 9, 11, 12]);
      final expectedMidi = [
        c4.midiNumber,
        ...[2, 4, 5, 7, 9, 11, 12].map((s) => c4.midiNumber + s),
      ];
      final expectedNoteNames = ['c4', 'd4', 'e4', 'f4', 'g4', 'a4', 'b4', 'c5'];
      expect(scale.notes.map((n) => n.midiNumber).toList(), expectedMidi);
      expect(scale.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('natural minor', () {
      final a3 = Note.a(3);
      final scale = Scale.naturalMinor(a3);
      final expectedNoteNames = ['a3', 'b3', 'c4', 'd4', 'e4', 'f4', 'g4', 'a4'];
      expect(scale.intervals, [2, 3, 5, 7, 8, 10, 12]);
      expect(scale.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('harmonic minor', () {
      final a3 = Note.a(3);
      final scale = Scale.harmonicMinor(a3);
      expect(scale.intervals, [2, 3, 5, 7, 8, 11, 12]);
      final expectedNoteNames = ['a3', 'b3', 'c4', 'd4', 'e4', 'f4', 'g#4', 'a4'];
      expect(scale.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('melodic minor', () {
      final a3 = Note.a(3);
      final scale = Scale.melodicMinor(a3);
      expect(scale.intervals, [2, 3, 5, 7, 9, 11, 12]);
      final expectedNoteNames = ['a3', 'b3', 'c4', 'd4', 'e4', 'f#4', 'g#4', 'a4'];
      expect(scale.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('major pentatonic', () {
      final c4 = Note.c(4);
      expect(Scale.majorPentatonic(c4).intervals, [2, 4, 7, 9, 12]);
      final expectedNoteNames = ['c4', 'd4', 'e4', 'g4', 'a4', 'c5'];
      expect(Scale.majorPentatonic(c4).notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('minor pentatonic', () {
      final a3 = Note.a(3);
      expect(Scale.minorPentatonic(a3).intervals, [3, 5, 7, 10, 12]);
      final expectedNoteNames = ['a3', 'c4', 'd4', 'e4', 'g4', 'a4'];
      expect(Scale.minorPentatonic(a3).notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('blues', () {
      final a3 = Note.a(3);
      expect(Scale.blues(a3).intervals, [3, 5, 6, 7, 10, 12]);
      final expectedNoteNames = ['a3', 'c4', 'd4', 'd#4', 'e4', 'g4', 'a4'];
      expect(Scale.blues(a3).notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('chromatic', () {
      final c4 = Note.c(4);
      final chrom = Scale.chromatic(c4);
      expect(chrom.intervals.length, 12);
      expect(chrom.intervals.first, 1);
      expect(chrom.intervals.last, 12);
      final expectedNoteNames = ['c4', 'c#4', 'd4', 'd#4', 'e4', 'f4', 'f#4', 'g4', 'g#4', 'a4', 'a#4', 'b4', 'c5'];
      expect(chrom.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('modes: dorian', () {
      final d = Scale.dorian(Note.d(4));
      expect(d.intervals, [2, 3, 5, 7, 9, 10, 12]);
      final expectedNoteNames = ['d4', 'e4', 'f4', 'g4', 'a4', 'b4', 'c5', 'd5'];
      expect(d.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('modes: phrygian', () {
      final p = Scale.phrygian(Note.e(4));
      expect(p.intervals, [1, 3, 5, 7, 8, 10, 12]);
      final expectedNoteNames = ['e4', 'f4', 'g4', 'a4', 'b4', 'c5', 'd5', 'e5'];
      expect(p.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('modes: lydian', () {
      final l = Scale.lydian(Note.f(4));
      expect(l.intervals, [2, 4, 6, 7, 9, 11, 12]);
      final expectedNoteNames = ['f4', 'g4', 'a4', 'b4', 'c5', 'd5', 'e5', 'f5'];
      expect(l.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('modes: mixolydian', () {
      final m = Scale.mixolydian(Note.g(4));
      expect(m.intervals, [2, 4, 5, 7, 9, 10, 12]);
      final expectedNoteNames = ['g4', 'a4', 'b4', 'c5', 'd5', 'e5', 'f5', 'g5'];
      expect(m.notes.map((n) => n.name).toList(), expectedNoteNames);
    });

    test('modes: locrian', () {
      final l = Scale.locrian(Note.b(4));
      expect(l.intervals, [1, 3, 5, 6, 8, 10, 12]);
      final expectedNoteNames = ['b4', 'c5', 'd5', 'e5', 'f5', 'g5', 'a5', 'b5'];
      expect(l.notes.map((n) => n.name).toList(), expectedNoteNames);
    });
  });
}
