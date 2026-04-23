import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/widget/device_widget.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<DeviceCubit>();
      if (cubit.state.status == DeviceStatus.initial) {
        cubit.fetch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WarmHeader(
              eyebrow: _eyebrow(state),
              title: 'Устройства',
              trailing: _AddButton(
                onTap: () => DeviceSettingsModal.show(context: context),
              ),
            ),
            Expanded(child: _content(context, state)),
          ],
        );
      },
    );
  }

  String _eyebrow(DeviceState state) {
    if (state.items.isEmpty) return 'Подключите свой первый телефон';
    return '${state.items.length} устройств в синхронизации';
  }

  Widget _content(BuildContext context, DeviceState state) {
    switch (state.status) {
      case DeviceStatus.initial:
      case DeviceStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColor.accent),
        );
      case DeviceStatus.error:
        return _ErrorView(
          onRetry: () => context.read<DeviceCubit>().fetch(),
        );
      case DeviceStatus.empty:
        return const _EmptyView();
      case DeviceStatus.loaded:
        if (state.items.isEmpty) return const _EmptyView();
        return RefreshIndicator(
          color: AppColor.accent,
          onRefresh: () => context.read<DeviceCubit>().updateDevice(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                DeviceWidget(device: state.items[index]),
          ),
        );
    }
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.accent,
      borderRadius: AppRadii.brPill,
      child: InkWell(
        borderRadius: AppRadii.brPill,
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brPill,
            boxShadow: AppShadows.accent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: AppColor.white),
              const SizedBox(width: 4),
              Text('Добавить', style: AppTextStyle.button(AppColor.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColor.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smartphone_rounded,
                  color: AppColor.accentDeep, size: 38),
            ),
            const SizedBox(height: 16),
            Text('Пока нет устройств',
                style: AppTextStyle.title(AppColor.ink)),
            const SizedBox(height: 6),
            Text(
              'Войдите в Simply на другом телефоне, чтобы он появился в списке.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySm(AppColor.inkTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Не удалось загрузить', style: AppTextStyle.title(AppColor.ink)),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.accent),
            onPressed: onRetry,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
