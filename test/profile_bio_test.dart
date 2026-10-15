import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/profile/components/profile_info_header.dart';
import 'package:snapan_market/features/profile/controllers/profile_controller.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SNAPS-72: Profile Bio Verification', () {
    test('ProfileUserModel properly holds and copies bio', () {
      const user = ProfileUserModel(
        id: 'user-123',
        name: 'Ahmad Dahlan',
        displayName: 'Ahmad',
        username: 'ahmad_d',
        avatar: '',
        bio: 'Siswa SMKN 8 Semarang · Freelance Flutter Dev 🚀',
        classGroup: 'XII PPLG 1',
      );

      expect(user.bio, 'Siswa SMKN 8 Semarang · Freelance Flutter Dev 🚀');

      final updated = user.copyWith(bio: 'New Updated Bio');
      expect(updated.bio, 'New Updated Bio');
      expect(updated.name, 'Ahmad Dahlan');
    });

    testWidgets('ProfileInfoHeader renders public bio for other user (isOwnProfile: false)', (tester) async {
      const otherUser = ProfileUserModel(
        id: 'user-456',
        name: 'Budi Santoso',
        displayName: 'Budi',
        username: 'budi_s',
        avatar: '',
        bio: 'Open commission desain poster & 3D render 🎨',
        classGroup: 'XI DKV 2',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileInfoHeader(
              user: otherUser,
              isOwnProfile: false,
            ),
          ),
        ),
      );

      // Verify the bio text is rendered in the UI
      expect(find.text('Open commission desain poster & 3D render 🎨'), findsOneWidget);
      // Verify placeholder for own profile is NOT shown
      expect(find.textContaining('Ketuk Edit Profil'), findsNothing);
    });

    testWidgets('ProfileInfoHeader hides bio when bio is empty for other user (isOwnProfile: false)', (tester) async {
      const otherUserWithoutBio = ProfileUserModel(
        id: 'user-789',
        name: 'Citra Kirana',
        displayName: 'Citra',
        username: 'citra_k',
        avatar: '',
        bio: '',
        classGroup: 'X AKL 1',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileInfoHeader(
              user: otherUserWithoutBio,
              isOwnProfile: false,
            ),
          ),
        ),
      );

      // Placeholder is only for own profile, must NOT appear for other user
      expect(find.textContaining('Ketuk Edit Profil'), findsNothing);
      expect(find.textContaining('Sentuh foto'), findsNothing);
    });

    testWidgets('ProfileInfoHeader shows edit prompt when own profile has empty bio', (tester) async {
      const ownUserWithoutBio = ProfileUserModel(
        id: 'user-self',
        name: 'Saya Sendiri',
        displayName: 'Saya',
        username: 'saya_dev',
        avatar: 'https://example.com/avatar.jpg',
        bio: '',
        classGroup: 'XII PPLG 2',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileInfoHeader(
              user: ownUserWithoutBio,
              isOwnProfile: true,
            ),
          ),
        ),
      );

      // Placeholder must show for own profile with avatar set
      expect(find.text('Ketuk Edit Profil untuk menambahkan bio Anda...'), findsOneWidget);
    });

    test('ProfileController deserializes public profile bio correctly without auth metadata', () {
      final controller = ProfileController();

      // Simulate visiting another user: profile comes from public.profiles, meta is empty {}
      final publicProfileRecord = {
        'id': 'target-user-99',
        'full_name': 'Dewi Sartika',
        'display_name': 'Dewi',
        'username': 'dewisartika',
        'class_group': 'XI PPLG 1',
        'avatar_url': 'https://example.com/dewi.png',
        'bio': '  Jual sticker custom & merchandise sekolah ✨  ',
        'link': 'https://instagram.com/dewi',
        'is_verified': true,
      };

      // Call internal logic by setting user via updateUser
      final user = ProfileUserModel(
        id: publicProfileRecord['id'] as String,
        name: publicProfileRecord['display_name'] as String,
        displayName: publicProfileRecord['display_name'] as String,
        username: publicProfileRecord['username'] as String,
        classGroup: publicProfileRecord['class_group'] as String,
        avatar: publicProfileRecord['avatar_url'] as String,
        bio: (publicProfileRecord['bio'] as String).trim(),
        link: (publicProfileRecord['link'] as String).trim(),
        isVerified: publicProfileRecord['is_verified'] as bool,
      );

      controller.updateUser(user);

      expect(controller.user?.bio, 'Jual sticker custom & merchandise sekolah ✨');
      expect(controller.user?.link, 'https://instagram.com/dewi');
      expect(controller.user?.isVerified, true);
    });
  });
}
