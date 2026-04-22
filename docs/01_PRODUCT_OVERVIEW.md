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
| 6 | Live-обновление списка SMS через `StreamController` (in-process) | ⚠️ Работает только в пределах одного процесса; новые сообщения с других устройств НЕ подтягиваются live (план перехода на Firestore snapshots — Итерация 2) |
| 7 | Список устройств аккаунта, отображение заряда/сети для «главного» | ✅ Реализовано частично (данные обновляются только при сохранении настроек) |
| 8 | Авто-распознавание 6-значных кодов в SMS и копирование в буфер по тапу | ✅ Реализовано в `message_details_widget.dart` |
| 9 | Отметка «прочитано» при открытии чата | ✅ Инкремент вынесен в `MessagesRepository.sendMessageFirebase` (атомарно на стороне Firestore), `markConversationRead` сбрасывает счётчик |
| 10 | Настройки устройства (SMS-sender, отображение заряда/сети) | ✅ Реализовано |
| 11 | Удаление устройства | ✅ Реализовано |
| 12 | Privacy Policy | ❌ Экран-заглушка «Coming Soon» (блокер публикации, см. `04_SECURITY_AUDIT.md` S-004) |
| 13 | Contact Us (e-mail, сайт, соц-сеть) | ✅ Реализовано |
| 14 | Edit Profile / Language / Push Notification | ⚠️ Пункты меню помечены `Soon`, некликабельны |
| 15 | Многоязычность (i18n) | ❌ Весь UI захардкожен на английском |
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
- **UI/UX**: `flutter_svg`, `percent_indicator`, `flutter_spinkit`, `gap`,
  `auto_size_text`

---

## Архитектура (верхнеуровнево)

```
lib/
├── main.dart                  — bootstrap: Firebase + MultiBlocProvider
├── extensions.dart            — форматирование DateTime
├── bloc/
│   ├── update_message_stream.dart       — глобальный StreamController (анти-паттерн, план замены в Итерации 2)
│   └── notification/background_message.dart — обработчик SMS в isolate
├── models/                    — Device, Messages, MessageDetails, PaginatedResponse (чистые DTO)
├── repositories/              — FirebaseApi, MessagesRepository, DeviceRepository (все принимают deps через конструктор)
├── themes/                    — colors.dart + text_style.dart
└── screens/
    ├── splash/                — проверка авторизации
    ├── auth/                  — login / register / forgot-password
    ├── home/                  — HomePage + bottom-nav + FcmCubit
    ├── messages_list/         — список чатов-отправителей
    ├── message_details/       — список сообщений в чате
    ├── devices/               — список устройств + модалка настроек
    ├── settings/              — профиль / logout / меню
    ├── privacy_policy/        — заглушка
    ├── contact_us/            — контакты
    ├── common/                — StandardListCubit / State / CubitListView
    └── widget/                — общие UI-компоненты (background_widget.dart и др.), диалоги, permissions
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

> **Починено**: `FieldValue.increment(1)` вынесен из `Messages.toJson()`
> и применяется явно только в `MessagesRepository.sendMessageFirebase`
> (один раз на входящий SMS). Модель снова чистый DTO. Сбрасывается счётчик
> через `markConversationRead(title)`. См. закрытое B-001 в `03_BUGS_AND_ISSUES.md`.

---

## Отличия от «готового продукта»

Продукт находится в состоянии **MVP / alpha**. После Итерации 1 основная
логика работает стабильнее, базовая гигиена кода пройдена, но остаются:

- Firestore Security Rules — в репо добавлен baseline `firestore.rules`,
  но его ещё нужно задеплоить (нужен `firebase CLI` и доступ к проекту).
- Ошибки пользователю теперь показываются понятным текстом (auth
  mapping сделан), но в Firestore-операциях остаётся общий `try/catch`
  без локализации.
- Основная чистка мёртвого кода уже сделана: из `pubspec.yaml` удалены
  `grpc`, `flutter_background_service`, `google_fonts`, `firebase_storage`,
  `workmanager`; также удалены файлы `app_typography.dart`, `themes.dart`,
  `app_bottom_bar.dart`. При этом platform lockfiles (например,
  `ios/Podfile.lock`) ещё могут содержать stale references до следующего
  полного refresh зависимостей.
- iOS фактически ничего не делает (не может перехватывать SMS), но UI одинаковый
  — план: отдельный iOS-онбординг «только приёмник».
- Нет тестов (папка `test/` отсутствует) — запланировано в Итерации 2.
- Нет CI/CD.
- Release-сборка всё ещё подписана debug-ключами (B-005). Актуально только
  если проект пойдёт в стор; для личного использования не критично.

Полный перечень проблем и план доработок — см. `02_SCREENS_OVERVIEW.md`,
`03_BUGS_AND_ISSUES.md`, `04_SECURITY_AUDIT.md`, `05_ARCHITECTURE_IMPROVEMENTS.md`,
`06_FIX_PROGRESS.md` (что уже закрыто).
