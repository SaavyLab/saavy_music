import 'package:saavy_music/saavy_music.dart';
import 'package:test/test.dart';

void main() {
  group('Chord', () {
    test('major triad notes and name', () {
      final c4 = Note.c(4);
      final chord = Chord.major(c4);
      final midi = chord.notes.map((n) => n.midiNumber).toList();
      expect(midi, [60, 64, 67]);
      expect(chord.name.startsWith('c4'), isTrue);
    });

    test('minor seventh from recipe', () {
      final d4 = Note.d(4);
      final chord = Chord.fromRecipe(d4, ChordRecipes.minorSeventh);
      final midi = chord.notes.map((n) => n.midiNumber).toList();
      expect(midi, [62, 65, 69, 72]);
    });

    test('inversions rotate and lift by octaves', () {
      final c4 = Note.c(4);
      final chord = Chord.major(c4);
      final inv1 = chord.invert(1);
      final inv2 = chord.invert(2);
      expect(inv1.notes.map((n) => n.midiNumber).toList(), [64, 67, 72]);
      expect(inv2.notes.map((n) => n.midiNumber).toList(), [67, 72, 76]);
    });

    test('dominant seventh slash name on inversion', () {
      final g4 = Note.g(4);
      final g7 = Chord.dominantSeventh(g4);
      final inv1 = g7.invert(1);
      // should include slash with bass note of inversion
      expect(inv1.name.contains('/'), isTrue);
      final bass = inv1.notes.first.name;
      expect(inv1.name.endsWith('/$bass'), isTrue);
    });

    test('minor eleventh recipe builds expected intervals', () {
      final d4 = Note.d(4);
      final m11 = Chord.fromRecipe(d4, ChordRecipes.minorEleventh);
      final midi = m11.notes.map((n) => n.midiNumber - d4.midiNumber).toList();
      expect(midi, containsAllInOrder([0, 3, 7, 10, 14, 17]));
    });
  });
}
