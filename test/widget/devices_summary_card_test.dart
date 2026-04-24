import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/screen/devices_screen.dart';
import 'package:simply/themes/radii.dart';

void main() {
  testWidgets('fleet summary renders compact today pill with online badge',
      (tester) async {
    final cubit = _LoadedDeviceCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DeviceCubit>.value(
          value: cubit,
          child: const Scaffold(body: DevicesScreen()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('СЕГОДНЯ'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);

    final clippedCard = tester
        .widgetList<Container>(find.byType(Container))
        .where((container) {
      final decoration = container.decoration;
      return decoration is BoxDecoration &&
          decoration.borderRadius == AppRadii.brR4 &&
          container.clipBehavior == Clip.antiAlias;
    }).toList();

    expect(clippedCard, isNotEmpty);
  });
}

class _LoadedDeviceCubit extends Cubit<DeviceState> implements DeviceCubit {
  _LoadedDeviceCubit()
      : super(
          DeviceState(
            status: DeviceStatus.loaded,
            currentDeviceId: 'redmi-9',
            items: [
              Device(
                userId: 'user',
                deviceName: 'Redmi 9',
                deviceId: 'redmi-9',
                platform: 'android',
                isMainDevice: true,
                todayMessageCount: 0,
                dateUpdateInfo: Timestamp.fromDate(DateTime.now()),
              ),
            ],
          ),
        );

  @override
  Future<void> deleteDevice(String deviceId) async {}

  @override
  Future<void> fetch() async {}

  @override
  Future<void> moveDown(String deviceId) async {}

  @override
  Future<void> moveUp(String deviceId) async {}

  @override
  Future<void> updateDevice() async {}
}
