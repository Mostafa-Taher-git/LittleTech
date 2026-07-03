import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:littletech/src/features/auth/data/models/user_model.dart';
import 'package:littletech/src/features/auth/data/services/auth_service.dart';

void main() {
  const usersKey = 'lt_users';
  const sessionKey = 'lt_session';

  Future<void> initPrefs(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    await SharedPreferences.getInstance();
    AuthService.init(await SharedPreferences.getInstance());
  }

  setUp(() async {
    await initPrefs({});
  });

  group('avatar migration', () {
    test('migrates old-set icon to corresponding current-set icon', () async {
      final oldUsers = [
        UserModel(id: 1, username: 'alice', password: 'pw', avatarIcon: '🔧', avatarSetVersion: 0),
        UserModel(id: 2, username: 'bob', password: 'pw', avatarIcon: '⌨️', avatarSetVersion: 0),
      ];
      await initPrefs({
        usersKey: jsonEncode(oldUsers.map((u) => u.toJson()).toList()),
      });

      final users = await AuthService.getAllUsers();

      expect(users.length, 2);
      // 🔧 (index 0 in v1) → 🔮 (index 0 in v2)
      expect(users[0].avatarIcon, '🔮');
      expect(users[0].avatarSetVersion, 2);
      // ⌨️ (index 7 in v1) → 🐋 (index 7 in v2)
      expect(users[1].avatarIcon, '🐋');
      expect(users[1].avatarSetVersion, 2);
    });

    test('current-set users are left unchanged (idempotent)', () async {
      final users = [
        UserModel(id: 1, username: 'alice', password: 'pw', avatarIcon: '🌌', avatarSetVersion: 2),
        UserModel(id: 2, username: 'bob', password: 'pw', avatarIcon: '🐋', avatarSetVersion: 2),
      ];
      await initPrefs({
        usersKey: jsonEncode(users.map((u) => u.toJson()).toList()),
      });

      final loaded = await AuthService.getAllUsers();

      expect(loaded.length, 2);
      expect(loaded[0].avatarIcon, '🌌');
      expect(loaded[0].avatarSetVersion, 2);
      expect(loaded[1].avatarIcon, '🐋');
      expect(loaded[1].avatarSetVersion, 2);
    });

    test('icon in neither set falls back to default', () async {
      final users = [
        UserModel(id: 1, username: 'alice', password: 'pw', avatarIcon: '🦄', avatarSetVersion: 0),
      ];
      await initPrefs({
        usersKey: jsonEncode(users.map((u) => u.toJson()).toList()),
      });

      final loaded = await AuthService.getAllUsers();

      expect(loaded.length, 1);
      // Not in any known set → first icon of current set
      expect(loaded[0].avatarIcon, AuthService.currentAvatars.first);
      expect(loaded[0].avatarSetVersion, 2);
    });

    test('updateAvatarIcon persists and is reflected by getCurrentUser', () async {
      final user = UserModel(id: 1, username: 'alice', password: 'pw', avatarIcon: '🔮', avatarSetVersion: 2);
      await initPrefs({
        usersKey: jsonEncode([user.toJson()]),
        sessionKey: 'alice',
        '${sessionKey}_id': 1,
      });

      final ok = await AuthService.updateAvatarIcon(1, '🌌');
      expect(ok, isTrue);

      final current = await AuthService.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.avatarIcon, '🌌');
    });
  });
}
