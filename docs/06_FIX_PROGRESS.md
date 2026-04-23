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

- [x] **B-001** `FieldValue.increment(1)` вынесен из DTO.
      Инкремент теперь делается явно в message-repository слое, а не в модели.
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

## Итерация 3 (2026-04-22)

Фокус: синхронизация сообщений между устройствами и очистка app lifecycle.

- [x] **B-003** `UpdateMessageStream` удалён. Список диалогов и экран диалога
      переведены на Firestore `snapshots()`, так что новые сообщения и
      изменения `unread_messages_count` теперь приезжают между устройствами
      без ручного pull-to-refresh.

- [x] Live `read / unread` синхронизация: `MessagesListWidget` больше не держит
      локальный `setState`-счётчик unread как отдельный источник истины.
      Сброс unread идёт через Firestore, а UI перечитывает его из live stream.

- [x] Нейминг модели сообщений выровнен:
      `Messages` → `Conversation`,
      `MessageDetails` → `Message`.
      Это сделано сейчас, пока база маленькая и rename ещё дешёвый.

- [x] Запись входящего SMS переведена на транзакционный сценарий в
      `MessagesRepository.saveIncomingMessage`: preview диалога и само сообщение
      пишутся вместе.
      Частично закрывает **S-019**. Полный переход дат на server timestamps
      отложен в отдельную миграцию, чтобы не смешивать типы данных со старой
      историей сообщений.

- [x] `MessagesListCubit` больше не создаётся глобально до логина.
      Он перенесён в auth-scoped `HomePage.route()`, чтобы не стартовать без
      валидного `uid`.

- [x] **FcmCubit lifecycle**: eager-init убран из `MyApp`; `FcmCubit`
      создаётся при входе в `HomePage.route()` и уничтожается при выходе из
      auth-части приложения.

- [x] `HomePage` переведён на `IndexedStack`, чтобы вкладки не зависели от
      повторного монтирования.

- [x] `BackgroundWidget` больше не использует platform-specific ветку для
      нижнего `SafeArea`; поведение выровнено между платформами.

---

## Итерация 4 (2026-04-22)

Фокус: security hardening, encrypted SMS storage и стабильная идентичность
устройства.

- [x] **S-001** В коде включено клиентское шифрование SMS:
      добавлены `CryptoService`, `SecurityRepository`, password-wrapped
      master key, локальный secure-cache ключа и encrypted schema для
      conversations/messages.

- [x] Plaintext fallback для новых SMS удалён:
      `MessagesRepository.saveIncomingMessage()` теперь требует готового
      encryption state и больше не пишет `text/title/last_message` в Firestore
      как запасной сценарий.

- [x] `MessagesRepository` теперь умеет:
      live-читать encrypted payload,
      писать новые SMS в encrypted-виде,
      лениво мигрировать старые plaintext-диалоги и сообщения после логина.

- [x] Auto-login ужесточён:
      восстановленная сессия считается валидной только если есть и remote
      `key_envelope`, и локальный master key. Это убирает тихий режим, где
      приложение ещё работало, но могло остаться без корректно инициализированного
      шифрования.

- [x] `AuthCubit` на `signIn / signUp` инициализирует или открывает
      пользовательский master key, а на logout очищает локальный key cache.
      `SplashCubit` больше не пускает в home-session без локального ключа,
      если remote security уже включён.

- [x] **S-002** Локальный `firestore.rules` переписан на owner-scoped правила
      для `users`, `devices` и `user_messages`.
      Деплой в реальный Firebase-проект всё ещё внешний шаг автора.

- [x] **B-022 / B-023** `CheckDeviceCubit` переписан:
      убран `SharedPreferences is_new_device`,
      добавлен stable `deviceId` через `flutter_secure_storage`,
      сохранения теперь `await`-safe,
      first-run modal больше не теряется из-за навигационной гонки.

- [x] `DeviceRepository.addBatteryAndNetworkStatus()` теперь безопаснее
      переключает `is_main_device`: при выборе нового main device остальные
      устройства снимаются с этого флага в одном batch.

- [x] `dart analyze lib test` снова чистый: дочищены оставшиеся
      `use_build_context_synchronously`, deprecated `activeColor` и
      `withOpacity` замечания в UI-слое.

---

## Итерация 5 — Warm redesign (2026-04-23)

Полная UI-итерация: единый дизайн-язык поверх существующей логики, без
изменений в репозиториях/моделях/security. Один коммит — `16fd1d1`
«Warm redesign: tokens, primitives, screens». `dart analyze` остаётся
чистым (32 info-level prefer_const замечания, 0 errors).

