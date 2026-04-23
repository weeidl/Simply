export 'package:simply/bloc/notification/incoming_sms_contracts.dart';

import 'package:flutter/foundation.dart';
import 'package:simply/bloc/notification/incoming_sms_contracts.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/repositories/pending_incoming_sms_repository.dart';
import 'package:simply/services/device_runtime_service.dart';

class FirestoreIncomingSmsSink implements IncomingSmsSink {
  final MessagesRepository _messagesRepository;

  FirestoreIncomingSmsSink({
    MessagesRepository? messagesRepository,
  }) : _messagesRepository = messagesRepository ?? MessagesRepository();

  @override
  Future<void> save(IncomingSmsPayload payload) {
    return _messagesRepository.saveIncomingMessage(
      conversation: payload.toConversation(),
      message: payload.toMessage(),
    );
  }
}

class IncomingSmsSyncService {
  final PendingIncomingSmsQueue _queue;
  final IncomingSmsSink _sink;
  final DeviceRuntimeService _deviceRuntimeService;

  IncomingSmsSyncService({
    PendingIncomingSmsQueue? queue,
    IncomingSmsSink? sink,
    DeviceRuntimeService? deviceRuntimeService,
  })  : _queue = queue ?? PendingIncomingSmsRepository(),
        _sink = sink ?? FirestoreIncomingSmsSink(),
        _deviceRuntimeService = deviceRuntimeService ?? DeviceRuntimeService();

  Future<void> handleIncomingSms(IncomingSmsPayload payload) async {
    final enrichedPayload =
        await _deviceRuntimeService.enrichIncomingPayload(payload);
    try {
      await _sink.save(enrichedPayload);
    } catch (e, stack) {
      debugPrint(
        '[IncomingSmsSyncService] immediate sync failed; queued ${enrichedPayload.dedupeKey}: $e\n$stack',
      );
      await _queue.enqueue(enrichedPayload);
    }
  }

  Future<int> flushPending() async {
    final pending = await _queue.readAll();
    if (pending.isEmpty) return 0;

    final processed = <String>[];

    for (final payload in pending) {
      final enrichedPayload =
          await _deviceRuntimeService.enrichIncomingPayload(payload);
      try {
        await _sink.save(enrichedPayload);
        processed.add(enrichedPayload.dedupeKey);
      } catch (e, stack) {
        debugPrint(
          '[IncomingSmsSyncService] pending sync failed for ${enrichedPayload.dedupeKey}: $e\n$stack',
        );
      }
    }

    if (processed.isNotEmpty) {
      await _queue.removeMany(processed);
    }

    return processed.length;
  }
}
