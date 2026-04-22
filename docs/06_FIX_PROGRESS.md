# Simply — Трекер исправлений

Живой документ. Обновляется по мере работы над проектом. Если видишь пункт
`[ ]` — значит, это ещё нужно сделать; `[x]` — закрыто в этой итерации.

Ссылки ID (`B-XXX`, `S-XXX`) — на документы `03_BUGS_AND_ISSUES.md` и
`04_SECURITY_AUDIT.md`.

---

## Итерация 1 (текущая)

Синхронизировано с текущим локальным состоянием репозитория: ниже отмечены не
только полностью закрытые пункты, но и те, что были закрыты лишь частично.

### Group A — Safe cleanups

- [x] **B-038** Переименован `bacgraund_widget.dart` → `background_widget.dart`,
      обновлены импорты.
- [x] **B-006** `.flutter-plugins-dependencies` и `.idea/` больше не
      трекаются git; правило в `.gitignore` уже есть.
- [x] **B-031** Удалён неиспользуемый `lib/themes/app_typography.dart`.
- [x] **B-031** Удалён мёртвый `lib/themes/themes.dart` (его `BuildContextExt.isDarkMode`
      не вызывался ни разу).
- [x] Удалён полностью закомментированный `lib/screens/home/widget/app_bottom_bar.dart`.
- [x] **B-032** Удалён комментарий с абсолютным путём `telephony: path: ...`
      из `pubspec.yaml`.
- Частично по **B-048**: удалены «мёртвые» комментарии из
      `device_info_widget.dart` и `main.dart`, но мелкие закомментированные
      фрагменты ещё остались в `auth_screen.dart`, `message_details_screen.dart`
      и `home.dart`.
- [x] **B-043** Русский лог в `device_repository.dart` переведён на английский.
- Частично по **B-049**: исправлено имя файла `background_widget.dart`, но
      нейминг `Messages` / `MessageDetails` и метод `DeviceCubit.updateDevice()`
      всё ещё стоит дочистить.
- [x] **B-050** `README.md` в корне заменён кратким описанием продукта +
      ссылками на `docs/`.

### Group B — Model & Repository

- [x] **B-001** `FieldValue.increment(1)` вынесен из `Messages.toJson()`.
      Модель стала чистым DTO. Инкремент делается в `MessagesRepository.sendMessageFirebase`.
- [x] **B-019** `DeviceRepository.fetch()` — убран ошибочный nullable `Future<List<Device>>?`.
- [x] **B-020** `getTokensForAllDevices(String userId)` переименован в
      `getTokensForCurrentUser()`, убран параметр `userId`, который не использовался.
- [x] **B-021** `FirebaseApi._cachedUser` удалён — тип-инвариант нарушался
      (каждый репозиторий создавал свою копию). Теперь всегда читаем
      `FirebaseAuth.instance.currentUser`.
- Частично по **B-033**: из `pubspec.yaml` уже удалены `grpc`,
      `flutter_background_service`, `google_fonts`, `firebase_storage`,
      `workmanager`; при этом `cupertino_icons` всё ещё остаётся кандидатом на
      удаление, а `auto_size_text` пока реально используется в `AuthScreen`.

### Group C — Navigation / Auth

- [x] **B-007** `SplashScreen` теперь делает `pushReplacement` на `AuthScreen`
      (не оставляет Splash в стеке).
- [x] **B-008** Logout в `SettingsScreen` навигирует на `AuthScreen.route()`
      через `pushAndRemoveUntil`, а НЕ на новый `MyApp` (убран вложенный `MaterialApp`).
- [x] **B-016** В `AuthCubit.signIn/signUp` добавлена минимальная валидация
      (email regex + password length ≥ 6). `FirebaseAuthException.code` мапится
      на понятные сообщения.
- [x] **B-017** При регистрации в коллекцию `users/{uid}` записываются
      `{name, email, createdAt}` — чтобы `SettingsScreen` мог показывать
      реального пользователя.
- [x] **B-018** Захардкоженное имя «Artur Rustamov» в `SettingsScreen` заменено
      на реальные данные из `FirebaseAuth.currentUser.displayName` (с fallback
      на email и на 'User').