### Group A — Design tokens

- [x] **Шрифт**: подключён локальный Manrope в четырёх весах
      (`assets/fonts/Manrope-{500,600,700,800}.ttf` + декларация в
      `pubspec.yaml`). `MaterialApp.theme.fontFamily = 'Manrope'`.
- [x] **`themes/colors.dart`**: переписан на семантическую warm-coral
      палитру — `accent` (`#F59B7E`), `accentDeep`, `accentSoft`,
      `accentInk`; surfaces `bg`/`bgAlt`/`surface`/`divider`; ink-шкала
      `ink`/`inkSecondary`/`inkTertiary`/`inkPlaceholder`; статусы
      `success`/`successSoft`/`amber`/`danger`; `avatarPalette` для
      буквенных аватарок.
- [x] **`themes/text_style.dart`**: переписан под единые
      `AppTextStyle.{display,h1,title,titleSm,bodyM,bodySm,bodySmBold,
      button,caption,captionUpper,micro,codeMono}` — вся типографика
      централизована.
- [x] Добавлен **`themes/radii.dart`**: `AppRadii.{r1..r4,pill}` +
      готовые `BorderRadius` (`brR1..brR4`, `brPill`).
- [x] Добавлен **`themes/shadows.dart`**: `AppShadows.{s,m,accent}` —
      три уровня тени (карточки, нав-таблетка, акцент).

### Group B — Новые UI-примитивы (`lib/screens/widget/warm/`)

- [x] `warm_card.dart` — обобщённая карточка
      `surface + brR3/4 + shadow.s + border(0x0A281910)`.
- [x] `warm_header.dart` — eyebrow + title + опциональный trailing,
      используется в верху каждой главной вкладки.
- [x] `warm_chip.dart` — pill-фильтр с active/inactive состоянием и
      опциональным count.
- [x] `warm_search_field.dart` — round-bordered input с иконкой поиска
      и `onChanged` колбэком.
- [x] `pill_tab_bar.dart` — плавающая нижняя нав-таблетка
      (`AppShadows.m`, `AppColor.surface`); активный таб — pill `accent`
      с иконкой + label, неактивные — только иконка `inkTertiary`.
- [x] `icon_tile.dart` — квадратная иконка-таблетка с настраиваемыми
      background/foreground (default `accentSoft / accentDeep`).

### Group C — Утилиты

- [x] **`utils/code_extractor.dart`** (`CodeExtractor.extract`) —
      heuristic под OTP: ищет 4–8-значные числа с привязкой к cue-словам
      («код», «code», «otp», «verification», «password», …), чтобы убрать
      ложные срабатывания на номера заказов и суммы. Используется в
      `MessagesListWidget._CodeChip` и `MessageDetailsScreen._CodeBlock`.

### Group D — Экраны: переписаны под warm-дизайн

- [x] **SplashScreen**: квадратный градиентный лого 96×96
      (`accent → accentDeep`) с белым `flash.png`, заголовок «Simply»,
      подпись «SMS-пересылка между устройствами», тонкий accent-спиннер.
- [x] **AuthScreen**: плоский `bg`-фон, заголовок-display
      («Привет!» / «Создать аккаунт»), карточка формы `surface + brR4`,
      `CustomSegmentedControl` (`bgAlt` + белая активная pill),
      `CustomTextField` с pill-бордером и focus-outline, pill-кнопка
      `accent`, `DividerWithText('или через')`, `SignInButton` для
      Google (белый) и Apple (тёмный). Все строки по-русски.
- [x] **HomePage**: `IndexedStack` + плавающая `PillTabBar`
      («Устройства» / «Сообщения» / «Настройки»), `extendBody: true`,
      `_didRequestInitialDeviceCheck` страхует от повторного триггера
      `CheckDeviceCubit.checkDevice()` при ребилдах.
- [x] **DevicesScreen**: `WarmHeader` + pill-кнопка «Добавить»
      с тенью `accent`, карточки `DeviceWidget` с phone-thumbnail
      (рамка `accentSoft` + чёрный экран + цветной inset, который для
      online-устройства градиентный, для offline — серый), бейдж
      «ГЛАВНОЕ» (`accentSoft`/`accentDeep`), `_StatusPill` («В сети» /
      «Был {relative}»), tinted footer `bgAlt` со stats grid.
