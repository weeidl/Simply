import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isLimited) {
      PermissionStatus newStatus = await permission.request();
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
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'To function correctly, the app requires access to $permissionName. Please grant access.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionSettingsDialog(
      BuildContext context, String permissionName) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Permanently Denied'),
        content: Text(
          'You have permanently denied access to $permissionName. Please grant access in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionRestrictedDialog(
      BuildContext context, String permissionName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Access to $permissionName is restricted and cannot be granted.',
        ),
      ),
    );
  }
}
