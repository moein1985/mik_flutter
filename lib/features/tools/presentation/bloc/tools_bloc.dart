import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/traceroute_hop.dart';
import '../../domain/usecases/dns_lookup_usecase.dart';
import '../../domain/usecases/ping_usecase.dart';
import '../../domain/usecases/traceroute_usecase.dart';
import 'tools_event.dart';
import 'tools_state.dart';

class ToolsBloc extends Bloc<ToolsEvent, ToolsState> {
  final PingUseCase pingUseCase;
  final TracerouteUseCase tracerouteUseCase;
  final DnsLookupUseCase dnsLookupUseCase;

  StreamSubscription? _pingSubscription;
  StreamSubscription? _tracerouteSubscription;

  ToolsBloc({
    required this.pingUseCase,
    required this.tracerouteUseCase,
    required this.dnsLookupUseCase,
  }) : super(const ToolsInitial()) {
    on<StartPing>(_onStartPing);
    on<StopPing>(_onStopPing);
    on<StartTraceroute>(_onStartTraceroute);
    on<StartDnsLookup>(_onStartDnsLookup);
    on<ClearResults>(_onClearResults);
  }

  Future<void> _onStartPing(StartPing event, Emitter<ToolsState> emit) async {
    emit(const PingInProgress());

    try {
      final result = await pingUseCase.call(
        target: event.target,
        count: event.count,
        timeout: event.timeout,
      );

      result.fold(
        (failure) => emit(PingFailed(failure.message)),
        (pingResult) => emit(PingCompleted(pingResult)),
      );
    } catch (e) {
      emit(PingFailed(e.toString()));
    }
  }

  void _onStopPing(StopPing event, Emitter<ToolsState> emit) {
    _pingSubscription?.cancel();
    emit(const ToolsInitial());
  }

  Future<void> _onStartTraceroute(
    StartTraceroute event,
    Emitter<ToolsState> emit,
  ) async {
    emit(const TracerouteInProgress());

    try {
      final hops = <TracerouteHop>[];
      
      // Stream hop updates as they arrive
      await emit.forEach(
        tracerouteUseCase.callStream(
          target: event.target,
          maxHops: event.maxHops,
          timeout: event.timeout,
        ),
        onData: (hop) {
          hops.add(hop);
          // Emit updated list with new hop
          return TracerouteUpdating(List.from(hops));
        },
        onError: (error, stackTrace) {
          return TracerouteFailed(error.toString());
        },
      );
      
      // Final state when all hops received
      if (hops.isNotEmpty) {
        emit(TracerouteCompleted(hops));
      }
    } catch (e) {
      emit(TracerouteFailed(e.toString()));
    }
  }

  Future<void> _onStartDnsLookup(
    StartDnsLookup event,
    Emitter<ToolsState> emit,
  ) async {
    emit(const DnsLookupInProgress());

    try {
      final result = await dnsLookupUseCase.call(
        domain: event.domain,
        timeout: event.timeout,
      );

      result.fold(
        (failure) => emit(DnsLookupFailed(failure.message)),
        (dnsResult) => emit(DnsLookupCompleted(dnsResult)),
      );
    } catch (e) {
      emit(DnsLookupFailed(e.toString()));
    }
  }

  void _onClearResults(ClearResults event, Emitter<ToolsState> emit) {
    emit(const ToolsInitial());
  }

  @override
  Future<void> close() {
    _pingSubscription?.cancel();
    _tracerouteSubscription?.cancel();
    return super.close();
  }
}