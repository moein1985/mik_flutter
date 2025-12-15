import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/auth/domain/usecases/login_usecase.dart';
import 'package:hsmik/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hsmik/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:hsmik/features/auth/domain/usecases/get_saved_credentials_usecase.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockSaveCredentialsUseCase extends Mock implements SaveCredentialsUseCase {}

class MockGetSavedCredentialsUseCase extends Mock implements GetSavedCredentialsUseCase {}
