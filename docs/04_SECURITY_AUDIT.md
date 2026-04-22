# Simply — Security Audit

Категория: мобильное приложение, работающее с **SMS** (включая OTP-коды для
банковских логинов, 2FA, подтверждений переводов). Уровень чувствительности
данных — **HIGH**. SMS с кодом банка, пересланный через Firestore в открытом
виде — это риск **полного финансового compromise пользователя**.

Оценки: 🔴 критично (до публикации ОБЯЗАТЕЛЬНО) · 🟠 важно · 🟡 средне.

Актуализация: этот документ синхронизирован с текущим локальным состоянием
репозитория. Там, где базовый фикс уже сделан в коде, но остаётся deployment
или policy-часть, это помечено как частично закрытый риск.

---

## 🔴 S-001. SMS хранятся в Firestore в plaintext, без E2EE

**Где**: `lib/models/message.dart`, `messages_repository.dart`.

Текст сообщения (`MessageDetails.text`) записывается в Firestore как обычная
строка. Firebase-оператор, сотрудник Google, владелец украденных креденшелов
сервис-аккаунта, или злоумышленник с доступом к Firestore видит:
- OTP-коды от банков / бирж.
- Пароли от Apple ID / Google (если восстанавливаются по SMS).
- Коды подтверждения 2FA от Telegram / WhatsApp.

**Минимум**: клиентское шифрование симметричным ключом, производным от
пароля пользователя (`PBKDF2 / Argon2id` → AES-GCM-256). Ключ никогда не
отправляется на сервер.

**Идеал**: отдельный master-ключ, хранящийся в Keychain / Keystore,
привязанный к биометрии; секреты расшифровываются только на устройстве.

---

## 🔴 S-002. Baseline Firestore Security Rules уже добавлены в репозиторий, но их деплой не подтверждён

Файл `firestore.rules` в корне проекта уже существует. Это хорошо, потому что
базовые user-scoped правила теперь описаны рядом с кодом. Но если в реальном
Firebase-проекте всё ещё оставлены старые/дефолтные правила после `firebase init`:
```
allow read, write: if request.auth != null;
```
— **любой авторизованный пользователь может читать все чужие SMS**.

**Что сделать**:
1. В Firebase Console проверить текущие правила.
2. Задеплоить `firestore.rules` из репозитория.
3. Добавить проверяемый `firebase deploy --only firestore:rules` флоу в CI
   или в release checklist.

---

## 🔴 S-003. Release-сборка подписана debug-ключом

**Файл**: `android/app/build.gradle:60`
```
release { signingConfig signingConfigs.debug }
```

**Риск**:
- Нельзя опубликовать в Google Play (или придётся использовать debug-signature
  навсегда).
- Debug-ключ известен — **любой может подписать вредоносную модификацию
  с тем же fingerprint** и подменить обновление.

---

## 🔴 S-004. Privacy Policy отсутствует (экран-заглушка)

**Файл**: `lib/screens/privacy_policy/screen/privacy_policy_screen.dart`

Google Play **запрещает** публикацию приложения с разрешением `READ_SMS` /
`RECEIVE_SMS` без Privacy Policy. Apple App Store требует явно указать
usage description (см. S-008). **Без политики приложение не попадёт в
сторы.**

---

## 🔴 S-005. Permissions уже частично почищены, но SMS/foreground-service policy всё ещё риск

**Файл**: `AndroidManifest.xml`

Текущее состояние:
1. Дубликат `READ_PHONE_STATE` уже удалён.
2. Запрос `locationWhenInUse` из Dart-кода уже убран.
3. В manifest уже добавлены `POST_NOTIFICATIONS` и
   `FOREGROUND_SERVICE_DATA_SYNC`.
4. Но всё ещё остаются риски:
   - `READ_SMS` / `RECEIVE_SMS` требуют отдельной policy/declaration в Google Play.
   - `READ_PHONE_NUMBERS` выглядит подозрительно, если реально не используется.
   - `ForegroundService` всё ещё объявлен с типами `location|dataSync|mediaPlayback`,
     хотя соответствующего класса в Kotlin-коде нет.

---

## 🟠 S-006. Отсутствие явной декларации использования SMS (Google Play Policy)

Google Play SMS/Call Log Permissions Policy требует подать форму
(«Permissions Declaration Form») и явно обосновать использование `READ_SMS`.
Без неё приложение будет deprecated через 30 дней.

---

## 🟠 S-007. Нет механизма шифрования SharedPreferences

**Файл**: `check_device_cubit.dart`, `settings_screen.dart`

