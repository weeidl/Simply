export 'package:simply/bloc/notification/incoming_sms_contracts.dart';

import 'package:flutter/foundation.dart';
import 'package:simply/bloc/notification/incoming_sms_contracts.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/repositories/pending_incoming_sms_repository.dart';

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

  IncomingSmsSyncService({
    PendingIncomingSmsQueue? queue,
    IncomingSmsSink? sink,
  })  : _queue = queue ?? PendingIncomingSmsRepository(),
        _sink = sink ?? FirestoreIncomingSmsSink();

  Future<void> handleIncomingSms(IncomingSmsPayload payload) async {
    try {
      await _sink.save(payload);
    } catch (e, stack) {
      debugPrint(
        '[IncomingSmsSyncService] immediate sync failed; queued ${payload.dedupeKey}: $e\n$stack',
      );
      await _queue.enqueue(payload);
    }
  }

  Future<int> flushPending() async {
    final pending = await _queue.readAll();
    if (pending.isEmpty) return 0;

    final processed = <String>[];

    for (final payload in pending) {
      try {
        await _sink.save(payload);
        processed.add(payload.dedupeKey);
      } catch (e, stack) {
        debugPrint(
          '[IncomingSmsSyncService] pending sync failed for ${payload.dedupeKey}: $e\n$stack',
        );
      }
    }

    if (processed.isNotEmpty) {
      await _queue.removeMany(processed);
    }

    return processed.length;
  }
}
