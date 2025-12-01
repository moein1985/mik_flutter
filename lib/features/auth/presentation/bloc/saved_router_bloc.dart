import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/saved_router.dart';
import '../../domain/usecases/get_saved_routers_usecase.dart';
import '../../domain/usecases/save_router_usecase.dart';
import '../../domain/usecases/delete_router_usecase.dart';
import '../../domain/usecases/update_router_usecase.dart';
import '../../domain/usecases/set_default_router_usecase.dart';
import 'saved_router_event.dart';
import 'saved_router_state.dart';

class SavedRouterBloc extends Bloc<SavedRouterEvent, SavedRouterState> {
  final _log = AppLogger.tag('SavedRouterBloc');

  final GetSavedRoutersUseCase getSavedRoutersUseCase;
  final SaveRouterUseCase saveRouterUseCase;
  final DeleteRouterUseCase deleteRouterUseCase;
  final UpdateRouterUseCase updateRouterUseCase;
  final SetDefaultRouterUseCase setDefaultRouterUseCase;

  SavedRouterBloc({
    required this.getSavedRoutersUseCase,
    required this.saveRouterUseCase,
    required this.deleteRouterUseCase,
    required this.updateRouterUseCase,
    required this.setDefaultRouterUseCase,
  }) : super(const SavedRouterInitial()) {
    _log.i('SavedRouterBloc initialized');
    on<LoadSavedRouters>(_onLoadSavedRouters);
    on<SaveRouter>(_onSaveRouter);
    on<DeleteSavedRouter>(_onDeleteRouter);
    on<SetDefaultSavedRouter>(_onSetDefaultRouter);
    on<UpdateSavedRouter>(_onUpdateRouter);
  }

  Future<void> _onLoadSavedRouters(
    LoadSavedRouters event,
    Emitter<SavedRouterState> emit,
  ) async {
    _log.i('Loading saved routers...');
    emit(const SavedRouterLoading());

    final result = await getSavedRoutersUseCase();

    result.fold(
      (failure) {
        _log.e('Failed to load saved routers: ${failure.message}');
        emit(SavedRouterError(failure.message));
      },
      (routers) {
        _log.i('Loaded ${routers.length} saved routers');
        emit(SavedRouterLoaded(routers));
      },
    );
  }

  Future<void> _onSaveRouter(
    SaveRouter event,
    Emitter<SavedRouterState> emit,
  ) async {
    _log.i('Saving router: ${event.name}');

    final result = await saveRouterUseCase(
      name: event.name,
      host: event.host,
      port: event.port,
      username: event.username,
      password: event.password,
      isDefault: event.isDefault,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to save router: ${failure.message}');
        emit(SavedRouterError(failure.message));
      },
      (router) async {
        _log.i('Router saved successfully: ${router.name}');
        // Reload the list
        final loadResult = await getSavedRoutersUseCase();
        loadResult.fold(
          (failure) => emit(SavedRouterOperationSuccess('Router saved successfully')),
          (routers) => emit(SavedRouterOperationSuccess(
            'Router saved successfully',
            routers: routers,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteRouter(
    DeleteSavedRouter event,
    Emitter<SavedRouterState> emit,
  ) async {
    _log.i('Deleting router: ${event.id}');

    final result = await deleteRouterUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to delete router: ${failure.message}');
        emit(SavedRouterError(failure.message));
      },
      (success) async {
        _log.i('Router deleted successfully');
        // Reload the list
        final loadResult = await getSavedRoutersUseCase();
        loadResult.fold(
          (failure) => emit(SavedRouterOperationSuccess('Router deleted successfully')),
          (routers) => emit(SavedRouterOperationSuccess(
            'Router deleted successfully',
            routers: routers,
          )),
        );
      },
    );
  }

  Future<void> _onSetDefaultRouter(
    SetDefaultSavedRouter event,
    Emitter<SavedRouterState> emit,
  ) async {
    _log.i('Setting default router: ${event.id}');

    final result = await setDefaultRouterUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to set default router: ${failure.message}');
        emit(SavedRouterError(failure.message));
      },
      (_) async {
        _log.i('Default router set successfully');
        // Reload the list
        final loadResult = await getSavedRoutersUseCase();
        loadResult.fold(
          (failure) => emit(SavedRouterOperationSuccess('Default router set')),
          (routers) => emit(SavedRouterOperationSuccess(
            'Default router set',
            routers: routers,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateRouter(
    UpdateSavedRouter event,
    Emitter<SavedRouterState> emit,
  ) async {
    _log.i('Updating router: ${event.id}');

    // First get the existing router to preserve created_at
    final existingResult = await getSavedRoutersUseCase();
    
    SavedRouter? existingRouter;
    existingResult.fold(
      (failure) => null,
      (routers) {
        existingRouter = routers.where((r) => r.id == event.id).firstOrNull;
      },
    );

    if (existingRouter == null) {
      emit(const SavedRouterError('Router not found'));
      return;
    }

    final updatedRouter = existingRouter!.copyWith(
      name: event.name,
      host: event.host,
      port: event.port,
      username: event.username,
      password: event.password,
      isDefault: event.isDefault,
      updatedAt: DateTime.now(),
    );

    final result = await updateRouterUseCase(updatedRouter);

    await result.fold(
      (failure) async {
        _log.e('Failed to update router: ${failure.message}');
        emit(SavedRouterError(failure.message));
      },
      (router) async {
        _log.i('Router updated successfully');
        // Reload the list
        final loadResult = await getSavedRoutersUseCase();
        loadResult.fold(
          (failure) => emit(SavedRouterOperationSuccess('Router updated successfully')),
          (routers) => emit(SavedRouterOperationSuccess(
            'Router updated successfully',
            routers: routers,
          )),
        );
      },
    );
  }
}
