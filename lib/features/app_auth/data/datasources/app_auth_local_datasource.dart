import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';
import '../models/app_user_model.dart';
import '../../domain/entities/app_user.dart';

abstract class AppAuthLocalDataSource {
  Future<AppUser?> getLoggedInUser();
  Future<AppUser?> login(String username, String password);
  Future<AppUser> register(String username, String password);
  Future<void> logout();
  Future<void> setLoggedInUser(String userId);
  Future<void> updateBiometricStatus(String userId, bool enabled);
  Future<void> changePassword(String userId, String oldPassword, String newPassword);
  Future<AppUser?> getUserById(String userId);
  /// Returns the first user that has biometric enabled, or null
  Future<AppUser?> getUserByBiometric();
  Future<bool> hasBiometricEnabledUsers();
  Future<void> ensureDefaultAdminExists();
}

class AppAuthLocalDataSourceImpl implements AppAuthLocalDataSource {
  static const String _boxName = 'app_users';
  static const String _sessionKey = 'logged_in_user_id';
  static const String _defaultAdminId = 'admin_default';

  final SharedPreferences sharedPreferences;

  AppAuthLocalDataSourceImpl(this.sharedPreferences);

  final _log = AppLogger.tag('AppAuthLocalDataSource');

  Box<AppUserModel> get _userBox => Hive.box<AppUserModel>(_boxName);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Future<void> ensureDefaultAdminExists() async {
    if (_userBox.get(_defaultAdminId) == null) {
      final admin = AppUserModel(
        id: _defaultAdminId,
        username: 'admin',
        passwordHash: _hashPassword(''),
        biometricEnabled: false,
        createdAt: DateTime.now(),
        isDefault: true,
      );
      await _userBox.put(_defaultAdminId, admin);
    }
  }

  @override
  Future<AppUser?> getLoggedInUser() async {
    _log.i('getLoggedInUser: START');
    final userId = sharedPreferences.getString(_sessionKey);
    _log.i('getLoggedInUser: session userId = $userId');
    if (userId == null) {
      _log.i('No session user id found');
      return null;
    }
    AppUser? user;
    try {
      user = await getUserById(userId);
      _log.i('getLoggedInUser: found user = ${user != null}');
    } catch (e, st) {
      _log.e('getLoggedInUser error: $e\n$st');
      rethrow;
    }
    return user;
  }

  @override
  Future<AppUser?> getUserById(String userId) async {
    final userModel = _userBox.get(userId);
    return userModel?.toEntity();
  }

  @override
  Future<AppUser?> getUserByBiometric() async {
    for (var userModel in _userBox.values) {
      if (userModel.biometricEnabled) {
        return userModel.toEntity();
      }
    }
    return null;
  }

  @override
  Future<AppUser?> login(String username, String password) async {
    final passwordHash = _hashPassword(password);
    
    for (var userModel in _userBox.values) {
      if (userModel.username.toLowerCase() == username.toLowerCase() &&
          userModel.passwordHash == passwordHash) {
        await setLoggedInUser(userModel.id);
        return userModel.toEntity();
      }
    }
    
    return null;
  }

  @override
  Future<AppUser> register(String username, String password) async {
    // Check if username already exists
    for (var userModel in _userBox.values) {
      if (userModel.username.toLowerCase() == username.toLowerCase()) {
        throw Exception('Username already exists');
      }
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = AppUserModel(
      id: userId,
      username: username,
      passwordHash: _hashPassword(password),
      biometricEnabled: false,
      createdAt: DateTime.now(),
      isDefault: false,
    );

    await _userBox.put(userId, user);
    await setLoggedInUser(userId);
    return user.toEntity();
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(_sessionKey);
  }

  @override
  Future<void> setLoggedInUser(String userId) async {
    await sharedPreferences.setString(_sessionKey, userId);
  }

  @override
  Future<void> updateBiometricStatus(String userId, bool enabled) async {
    final userModel = _userBox.get(userId);
    if (userModel != null) {
      userModel.biometricEnabled = enabled;
      await userModel.save();
    }
  }

  @override
  Future<bool> hasBiometricEnabledUsers() async {
    _log.i('Checking Hive for biometric-enabled users');
    for (var user in _userBox.values) {
      if (user.biometricEnabled) {
        _log.i('Found biometric-enabled user: id=${user.id} username=${user.username}');
        return true;
      }
    }
    _log.i('No biometric-enabled users found');
    return false;
  }

  @override
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    final userModel = _userBox.get(userId);
    if (userModel == null) throw Exception('User not found');
    final oldHash = _hashPassword(oldPassword);
    if (userModel.passwordHash != oldHash) throw Exception('Old password is incorrect');

    userModel.passwordHash = _hashPassword(newPassword);
    await userModel.save();
  }
}
