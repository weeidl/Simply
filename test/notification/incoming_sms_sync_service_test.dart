import 'package:flutter_test/flutter_test.dart';
import 'package:simply/bloc/notification/incoming_sms_sync_service.dart';
import 'package:simply/models/incoming_sms_payload.dart';

class _FakeQueue implements PendingIncomingSmsQueue {
  final List<IncomingSmsPayload> items = [];

  @override
  Future<void> enqueue(IncomingSmsPayload payload) async {
    items.removeWhere((item) => item.dedupeKey == payload.dedupeKey);
    items.add(payload);
  }

  @override
  Future<List<IncomingSmsPayload>> readAll() async {
    return List<IncomingSmsPayload>.from(items);
  }

  @override
  Future<void> removeMany(Iterable<String> dedupeKeys) async {
    final keys = dedupeKeys.toSet();
    items.removeWhere((item) => keys.contains(item.dedupeKey));
  }
}

class _FakeSink implements IncomingSmsSink {
  final List<IncomingSmsPayload> saved = [];
  final Set<String> failingKeys = {};

  @override
  Future<void> save(IncomingSmsPayload payload) async {
    if (failingKeys.contains(payload.dedupeKey)) {
      throw StateError('write failed');
    }
    saved.add(payload);
  }
}

void main() {
  group('IncomingSmsSyncService', () {
    late _FakeQueue queue;
    late _FakeSink sink;
    late IncomingSmsSyncService service;

    setUp(() {
      queue = _FakeQueue();
      sink = _FakeSink();
      service = IncomingSmsSyncService(
        queue: queue,
        sink: sink,
      );
    });

    IncomingSmsPayload payload({
      required String address,
      required String body,
      required int minute,
    }) {
      return IncomingSmsPayload(
        address: address,
        body: body,
        receivedAt: DateTime.utc(2026, 4, 23, 10, minute),
      );
    }

    test('queues SMS when remote sync fails', () async {
      final sms = payload(
        address: '+381601234567',
        body: 'OTP 1234',
        minute: 30,
      );
      sink.failingKeys.add(sms.dedupeKey);

      await service.handleIncomingSms(sms);

      expect(sink.saved, isEmpty);
      expect(queue.items.map((item) => item.dedupeKey), [sms.dedupeKey]);
    });

    test('does not queue SMS when remote sync succeeds', () async {
      final sms = payload(
        address: '+381601234567',
        body: 'OTP 5678',
        minute: 31,
      );

      await service.handleIncomingSms(sms);

      expect(sink.saved.map((item) => item.dedupeKey), [sms.dedupeKey]);
      expect(queue.items, isEmpty);
    });

    test('flushes successful pending SMS and keeps failed ones queued', () async {
      final first = payload(
        address: '+381601234567',
        body: 'First',
        minute: 32,
      );
      final second = payload(
        address: '+381601111111',
        body: 'Second',
        minute: 33,
      );

      await queue.enqueue(first);
      await queue.enqueue(second);
      sink.failingKeys.add(second.dedupeKey);

      final flushedCount = await service.flushPending();

      expect(flushedCount, 1);
      expect(sink.saved.map((item) => item.dedupeKey), [first.dedupeKey]);
      expect(queue.items.map((item) => item.dedupeKey), [second.dedupeKey]);
    });
  });
}
