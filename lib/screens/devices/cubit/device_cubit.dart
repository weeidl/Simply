import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/repositories/device_repository.dart';

part 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final DeviceRepository _deviceRepository = DeviceRepository();

  DeviceCubit() : super(DeviceState(status: DeviceStatus.initial));

  Future fetch() async {
    emit(state.copyWith(status: DeviceStatus.loading));
    try {
      final response = await _deviceRepository.fetch();
      emit(
        state.copyWith(
          status: DeviceStatus.loaded,
          items: response,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: DeviceStatus.error));
    }
  }

  Future<void> updateDevice() async {
    try {
      final response = await _deviceRepository.fetch();
      emit(state.copyWith(items: response));
    } catch (e) {
      emit(state.copyWith(status: DeviceStatus.error));
    }
  }
}
