# Simply — Улучшения архитектуры

Цель этого документа — **поэтапно перевести проект с MVP на production-grade
архитектуру**, не ломая поведение. Каждый этап самодостаточен и может быть
выпущен отдельным PR-ом.

Дизайн-принципы:
1. **Separation of concerns** — UI не знает про Firestore; cubit — только
   про state; repository — только про данные; model — только DTO.
2. **Dependency Injection** — репозитории инжектируются, не создаются внутри
   Cubit-ов через `new`.
3. **Reactive data flow** — Firestore streams (снапшоты) вместо ручного
   polling через in-process StreamController.
4. **Fail-safe** — все ошибки поднимаются в UI с понятным текстом.

Примечание: часть шагов из Этапов 0 и 1 уже выполнена локально. Чекбоксы ниже
обновлены под текущее состояние репозитория.

---

## Этап 0. Гигиена репозитория (быстро, безопасно)

- [x] `.flutter-plugins-dependencies` больше не трекается git, `.gitignore`
      уже содержит правило.
- [x] `.idea/` не трекается git.
- [x] Удалить закомментированный путь в `pubspec.yaml`.
- [x] Удалить файл `lib/screens/home/widget/app_bottom_bar.dart`
      (полностью закомментирован).
- [x] Переименовать `bacgraund_widget.dart` → `background_widget.dart`.
- [x] Удалить `lib/themes/themes.dart` (мёртвый) и `app_typography.dart`
      (не используется).
- [ ] Заменить `flutter_lints: ^2.0.0` на `^5.0.0`, пройти
      `flutter analyze`, исправить новые warning-и.
- [x] Удалить из `pubspec.yaml` основные неиспользуемые зависимости:
      `grpc`, `flutter_background_service`, `google_fonts`,
      `firebase_storage`, `workmanager`.
- [ ] Удалить `cupertino_icons`, если пакет действительно не нужен.
- [ ] Переоценить `auto_size_text`: сейчас пакет всё ещё используется на
      `AuthScreen`, так что его removal — отдельная задача, а не уже готовый
      cleanup.
- [ ] Добавить `.editorconfig` для единообразия.

**Результат**: минус ~15% размера APK/IPA, чище код.

---

## Этап 1. Починить критичные баги (см. `03_BUGS_AND_ISSUES.md`)

Минимум, что нужно сделать перед следующими этапами:

- [x] B-001 — `unread_messages_count` вынести из модели.
- [x] B-002 — не дублировать сообщения.
- [ ] B-005 — release-signing.
- [x] B-008 — logout navigation fix.
- [ ] B-009 — не звать `fetch()` в `build()`.
- [x] B-018 — не хардкодить имя пользователя.

---

## Этап 2. Слой абстракций: новый `lib/` layout

**Предлагаемая структура** (Feature-first, следует принципам Clean Architecture
в лёгкой форме):

