import 'dart:ui';

abstract class ForegroundRuntimeNotice {
  static const channelId = 'foreground_channel_id';
  static String get channelName =>
      _isRu ? 'Синхронизация SMS' : 'SMS Sync';
  static String get channelDescription => _isRu
      ? 'Пересылает входящие SMS на ваши устройства.'
      : 'Forwards incoming SMS to your devices.';

  static String get title => _isRu ? 'SMS на связи' : 'SMS connected';
  static String get body => _isRu
      ? 'Сообщения приходят на все ваши устройства.'
      : 'Messages arrive on all your devices.';

  static const smallIcon = 'ic_notification_simply';
  static const largeIcon = 'ic_notification_avatar';

  static bool get _isRu =>
      PlatformDispatcher.instance.locale.languageCode.toLowerCase() == 'ru';
}
