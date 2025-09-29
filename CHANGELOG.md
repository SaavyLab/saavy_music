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