```
lib/
├── app/
│   ├── app.dart                    — root MaterialApp + MultiRepositoryProvider
│   ├── router.dart                 — go_router-роутинг (см. Этап 4)
│   └── theme/
│        ├── app_colors.dart
│        ├── app_typography.dart
│        └── app_theme.dart         — ThemeData.light/.dark
│
├── core/
│   ├── constants.dart
│   ├── error/failures.dart         — sealed class Failure
│   ├── error/exceptions.dart
│   ├── extensions/datetime.dart    — formatDateTime (из текущего extensions.dart)
│   ├── services/
│   │   ├── permissions_service.dart
│   │   ├── crypto_service.dart     — E2E-шифрование (см. S-001)
│   │   ├── local_storage.dart      — Secure storage wrapper
│   │   └── logger.dart             — обёртка над logger пакетом
│   └── widgets/
│        ├── background_widget.dart
│        ├── app_bar_widget.dart
│        ├── rounded_button.dart
│        ├── divider_with_text.dart
│        ├── custom_progress_indicator.dart
│        ├── placeholders/no_messages.dart
│        └── dialogs/
│            ├── message_dialog.dart
│            ├── modal_dialog.dart
│            └── confirmation_dialog.dart
│
├── data/
│   ├── models/                     — JSON DTO
│   │   ├── device_dto.dart
│   │   ├── message_dto.dart
│   │   └── conversation_dto.dart   — бывший Messages (переименовать!)
│   ├── sources/
│   │   ├── firebase_auth_source.dart
│   │   ├── firestore_device_source.dart
│   │   └── firestore_message_source.dart
│   └── repositories/
│        ├── auth_repository.dart
│        ├── device_repository.dart
│        └── message_repository.dart
│
├── domain/
│   ├── entities/
│   │   ├── device.dart
│   │   ├── message.dart
│   │   └── conversation.dart
│   └── usecases/                    — по желанию для сложных потоков
│
├── features/
│   ├── splash/
│   │   ├── cubit/
│   │   └── splash_page.dart
│   ├── auth/
│   │   ├── cubit/
│   │   ├── widgets/
│   │   └── auth_page.dart
│   ├── home/
│   │   ├── cubit/
│   │   └── home_page.dart
│   ├── messages/
│   │   ├── list/
│   │   │   ├── cubit/
│   │   │   ├── widgets/
│   │   │   └── messages_list_page.dart
│   │   └── details/
│   │        ├── cubit/
│   │        ├── widgets/
│   │        └── message_details_page.dart
│   ├── devices/
│   │   ├── list/
│   │   ├── settings/
│   │   └── onboarding/
│   ├── settings/
│   ├── privacy_policy/
│   └── contact_us/
│
└── main.dart
```

**Зачем**:
- Поиск «где то-то лежит» становится тривиальным.
- Можно грузить feature через modular (если приложение вырастет).
- Тесты пишутся по слоям: `data/` → integration, `domain/` → unit,
  `features/.../cubit/` → bloc_test, `widgets/` → widget_test.

---

## Этап 3. DI через RepositoryProvider + get_it (опционально)

Сейчас `MessagesRepository()` создаётся напрямую в cubit-ах. Как следствие:
- Не замокать в тестах.
- Два экземпляра `FirebaseApi` — кэш `_cachedUser` разъезжается.

**Как сделать**:
```dart
// main.dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider(create: (_) => AuthRepository(...)),
    RepositoryProvider(create: (_) => DeviceRepository(...)),
    RepositoryProvider(create: (_) => MessageRepository(...)),
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider(create: (ctx) => SplashCubit(ctx.read<AuthRepository>())),
      BlocProvider(create: (ctx) => MessagesListCubit(ctx.read<MessageRepository>())..fetch()),
      ...
    ],
    child: const MyApp(),
  ),
)
```

---

## Этап 4. Роутинг через `go_router`

Сейчас: статические `Route route()` на каждом экране, ручной
`Navigator.pushReplacement`, `pushAndRemoveUntil`. При добавлении
deep-linking (например, `simply://chat/+79001234567`) будет больно.

**Переезд на `go_router`**:
- Единая конфигурация маршрутов.
- Redirect-guards для auth (`/splash` → `/auth` или `/home`).
- Deep-linking из push-уведомлений (при тапе сразу открыть нужный чат).

---

## Этап 5. Реактивная загрузка через Firestore Streams

Заменить текущий `fetchMessages()` + `StreamController.broadcast()` на:

```dart
// MessageRepository
Stream<List<Conversation>> watchConversations({int limit = 20}) {
  return _firestore
      .collection('user_messages').doc(uid)
      .collection('messages')
      .orderBy('last_message_date', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => Conversation.fromJson(d.data())).toList());
}

// MessagesListCubit
StreamSubscription? _sub;

void start() {
  _sub?.cancel();
  _sub = _repo.watchConversations().listen(
    (items) => emit(state.copyWith(items: items, status: loaded)),
    onError: (e) => emit(state.copyWith(status: error, error: e)),
  );
}

@override
Future<void> close() { _sub?.cancel(); return super.close(); }
```

**Преимущества**:
- Реальный live-update между устройствами.
- Офлайн-кеш через Firestore SDK (работает «из коробки»).
- Убирается `UpdateMessageStream` — один источник правды.

---

## Этап 6. Ошибки через `Either<Failure, T>` / `Result<T>`

