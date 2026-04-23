import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/home/foreground_runtime_notice.dart';

void main() {
  group('ForegroundRuntimeNotice', () {
    test('uses clear product-oriented copy and branded resources', () {
      expect(
        ForegroundRuntimeNotice.title,
        'Simply активен',
      );
      expect(
        ForegroundRuntimeNotice.body,
        'Новые SMS автоматически появляются на всех ваших устройствах.',
      );
      expect(ForegroundRuntimeNotice.smallIcon, 'ic_notification_simply');
      expect(ForegroundRuntimeNotice.largeIcon, 'ic_notification_avatar');
      expect(
        ForegroundRuntimeNotice.channelName,
        'Синхронизация SMS',
      );
    });
  });
}
