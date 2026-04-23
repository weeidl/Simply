part of 'device_cubit.dart';

enum DeviceStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class DeviceState {
  final DeviceStatus _status;
  final List<Device> _items;
  final String? _currentDeviceId;

  DeviceState({
    required DeviceStatus status,
    List<Device>? items,
    String? currentDeviceId,
  })  : _status = status,
        _items = items ?? const [],
        _currentDeviceId = currentDeviceId;

  List<Device> get items => _items;

  DeviceStatus get status => _status;

  String? get currentDeviceId => _currentDeviceId;

  DeviceState copyWith({
    DeviceStatus? status,
    List<Device>? items,
    String? currentDeviceId,
  }) {
    return DeviceState(
      status: status ?? _status,
      items: items ?? _items,
      currentDeviceId: currentDeviceId ?? _currentDeviceId,
    );
  }
}