`is_new_device` — не чувствительный флаг. Но если в будущем будет хранится
токен/ключ — `SharedPreferences` (на Android) / `NSUserDefaults` (iOS)
**читаемы** при root / jailbreak. Использовать `flutter_secure_storage`.

---

## 🟠 S-008. Нет iOS `Info.plist`-объяснений для background modes

**Файл**: `ios/Runner/Info.plist`

- `UIBackgroundModes` включает `fetch` и `remote-notification` — допустимо.
- Нет `NSUserTrackingUsageDescription`, `NSLocalNetworkUsageDescription`,
  `NSContactsUsageDescription` — но если код использует analytics или
  что-то ещё, Apple reject-нет.
- На iPhone SMS **физически не перехватывается**, но UI показывает этот
  функционал. Для iOS-сборки нужна отдельная ветка онбординга
  «iPhone — только получатель».

---

## 🟠 S-009. Пользовательские auth-ошибки уже санитизированы, но сырые исключения ещё встречаются

**Файл**: `auth_cubit.dart`, `firebase_api.dart`, `fcm_cubit.dart`
```dart
emit(state.copyWith(authErrorMessage: 'Failed to sign in: ${e.toString()}'));
```
Старый user-facing кейс в `AuthCubit` уже исправлен: теперь UI получает
нормализованные сообщения по `FirebaseAuthException.code`. Но сырые `e`
по-прежнему попадают в некоторые `Exception(...)` в `FirebaseApi` и в
`debugPrint('Error handling new message: $e')` в `FcmCubit`.

**Как исправить**: для пользователя — только `e.code`; для crashlytics —
редактированный отчёт без email/password.

---

## 🟠 S-010. Нет rate-limiting на Firebase Auth

По умолчанию Firebase имеет базовый throttle, но:
- Email-enumeration атака возможна: по коду ошибки `user-not-found` vs
  `wrong-password` атакующий понимает, зарегистрирован ли email.
- Включить **Email Enumeration Protection** в Firebase Console
  (Authentication → Settings → User actions).

---

## 🟠 S-011. TLS pinning отсутствует

Firestore и FCM по умолчанию используют публичные CA. На root-устройстве
атакующий может установить свой CA и расшифровать HTTPS-трафик (но не
Firestore gRPC с ProtoBuf — но auth-токены в plaintext HTTP/2 read-able).
Добавить `http_certificate_pinning` или ограничиться принципом «trust
but verify».

---

## 🟠 S-012. `getTokensForCurrentUser` — потенциальный vector для утечки

**Файл**: `device_repository.dart:19-31`

Метод уже переименован и теперь честно отражает своё поведение: он возвращает
`token` устройств текущего пользователя. Если эти
токены попадают в логи / crashlytics / аналитику — FCM-токен может быть
использован для отправки произвольных push на устройство пользователя.

---

## 🟡 S-013. Нет защиты от screenshot / screen-recording

Для экрана `MessageDetailsScreen` (где видны OTP-коды) — желательно на
Android ставить `FLAG_SECURE`, чтобы скриншоты блокировались. Особенно
в overlay-атаках (overlay-trojan).

---

## 🟡 S-014. Нет проверки root / jailbreak

На rooted Android / jailbroken iOS приложение не должно работать (или
хотя бы предупреждать). Для SMS-приложения это критично — на root-устройстве
плейн-текст SMS может читать любое другое приложение.

---

## 🟡 S-015. Нет защиты от reverse-engineering

- ProGuard / R8 отключены (в `build.gradle` нет `minifyEnabled true`).
- Нет Obfuscation для Dart (`--obfuscate --split-debug-info=...`).
- Firebase project ID и API-ключи хранятся в `google-services.json` в
  открытом виде (это нормально, если правильно настроены Firestore Rules —
  см. S-002).

---

## 🟡 S-016. Логика «Main Device» небезопасна

**Файл**: `check_device_cubit.dart`

Пользователь может сделать произвольное устройство `isMainDevice = true`
без какой-либо проверки. В многопользовательском сценарии (если кто-то
узнал пароль) — злоумышленник ставит приложение на своё устройство,
назначает его главным, и все SMS пользователя начинают поступать на его
номер (если Android API позволит).

**Как исправить**: Cloud Function, проверяющая что новое main-device
подтверждено OTP на старом main-device.

---

## 🟡 S-017. Firebase App Check не подключён

Без `firebase_app_check`:
- Любой с API-ключом (легко достаётся из APK) может обращаться к Firestore
  напрямую (уже от имени «аутентифицированного пользователя», если украл
  token).
