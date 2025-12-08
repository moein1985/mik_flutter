import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wireless_interface.dart';
import '../../domain/entities/wireless_registration.dart';
import '../../domain/entities/security_profile.dart';
import '../../domain/repositories/wireless_repository.dart';
import '../datasources/wireless_remote_data_source.dart';

class WirelessRepositoryImpl implements WirelessRepository {
  final WirelessRemoteDataSource remoteDataSource;

  WirelessRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WirelessInterface>>> getWirelessInterfaces() async {
    try {
      final result = await remoteDataSource.getWirelessInterfaces();
      return Right(result);
    } on ServerException {
      return Left(const ServerFailure('Failed to load wireless interfaces'));
    }
  }

  @override
  Future<Either<Failure, void>> enableInterface(String interfaceName) async {
    try {
      await remoteDataSource.enableInterface(interfaceName);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to enable wireless interface'));
    }
  }

  @override
  Future<Either<Failure, void>> disableInterface(String interfaceName) async {
    try {
      await remoteDataSource.disableInterface(interfaceName);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to disable wireless interface'));
    }
  }

  @override
  Future<Either<Failure, List<WirelessRegistration>>> getWirelessRegistrations() async {
    try {
      final result = await remoteDataSource.getWirelessRegistrations();
      return Right(result);
    } on ServerException {
      return Left(const ServerFailure('Failed to load wireless registrations'));
    }
  }

  @override
  Future<Either<Failure, List<WirelessRegistration>>> getRegistrationsByInterface(String interfaceName) async {
    try {
      final result = await remoteDataSource.getRegistrationsByInterface(interfaceName);
      return Right(result);
    } on ServerException {
      return Left(const ServerFailure('Failed to load wireless registrations'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectClient(String interfaceName, String macAddress) async {
    try {
      await remoteDataSource.disconnectClient(macAddress, interfaceName);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to disconnect wireless client'));
    }
  }

  @override
  Future<Either<Failure, List<SecurityProfile>>> getSecurityProfiles() async {
    try {
      final result = await remoteDataSource.getSecurityProfiles();
      return Right(result);
    } on ServerException {
      return Left(const ServerFailure('Failed to load security profiles'));
    }
  }

  @override
  Future<Either<Failure, void>> createSecurityProfile(SecurityProfile profile) async {
    try {
      await remoteDataSource.createSecurityProfile(profile);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to create security profile'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSecurityProfile(SecurityProfile profile) async {
    try {
      await remoteDataSource.updateSecurityProfile(profile);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to update security profile'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSecurityProfile(String profileId) async {
    try {
      await remoteDataSource.deleteSecurityProfile(profileId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to delete security profile'));
    }
  }
}