- [x] **DeviceInfoWidget**: переписан в 3-колоночную сетку
      Battery / Signal / Sync (раньше — orange CircularProgress + 80%
      magic).
- [x] **MessagesListScreen**: `WarmHeader` с динамическим eyebrow
      («N новых · сегодня» / «N в архиве»), `_ProfileBubble`,
      `WarmSearchField`, `_FilterChips` (Все / Непрочитанные / Коды /
      Банки / Доставка), `MessagesListWidget` с буквенным аватаром на
      цвете из `avatarPalette`, опциональным `_CategoryTag`, `_CodeChip`
      для предпросмотра OTP.
- [x] **MessagesListCubit**: добавлены поле `query` (`setQuery`),
      `filter` (`setFilter`, `MessagesFilter` enum), производные
      `filteredItems`, `unreadCount`, `totalCount` для нового UI.
- [x] **MessageDetailsScreen**: `BackgroundWidget` + кастомный
      `AppBarWidget` с back, `AvatarWithIndicator`-leading, subtitle
      «● SMS · с iPhone/Android» и `_DotsButton`-trailing; ленту
      сообщений возглавляет `_InfoBanner` («Simply пересылает SMS
      и автоматически копирует найденные коды…»); между разными днями —
      `_DateDivider` (`formatChatDivider`); каждый bubble — карточка
      `surface` с stair-step углами, под bubble — `formatTime()`.
      `_CodeBlock` подсвечивает OTP (моно, 4-4 split) и копирует
      по тапу на pill «Копировать».
- [x] **DeviceSettingsModal / DeviceSettingsWidget**: переписаны в
      warm стиль — drag-handle `bgAlt`, заголовок «Настройки устройства»
      / «Новое устройство», три `BuildSwitchTile` (`bgAlt` / `accent`),
      `_PrimaryAction` («Сохранить») и `_DangerAction` («Удалить
      устройство») вместо прежних зелёной/розовой кнопок.
- [x] **BuildSwitchTile**: оранжевый/серый scheme заменён на
      warm (`bgAlt` background + `accent` toggle).
- [x] **SettingsScreen**: `WarmHeader('Аккаунт и приложение',
      'Настройки')`, `_ProfileCard` (градиентный круг с инициалами,
      имя, email, кнопка edit), `_PremiumBanner` (градиент
      `accentDeep → accent`, `AppShadows.accent`, pill «Открыть»),
      грouped `_Group`/`_SectionTitle`/`_Divider` (Аккаунт / Помощь),
      красный `_LogoutButton` через `ConfirmationDialog`. Подвал
      «Создано с ♥ командой Simply».
- [x] **SettingsRow** (бывший `SettingWidget`): переписан поверх
      `IconTile`, поддерживает `subtitle`, `trailing`, опциональный
      `comingSoon` бейдж и кастомные `iconBg`/`iconFg`.
- [x] **PrivacyPolicyScreen**: `BackgroundWidget` + `AppBarWidget`,
      плашка `accentSoft` с предупреждением «готовим документ»,
      раздел «Что будет в политике» с белой карточкой.
- [x] **ContactUsScreen**: `BackgroundWidget` + `AppBarWidget(back)`,
      три цветные `_ContactCard`-а (Почта/Сайт/Соцсети), блок «Команда»
      с `_TeamMember` (градиентный кружок-инициалы).
- [x] **AvatarWithIndicator**: переписан с SVG-заглушки на буквенный
      аватар на цвете из `avatarPalette` (стабильный hash от title) +
      опциональный platform-бейдж в углу.
- [x] **BackgroundWidget**: переписан в плоский
      `Scaffold(bg) + SafeArea(bottom: false)` без оранжевого header-sheet
      и без platform-веток (B-035 закрыт).
- [x] **AppBarWidget**: round back-кнопка + title + опциональные
      leading/subtitle/trailing, `AppShadows.s`. Старая «people»-иконка
      из MessagesList убрана.
- [x] **RoundedButton / SignInButton / Dialogs / DividerWithText /
      CustomTextField / CustomSegmentedControl** — выровнены по новой
      палитре и токенам.

### Group E — Платформенные / lifecycle штрихи

- [x] **`main.dart`**: `await initializeDateFormatting('ru_RU')` перед
      `runApp`, чтобы все `DateFormat`-ы корректно работали с русской
      локалью; `MaterialApp.theme` теперь поднимает Manrope, warm
      `colorScheme`, `elevatedButtonTheme` (pill `accent`),
      `inputDecorationTheme` (pill outline, focus `accent`).