- [x] **B-014** «Forget password?» обёрнут в `InkWell` с обработчиком,
      запускающим `FirebaseAuth.sendPasswordResetEmail`. Если email не введён —
      показывается подсказка.

### Group D — UI / widget fixes

- [x] **B-002** `MessagesListCubit.initStream` больше не дублирует сообщения —
      результат `fetchMessages` заменяет `items`, а не конкатенируется.
- [x] **B-010** `DeviceInfoWidget.imageDevice()` использует `device.platform`
      вместо сравнения с `'iPhone 15'`. Дублирующий метод из `device_widget.dart`
      удалён.
- [x] **B-011** `CustomProgressIndicator` для Mobile Data больше не показывает
      магические 80%. Заменён на компактный бейдж с типом сети.
- [x] **B-012** `DeviceStatus.empty` теперь показывает normal placeholder
      «No devices yet», а не спиннер.
- [x] **B-013** Кнопка «+» на `DevicesScreen` открывает `DeviceSettingsModal`
      (добавить текущее устройство).
- [x] **B-024** `ContactUsScreen._launchUrl` больше не бросает Exception —
      показывает SnackBar при ошибке.
- [x] **B-030** Убран внешний пустой `InkWell` в `RoundedButton`.
- [x] **B-036** `Icon(weight: 24)` заменён на `size: 20` (правильный параметр).
- [x] **B-037** `NoMessagesAvailable` — задан размер SVG (64×64).
- [x] **B-041** Пункты-заглушки (Edit Profile / Language / Push Notification)
      визуально помечены как «coming soon» и сделаны некликабельными.
- [x] Удалён ненужный запрос `Permission.locationWhenInUse` из `HomePage`
      (Google Play санкционирует за лишние permissions).

### Group E — Android manifest

- [x] **S-005** Удалён дубликат `<uses-permission READ_PHONE_STATE>`.
- [x] **S-005** Убран запрос на locationWhenInUse в Dart (в манифесте не было).
- [x] Добавлены `POST_NOTIFICATIONS` и `FOREGROUND_SERVICE_DATA_SYNC`
      (Android 13 / 14 требования).

### Group F — Android build toolchain (экстренный апгрейд для Java 21)

Проблема окружения: Flutter 3.24+ берёт JDK из Android Studio (Java 21),
а проект был на Gradle 7.5 / AGP 7.3.0 (поддерживают max Java 18).
`Unsupported class file major version 65`.

Исправлено проектно, системную Java не трогали:

- [x] `android/gradle/wrapper/gradle-wrapper.properties`:
      Gradle **7.5 → 8.7**.
- [x] `android/settings.gradle`: миграция на declarative plugin-style
      (Flutter 3.24+ требует именно такой формат), прописаны версии плагинов
      в `plugins { }`:
      AGP **7.3.0 → 8.6.0**, Kotlin **1.9.10 → 2.1.0**,
      google-services **4.3.15 → 4.4.2**.
- [x] `android/build.gradle`: удалён устаревший `buildscript { classpath … }`
      блок. Оставлен namespace-fallback `afterEvaluate` для плагинов, которые
      ещё не проставили свой `namespace` (AGP 8 требует его обязательно).
- [x] `android/gradle.properties`:
      `-Xmx1536M → -Xmx4096M` (Gradle 8 + Kotlin 2 прожорливее),
      добавлены `android.defaults.buildfeatures.buildconfig=true`,
      `android.nonTransitiveRClass=true`, `android.nonFinalResIds=false`.
- [x] `android/app/build.gradle`:
      Java **1.8 → 17** (source/target + kotlin jvmTarget),
      явный `buildFeatures { buildConfig true }`,
      **включён `coreLibraryDesugaringEnabled true`** (нужен для
      `flutter_local_notifications`) + dep
      `com.android.tools:desugar_jdk_libs:2.1.4`.
- [x] **B-025** `workmanager` удалён из Dart-кода и `pubspec.yaml`
      (задача была пустая + плагин использовал deprecated v1 embedding и не
      компилируется с AGP 8). Убраны импорты/инициализация из `main.dart` и
      `fcm_cubit.dart`; при следующем refresh зависимостей стоит проверить,
      что stale references ушли и из `ios/Podfile.lock`.

