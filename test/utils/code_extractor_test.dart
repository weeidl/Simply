import 'package:flutter_test/flutter_test.dart';
import 'package:simply/utils/code_extractor.dart';

void main() {
  group('CodeExtractor', () {
    test('uses Turkish password cue instead of the payment amount', () {
      const message =
          'Lutfen sifrenizi kimseyle paylasmayiniz. 1002,00 RSD tutarindaki GLOVOAPP alisverisiniz icin sifreniz 986363 Tarih: 24.04.2026 13:29 B002';

      expect(CodeExtractor.extract(message), '986363');
    });

    test('does not treat decimal payment amounts as standalone codes', () {
      const message = 'Kartinizdan 1002,00 RSD odeme alindi.';

      expect(CodeExtractor.extract(message), isNull);
    });

    test('skips amounts before later standalone codes', () {
      const message = 'Kartinizdan 1002,00 RSD odeme alindi. 986363';

      expect(CodeExtractor.extract(message), '986363');
    });

    test('keeps extracting codes with explicit Russian cues', () {
      expect(CodeExtractor.extract('Ваш код подтверждения: 70282'), '70282');
    });
  });
}
