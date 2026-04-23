# Simply — Product Overview

## Назначение

**Simply** — это кроссплатформенное мобильное приложение (Flutter), предназначенное
для **пересылки входящих SMS-сообщений с одного устройства (Android) на другие
устройства пользователя** (Android / iOS) через облако Firebase.

Основной сценарий: у пользователя несколько устройств (например, рабочий Android
с SIM-картой и личный iPhone). Пользователь устанавливает Simply на оба,
авторизуется одним и тем же аккаунтом, назначает Android «главным устройством»
(Main Device). После этого все входящие SMS автоматически перехватываются на
Android, сохраняются в Firestore и доступны в реальном времени на iPhone и на
любых других устройствах в этом же аккаунте.

> Короткое описание в `pubspec.yaml`: `Sms Forward App`.

---

## Ключевые возможности (по факту реализации в коде)

| # | Возможность | Статус |
|---|-------------|--------|
| 1 | Регистрация / вход по e-mail + паролю (Firebase Auth) | ✅ Реализовано |
| 2 | Вход через Google / Apple | ⚠️ Кнопки есть, но `onPressed: () {}` — заглушка |
| 3 | Восстановление пароля («Forget password?») | ✅ `AuthCubit.sendPasswordReset()` отправляет ссылку на email |
| 4 | Перехват входящих SMS в фоне (Android only) через `another_telephony` | ✅ Реализовано |
| 5 | Сохранение SMS в Firestore, сгруппированное по отправителю | ✅ Реализовано |
| 6 | Live-обновление списка SMS и диалога между устройствами | ✅ Реализовано через Firestore `snapshots()` |
| 7 | Список устройств аккаунта, отображение заряда/сети для «главного» | ✅ Реализовано частично (данные обновляются только при сохранении настроек) |
| 8 | Авто-распознавание 6-значных OTP в SMS, подсветка и копирование в буфер | ✅ Реализовано через `lib/utils/code_extractor.dart` + code-block в `message_details_screen.dart` и `_CodeChip` в `messages_list_widget.dart` |
| 9 | Отметка «прочитано» при открытии чата | ✅ `markConversationRead` синхронизируется через Firestore и live-обновляется на других устройствах |
| 10 | Настройки устройства (SMS-sender, отображение заряда/сети) | ✅ Реализовано |
| 11 | Удаление устройства | ✅ Реализовано |
| 12 | Privacy Policy | ❌ Экран-заглушка «Coming Soon» (блокер публикации, см. `04_SECURITY_AUDIT.md` S-004) |
| 13 | Contact Us (e-mail, сайт, соц-сеть) | ✅ Реализовано |
| 14 | Edit Profile / Language / Push Notification | ⚠️ Пункты меню помечены `Soon`, некликабельны |
| 15 | Многоязычность (i18n) | ⚠️ Весь UI теперь на русском (захардкоженные строки), `intl` инициализирован для `ru_RU` в `main.dart`. Полноценный gen-l10n с EN/RU всё ещё не подключён |
| 16 | Foreground-service notification на Android | ✅ «Running in the background» |
| 17 | Валидация и понятные ошибки auth (mapping `FirebaseAuthException.code`) | ✅ Реализовано в `AuthCubit._mapAuthError()` |
| 18 | Запись профиля (name, email, createdAt) в `users/{uid}` при регистрации | ✅ Реализовано |

---

## Целевая аудитория

1. Пользователи с несколькими устройствами (iPhone + Android, рабочий + личный).
2. Люди, которые используют Android-номер исключительно как «приёмник OTP/2FA»
   и хотят видеть коды на основном iPhone.
3. Пользователи, которым нужно централизованное хранение SMS-истории в облаке.

---

## Технологический стек

- **Framework**: Flutter 3.24.3 / Dart 3.5.3
- **Android build toolchain**: Gradle 8.7 · AGP 8.6.0 · Kotlin 2.1.0 · Java 17
  (совместимо с JDK 21 из свежего Android Studio).
- **State management**: `flutter_bloc` (Cubit)
- **Backend-as-a-Service**: Firebase
  - Firebase Auth (email/password)
  - Cloud Firestore (хранение сообщений и устройств)
  - Firebase Messaging (инициализация есть, push пока не используется для
    доставки SMS — полагается на Firestore)
- **Нативные интеграции (Android)**:
  - `another_telephony` — перехват входящих SMS
  - `flutter_local_notifications` — постоянное уведомление foreground-сервиса
  - `battery_plus`, `device_info_plus`, `permission_handler`
- **Безопасность**: `cryptography` (AES-GCM E2EE для SMS),
  `flutter_secure_storage` (master key + stable deviceId).
- **UI/UX**:
  - **Шрифт**: Manrope (бандлится локально, веса 500/600/700/800).
  - Дизайн-токены: `themes/colors.dart` (warm coral),
    `themes/text_style.dart`, `themes/radii.dart`, `themes/shadows.dart`.
  - Примитивы: `screens/widget/warm/{warm_card,warm_chip,warm_header,warm_search_field,pill_tab_bar,icon_tile}.dart`.
  - Утилиты: `utils/code_extractor.dart` (heuristic для OTP).
  - Активно используются: `gap`, `flutter_spinkit` (только в `CubitListView`),
    `percent_indicator` (только в `CustomProgressIndicator`).
  - **В `pubspec.yaml`, но фактически больше не импортируются нигде в `lib/`**:
    `flutter_svg`, `auto_size_text`, `cupertino_icons` —
    кандидаты на удаление в следующем cleanup (см. `05_ARCHITECTURE_IMPROVEMENTS.md`
    Этап 0).

