import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;

class DeviceService {
  static const String _deviceIdKey = 'device_id';
  final Uuid _uuid = const Uuid();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  // Get or create a stable device ID for this device
  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null || deviceId.isEmpty) {
        // Generate a new device ID
        deviceId = _uuid.v4();
        await prefs.setString(_deviceIdKey, deviceId);
      }

      return deviceId;
    } catch (e) {
      // Fallback to session-based ID if SharedPreferences fails
      return _generateSessionDeviceId();
    }
  }

  // Generate a session-based device ID as fallback
  String _generateSessionDeviceId() {
    // Use device information as fallback
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return _uuid.v5(Uuid.NAMESPACE_DNS, 'device_$random');
  }

  // Get device information for logging
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceId = await getDeviceId();
      final deviceInfo = await _deviceInfoPlugin.deviceInfo;

      if (Platform.isAndroid) {
        final androidInfo = deviceInfo as AndroidDeviceInfo;
        return {
          'device_id': deviceId,
          'device_model': androidInfo.model,
          'device_brand': androidInfo.brand,
          'device_manufacturer': androidInfo.manufacturer,
          'android_version': androidInfo.version.release,
          'sdk_version': androidInfo.version.sdkInt,
          'device_name': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
          'platform': 'Android',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = deviceInfo as IosDeviceInfo;
        return {
          'device_id': deviceId,
          'device_model': iosInfo.model,
          'device_name': iosInfo.name,
          'system_name': iosInfo.systemName,
          'system_version': iosInfo.systemVersion,
          'platform': 'iOS',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        // Fallback for other platforms
        return {
          'device_id': deviceId,
          'platform': Platform.operatingSystem,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {
        'device_id': await getDeviceId(),
        'error': 'Failed to get device info: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Clear device ID (for testing or logout)
  Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
    } catch (e) {
      // Ignore errors when clearing
    }
  }

  // Check if device is mobile
  bool isMobile() {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }
}
