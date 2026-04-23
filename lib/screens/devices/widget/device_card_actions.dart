enum DeviceCardAction {
  reconnect,
  moveUp,
  moveDown,
  delete,
}

List<DeviceCardAction> buildDeviceCardActions({
  required bool isCurrentDevice,
  required bool canMoveUp,
  required bool canMoveDown,
}) {
  return [
    if (isCurrentDevice) DeviceCardAction.reconnect,
    if (canMoveUp) DeviceCardAction.moveUp,
    if (canMoveDown) DeviceCardAction.moveDown,
    DeviceCardAction.delete,
  ];
}