Сейчас везде `try/catch (e) { return false; }` или `throw Exception`.
UI получает `false` и показывает general error. Пользователь не знает,
что пошло не так.

**Паттерн**:
```dart
sealed class Failure { const Failure(this.message); final String message; }
class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { final String code; ... }
class ValidationFailure extends Failure { ... }

Future<Result<User>> signIn(...) async {
  try {
    final u = await _auth.signInWithEmailAndPassword(...);
    return Result.success(u.user!);
  } on FirebaseAuthException catch (e) {
    return Result.failure(AuthFailure(e.message ?? '', code: e.code));
  } on FirebaseException catch (e) {
    return Result.failure(NetworkFailure(e.message ?? ''));
  }
}
```

В UI:
```dart
final result = await cubit.signIn();
result.when(
  success: (_) => Navigator.push...,
  failure: (f) => MessageDialog.show(text: _localize(f)),
);
```

---

## Этап 7. Интернационализация (i18n)

Подключить `flutter_localizations` + `intl`:

```
lib/l10n/
├── app_en.arb
├── app_ru.arb
└── app_localizations.dart  (генерируется flutter gen-l10n)
```

Все строки через `context.l10n.welcomeBack` вместо литералов.
Это откроет рынок RU / кириллических стран.

---

## Этап 8. Тестирование

Минимум:
```
test/
├── unit/
│   ├── extensions_test.dart
│   ├── crypto_service_test.dart
│   └── repositories/
│        ├── auth_repository_test.dart
│        └── message_repository_test.dart
├── cubit/
│   ├── auth_cubit_test.dart
│   ├── messages_list_cubit_test.dart
│   └── device_cubit_test.dart
├── widget/
│   ├── auth_page_test.dart
│   └── message_details_widget_test.dart
└── integration_test/
    └── e2e_auth_to_home.dart
```

Пакеты: `bloc_test`, `mocktail`, `fake_cloud_firestore`, `firebase_auth_mocks`.

---

## Этап 9. CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.24.3' }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
  build-android:
    ...
  build-ios:
    ...
```

Дополнительно:
- Codemagic / Fastlane для TestFlight / Play-Internal-testing.
- Sentry / Firebase Crashlytics для production crash reporting.

---

## Этап 10. Observability (Crashlytics + Analytics)

- `firebase_crashlytics` — автоматически ловит Flutter + native краши.
- Events — `logLogin`, `logSignUp`, `logMessageReceived`, `logDeviceAdded`.
- Perf — время от клика до открытия экрана.

---

## Этап 11. Feature flags

Для постепенного раскрытия фич (`google_sign_in`, E2EE) — Firebase Remote
Config:
```dart
final useE2E = FirebaseRemoteConfig.instance.getBool('use_e2e_encryption');
```

---

## Итоговая дорожная карта (по спринтам)

| Sprint | Задачи | Риск |
|--------|--------|------|
| 1 (1–2 недели) | Этап 0 + Этап 1 + начало Этапа 2 (рефакторинг путей) | низкий |
| 2 | Firestore Security Rules + release signing + Privacy Policy + онбординг | средний |
| 3 | Этап 5 (Streams) + устранение B-002, B-003 | средний |
| 4 | Этап 3 + Этап 6 (DI + Result) | средний |
| 5 | Этап 7 (i18n) + Этап 8 (тесты) | низкий |
| 6 | E2EE (S-001) + FlutterSecureStorage + Crashlytics | **высокий** (требует миграции данных) |
| 7 | Google/Apple login + edit-profile + settings polish | низкий |
| 8 | CI/CD, релиз в TestFlight / Internal track | низкий |

---

## Минимальный набор для «не стыдно показать» (hotfix-release 1.0.1)

1. Privacy Policy (текст + ссылка → сайт или локальная страница).
2. Fix `is_new_device` + стабильный `deviceId`.
3. Удалить оставшиеся лишние Android-permissions и привести foreground-service
   декларацию к реальному использованию.
4. Release-signing.
5. Задеплоить и проверить базовые Firestore Rules.
6. Закрыть оставшиеся security/policy хвосты для SMS-permissions в Google Play.

Эти 6 пунктов — ~1 день работы, но убирают «позорные» блокеры.
