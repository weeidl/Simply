import 'package:flutter_test/flutter_test.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';
import 'package:simply/security/crypto_service.dart';
import 'package:simply/security/messages_codec.dart';

void main() {
  group('MessagesCodec', () {
    final cryptoService = CryptoService();
    final codec = MessagesCodec(cryptoService: cryptoService);

    test('encodes and decodes a conversation', () async {
      final generated = await cryptoService.createMasterKeyEnvelope(
        password: 'correct horse battery staple',
      );
      final conversation = Conversation(
        id: 'raw-id',
        title: '+381601234567',
        lastMessage: 'Hello from encrypted world',
        lastMessageDate: DateTime.utc(2026, 4, 22, 10, 30),
        unreadMessagesCount: 2,
      );

      final encoded = await codec.encodeConversation(
        conversation: conversation,
        masterKey: generated.masterKey,
      );
      final decoded = await codec.decodeConversation(
        encoded,
        masterKey: generated.masterKey,
      );

      expect(decoded.id, isNot('raw-id'));
      expect(decoded.title, conversation.title);
      expect(decoded.lastMessage, conversation.lastMessage);
      expect(decoded.unreadMessagesCount, conversation.unreadMessagesCount);
      expect(encoded['title'], isNull);
      expect(encoded['last_message'], isNull);
      expect(encoded['encrypted_title'], isA<Map<String, dynamic>>());
      expect(encoded['encrypted_last_message'], isA<Map<String, dynamic>>());
    });

    test('decodes legacy plaintext conversation payloads', () async {
      final decoded = await codec.decodeConversation(
        {
          'id': '+381601234567',
          'title': '+381601234567',
          'last_message': 'Legacy body',
          'last_message_date': '2026-04-22T10:30:00.000Z',
          'unread_messages_count': 3,
        },
        masterKey: null,
      );

      expect(decoded.id, '+381601234567');
      expect(decoded.title, '+381601234567');
      expect(decoded.lastMessage, 'Legacy body');
      expect(decoded.unreadMessagesCount, 3);
    });

    test('encodes and decodes a message', () async {
      final generated = await cryptoService.createMasterKeyEnvelope(
        password: 'correct horse battery staple',
      );
      final message = Message(
        text: 'Top secret message',
        date: DateTime.utc(2026, 4, 22, 10, 31),
      );

      final encoded = await codec.encodeMessage(
        message: message,
        masterKey: generated.masterKey,
      );
      final decoded = await codec.decodeMessage(
        encoded,
        masterKey: generated.masterKey,
      );

      expect(decoded.text, message.text);
      expect(encoded['text'], isNull);
      expect(encoded['encrypted_text'], isA<Map<String, dynamic>>());
    });

    test('decodes legacy plaintext message payloads', () async {
      final decoded = await codec.decodeMessage(
        {
          'text': 'Legacy message',
          'date': '2026-04-22T10:31:00.000Z',
        },
        masterKey: null,
      );

      expect(decoded.text, 'Legacy message');
    });
  });
}
