/// Simple accidental support for altered notes and scale degrees.
enum Accidental { doubleFlat, flat, natural, sharp, doubleSharp }

/// Get the semitone offset for an accidental.
int accidentalOffset(final Accidental accidental) {
  switch (accidental) {
    case Accidental.doubleFlat:
      return -2;
    case Accidental.flat:
      return -1;
    case Accidental.natural:
      return 0;
    case Accidental.sharp:
      return 1;
    case Accidental.doubleSharp:
      return 2;
  }
}
