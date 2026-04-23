import 'dart:convert';

import 'package:simply/bloc/notification/incoming_sms_contracts.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/security/secure_storage_service.dart';

class PendingIncomingSmsRepository implements PendingIncomingSmsQueue {
  static const _storageKey = 'sms.pending_incoming';

  final SecureStorageService _secureStorageService;

  PendingIncomingSmsRepository({
    SecureStorageService? secureStorageService,
  }) : _secureStorageService =
            secureStorageService ?? SecureStorageService();

  @override
  Future<void> enqueue(IncomingSmsPayload payload) async {
    final items = await readAll();
    items.removeWhere((item) => item.dedupeKey == payload.dedupeKey);
    items.add(payload);
    await _writeAll(items);
  }

  @override
  Future<List<IncomingSmsPayload>> readAll() async {
    final raw = await _secureStorageService.readValue(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map(
          (item) => IncomingSmsPayload.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  @override
  Future<void> removeMany(Iterable<String> dedupeKeys) async {
    final keys = dedupeKeys.toSet();
    final items = await readAll();
    items.removeWhere((item) => keys.contains(item.dedupeKey));
    await _writeAll(items);
  }

  Future<void> clear() {
    return _secureStorageService.deleteValue(_storageKey);
  }

  Future<void> _writeAll(List<IncomingSmsPayload> items) async {
    if (items.isEmpty) {
      await clear();
      return;
    }

    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await _secureStorageService.writeValue(_storageKey, encoded);
  }
}
