/// Pulls a one-time code (OTP) out of message text.
///
/// Heuristic in two passes:
///   1. Look for an explicit cue word (код / code / OTP / verification…) near
///      a 4–8 digit run. This wins because cue words are reliable signals.
///   2. Fall back to the first standalone 4–8 digit number in the text.
///
/// Surrounding non-digit characters (spaces, dashes) are stripped so the
/// returned string is always pure digits.
abstract class CodeExtractor {
  static final List<RegExp> _cuedPatterns = [
    RegExp(
      r'(?:код|code|otp|пароль|пин|pin|verification)\s*[:\-—]?\s*([0-9][0-9 \-]{3,9})',
      caseSensitive: false,
    ),
    RegExp(r'([0-9][0-9 \-]{3,9})\s*[—\-]?\s*(?:код|code)',
        caseSensitive: false),
  ];

  static final RegExp _standalone = RegExp(r'(?<!\d)(\d{4,8})(?!\d)');

  static String? extract(String text) {
    if (text.isEmpty) return null;
    for (final p in _cuedPatterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final raw = m.group(1) ?? '';
        final digits = raw.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 4 && digits.length <= 8) return digits;
      }
    }
    final m = _standalone.firstMatch(text);
    return m?.group(1);
  }

  static bool hasCode(String text) => extract(text) != null;
}
