import 'package:bloc/bloc.dart';
import '../../core/result.dart';
import '../../domain/usecases/get_cdr_records_usecase.dart';
import '../../domain/usecases/export_cdr_to_csv_usecase.dart';
import 'cdr_event.dart';
import 'cdr_state.dart';

class CdrBloc extends Bloc<CdrEvent, CdrState> {
  final GetCdrRecordsUseCase getCdrRecordsUseCase;
  final ExportCdrToCsvUseCase exportCdrToCsvUseCase;

  CdrBloc({
    required this.getCdrRecordsUseCase,
    required this.exportCdrToCsvUseCase,
  }) : super(CdrInitial()) {
    on<LoadCdrRecords>((event, emit) async {
      emit(CdrLoading());
      
      final result = await getCdrRecordsUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
        src: event.src,
        dst: event.dst,
        disposition: event.disposition,
        limit: event.limit,
      );
      
      switch (result) {
        case Success(:final data):
          final records = data;
          emit(CdrLoaded(records));
        case Failure(:final message):
          emit(CdrError(message));
      }
    });

    on<FilterCdrRecords>((event, emit) async {
      emit(CdrLoading());
      final result = await getCdrRecordsUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
        src: event.src,
        dst: event.dst,
        disposition: event.disposition,
        limit: event.limit,
      );
      switch (result) {
        case Success(:final data):
          final records = data;
          emit(CdrLoaded(records));
        case Failure(:final message):
          emit(CdrError(message));
      }
    });

    on<ExportCdrRecords>((event, emit) async {
      emit(CdrExporting());
      final result = await exportCdrToCsvUseCase(event.records);
      switch (result) {
        case Success(:final data):
          final filePath = data;
          emit(CdrExported(filePath));
        case Failure(:final message):
          emit(CdrExportError(message));
      }
    });
  }
}
