import '../entities/agent_details.dart';
import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class GetAgentDetailsUseCase {
  final IMonitorRepository repository;

  GetAgentDetailsUseCase(this.repository);

  Future<Result<AgentDetails>> call(String agentInterface) async {
    // Get all queue statuses to find the agent
    final queuesResult = await repository.getQueueStatuses();
    switch (queuesResult) {
      case Failure(:final message):
        return Failure('Failed to fetch queue statuses: $message');
      case Success(:final data):
        final queues = data;

        final agentQueues = <String>[];
        int totalCallsTaken = 0;
        int lastCall = 0;
        String name = '';
        String interface = agentInterface;
        String state = 'Unknown';
        bool paused = false;
        String? pauseReason;

        for (final queue in queues) {
          for (final member in queue.members) {
            if (member.interface == agentInterface) {
              agentQueues.add(queue.queue);
              totalCallsTaken += member.callsTaken.toInt();
              if (member.lastCall > lastCall) {
                lastCall = member.lastCall;
              }
              name = member.name;
              state = member.state;
              paused = member.paused;
            }
          }
        }

        // For now, we'll use the total calls taken as today's count
        final callsAnsweredToday = totalCallsTaken;

        // Average talk time would come from CDR analysis
        final averageTalkTime = 0.0;

        return Success(AgentDetails(
          name: name.isEmpty ? agentInterface : name,
          interface: interface,
          state: state,
          paused: paused,
          pauseReason: pauseReason,
          callsTaken: totalCallsTaken,
          lastCall: lastCall,
          queues: agentQueues,
          callsAnsweredToday: callsAnsweredToday,
          averageTalkTime: averageTalkTime,
        ));
    }
  }
}
