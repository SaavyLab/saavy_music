// ignore_for_file: avoid_print

import 'package:saavy_music/saavy_music.dart';

void main() {
  print('🎵 Welcome to saavy_music examples!\n');

  // Basic note creation and properties
  basicNoteExample();
  print('');

  // Chord recipe system demonstration
  chordRecipeExample();
  print('');

  // Key signatures and scale degrees
  keySignatureExample();
  print('');

  // Chord inversions
  inversionExample();
  print('');

  // Custom chord recipes
  customChordExample();
  print('');

  // Diatonic chord qualities
  diatonicChordExample();
  print('');

  // Ear training progression generator
  earTrainingExample();
  print('');

  // Key-aware enharmonic spelling
  enharmonicSpellingExample();
}

void basicNoteExample() {
  print('📝 Basic Notes and Intervals:');
  print('==========================');

  // Create notes using factory constructors
  final c4 = Note.c(4);
  final fSharp5 = Note.f(5, accidental: Accidental.sharp);

  print('C4: ${c4.name} (MIDI ${c4.midiNumber}, ${c4.frequency.toStringAsFixed(2)} Hz)');
  print('F#5: ${fSharp5.name} (MIDI ${fSharp5.midiNumber}, ${fSharp5.frequency.toStringAsFixed(2)} Hz)');

  // Work with intervals
  final perfectFifth = Interval.perfectFifth();
  final majorThird = Interval.majorThird();

  print('Perfect Fifth: ${perfectFifth.name} (${perfectFifth.semitones} semitones)');
  print('Major Third: ${majorThird.name} (${majorThird.semitones} semitones)');
}

void chordRecipeExample() {
  print('🎹 ChordRecipe System:');
  print('=====================');

  final c4 = Note.c(4);

  // Use pre-defined recipes
  final cmaj7 = Chord.fromRecipe(c4, ChordRecipes.majorSeventh);
  final dm = Chord.fromRecipe(Note.d(4), ChordRecipes.minorTriad);
  final g7 = Chord.fromRecipe(Note.g(4), ChordRecipes.dominantSeventh);

  print('Cmaj7: ${cmaj7.name} → ${cmaj7.notes.map((n) => n.name).join(', ')}');
  print('Dm: ${dm.name} → ${dm.notes.map((n) => n.name).join(', ')}');
  print('G7: ${g7.name} → ${g7.notes.map((n) => n.name).join(', ')}');

  // Show available recipe collections
  print('\nAvailable recipes:');
  print('- Triads: ${ChordRecipes.triads.length} (${ChordRecipes.triads.map((r) => r.displayLabel).join(', ')})');
  print('- Sevenths: ${ChordRecipes.sevenths.length} (${ChordRecipes.sevenths.map((r) => r.displayLabel).join(', ')})');
  print(
    '- Extensions: ${ChordRecipes.extensions.length} (${ChordRecipes.extensions.map((r) => r.displayLabel).join(', ')})',
  );
}

void keySignatureExample() {
  print('🗝️  Key Signatures and Scale Degrees:');
  print('===================================');

  // Define a key signature
  final keyOfEbMajor = KeySignature(tonic: Note.e(4, accidental: Accidental.flat));

  print('Key: ${keyOfEbMajor.label}');

  // Resolve scale degrees
  final degrees = [Degrees.i, Degrees.ii, Degrees.iii, Degrees.iv, Degrees.v, Degrees.vi, Degrees.vii];
  final romanNumerals = ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'];

  for (int i = 0; i < degrees.length; i++) {
    final note = keyOfEbMajor.resolveDegree(degrees[i]);
    print('${romanNumerals[i]}: ${note.name}');
  }

  // Build a chord progression
  final tonic = Chord.major(keyOfEbMajor.resolveDegree(Degrees.i));
  final vi = Chord.minor(keyOfEbMajor.resolveDegree(Degrees.vi));
  final subdominant = Chord.major(keyOfEbMajor.resolveDegree(Degrees.iv));
  final dominantSeventh = Chord.dominantSeventh(keyOfEbMajor.resolveDegree(Degrees.v));

  print('\nvi-IV-I-V progression in ${keyOfEbMajor.label}:');
  print('${vi.name} - ${subdominant.name} - ${tonic.name} - ${dominantSeventh.name}');
}

