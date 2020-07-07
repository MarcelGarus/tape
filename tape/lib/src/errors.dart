const repositoryLink = 'https://github.com/marcelgarus/tape';

class TapeError extends Error {
  TapeError(this.parts) : assert(parts != null);

  final List<ErrorPart> parts;

  @override
  String toString() => parts.join('\n');
}

class TapeException implements Exception {
  TapeException(this.parts) : assert(parts != null);

  final List<ErrorPart> parts;

  @override
  String toString() => parts.join('\n');
}

class ErrorPart {}

class ErrorSummary extends ErrorPart {
  ErrorSummary(this.text)
      : assert(text != null),
        assert(text.isNotEmpty);

  final String text;
}

class ErrorText extends ErrorPart {
  ErrorText(this.text)
      : assert(text != null),
        assert(text.isNotEmpty);

  final String text;
}

class ErrorCallToAction extends ErrorPart {
  ErrorCallToAction(this.text)
      : assert(text != null),
        assert(text.isNotEmpty);

  final String text;
}
