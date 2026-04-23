import 'package:simply/models/incoming_sms_payload.dart';

abstract class IncomingSmsSink {
  Future<void> save(IncomingSmsPayload payload);
}

abstract class PendingIncomingSmsQueue {
  Future<void> enqueue(IncomingSmsPayload payload);
  Future<List<IncomingSmsPayload>> readAll();
  Future<void> removeMany(Iterable<String> dedupeKeys);
}