void inversionExample() {
  print('🔄 Chord Inversions:');
  print('==================');

  final cMajor = Chord.major(Note.c(4));

  print('C Major chord inversions:');
  print('Root position: ${cMajor.notes.map((n) => n.name).join(', ')} (${cMajor.name})');
  print('1st inversion: ${cMajor.invert(1).notes.map((n) => n.name).join(', ')} (${cMajor.invert(1).name})');
  print('2nd inversion: ${cMajor.invert(2).notes.map((n) => n.name).join(', ')} (${cMajor.invert(2).name})');
}

void customChordExample() {
  print('🎨 Custom Chord Recipes:');
  print('=======================');

  // Create a custom chord recipe
  const customAdd9 = ChordRecipe(
    id: 'custom_add9',
    displayLabel: 'add9',
    fullName: 'Custom Add Nine',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.majorNinth},
  );

  final cAdd9 = Chord.fromRecipe(Note.c(4), customAdd9);
  print('Custom Cadd9: ${cAdd9.name} → ${cAdd9.notes.map((n) => n.name).join(', ')}');

  // Create an altered dominant
  const alteredDominant = ChordRecipe(
    id: 'altered_dom',
    displayLabel: '7alt',
    fullName: 'Altered Dominant',
    triadQuality: TriadQuality.major,
    extensions: {ChordExtension.minorSeventh, ChordExtension.augmentedNinth, ChordExtension.augmentedEleventh},
  );

  final g7alt = Chord.fromRecipe(Note.g(4), alteredDominant);
  print('G7alt: ${g7alt.name} → ${g7alt.notes.map((n) => n.name).join(', ')}');
}

void diatonicChordExample() {
  print('🎼 Diatonic Chord Qualities:');
  print('===========================');

  final cMajor = KeySignature(tonic: Note.c(4), mode: ScaleMode.ionian);
  print('Key: ${cMajor.label}');
  print('Diatonic triads (I, ii, iii, IV, V, vi, vii°):');

  final degrees = [Degrees.i, Degrees.ii, Degrees.iii, Degrees.iv, Degrees.v, Degrees.vi, Degrees.vii];
  final romanNumerals = ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'];

  for (int i = 0; i < degrees.length; i++) {
    final triad = cMajor.getDiatonicTriad(degrees[i]);
    final seventh = cMajor.getDiatonicSeventh(degrees[i]);
    final root = cMajor.resolveDegree(degrees[i]);
    print('  ${romanNumerals[i]}: ${triad.displayLabel} (${Chord.fromRecipe(root, triad).name}) or '
        '${seventh.displayLabel} (${Chord.fromRecipe(root, seventh).name})');
  }

  print('\nKey: A Natural Minor (Aeolian)');
  final aMinor = KeySignature(tonic: Note.a(3), mode: ScaleMode.aeolian);
  print('Diatonic triads (i, ii°, ♭III, iv, v, ♭VI, ♭VII):');

  final minorNumerals = ['i', 'ii°', '♭III', 'iv', 'v', '♭VI', '♭VII'];
  for (int i = 0; i < degrees.length; i++) {
    final triad = aMinor.getDiatonicTriad(degrees[i]);
    final root = aMinor.resolveDegree(degrees[i]);
    print('  ${minorNumerals[i]}: ${triad.displayLabel} (${Chord.fromRecipe(root, triad).name})');
  }

  print('\nValidating diatonic vs borrowed chords:');
  print('  In C Major:');
  print('    V (G major): ${cMajor.isDiatonic(Degrees.v, ChordRecipes.majorTriad)} ✓');
  print('    v (G minor): ${cMajor.isDiatonic(Degrees.v, ChordRecipes.minorTriad)} ✗ (borrowed from minor)');
  print('    ii (D minor): ${cMajor.isDiatonic(Degrees.ii, ChordRecipes.minorTriad)} ✓');
  print('    II (D major): ${cMajor.isDiatonic(Degrees.ii, ChordRecipes.majorTriad)} ✗ (borrowed/altered)');
  print('    V7 (G7): ${cMajor.isDiatonic(Degrees.v, ChordRecipes.dominantSeventh)} ✓ (diatonic seventh)');
}