- Нет защиты от бота, который регистрирует 100500 fake-аккаунтов.

---

## 🟡 S-018. FCM background handler не проверяет аутентификацию

**Файл**: `lib/main.dart:17`
```dart
Future<void> _firebaseMessagingBackground(RemoteMessage message) async {}
```
Тело пустое. Если в будущем добавить — обязательно проверить
`FirebaseAuth.instance.currentUser` и не выполнять действия от имени
«прежнего» пользователя при передаче устройства.

---

## 🟡 S-019. SMS могут читаться out-of-order

**Файл**: `background_message.dart:8-14`

Несколько SMS подряд = несколько параллельных `sendMessageFirebase` вызовов,
запись в коллекцию через `messagesCollection.add(...)`. Firestore не
гарантирует порядок `ServerTimestamp` для параллельных запросов.

Для UX (сортировка по дате) это не критично, но для атак replay / race —
отсутствие транзакции означает, что два одновременных SMS могут дать
одинаковый `last_message_date`.

---

## 🟡 S-020. SignOut не отзывает Firebase token

`FirebaseAuth.signOut()` удаляет локальный токен, но сервер-сайд сессия
ID-токена действует ~1 час. Если token утёк до logout — действует ещё час.

**Митигация**: использовать `user.getIdToken(true)` для revoke или Cloud
Function, помечающий token как revoked.

---

## 🟡 S-021. Dependency CVE-скан не проводился

Зависимости не проверены на уязвимости. Актуальные точки внимания:
- `another_telephony: ^0.4.1` — мало звёзд, редко обновляется.
- `permission_handler`, `firebase_messaging`, `flutter_local_notifications`,
  `cloud_firestore`, `firebase_auth` — критичные для runtime разрешений,
  push и данных, требуют регулярного audit/upgrade.
- Ряд старых зависимостей уже удалён из `pubspec.yaml`, но в
  `ios/Podfile.lock` всё ещё могут оставаться stale references до следующего
  полного refresh CocoaPods.

Запустить `flutter pub outdated` и `flutter pub audit` (или сторонний).

---

## 🟡 S-022. `.flutter-plugins-dependencies` в репозитории — ✅ FIXED

Файл `.flutter-plugins-dependencies` и `.idea/` больше не трекаются git, а
закомментированный абсолютный путь `telephony` уже удалён из `pubspec.yaml`.
Локально этот файл Flutter всё ещё может существовать как игнорируемый
артефакт, но в репозиторий он больше не должен попадать.

---

## 🟡 S-023. Нет audit log

Ни одно действие (логин, добавление устройства, смена main-device) не
логируется. В случае компрометации невозможно отследить, кто и когда.

**Решение**: Cloud Function, записывающая события в `users/{uid}/audit/{id}`.

---

## 🟡 S-024. Password policy — Firebase default

**Минимум 6 символов**. Слишком слабо для приложения с SMS. Включить в
Firebase Console требования: ≥ 8 символов, mixed case, digit.

---

## Сводка (checklist перед публикацией)

- [ ] **S-001** — E2E-шифрование SMS.
- [ ] **S-002** — Firestore Security Rules.
- [ ] **S-003** — Release signing key.
- [ ] **S-004** — Privacy Policy (текст + экран).
- [ ] **S-005** — Чистка разрешений Android.
- [ ] **S-006** — Google Play Permissions Declaration.
- [ ] **S-007** — `flutter_secure_storage`.
- [ ] **S-008** — iOS onboarding, Info.plist keys.
- [ ] **S-009** — Санитизация логов.
- [ ] **S-010** — Email Enumeration Protection.
- [ ] **S-011** — Рассмотреть TLS pinning.
- [ ] **S-013** — `FLAG_SECURE` на MessageDetails.
- [ ] **S-014** — Root/Jailbreak detection.
- [ ] **S-015** — Obfuscation + R8.
- [ ] **S-017** — Firebase App Check.
- [ ] **S-021** — Dependency audit.

---

## Рекомендуемое поверх всего

1. **Пересмотреть бизнес-модель**. SMS-forwarder — регулируемая категория.
   В ЕС/США запрос `READ_SMS` у пользователя из не-default-sms-handler
   приложения практически запрещён. Рассмотреть альтернативу:
   сделать Simply default SMS-приложением (требует другой архитектуры,
   но снимает policy-блокеры) или отказаться от чтения SMS в пользу
   только "код скопирован пользователем".
2. **Bug bounty policy** — если приложение планируется массовым,
   принять формат security disclosure (SECURITY.md в репо).
3. **Pen-test** перед публичным релизом.
