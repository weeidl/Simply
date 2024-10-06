import 'package:battery_plus/battery_plus.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      emit(
        state.copyWith(
          status: DeviceStatus.error,
        ),
      );
    }

    // ----------------------------------------------------------------------------
    // if (state.items[0].isMainDevice == true) {
    //   batteryStatus();
    //   networkTypeStatus();
    // }
  }
}
