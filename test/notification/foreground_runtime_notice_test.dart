import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/home/foreground_runtime_notice.dart';

void main() {
  group('ForegroundRuntimeNotice', () {
    test('uses short product-oriented copy and branded resources', () {
      expect(ForegroundRuntimeNotice.title, 'SMS на связи');
      expect(
        ForegroundRuntimeNotice.body,
        'Сообщения приходят на все ваши устройства.',
      );
      expect(ForegroundRuntimeNotice.smallIcon, 'ic_notification_simply');
      expect(ForegroundRuntimeNotice.largeIcon, 'ic_notification_avatar');
      expect(ForegroundRuntimeNotice.channelName, 'Синхронизация SMS');
    });
  });
}
