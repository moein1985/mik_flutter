import 'package:bloc/bloc.dart';
import '../../core/result.dart';
import '../../domain/usecases/get_extensions_usecase.dart';
import 'extension_event.dart';
import 'extension_state.dart';

class ExtensionBloc extends Bloc<ExtensionEvent, ExtensionState> {
  final GetExtensionsUseCase getExtensionsUseCase;

  ExtensionBloc(this.getExtensionsUseCase) : super(const ExtensionInitial()) {
    on<LoadExtensions>((event, emit) async {
      emit(const ExtensionLoading());
      final result = await getExtensionsUseCase();
      switch (result) {
        case Success(:final data):
          // Sort: Online first, then by Name
          data.sort((a, b) {
            if (a.isOnline && !b.isOnline) return -1;
            if (!a.isOnline && b.isOnline) return 1;
            return a.name.compareTo(b.name);
          });
          emit(ExtensionLoaded(data));
        case Failure(:final message):
          emit(ExtensionError(message));
      }
    });
  }
}
