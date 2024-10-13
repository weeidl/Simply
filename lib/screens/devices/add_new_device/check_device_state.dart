part of 'check_device_cubit.dart';

enum DeviceSettingStatus {
  initial,
  showModal,
  loading,
}

class CheckDeviceState {
  final List<Device> _items;
  final DeviceSettingStatus? _status;
  final int? _batteryLevel;
  final String? _networkType;

  CheckDeviceState({
    DeviceSettingStatus? status,
    List<Device>? items,
    int? batteryLevel,
    String? networkType,
  })  : _items = items ?? [],
        _status = status,
        _batteryLevel = batteryLevel,
        _networkType = networkType;

  List<Device> get items => _items;

  DeviceSettingStatus? get status => _status;
  int? get batteryLevel => _batteryLevel;

  String? get networkType => _networkType;

  CheckDeviceState copyWith({
    List<Device>? items,
    DeviceSettingStatus? status,
    int? batteryLevel,
    String? networkType,
  }) {
    return CheckDeviceState(
      status: status ?? _status,
      items: items ?? _items,
      batteryLevel: batteryLevel ?? _batteryLevel,
      networkType: networkType ?? _networkType,
    );
  }
}
