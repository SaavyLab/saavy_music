# contributing to saavy_music

## prerequisites
- dart sdk: stable (see `pubspec.yaml`)

## setup
- dart pub get

## checks
- dart analyze
- dart test -r compact

## style & design
- prefer immutable models (`@immutable` from `meta`)
- shape/composition over enumerating chord types (`ChordRecipe`-centric)
- no string-parse apis for notes
- keep enharmonic spelling key-aware
- avoid new deps; stick to `meta`, `collection`

## tests
- add tests for any new scale/chord/note/interval behavior
- include inversion & naming expectations for chords
- ensure modal scales match expected intervals

## docs & versioning
- update README examples if api changes
- bump version in `pubspec.yaml` and add `CHANGELOG.md` entry
- tag releases as `vX.Y.Z` (workflow auto-publishes to pub.dev)
- keep repository secret `PUB_CREDENTIALS` synced with pub.dev credentials


## pr checklist
- [ ] dart analyze passes
- [ ] dart test passes
- [ ] tests added/updated
- [ ] docs updated (if applicable)
- [ ] version + changelog (if user-facing)