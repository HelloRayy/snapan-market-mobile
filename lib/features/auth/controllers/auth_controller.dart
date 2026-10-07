import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/device_security_service.dart';
import 'package:snapan_market/core/services/global_notification_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

class AuthController {
  static Future<String?> submitLogin({
    required String username,
    required String password,
  }) async {
    try {
      final cleanInput = username.trim().toLowerCase().replaceAll('@', '');
      String email;
      if (username.contains('@') && username.contains('.')) {
        email = username.trim().toLowerCase();
      } else if (RegExp(r'^\d+$').hasMatch(cleanInput)) {
        // Pengguna memasukkan NIS (deretan angka)
        // Coba cari profil terdaftar berdasarkan NIS
        final profile = await SupabaseService.instance.getProfileByNis(cleanInput);
        if (profile != null && profile['username'] != null) {
          final registeredUsername = (profile['username'] as String).toLowerCase();
          email = '$registeredUsername@snapan.id';
        } else {
          // Fallback ke format email NIS langsung
          email = '$cleanInput@snapan.id';
        }
      } else {
        email = '$cleanInput@snapan.id';
      }

      AuthResponse response;
      try {
        response = await SupabaseService.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (authErr) {
        // Jika login dengan email username gagal dan input adalah NIS, coba alternatif $cleanInput@snapan.id
        if (RegExp(r'^\d+$').hasMatch(cleanInput) && email != '$cleanInput@snapan.id') {
          response = await SupabaseService.instance.client.auth.signInWithPassword(
            email: '$cleanInput@snapan.id',
            password: password,
          );
        } else {
          rethrow;
        }
      }

      if (response.user != null) {
        // Cek apakah akun berstatus ditangguhkan (suspended) (SNAPS-16)
        final suspension = await SupabaseService.instance.auth.getCurrentUserSuspensionStatus();
        if (suspension != null) {
          await SupabaseService.instance.signOut();
          final reason = suspension['suspend_reason'] as String? ??
              'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.';
          final untilStr = suspension['suspended_until'] as String?;
          final until = untilStr != null ? DateTime.tryParse(untilStr) : null;
          final untilFormatted = until == null
              ? 'Permanen (Tanpa Batas Waktu)'
              : 'Berlaku hingga ${until.day}/${until.month}/${until.year} ${until.hour.toString().padLeft(2, '0')}:${until.minute.toString().padLeft(2, '0')} WIB';
          return 'ACCOUNT_SUSPENDED::$reason::$untilFormatted';
        }

        // Segera hubungkan FCM token & Realtime listener untuk user yang baru login
        unawaited(GlobalNotificationService.instance.syncFcmTokenNow().catchError((_) => ''));

        return null; // success
      }
      return 'Gagal masuk. Periksa kembali akun Anda.';
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('retryable') ||
          errStr.contains('xmlhttprequest') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('socketexception') ||
          errStr.contains('connection')) {
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      }
      return 'Username, NIS, atau kata sandi tidak cocok';
    }
  }

  static Future<String?> submitRegister({
    required String fullName,
    required String rawUsername,
    String? grade,
    String? major,
    String? classNum,
    String? classGroup,
    String? nis,
    required String password,
  }) async {
    try {
      // 1. Validasi kuota pendaftaran perangkat fisik (1 HP Max 3 Akun)
      final quota = await DeviceSecurityService.instance.checkRegistrationQuota();
      if (!quota.allowed) {
        return quota.message;
      }

      final cleanUsername = rawUsername.trim().toLowerCase().replaceAll('@', '');
      final isTaken = await SupabaseService.instance.isUsernameTaken(cleanUsername);
      if (isTaken) {
        return 'Username @$cleanUsername sudah terdaftar. Gunakan username lain.';
      }

      // Validasi NIS jika disertakan
      final cleanNis = nis?.trim();
      if (cleanNis != null && cleanNis.isNotEmpty) {
        final isClaimed = await SupabaseService.instance.isNisClaimed(cleanNis);
        if (isClaimed) {
          return 'NIS $cleanNis sudah terdaftar. Silakan beralih ke tab Masuk.';
        }
      }

      final finalClassGroup = classGroup ??
          (grade != null && major != null && classNum != null
              ? '$grade $major $classNum'
              : 'Siswa Snapan');

      final email = '$cleanUsername@snapan.id';

      final response = await SupabaseService.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': cleanUsername,
          'class_group': finalClassGroup,
          if (cleanNis != null && cleanNis.isNotEmpty) 'nis': cleanNis,
        },
      );

      if (response.user != null) {
        await SupabaseService.instance.updateProfile(
          userId: response.user!.id,
          fullName: fullName,
          username: cleanUsername,
          classGroup: finalClassGroup,
          nis: cleanNis,
        );

        // Catat klaim NIS ke student_registry jika tabel tersedia
        if (cleanNis != null && cleanNis.isNotEmpty) {
          try {
            await SupabaseService.instance.client
                .from('student_registry')
                .update({
                  'is_claimed': true,
                  'claimed_by': response.user!.id,
                  'claimed_at': DateTime.now().toUtc().toIso8601String(),
                })
                .eq('nis', cleanNis);
          } catch (_) {
            // Non-critical fallback jika tabel migration belum dieksekusi di Supabase
          }
        }

        // 2. Catat perangkat fisik ke sistem keamanan secara background
        unawaited(DeviceSecurityService.instance.recordRegistration(
          userId: response.user!.id,
          username: cleanUsername,
        ));

        return null; // success
      }
      return 'Pendaftaran gagal. Silakan coba lagi.';
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('already registered') || errStr.contains('user_already_exists')) {
        return 'Username sudah terdaftar. Silakan beralih ke tab Masuk.';
      } else if (errStr.contains('retryable') ||
          errStr.contains('xmlhttprequest') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('socketexception') ||
          errStr.contains('connection')) {
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      } else if (errStr.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
      }
      return 'Pendaftaran gagal: ${e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', '')}';
    }
  }
}
