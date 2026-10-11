import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Hasil pengecekan kuota registrasi perangkat fisik
class DeviceQuotaResult {
  final bool allowed;
  final int registeredCount;
  final int maxAllowed;
  final String message;

  const DeviceQuotaResult({
    required this.allowed,
    required this.registeredCount,
    required this.maxAllowed,
    required this.message,
  });
}

/// Layanan keamanan perangkat untuk membatasi pendaftaran akun & analisa device login per NIS
class DeviceSecurityService {
  DeviceSecurityService._internal();
  static final DeviceSecurityService instance = DeviceSecurityService._internal();

  static const String _prefKeyDeviceId = 'snaps_device_fingerprint_id';
  static const int maxAccountsPerDevice = 3;

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  String? _cachedDeviceId;
  String? _cachedDeviceModel;

  /// Mengambil identitas unik perangkat yang persisten (Hardware + Local UUID)
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_prefKeyDeviceId);
    if (savedId != null && savedId.isNotEmpty) {
      _cachedDeviceId = savedId;
      return savedId;
    }

    String deviceIdentifier = 'unknown_device';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final brand = androidInfo.brand.trim().toLowerCase();
        final model = androidInfo.model.trim().toLowerCase();
        final hardware = androidInfo.hardware.trim().toLowerCase();
        final randomEntropy = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999).toString().padLeft(6, '0')}';

        // Gabungan identitas hardware dan entropy acak agar tidak bentrok antar siswa bertipe HP sama
        final rawId = '${brand}_${model}_${hardware}_$randomEntropy';
        deviceIdentifier = rawId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        final identifierForVendor = iosInfo.identifierForVendor ?? 'ios_${DateTime.now().millisecondsSinceEpoch}';
        deviceIdentifier = 'ios_${identifierForVendor.replaceAll('-', '_')}';
      } else {
        deviceIdentifier = 'platform_${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (_) {
      // Fallback identifier bila akses info perangkat terkendala
      deviceIdentifier = 'dev_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    }

    if (deviceIdentifier.isEmpty) {
      deviceIdentifier = 'dev_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    }

    await prefs.setString(_prefKeyDeviceId, deviceIdentifier);
    _cachedDeviceId = deviceIdentifier;
    return deviceIdentifier;
  }

  /// Mengambil nama model perangkat untuk audit admin (contoh: SAMSUNG SM-A525F)
  Future<String> getDeviceModel() async {
    if (_cachedDeviceModel != null) {
      return _cachedDeviceModel!;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final brand = androidInfo.brand.toUpperCase();
        final model = androidInfo.model.toUpperCase();
        _cachedDeviceModel = '$brand $model'.trim();
        return _cachedDeviceModel!;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        final machine = iosInfo.utsname.machine.toUpperCase();
        _cachedDeviceModel = 'APPLE $machine'.trim();
        return _cachedDeviceModel!;
      }
    } catch (_) {}

    _cachedDeviceModel = Platform.operatingSystem.toUpperCase();
    return _cachedDeviceModel!;
  }

  /// Memeriksa apakah perangkat ini masih memiliki kuota untuk mendaftar akun baru
  Future<DeviceQuotaResult> checkRegistrationQuota() async {
    try {
      final deviceId = await getDeviceId();
      final response = await SupabaseService.instance.client.rpc(
        'check_device_registration_quota',
        params: {
          'check_device_id': deviceId,
          'max_allowed': maxAccountsPerDevice,
        },
      );

      if (response is Map) {
        final allowed = response['allowed'] as bool? ?? true;
        final message = response['message'] as String? ?? '';
        final count = response['registered_count'] as int? ?? 0;
        final maxAllowed = response['max_allowed'] as int? ?? maxAccountsPerDevice;

        return DeviceQuotaResult(
          allowed: allowed,
          registeredCount: count,
          maxAllowed: maxAllowed,
          message: message,
        );
      }

      return const DeviceQuotaResult(
        allowed: true,
        registeredCount: 0,
        maxAllowed: maxAccountsPerDevice,
        message: 'Kuota pendaftaran tersedia',
      );
    } catch (_) {
      // Fail-open: Jangan memblokir pendaftaran siswa jika RPC/koneksi Supabase sementara belum sinkron
      return const DeviceQuotaResult(
        allowed: true,
        registeredCount: 0,
        maxAllowed: maxAccountsPerDevice,
        message: 'Pemeriksaan dilewati',
      );
    }
  }

  /// Mencatat pendaftaran akun baru pada perangkat fisik ini setelah akun berhasil dibuat
  Future<void> recordRegistration({
    required String userId,
    required String username,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final deviceModel = await getDeviceModel();

      await SupabaseService.instance.client.rpc(
        'record_device_registration',
        params: {
          'p_device_id': deviceId,
          'p_device_model': deviceModel,
        },
      );
    } catch (_) {
      // Non-blocking background log
    }
  }

  /// [SNAPS-63] Mencatat aktivitas autentikasi perangkat (login_success, login_failed, register)
  Future<void> recordAuthLog({
    required String nis,
    required String eventType, // 'login_success' | 'login_failed' | 'register'
    String? userId,
  }) async {
    try {
      final cleanNis = nis.trim();
      if (cleanNis.isEmpty) return;

      final deviceId = await getDeviceId();
      final deviceModel = await getDeviceModel();

      await SupabaseService.instance.client.rpc(
        'record_device_auth_event',
        params: {
          'p_nis': cleanNis,
          'p_device_id': deviceId,
          'p_device_model': deviceModel,
          'p_event_type': eventType,
          if (userId != null && userId.isNotEmpty) 'p_user_id': userId,
        },
      );
    } catch (_) {
      // Non-blocking background telemetry
    }
  }
}
