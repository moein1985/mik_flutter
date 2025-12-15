import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/queues/domain/repositories/queues_repository.dart';
import 'package:hsmik/features/queues/domain/usecases/get_queues_usecase.dart';
import 'package:hsmik/features/queues/domain/usecases/get_queue_by_id_usecase.dart';
import 'package:hsmik/features/queues/domain/usecases/add_queue_usecase.dart';
import 'package:hsmik/features/queues/domain/usecases/edit_queue_usecase.dart';
import 'package:hsmik/features/queues/domain/usecases/delete_queue_usecase.dart';
import 'package:hsmik/features/queues/domain/usecases/toggle_queue_usecase.dart';

class MockQueuesRepository extends Mock implements QueuesRepository {}

class MockGetQueuesUseCase extends Mock implements GetQueuesUseCase {}

class MockGetQueueByIdUseCase extends Mock implements GetQueueByIdUseCase {}

class MockAddQueueUseCase extends Mock implements AddQueueUseCase {}

class MockEditQueueUseCase extends Mock implements EditQueueUseCase {}

class MockDeleteQueueUseCase extends Mock implements DeleteQueueUseCase {}

class MockToggleQueueUseCase extends Mock implements ToggleQueueUseCase {}
