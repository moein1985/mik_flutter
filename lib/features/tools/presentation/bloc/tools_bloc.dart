import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/usecases/get_interfaces_usecase.dart';
import '../../../dashboard/domain/usecases/get_ip_addresses_usecase.dart';
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
  final GetInterfacesUseCase getInterfacesUseCase;
  final GetIpAddressesUseCase getIpAddressesUseCase;

  bool _isPingCancelled = false;
  bool _isTracerouteCancelled = false;
  
  // Cache network info for ping options
  List<String> _cachedInterfaces = [];
  List<String> _cachedIpAddresses = [];

  ToolsBloc({
    required this.pingUseCase,
    required this.tracerouteUseCase,
    required this.dnsLookupUseCase,
    required this.getInterfacesUseCase,
    required this.getIpAddressesUseCase,
  }) : super(const ToolsInitial()) {
    on<StartPing>(_onStartPing);
    on<StopPing>(_onStopPing);
    on<StartTraceroute>(_onStartTraceroute);
    on<StopTraceroute>(_onStopTraceroute);
    on<StartDnsLookup>(_onStartDnsLookup);
    on<ClearResults>(_onClearResults);
    on<LoadNetworkInfo>(_onLoadNetworkInfo);
  }
  
  // Getters for cached network info
  List<String> get interfaces => _cachedInterfaces;
  List<String> get ipAddresses => _cachedIpAddresses;

  Future<void> _onLoadNetworkInfo(
    LoadNetworkInfo event,
    Emitter<ToolsState> emit,
  ) async {
    try {
      // Fetch interfaces
      final interfacesResult = await getInterfacesUseCase();
      interfacesResult.fold(
        (failure) => null,
        (interfaces) {
          _cachedInterfaces = interfaces.map((i) => i.name).toList();
        },
      );
      
      // Fetch IP addresses
      final ipResult = await getIpAddressesUseCase();
      ipResult.fold(
        (failure) => null,
        (ips) {
          _cachedIpAddresses = ips.map((ip) => ip.address.split('/').first).toList();
        },
      );
      
      emit(NetworkInfoLoaded(
        interfaces: _cachedInterfaces,
        ipAddresses: _cachedIpAddresses,
      ));
    } catch (e) {
      // Silent fail - just use empty lists
    }
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
          interval: event.interval,
          count: event.count,
          size: event.size,
          ttl: event.ttl,
          srcAddress: event.srcAddress,
          interfaceName: event.interfaceName,
          doNotFragment: event.doNotFragment,
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
    // Stop ping stream through use case (which manages the tag)
    pingUseCase.stop();
    
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
      // Map to track unique hops by hopNumber (handles updates to same hop)
      final hopMap = <int, TracerouteHop>{};
      
      // Stream hop updates as they arrive
      // Use takeWhile to allow cancellation
      await emit.forEach(
        tracerouteUseCase.callStream(
          target: event.target,
          maxHops: event.maxHops,
          timeout: event.timeout,
        ).takeWhile((_) => !_isTracerouteCancelled),
        onData: (hop) {
          // Update or add hop (handles RouterOS sending multiple updates per hop)
          hopMap[hop.hopNumber] = hop;
          
          // Get sorted list of hops
          final sortedHops = hopMap.values.toList()
            ..sort((a, b) => a.hopNumber.compareTo(b.hopNumber));
          
          // Emit updated list
          return TracerouteUpdating(sortedHops);
        },
        onError: (error, stackTrace) {
          return TracerouteFailed(error.toString());
        },
      );
      
      // Final state when all hops received
      if (!_isTracerouteCancelled && hopMap.isNotEmpty) {
        final sortedHops = hopMap.values.toList()
          ..sort((a, b) => a.hopNumber.compareTo(b.hopNumber));
        emit(TracerouteCompleted(sortedHops));
      }
    } catch (e) {
      if (!_isTracerouteCancelled) {
        emit(TracerouteFailed(e.toString()));
      }
    }
  }

  void _onStopTraceroute(StopTraceroute event, Emitter<ToolsState> emit) {
    _isTracerouteCancelled = true;
    // Stop traceroute stream through use case (which manages the tag)
    tracerouteUseCase.stop();
    
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
        recordType: event.recordType,
        dnsServer: event.dnsServer,
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
    // Stop active streams through use cases
    pingUseCase.stop();
    tracerouteUseCase.stop();
    return super.close();
  }
}