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

  DeviceState({
    required DeviceStatus status,
    List<Device>? items,
  })  : _status = status,
        _items = items ?? [];

  List<Device> get items => _items;

  DeviceStatus get status => _status;

  DeviceState copyWith({
    DeviceStatus? status,
    List<Device>? items,
  }) {
    return DeviceState(
      status: status ?? _status,
      items: items ?? _items,
    );
  }
}
