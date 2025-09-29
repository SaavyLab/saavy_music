## 0.3.0

* new: added `ChordRecipes.minorEleventh` (`m11`) chord recipe
* fix: corrected modal scale factories in `lib/src/theory/scale.dart` (dorian, phrygian, lydian, mixolydian, locrian) to match standard semitone patterns and `ScaleMode` (including octave `12` endpoint)
* fix: `Chord` constructor now defensively copies `intervals` before sorting to preserve immutability and avoid errors when inverting chords
* maintenance: switched from `freezed_annotation` to `meta` for `@immutable` and removed the unused dependency
* docs: updated examples to use `ChordRecipes.minorEleventh` and clarified advanced harmony section
* tests: added unit tests for scales, notes, intervals, and chords to prevent regressions (modes, naming, inversions)
* ci: added github actions workflow to run `dart analyze` and `dart test` on push/pr

> note: correcting modal intervals may change behavior if you relied on the previous incorrect values.

## 0.2.0

* Added `KeyAwareNote` support so `KeySignature.resolveDegree` returns notes spelled correctly for the active key/mode, including double accidentals
* Fixed octave handling for altered scale degrees so sevenths and accidentals stay in their intended register
* Improved documentation with examples for key-aware enharmonic spelling and clarified feature list

## 0.1.0

* Initial release of saavy_music
* Core music theory models: Note, Interval, Chord, ChordRecipe, KeySignature
* Compositional chord system with TriadQuality and ChordExtension
* Comprehensive set of pre-defined chord recipes (triads, sevenths, extensions)
* MIDI integration with frequency calculation
* Scale degree resolution within key signatures
* Support for chord inversions
* Full test coverage
* Educational focus for ear training applications
