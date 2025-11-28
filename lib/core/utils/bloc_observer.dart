import 'package:flutter_bloc/flutter_bloc.dart';
import 'logger.dart';

class AppBlocObserver extends BlocObserver {
  final _log = AppLogger.tag('BlocObserver');

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _log.d('onCreate: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _log.i('onEvent: ${bloc.runtimeType} -> ${event.runtimeType}');
    _log.d('  Event details: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _log.i('onChange: ${bloc.runtimeType}');
    _log.d('  From: ${change.currentState.runtimeType}');
    _log.d('  To: ${change.nextState.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _log.d('onTransition: ${bloc.runtimeType}');
    _log.d('  Event: ${transition.event.runtimeType}');
    _log.d('  CurrentState: ${transition.currentState.runtimeType}');
    _log.d('  NextState: ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _log.e(
      'onError: ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _log.d('onClose: ${bloc.runtimeType}');
  }
}
