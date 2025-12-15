import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/logs/domain/usecases/get_logs_usecase.dart';
import 'package:hsmik/features/logs/domain/usecases/follow_logs_usecase.dart';
import 'package:hsmik/features/logs/domain/usecases/clear_logs_usecase.dart';
import 'package:hsmik/features/logs/domain/usecases/search_logs_usecase.dart';

class MockGetLogsUseCase extends Mock implements GetLogsUseCase {}

class MockFollowLogsUseCase extends Mock implements FollowLogsUseCase {}

class MockClearLogsUseCase extends Mock implements ClearLogsUseCase {}

class MockSearchLogsUseCase extends Mock implements SearchLogsUseCase {}
