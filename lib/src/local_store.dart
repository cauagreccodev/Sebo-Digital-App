import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class LocalStore {
  static const _authKey = 'seboDigitalAuth';
  static const _cartKey = 'seboDigitalCart';
  static const _themeKey = 'seboDigitalThemeMode';

  Future<AuthSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_authKey);
    if (!isFilled(value)) return null;

    try {
      final session = AuthSession.fromJson(asMap(jsonDecode(value!)));
      if (session.token.isEmpty || session.isExpired) {
        await clearSession();
        return null;
      }
      return session;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
  }

  Future<Map<int, int>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_cartKey);
    if (!isFilled(value)) return {};

    try {
      final decoded = jsonDecode(value!);
      if (decoded is! List) return {};
      final cart = <int, int>{};
      for (final item in decoded) {
        final map = asMap(item);
        final id = asInt(map['id']);
        final quantity = asInt(map['quantity']) ?? 1;
        if (id != null && quantity > 0) {
          cart[id] = quantity;
        }
      }
      return cart;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCart(Map<int, int> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = cart.entries
        .map((entry) => {'id': entry.key, 'quantity': entry.value})
        .toList(growable: false);
    await prefs.setString(_cartKey, jsonEncode(payload));
  }

  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }
}
