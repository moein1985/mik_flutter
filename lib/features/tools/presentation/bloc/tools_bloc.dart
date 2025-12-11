import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/routeros_client.dart';
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
  final RouterOSClient routerOsClient;

  bool _isPingCancelled = false;
  bool _isTracerouteCancelled = false;

  ToolsBloc({
    required this.pingUseCase,
    required this.tracerouteUseCase,
    required this.dnsLookupUseCase,
    required this.routerOsClient,
  }) : super(const ToolsInitial()) {
    on<StartPing>(_onStartPing);
    on<StopPing>(_onStopPing);
    on<StartTraceroute>(_onStartTraceroute);
    on<StopTraceroute>(_onStopTraceroute);
    on<StartDnsLookup>(_onStartDnsLookup);
    on<ClearResults>(_onClearResults);
  }

  Future<void> _onStartPing(StartPing event, Emitter<ToolsState> emit) async {
    _isPingCancelled = false;
    emit(const PingInProgress());

    try {
      // Stream ping updates as they arrive
      // Use takeWhile to allow cancellation
      await emit.forEach(
        pingUseCase.callStream(
          target: event.target,
          timeout: event.timeout,
        ).takeWhile((_) => !_isPingCancelled),
        onData: (result) {
          // Emit updated result with new packet
          return PingUpdating(result);
        },
        onError: (error, stackTrace) {
          return PingFailed(error.toString());
        },
      );
      
      // If stream completes (either naturally or cancelled)
      // Only emit completed if we have results and weren't cancelled
      if (!_isPingCancelled && state is PingUpdating) {
        emit(PingCompleted((state as PingUpdating).result));
      }
    } catch (e) {
      if (!_isPingCancelled) {
        emit(PingFailed(e.toString()));
      }
    }
  }

  void _onStopPing(StopPing event, Emitter<ToolsState> emit) {
    _isPingCancelled = true;
    // Stop the streaming on RouterOS side
    routerOsClient.stopStreaming();
    
    // Keep the last ping result when stopping
    if (state is PingUpdating) {
      emit(PingCompleted((state as PingUpdating).result));
    } else {
      emit(const ToolsInitial());
    }
  }

  Future<void> _onStartTraceroute(
    StartTraceroute event,
    Emitter<ToolsState> emit,
  ) async {
    _isTracerouteCancelled = false;
    emit(const TracerouteInProgress());

    try {
      final hops = <TracerouteHop>[];
      
      // Stream hop updates as they arrive
      // Use takeWhile to allow cancellation
      await emit.forEach(
        tracerouteUseCase.callStream(
          target: event.target,
          maxHops: event.maxHops,
          timeout: event.timeout,
        ).takeWhile((_) => !_isTracerouteCancelled),
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
      if (!_isTracerouteCancelled && hops.isNotEmpty) {
        emit(TracerouteCompleted(hops));
      }
    } catch (e) {
      if (!_isTracerouteCancelled) {
        emit(TracerouteFailed(e.toString()));
      }
    }
  }

  void _onStopTraceroute(StopTraceroute event, Emitter<ToolsState> emit) {
    _isTracerouteCancelled = true;
    // Stop the streaming on RouterOS side
    routerOsClient.stopStreaming();
    
    // Keep the last traceroute result when stopping
    if (state is TracerouteUpdating) {
      emit(TracerouteCompleted((state as TracerouteUpdating).hops));
    } else {
      emit(const ToolsInitial());
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
    _isPingCancelled = true;
    _isTracerouteCancelled = true;
    routerOsClient.stopStreaming();
    return super.close();
  }
}