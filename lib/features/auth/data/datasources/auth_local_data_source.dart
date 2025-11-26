import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/router_credentials_model.dart';
import '../models/router_session_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveCredentials(RouterCredentialsModel credentials);
  Future<RouterCredentialsModel?> getSavedCredentials();
  Future<void> clearCredentials();
  Future<void> saveSession(RouterSessionModel session);
  Future<RouterSessionModel?> getSavedSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveCredentials(RouterCredentialsModel credentials) async {
    try {
      final jsonString = json.encode(credentials.toJson());
      await secureStorage.write(key: 'credentials', value: jsonString);
    } catch (e) {
      throw CacheException('Failed to save credentials: $e');
    }
  }

  @override
  Future<RouterCredentialsModel?> getSavedCredentials() async {
    try {
      final jsonString = await secureStorage.read(key: 'credentials');
      if (jsonString == null) return null;
      
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return RouterCredentialsModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException('Failed to get saved credentials: $e');
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await secureStorage.delete(key: 'credentials');
    } catch (e) {
      throw CacheException('Failed to clear credentials: $e');
    }
  }

  @override
  Future<void> saveSession(RouterSessionModel session) async {
    try {
      final jsonString = json.encode(session.toJson());
      await secureStorage.write(key: 'session', value: jsonString);
    } catch (e) {
      throw CacheException('Failed to save session: $e');
    }
  }

  @override
  Future<RouterSessionModel?> getSavedSession() async {
    try {
      final jsonString = await secureStorage.read(key: 'session');
      if (jsonString == null) return null;
      
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return RouterSessionModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException('Failed to get saved session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await secureStorage.delete(key: 'session');
    } catch (e) {
      throw CacheException('Failed to clear session: $e');
    }
  }
}
