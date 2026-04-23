import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/settings/build_switch_tile.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

class DeviceSettingsWidget extends StatefulWidget {
  final Device? device;
  const DeviceSettingsWidget({super.key, this.device});

  @override
  State<DeviceSettingsWidget> createState() => _DeviceSettingsWidgetState();
}

class _DeviceSettingsWidgetState extends State<DeviceSettingsWidget> {
  late bool isSMSEnabled;
  late bool isNetworkEnabled;
  late bool isChargingEnabled;

  @override
  void initState() {
    super.initState();
    isSMSEnabled = widget.device?.isMainDevice ?? true;
    isNetworkEnabled = widget.device == null
        ? true
        : widget.device?.networkType != null;
    isChargingEnabled = widget.device == null
        ? true
        : widget.device?.batteryLevel != null;
  }

  double _height(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return h < 650 ? h * 0.95 : h * 0.78;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.device != null;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _height(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.bgAlt,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isEdit ? 'Настройки устройства' : 'Новое устройство',
                style: AppTextStyle.title(AppColor.ink),
              ),
              const SizedBox(height: 6),
              Text(
                'Выберите, какие данные показывать в приложении и какие функции активировать.',
                style: AppTextStyle.bodySm(AppColor.inkTertiary),
              ),
              const SizedBox(height: 20),
              BuildSwitchTile(
                title: 'Отправка SMS',
                subtitle:
                    'Разрешить пересылать сообщения с этого устройства',
                value: isSMSEnabled,
                onChanged: (v) => setState(() => isSMSEnabled = v),
              ),
              const SizedBox(height: 10),
              BuildSwitchTile(
                title: 'Показ сети',
                subtitle: 'В карточке отобразится тип сети и качество сигнала',
                value: isNetworkEnabled,
                onChanged: (v) => setState(() => isNetworkEnabled = v),
              ),
              const SizedBox(height: 10),
              BuildSwitchTile(
                title: 'Уровень заряда',
                subtitle:
                    'В разделе «Устройства» появится текущий уровень заряда',
                value: isChargingEnabled,
                onChanged: (v) => setState(() => isChargingEnabled = v),
              ),
              const Spacer(),
              _PrimaryAction(
                label: 'Сохранить',
                onTap: _save,
              ),
              if (isEdit) ...[
                const SizedBox(height: 10),
                _DangerAction(label: 'Удалить устройство', onTap: _delete),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final checkDeviceCubit = context.read<CheckDeviceCubit>();
    final deviceCubit = context.read<DeviceCubit>();

    await checkDeviceCubit.saveSettingDevice(
      isSMSEnabled: isSMSEnabled,
      isNetworkEnabled: isNetworkEnabled,
      isChargingEnabled: isChargingEnabled,
      deviceId: widget.device?.deviceId,
    );
    if (!mounted) return;
    if (widget.device != null) {
      await deviceCubit.updateDevice();
      if (!mounted) return;
    }
    navigator.pop();
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final deviceCubit = context.read<DeviceCubit>();
    await deviceCubit.deleteDevice(widget.device!.deviceId);
    if (!mounted) return;
    navigator.pop();
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.accent,
      borderRadius: AppRadii.brR2,
      child: InkWell(
        borderRadius: AppRadii.brR2,
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(label, style: AppTextStyle.button(AppColor.white)),
          ),
        ),
      ),
    );
  }
}

class _DangerAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DangerAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.danger.withValues(alpha: 0.10),
      borderRadius: AppRadii.brR2,
      child: InkWell(
        borderRadius: AppRadii.brR2,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(label, style: AppTextStyle.button(AppColor.danger)),
          ),
        ),
      ),
    );
  }
}
