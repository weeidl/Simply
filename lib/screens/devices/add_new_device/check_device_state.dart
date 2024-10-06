part of 'check_device_cubit.dart';

class CheckDeviceState {
  final List<Device> _items;
  final int? _batteryLevel;
  final String? _networkType;

  CheckDeviceState({
    List<Device>? items,
    int? batteryLevel,
    String? networkType,
  })  : _items = items ?? [],
        _batteryLevel = batteryLevel,
        _networkType = networkType;

  List<Device> get items => _items;

  int? get batteryLevel => _batteryLevel;

  String? get networkType => _networkType;

  CheckDeviceState copyWith({
    List<Device>? items,
    int? batteryLevel,
    String? networkType,
  }) {
    return CheckDeviceState(
      items: items ?? _items,
      batteryLevel: batteryLevel ?? _batteryLevel,
      networkType: networkType ?? _networkType,
    );
  }
}
