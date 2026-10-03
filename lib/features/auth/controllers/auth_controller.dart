import 'package:snapan_market/core/services/supabase_service.dart';

class AuthController {
  static Future<String?> submitLogin({
    required String username,
    required String password,
  }) async {
    try {
      final email = username.contains('@') ? username : '$username@snapan.id';
      final response = await SupabaseService.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

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
      return 'Username atau kata sandi tidak cocok';
    }
  }

  static Future<String?> submitRegister({
    required String fullName,
    required String rawUsername,
    required String grade,
    required String major,
    required String classNum,
    required String password,
  }) async {
    try {
      final isTaken = await SupabaseService.instance.isUsernameTaken(rawUsername);
      if (isTaken) {
        return 'Username @$rawUsername sudah terdaftar. Gunakan username lain.';
      }

      final email = '$rawUsername@snapan.id';
      final classGroup = '$grade $major $classNum';

      final response = await SupabaseService.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': rawUsername,
          'class_group': classGroup,
        },
      );

      if (response.user != null) {
        await SupabaseService.instance.updateProfile(
          userId: response.user!.id,
          fullName: fullName,
          username: rawUsername,
          classGroup: classGroup,
        );
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
