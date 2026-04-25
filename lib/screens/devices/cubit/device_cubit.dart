import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/device.dart';
import 'package:simply/repositories/device_repository.dart';
import 'package:simply/security/secure_storage_service.dart';

part 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final DeviceRepository _deviceRepository;
  final SecureStorageService _secureStorageService;
  StreamSubscription<List<Device>>? _devicesSub;

  DeviceCubit({
    DeviceRepository? deviceRepository,
    SecureStorageService? secureStorageService,
  })  : _deviceRepository = deviceRepository ?? DeviceRepository(),
        _secureStorageService = secureStorageService ?? SecureStorageService(),
        super(DeviceState(status: DeviceStatus.initial));

  Future<void> fetch() async {
    emit(state.copyWith(status: DeviceStatus.loading));
    await _bindDevices();
  }

  /// Forces the current stream to drop and re-subscribe. Mainly used by
  /// pull-to-refresh; the live subscription means data stays current on its
  /// own after the initial [fetch].
  Future<void> updateDevice() => _bindDevices();

  Future<void> deleteDevice(String deviceId) async {
    try {
      await _deviceRepository.delete(deviceId);
      final updatedDevices =
          state.items.where((device) => device.deviceId != deviceId).toList();
      final normalized = await _persistOrder(updatedDevices);
      emit(state.copyWith(
        items: normalized,
        status: normalized.isEmpty ? DeviceStatus.empty : DeviceStatus.loaded,
      ));
    } catch (_) {
      emit(state.copyWith(status: DeviceStatus.error));
    }
  }

  Future<void> togglePin(String deviceId) async {
    final device = state.items.firstWhere(
      (d) => d.deviceId == deviceId,
      orElse: () => throw StateError('Device $deviceId not in state'),
    );
    final next = !device.pinned;
    final optimistic = state.items
        .map((d) => d.deviceId == deviceId ? d.copyWith(pinned: next) : d)
        .toList();
    emit(state.copyWith(items: optimistic));
    try {
      await _deviceRepository.setPinned(deviceId, next);
    } catch (_) {
      final rolledBack = state.items
          .map((d) => d.deviceId == deviceId ? d.copyWith(pinned: !next) : d)
          .toList();
      emit(state.copyWith(items: rolledBack));
    }
  }

  Future<void> moveUp(String deviceId) async {
    final index =
        state.items.indexWhere((device) => device.deviceId == deviceId);
    if (index <= 0) return;
    final reordered = [...state.items];
    final item = reordered.removeAt(index);
    reordered.insert(index - 1, item);
    final normalized = await _persistOrder(reordered);
    emit(state.copyWith(items: normalized));
  }

  Future<void> moveDown(String deviceId) async {
    final index =
        state.items.indexWhere((device) => device.deviceId == deviceId);
    if (index == -1 || index >= state.items.length - 1) return;
    final reordered = [...state.items];
    final item = reordered.removeAt(index);
    reordered.insert(index + 1, item);
    final normalized = await _persistOrder(reordered);
    emit(state.copyWith(items: normalized));
  }

  Future<List<Device>> _normalizeOrder(List<Device> devices) async {
    final ordered = [...devices]..sort(_deviceComparator);
    final needsNormalization = ordered.asMap().entries.any(
          (entry) => entry.value.sortOrder != entry.key,
        );
    if (!needsNormalization) return ordered;
    return _persistOrder(ordered);
  }

  Future<List<Device>> _persistOrder(List<Device> devices) async {
    if (devices.isEmpty) return const [];
    final normalized = [
      for (var i = 0; i < devices.length; i++)
        devices[i].copyWith(sortOrder: i),
    ];
    await _deviceRepository.saveOrder(normalized);
    return normalized;
  }

  Future<void> _bindDevices() async {
    await _devicesSub?.cancel();

    final currentDeviceId = await _secureStorageService.readDeviceId();

    // Completes once the stream produces its first event (success or error) so
    // callers like `fetch()` / `updateDevice()` can await the initial load and
    // drive the pull-to-refresh indicator. Subsequent events keep updating the
    // state in-place.
    final firstEvent = Completer<void>();
    _devicesSub = _deviceRepository.watch().listen(
      (devices) async {
        try {
          final normalized = await _normalizeOrder(devices);
          emit(state.copyWith(
            status:
                normalized.isEmpty ? DeviceStatus.empty : DeviceStatus.loaded,
            items: normalized,
            currentDeviceId: currentDeviceId,
          ));
        } catch (_) {
          emit(state.copyWith(status: DeviceStatus.error));
        } finally {
          if (!firstEvent.isCompleted) firstEvent.complete();
        }
      },
      onError: (Object _) {
        emit(state.copyWith(status: DeviceStatus.error));
        if (!firstEvent.isCompleted) firstEvent.complete();
      },
    );

    return firstEvent.future;
  }

  @override
  Future<void> close() async {
    await _devicesSub?.cancel();
    return super.close();
  }

  int _deviceComparator(Device a, Device b) {
    final aOrder = a.sortOrder;
    final bOrder = b.sortOrder;
    if (aOrder != null && bOrder != null) {
      final compare = aOrder.compareTo(bOrder);
      if (compare != 0) return compare;
    } else if (aOrder != null) {
      return -1;
    } else if (bOrder != null) {
      return 1;
    }

    final aMain = a.isMainDevice ? 0 : 1;
    final bMain = b.isMainDevice ? 0 : 1;
    if (aMain != bMain) return aMain.compareTo(bMain);

    final aReceiver = a.isReceiverOnly ? 1 : 0;
    final bReceiver = b.isReceiverOnly ? 1 : 0;
    if (aReceiver != bReceiver) return aReceiver.compareTo(bReceiver);

    final aDate = a.dateUpdateInfo?.toDate();
    final bDate = b.dateUpdateInfo?.toDate();
    if (aDate != null && bDate != null) {
      final compare = bDate.compareTo(aDate);
      if (compare != 0) return compare;
    }

    return a.deviceName.toLowerCase().compareTo(b.deviceName.toLowerCase());
  }
}
