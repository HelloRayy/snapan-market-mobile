import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/device_security_service.dart';
import 'package:snapan_market/core/services/global_notification_service.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';

class AuthController {
  static Future<String?> submitLogin({
    required String username,
    required String password,
  }) async {
    try {
      final cleanInput = username.trim().toLowerCase().replaceAll('@', '');
      String email;
      String? resolvedUsername;
      final candidateEmails = <String>[];

      if (username.contains('@') && username.contains('.')) {
        // Input adalah format email langsung (misal: admin@snapan.id)
        email = username.trim().toLowerCase();
        candidateEmails.add(email);
      } else {
        // 1. Coba lookup via RPC 'lookup_login_email' terlebih dahulu jika ada
        bool rpcMatched = false;
        try {
          final rpcData = await SupabaseService.instance.client.rpc(
            'lookup_login_email',
            params: {'identifier': cleanInput},
          );
          if (rpcData is Map && rpcData['email'] != null) {
            email = (rpcData['email'] as String).toLowerCase();
            resolvedUsername = rpcData['username'] as String?;
            candidateEmails.add(email);
            rpcMatched = true;
          }
        } catch (_) {}

        if (!rpcMatched) {
          if (RegExp(r'^\d+$').hasMatch(cleanInput)) {
            // Input adalah NIS (deretan angka)
            // A. Coba cari profil terdaftar berdasarkan NIS di Supabase
            final profile = await SupabaseService.instance.getProfileByNis(cleanInput);
            if (profile != null && profile['username'] != null && (profile['username'] as String).isNotEmpty) {
              resolvedUsername = (profile['username'] as String).toLowerCase();
              email = '$resolvedUsername@snapan.id';
              candidateEmails.add(email);
            } else {
              // B. Coba cari di dataset registri siswa offline jika ada saran username
              final offline = StudentRegistryService.instance.findByNis(cleanInput);
              if (offline != null) {
                final suggested = StudentRegistryService.generateSuggestedUsername(offline.name);
                email = '$suggested@snapan.id';
                candidateEmails.add(email);
              } else {
                email = '$cleanInput@snapan.id';
                candidateEmails.add(email);
              }
            }
            if (!candidateEmails.contains('$cleanInput@snapan.id')) {
              candidateEmails.add('$cleanInput@snapan.id');
            }
          } else {
            // Input adalah username biasa
            email = '$cleanInput@snapan.id';
            candidateEmails.add(email);

            // Coba ambil NIS terkait jika ada profilnya untuk fallback
            try {
              final profile = await SupabaseService.instance.getProfileByUsername(cleanInput);
              if (profile != null && profile['nis'] != null) {
                final nisStr = (profile['nis'] as String).trim();
                if (nisStr.isNotEmpty && !candidateEmails.contains('$nisStr@snapan.id')) {
                  candidateEmails.add('$nisStr@snapan.id');
                }
              }
            } catch (_) {}
          }
        }
      }

      AuthResponse? response;
      dynamic lastAuthError;

      // Coba autentikasi menggunakan kandidat email yang tersedia secara berurutan
      for (final candidate in candidateEmails) {
        try {
          final authRes = await SupabaseService.instance.client.auth.signInWithPassword(
            email: candidate,
            password: password,
          );
          if (authRes.user != null) {
            response = authRes;
            break;
          }
        } catch (authErr) {
          lastAuthError = authErr;
        }
      }

      if (response == null || response.user == null) {
        if (lastAuthError != null) {
          throw lastAuthError;
        }
        return 'Username, NIS, atau kata sandi tidak cocok.';
      }

      if (response.user != null) {
        // Sinkronkan kredensial di background jika username pernah diganti (SNAPS-64)
        unawaited(SupabaseService.instance.syncProfileAuthCredentials());
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
    String? displayName,
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

      // Pastikan kelas otomatis tersinkronisasi dari NIS terdaftar jika belum spesifik
      String resolvedClassGroup = classGroup?.trim() ?? '';
      if ((resolvedClassGroup.isEmpty || resolvedClassGroup.toLowerCase() == 'siswa snapan') &&
          cleanNis != null &&
          cleanNis.isNotEmpty) {
        final matchedClass = StudentRegistryService.instance.findClassByNis(cleanNis);
        if (matchedClass != null && matchedClass.isNotEmpty) {
          resolvedClassGroup = matchedClass;
        }
      }

      final normalizedClass = AuthConstants.normalizeClassGroup(resolvedClassGroup);
      final finalClassGroup = normalizedClass.isNotEmpty
          ? normalizedClass
          : (grade != null && major != null && classNum != null
              ? '$grade $major $classNum'
              : 'Siswa Snapan');

      final cleanDisplayName = displayName?.trim();
      final hasDisplayName = cleanDisplayName != null && cleanDisplayName.isNotEmpty;

      final email = '$cleanUsername@snapan.id';

      final response = await SupabaseService.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (hasDisplayName) 'display_name': cleanDisplayName,
          'username': cleanUsername,
          'class_group': finalClassGroup,
          if (cleanNis != null && cleanNis.isNotEmpty) 'nis': cleanNis,
        },
      );

      if (response.user != null) {
        // Jika sesi belum aktif (misal auth setting tanpa auto-confirm), aktifkan sesi via signInWithPassword
        if (response.session == null) {
          try {
            await SupabaseService.instance.client.auth.signInWithPassword(
              email: email,
              password: password,
            );
          } catch (_) {
            // Non-critical fallback jika server require manual confirm
          }
        }

        await SupabaseService.instance.updateProfile(
          userId: response.user!.id,
          fullName: fullName,
          displayName: hasDisplayName ? cleanDisplayName : null,
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
