part of 'device_cubit.dart';

enum DeviceStatus {
  initial,
  loading,
  loaded,
  waiting,
  redirect,
  success,
  error,
}

class DeviceState {
  final DeviceStatus _status;
  final List<Device> _items;
  final int? _batteryLevel;
  final String? _networkType;

  DeviceState({
    required DeviceStatus status,
    List<Device>? items,
    int? batteryLevel,
    String? networkType,
  })  : _status = status,
        _items = items ?? [],
        _batteryLevel = batteryLevel,
        _networkType = networkType;

  List<Device> get items => _items;

  DeviceStatus get status => _status;

  int? get batteryLevel => _batteryLevel;

  String? get networkType => _networkType;

  DeviceState copyWith({
    DeviceStatus? status,
    List<Device>? items,
    int? batteryLevel,
    String? networkType,
  }) {
    return DeviceState(
      status: status ?? _status,
      items: items ?? _items,
      batteryLevel: batteryLevel ?? _batteryLevel,
      networkType: networkType ?? _networkType,
    );
  }
}