void earTrainingExample() {
  print('🎓 Ear Training Progression Generator:');
  print('====================================');

  final keys = [KeySignature(tonic: Note.c(4)), KeySignature(tonic: Note.g(4)), KeySignature(tonic: Note.f(4))];

  final progressions = [
    ([Degrees.i, Degrees.vi, Degrees.iv, Degrees.v], 'I-vi-IV-V'),
    ([Degrees.ii, Degrees.v, Degrees.i], 'ii-V-I'),
    ([Degrees.i, Degrees.iv, Degrees.v, Degrees.i], 'I-IV-V-I'),
  ];

  print('Random chord progressions for practice:\n');

  for (final key in keys) {
    print('Key of ${key.label}:');
    for (final (progression, name) in progressions) {
      final chords = progression.map((degree) {
        // Use the new getDiatonicTriad method to get the correct chord quality!
        final recipe = key.getDiatonicTriad(degree);
        final root = key.resolveDegree(degree);
        return Chord.fromRecipe(root, recipe);
      }).toList();

      print('  $name: ${chords.map((c) => c.name).join(' - ')}');
    }
    print('');
  }
}

void enharmonicSpellingExample() {
  print('🎼 Key-Aware Enharmonic Spelling:');
  print('=================================');

  // Compare the same pitches in different key contexts
  print('Same MIDI pitches, different key contexts:\n');

  // D♭ major (5 flats)
  final dbMajorKey = KeySignature(tonic: Note.d(4, accidental: Accidental.flat));
  print('D♭ Major scale:');
  final dbMajorDegrees = [Degrees.i, Degrees.ii, Degrees.iii, Degrees.iv, Degrees.v, Degrees.vi, Degrees.vii];
  final dbMajorScale = dbMajorDegrees.map((degree) => dbMajorKey.resolveDegree(degree)).toList();
  print('  ${dbMajorScale.map((n) => n.name).join(' - ')}');

  // F# major (6 sharps)
  final fSharpMajorKey = KeySignature(tonic: Note.f(4, accidental: Accidental.sharp));
  print('\nF# Major scale:');
  final fSharpMajorScale = dbMajorDegrees.map((degree) => fSharpMajorKey.resolveDegree(degree)).toList();
  print('  ${fSharpMajorScale.map((n) => n.name).join(' - ')}');

  print('\nNotice how:');
  print('- D♭ major uses flats: db4, eb4, ab4, bb4');
  print('- F# major uses sharps: f#4, g#4, a#4, c#5, d#5, e#4');
  print('- The E# in F# major (not F) maintains proper letter sequence!');

  // Show Phrygian mode with proper flat spelling
  print('\nC Phrygian mode (demonstrating the original issue):');
  final cPhrygianKey = KeySignature(tonic: Note.c(4), mode: ScaleMode.phrygian);
  final phrygianScale = dbMajorDegrees.map((degree) => cPhrygianKey.resolveDegree(degree)).toList();
  print('  ${phrygianScale.map((n) => n.name).join(' - ')}');
  print('  Now the second degree is properly spelled as "db4" (not "c#4")!');

  // Show accidental modifications
  print('\nAccidental modifications:');
  final cMajorKey = KeySignature(tonic: Note.c(4));
  print('C Major with altered degrees:');
  print('  ♭II: ${cMajorKey.resolveDegree(Degrees.ii.flat()).name} (D♭, not C#)');
  print('  #IV: ${cMajorKey.resolveDegree(Degrees.iv.sharp()).name} (F#, not G♭)');
  print('  ♭VII: ${cMajorKey.resolveDegree(Degrees.vii.flat()).name} (B♭, not A#)');
}
