import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/widget/warm/warm_toast.dart';

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();

  factory PermissionsService() {
    return _instance;
  }

  PermissionsService._internal();

  Future<bool> requestPermission({
    required Permission permission,
    required String permissionName,
    required BuildContext context,
  }) async {
    if (!Platform.isAndroid) return true;

    PermissionStatus status = await permission.status;
    if (!context.mounted) return false;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isLimited) {
      PermissionStatus newStatus = await permission.request();
      if (!context.mounted) return false;
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied) {
        await _showPermissionSettingsDialog(context, permissionName);
        return false;
      } else {
        await _showPermissionRationale(context, permissionName);
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      await _showPermissionSettingsDialog(context, permissionName);
      return false;
    } else if (status.isRestricted) {
      await _showPermissionRestrictedDialog(context, permissionName);
      return false;
    } else {
      return false;
    }
  }

  Future<void> _showPermissionRationale(
      BuildContext context, String permissionName) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequiredTitle),
        content: Text(
          l10n.permissionRequiredMessage(permissionName),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionSettingsDialog(
      BuildContext context, String permissionName) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionPermanentlyDeniedTitle),
        content: Text(
          l10n.permissionPermanentlyDeniedMessage(permissionName),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionRestrictedDialog(
      BuildContext context, String permissionName) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    WarmToast.error(
      context,
      l10n.permissionRestrictedMessage(permissionName),
    );
  }
}
