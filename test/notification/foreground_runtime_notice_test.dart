import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/home/foreground_runtime_notice.dart';

void main() {
  group('ForegroundRuntimeNotice', () {
    test('uses friendly copy and branded resources', () {
      expect(
        ForegroundRuntimeNotice.title,
        'Simply рядом',
      );
      expect(
        ForegroundRuntimeNotice.body,
        'Я тихо принимаю новые SMS и аккуратно синхронизирую их, пока ты занят.',
      );
      expect(ForegroundRuntimeNotice.smallIcon, 'ic_notification_simply');
      expect(ForegroundRuntimeNotice.largeIcon, 'ic_notification_avatar');
      expect(
        ForegroundRuntimeNotice.channelName,
        'Фоновая синхронизация Simply',
      );
    });
  });
}