**Проверено**: `flutter build apk --debug` проходит, APK собирается (≈151 MB
debug — нормально, release будет меньше после R8 minify).

---

## Итерация 2 (2026-04-22)

Точечный hotfix критичного бага с SMS в фоне + косметика документации.

- [x] **B-051** Фоновые SMS не долетали до приложения: в фоновом изоляте
      `FirebaseAuth.instance.currentUser` был null, поэтому записи уходили в
      `user_messages/null/...` вместо `user_messages/<uid>/...`. Дополнительно
      отсутствовал `@pragma('vm:entry-point')` (риск для release-сборки из-за
      tree-shaking) и `await` на Firestore-вызовах (write мог не успеть до
      убийства изолята).
      **Файлы**: `lib/bloc/notification/background_message.dart` — полный
      рерайт с ожиданием `authStateChanges().firstWhere((u) => u != null)` с
      5-сек таймаутом и явной сборкой пути через `user.uid`.
      `lib/main.dart:14` — `@pragma('vm:entry-point')` добавлен к
      `_firebaseMessagingBackground` (заготовка на будущее, тело пока пустое).

- [x] Документация: удалены битые ссылки на несуществующие файлы
      `07_RELEASE_SIGNING.md` и `08_CLAUDE_DESIGN_PROMPT.md` из
      `docs/README.md`, `docs/01_PRODUCT_OVERVIEW.md`, `docs/06_FIX_PROGRESS.md`.
- [x] `docs/README.md` — сводка переписана под режим «personal use», добавлена
      дата последней синхронизации.
- [x] Обновлены S-018 и S-019 в `04_SECURITY_AUDIT.md` под текущее состояние
      кода (B-051).

---

## Что НЕ сделано в этой итерации (следующий заход)

Это осознанно отложено, потому что требует более масштабной работы, бэкенд-части
или внешних учётных данных.

### Будет в Итерации 2

- [ ] **B-003** Реактивные Firestore streams вместо in-process StreamController.
      Нужен переход `MessagesRepository.fetchMessages → watchConversations`,
      `MessageDetailsCubit → watchMessages`. Средняя сложность, ~1-2 дня.
- [ ] **B-004 / S-018** FCM pipeline: сохранение токена в `devices.token`,
      подписка на `onMessage`, `onMessageOpenedApp`, показ через
      `flutter_local_notifications`. Требует Cloud Function для sender-side
      (или Firebase Extension «Trigger FCM Notifications»).
- [ ] **B-009** Убрать `fetch()` из `build()` в `CubitListView`.
      `DevicesScreen` уже переведён на `initState`, но общий список всё ещё
      держит initial-fetch внутри `build()`.
- [ ] **B-022 / B-023** Стабильный `deviceId` через UUID в
      `flutter_secure_storage` (связано с S-007).
- [ ] **B-029** Пересмотреть `StandardListCubit` с учётом реактивности.
- [ ] **B-047 / B-048 / B-049** Дочистить оставшиеся русские комментарии,
      мелкие закомментированные фрагменты и неудачный нейминг.

### Требует внешних действий от автора

- [ ] **B-005 / S-003** Release signing — нужен keystore (ключ не в репо).
      Актуально только если проект пойдёт в стор.
- [ ] **S-002** Firestore Security Rules — нужны проект-ID и firebase CLI.
      Файл `firestore.rules` добавлен в репо как baseline.
- [ ] **S-004** Текст Privacy Policy — юридический документ, нужен от продакта.
- [ ] **S-001** E2E-шифрование SMS — требует миграции схемы, дизайна KDF,
      UX для повторного входа (что делать, если пароль забыт → данные теряются).
- [ ] **S-015** Obfuscation — `flutter build --obfuscate --split-debug-info`.
- [ ] **S-017** Firebase App Check.

---

## Как продолжать

1. Каждое закрытое в будущем issue помечай `[x]` + ссылку на PR/коммит.
2. Появилось новое issue в процессе — добавляй `B-XXX` или `S-XXX` в
   `03_BUGS_AND_ISSUES.md` / `04_SECURITY_AUDIT.md` (не размывай их в
   этот прогресс-файл).
3. Раз в итерацию — сверяйся с `05_ARCHITECTURE_IMPROVEMENTS.md` и
   двигайся по спринтам.
