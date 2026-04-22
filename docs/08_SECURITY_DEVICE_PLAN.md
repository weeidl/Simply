# Security And Device Hardening Plan

**Goal:** закрыть открытые Firestore rules, включить шифрование SMS с обратной совместимостью и добить стабильную идентичность устройства без регрессий в текущем UX.

**Scope:**
- Firestore rules: закрыть доступ до owner-scoped правил.
- Security core: password-wrapped master key, secure storage cache, AES-GCM для SMS.
- Messages: encrypted conversations/messages, live read/unread без plaintext в Firestore.
- Migration: старые plaintext документы читаются и лениво мигрируются в encrypted-схему.
- Device flow: stable `deviceId`, безопасный `check_device_cubit`, без гонок при первом запуске.

**Execution order:**
1. Написать unit-тесты для crypto service и message codec.
2. Реализовать secure storage + password-wrapped master key.
3. Перевести `MessagesRepository` на encrypted schema и lazy migration.
4. Закрыть `firestore.rules` под owner-only доступ.
5. Переписать `check_device_cubit` на стабильный `deviceId` и `await`-safe сохранение.
6. Перенести проверку нового устройства в `HomePage`, чтобы не терять modal на старте.
7. Прогнать `flutter test` и `dart analyze`, затем синхронизировать `docs`.

**Notes:**
- Для существующих пользователей шифрование включается на ближайшем логине: ключ создается из текущего пароля и сразу кэшируется локально.
- Если локальный кэш ключа потерян, а remote security уже включен, приложение форсирует повторный логин вместо показа битых encrypted данных.
- `conversationId` строится как детерминированный hash от отправителя и master key, чтобы номер не светился в путях Firestore.
