import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/devices/widget/device_card_actions.dart';

void main() {
  group('buildDeviceCardActions', () {
    test('returns reconnect and full move controls for current device', () {
      final actions = buildDeviceCardActions(
        isCurrentDevice: true,
        canMoveUp: true,
        canMoveDown: true,
      );

      expect(
        actions,
        [
          DeviceCardAction.reconnect,
          DeviceCardAction.moveUp,
          DeviceCardAction.moveDown,
          DeviceCardAction.delete,
        ],
      );
    });

    test('hides reconnect and unavailable moves for remote edge items', () {
      final actions = buildDeviceCardActions(
        isCurrentDevice: false,
        canMoveUp: false,
        canMoveDown: true,
      );

      expect(
        actions,
        [
          DeviceCardAction.moveDown,
          DeviceCardAction.delete,
        ],
      );
    });
  });
}