- [x] **`extensions.dart`**: добавлены `formatRelativeShort`,
      `formatChatDivider`, `formatTime` для нового UI; старый
      `formatDateTime` оставлен для совместимости.
- [x] **`models/conversation.dart`**: добавлены опциональные
      `category` и `sourcePlatform`, чтобы UI мог рисовать
      `_CategoryTag` и platform-бейдж в аватаре.

### Group F — Cleanup, который остался после редизайна

После warm-редизайна в `pubspec.yaml` появились dependencies без
единого `import` в `lib/`:

- [ ] `flutter_svg: 2.0.10+1` — убрать (раньше использовался в
      `NoMessagesAvailable`).
- [ ] `auto_size_text: 3.0.0` — убрать (раньше использовался в
      `AuthScreen`).
- [ ] `cupertino_icons: ^1.0.2` — Material-only.
- [ ] `lib/screens/widget/custom_progress_indicator.dart` — без юзеров.
- [ ] `lib/screens/common/cubit_list_view.dart` — без юзеров после
      того, как `Messages` и `Devices` экраны перешли на собственные
      `BlocBuilder` + `ListView.builder`.

### Group G — Документация (текущий заход, 2026-04-23)

- [x] `docs/README.md`: дата синхронизации обновлена до **2026-04-23**,
      добавлен note про warm-редизайн.
- [x] `docs/01_PRODUCT_OVERVIEW.md`: переписаны секции i18n, стек,
      архитектура (`themes/{radii,shadows}.dart`, `screens/widget/warm/`,
      `utils/code_extractor.dart`, `security/`), отмечены dead-deps.
- [x] `docs/02_SCREENS_OVERVIEW.md`: полностью переписан под новый UI
      (Splash, Auth, Home/PillTabBar, Devices, Messages, MessageDetails,
      Settings, DeviceSettingsModal, Privacy, Contact, общие примитивы,
      существующее-но-неиспользуемое).
- [x] `docs/03_BUGS_AND_ISSUES.md`: B-035 ✅, B-037 помечен «файл удалён»,
      B-041 переоформлен под `IconTile`/`SettingsRow`, B-043 помечен
      обратным сдвигом (UI на русском, gen-l10n всё ещё в Этап 7),
      B-033 расширен dead-deps списком.
- [x] `docs/05_ARCHITECTURE_IMPROVEMENTS.md`: Этап 0 — пункт по
      `auto_size_text` заменён общим cleanup-пунктом
      (`flutter_svg`/`auto_size_text`/`cupertino_icons` +
      `CubitListView`/`CustomProgressIndicator`).
- [x] `docs/06_FIX_PROGRESS.md` (этот файл): добавлена Итерация 5 —
      warm redesign.

---

## Что НЕ сделано в этой итерации (следующий заход)

Это осознанно отложено, потому что требует более масштабной работы, бэкенд-части
или внешних учётных данных.

### Следующий заход

- [ ] **B-004 / S-018** FCM pipeline: сохранение токена в `devices.token`,
      подписка на `onMessage`, `onMessageOpenedApp`, показ через
      `flutter_local_notifications`. Требует Cloud Function для sender-side
      (или Firebase Extension «Trigger FCM Notifications»).
- [ ] **B-009** Убрать `fetch()` из `build()` в `CubitListView`.
      `DevicesScreen` уже переведён на `initState`, но `CubitListView`
      всё ещё держит initial-fetch внутри `build()`. После warm-редизайна
      ни один экран `CubitListView` больше не использует, так что,
      возможно, проще сразу удалить его (см. cleanup в Итерации 5
      Group F) и закрыть B-009 этим путём.
- [ ] **B-029** Пересмотреть `StandardListCubit` с учётом реактивности
      (тоже потенциально удаляется вместе с `CubitListView`).
- [ ] **B-047 / B-049** Дочистить остатки кириллических комментариев и
      неудачного нейминга (`DeviceCubit.updateDevice` всё ещё обновляет
      весь список). `B-048` после редизайна почти закрыт — большинство
      затронутых экранов переписаны.

### Требует внешних действий от автора

- [ ] **B-005 / S-003** Release signing — нужен keystore (ключ не в репо).
      Актуально только если проект пойдёт в стор.
- [ ] **S-002** Firestore Security Rules — задеплоить обновлённый
      owner-scoped `firestore.rules` в реальный Firebase-проект.
- [ ] **S-004** Текст Privacy Policy — юридический документ, нужен от продакта.
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
