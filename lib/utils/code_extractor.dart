/// Pulls a one-time code (OTP) out of message text.
///
/// Heuristic in two passes:
///   1. Look for an explicit cue word (код / code / OTP / sifre…) near a 4–8
///      digit run. This wins because cue words are reliable signals.
///   2. Fall back to the first standalone 4–8 digit number in the text, while
///      skipping decimal amounts and date fragments.
///
/// Surrounding non-digit characters (spaces, dashes) are stripped so the
/// returned string is always pure digits.
abstract class CodeExtractor {
  static const String _cueWords =
      r'код|code|otp|пароль|пин|pin|verification|(?:sifre|şifre)(?:niz(?:i)?|si)?';

  static final List<RegExp> _cuedPatterns = [
    RegExp(
      '(?:$_cueWords)\\s*[:\\-—]?\\s*([0-9][0-9 \\-]{3,9})',
      caseSensitive: false,
      unicode: true,
    ),
    RegExp(
      '([0-9][0-9 \\-]{3,9})\\s*[—\\-]?\\s*(?:$_cueWords)',
      caseSensitive: false,
      unicode: true,
    ),
  ];

  static final RegExp _standalone = RegExp(r'(?<!\d)(\d{4,8})(?!\d)');

  static String? extract(String text) {
    if (text.isEmpty) return null;
    for (final p in _cuedPatterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final digits = _normalizeCandidate(text, m, 1);
        if (digits != null) return digits;
      }
    }
    for (final m in _standalone.allMatches(text)) {
      final digits = _normalizeCandidate(text, m, 1);
      if (digits != null) return digits;
    }
    return null;
  }

  static bool hasCode(String text) => extract(text) != null;

  static String? _normalizeCandidate(String text, Match match, int group) {
    final raw = match.group(group) ?? '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4 || digits.length > 8) return null;
    final (start, end) = _groupBounds(match, raw);
    if (_looksLikeAmountOrDate(text, start, end)) {
      return null;
    }
    return digits;
  }

  static (int, int) _groupBounds(Match match, String raw) {
    final fullMatch = match.group(0) ?? '';
    final relativeStart = fullMatch.indexOf(raw);
    final start =
        relativeStart >= 0 ? match.start + relativeStart : match.start;
    return (start, start + raw.length);
  }

  static bool _looksLikeAmountOrDate(String text, int start, int end) {
    final before = start > 0 ? text[start - 1] : '';
    final beforePrevious = start > 1 ? text[start - 2] : '';
    final after = end < text.length ? text[end] : '';
    final afterNext = end + 1 < text.length ? text[end + 1] : '';

    if (_isDecimalSeparator(after) && _isDigit(afterNext)) return true;
    if (_isDecimalSeparator(before) && _isDigit(beforePrevious)) return true;
    if (_isDateSeparator(after) && _isDigit(afterNext)) return true;
    if (_isDateSeparator(before) && _isDigit(beforePrevious)) return true;

    return false;
  }

  static bool _isDecimalSeparator(String value) => value == ',' || value == '.';

  static bool _isDateSeparator(String value) => value == '/' || value == '-';

  static bool _isDigit(String value) {
    if (value.isEmpty) return false;
    final codeUnit = value.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57;
  }
}
