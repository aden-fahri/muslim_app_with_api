import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class QiblatService {
  Future<bool> get isSensorAvailable async {
    return await FlutterQiblah.androidDeviceSensorSupport() ?? false;
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  // Tipe eksplisit: Stream<QiblahDirection>
  Stream<QiblahDirection> get qiblahStream => FlutterQiblah.qiblahStream;
}