---

## Архитектура (верхнеуровнево)

```
lib/
├── main.dart                  — bootstrap: Firebase + initializeDateFormatting('ru_RU')
│                                + MultiBlocProvider + ThemeData (Manrope)
├── extensions.dart            — форматирование DateTime (formatRelativeShort,
│                                formatChatDivider, formatTime, …)
├── bloc/
│   └── notification/background_message.dart — обработчик SMS в isolate
├── models/                    — Device, Conversation, Message, PaginatedResponse (чистые DTO)
├── repositories/              — FirebaseApi, MessagesRepository, DeviceRepository
├── security/                  — CryptoService, SecurityRepository, SecureStorageService,
│                                EncryptionReadiness, KeyEnvelope, MessagesCodec
├── themes/                    — colors.dart, text_style.dart, radii.dart, shadows.dart
├── utils/
│   └── code_extractor.dart    — heuristic для распознавания OTP (cue-words + regex)
└── screens/
    ├── splash/                — лого + редирект Auth/Home
    ├── auth/                  — login / register / forgot-password
    ├── home/                  — HomePage + PillTabBar + FcmCubit
    ├── messages_list/         — список диалогов с поиском, фильтр-чипами,
    │                            категориями и code-chips
    ├── message_details/       — лента сообщений с date dividers и code blocks
    ├── devices/               — список устройств, карточки с stats grid,
    │                            settings modal
    ├── settings/              — profile card, premium banner, grouped sections
    ├── privacy_policy/        — заглушка-плашка «готовим документ»
    ├── contact_us/            — контактные карточки + блок «Команда»
    ├── common/                — StandardListCubit / State (CubitListView пока
    │                            оставлен, но фактически не используется ни одним
    │                            экраном после редизайна)
    └── widget/                — общие UI-компоненты (background_widget,
        ├── warm/              ↘ дизайн-примитивы (WarmHeader, WarmChip,
        ├── dialogs/             WarmSearchField, WarmCard, PillTabBar, IconTile)
        └── permissions/         + AppBarWidget, RoundedButton, SignInButton,
                                  CustomProgressIndicator, dialogs, permissions
```

### Схема данных в Firestore

```
devices/{userId}/items/{deviceId}
    user_id, device_name, device_id, is_main_device,
    battery_level, network_type, date_update_info, platform, token?

user_messages/{userId}/
    messages/{address}                       ← «превью» чата (заголовок, last_message)
         id, title, last_message, last_message_date, unread_messages_count, createdAt
    message/items/{address}/{autoId}         ← сами сообщения
         text, date
```

> **Починено**: инкремент unread-счётчика больше не живёт в модели.
> Он применяется явно в `MessagesRepository.saveIncomingMessage`, а сброс
> делается через `markConversationRead(conversationId)`. Список диалогов и
> экран переписки теперь получают live-обновления через Firestore snapshots.

---

## Отличия от «готового продукта»

Продукт находится в состоянии **MVP / alpha**. После итераций 1–5 основная
логика работает стабильно, базовая гигиена кода пройдена, UI приведён к
единому warm-coral дизайн-языку, но остаются:

- Firestore Security Rules — в репо добавлен owner-scoped `firestore.rules`,
  но его ещё нужно задеплоить (нужен `firebase CLI` и доступ к проекту).
- Ошибки пользователю теперь показываются понятным текстом (auth
  mapping сделан), но в Firestore-операциях остаётся общий `try/catch`
  без локализации.
- Основная чистка мёртвого кода уже сделана: из `pubspec.yaml` удалены
  `grpc`, `flutter_background_service`, `google_fonts`, `firebase_storage`,
  `workmanager`; также удалены файлы `app_typography.dart`, `themes.dart`,
  `app_bottom_bar.dart`. После редизайна стали dead-code и подлежат
  удалению из `pubspec.yaml`: `flutter_svg`, `auto_size_text`,
  `cupertino_icons` (нет ни одного `import` в `lib/`). `CubitListView` и
  `CustomProgressIndicator` тоже остались без юзеров.
- iOS фактически ничего не делает (не может перехватывать SMS), но UI одинаковый
  — план: отдельный iOS-онбординг «только приёмник».
- Нет тестов (папка `test/` отсутствует, есть только `security/`).
- Нет CI/CD.
- Release-сборка всё ещё подписана debug-ключами (B-005). Актуально только
  если проект пойдёт в стор; для личного использования не критично.

Полный перечень проблем и план доработок — см. `02_SCREENS_OVERVIEW.md`,
`03_BUGS_AND_ISSUES.md`, `04_SECURITY_AUDIT.md`, `05_ARCHITECTURE_IMPROVEMENTS.md`,
`06_FIX_PROGRESS.md` (что уже закрыто).
