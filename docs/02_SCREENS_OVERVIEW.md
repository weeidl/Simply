# Simply — Полная карта экранов и их содержимого

Цель документа — описать КАЖДЫЙ экран приложения, что в нём отображается,
какие действия доступны пользователю и какая логика за ним стоит. Используйте
как «компас» при доработке.

> **Свежее (2026-04-23)**: вся UI-часть приложения переехала на единый
> «warm coral» дизайн-язык — Manrope-шрифт, тёплая палитра
> (`AppColor.bg / accent / accentDeep / accentSoft / ink…`), новые
> design-tokens (`themes/radii.dart`, `themes/shadows.dart`) и набор
> примитивов в `lib/screens/widget/warm/`
> (`WarmHeader`, `WarmChip`, `WarmSearchField`, `WarmCard`, `PillTabBar`,
> `IconTile`). Все строки UI переведены на русский. Описания ниже отражают
> состояние **после** редизайна.

---

## Навигационный граф

```
SplashScreen
  ├── (authenticated)  → HomePage (pushReplacement)
  │                        ├── DevicesScreen      (tab 0)
  │                        ├── MessagesListScreen (tab 1, default)
  │                        │     └── MessageDetailsScreen
  │                        └── SettingsScreen     (tab 2)
  │                              ├── ContactUsScreen
  │                              └── PrivacyPolicyScreen
  │                        + CheckDeviceCubit ► DeviceSettingsModal (первый запуск)
  │
  └── (unauthenticated) → AuthScreen (pushReplacement)
                             └── HomePage (pushAndRemoveUntil)

Любой DeviceWidget  → DeviceSettingsModal (bottomSheet)
```

---

## 1. SplashScreen
**Файл:** `lib/screens/splash/splash_screen.dart`

### UI
- `Scaffold(backgroundColor: AppColor.bg)`.
- По центру: квадратный лого 96×96 с градиентом
  `accent → accentDeep`, `borderRadius: 28`, `boxShadow: AppShadows.accent`,
  внутри — белый `assets/flash.png` 44px.
- Под лого — `Text('Simply', AppTextStyle.h1)` и подпись
  `'SMS-пересылка между устройствами'` стилем `bodySm(inkTertiary)`.
- Тонкий `CircularProgressIndicator(color: AppColor.accent, strokeWidth: 2.4)`
  22×22 в самом низу.
- `SystemUiOverlayStyle`: статус-бар прозрачный, иконки тёмные;
  systemNavigationBar — `AppColor.bg` с тёмными иконками.

### Логика
- `SplashCubit` подписан на `FirebaseAuth.authStateChanges()`.
- При `AuthAuthenticated` → `HomePage.route()` через `pushReplacement` +
  запуск `CheckDeviceCubit.checkDevice()`.
- При `AuthUnauthenticated` → `AuthScreen.route()` через `pushReplacement`
  (Splash больше не остаётся в стеке — B-007 закрыт).

### Что ещё можно улучшить
- При первом запуске видно дефолтный индикатор без лого-анимации — можно
  добавить `flutter_native_splash` для нативного splash до Flutter init.

---

## 2. AuthScreen (Login / Register)
**Файл:** `lib/screens/auth/screen/auth_screen.dart`

### UI
- Плоский фон `AppColor.bg` (без оранжевой шапки + белого sheet, как раньше).
- Заголовок: «Привет!» / «Создать аккаунт» (стиль `display(ink)`,
  меняется в зависимости от вкладки).
- Подзаголовок: «Войдите, чтобы продолжить пересылку SMS» /
  «Несколько секунд — и вы в Simply» (стиль `bodyM(inkSecondary)`).
- Карточка формы: `AppColor.surface`, `AppRadii.brR4`, `AppShadows.s`,
  тонкая граница `Color(0x0A281910)`. Контент внутри `SingleChildScrollView`.
- **CustomSegmentedControl**: две вкладки — `Вход` / `Регистрация`.
  Контейнер `AppColor.bgAlt`, активная вкладка — белая «таблетка».
- Поля формы (`CustomTextField` с pill-бордером и outline focus):
  - В режиме Регистрация: `Имя` (Icons.person_outline_rounded).
  - `E-mail` (Icons.mail_outline_rounded).
  - `Пароль` (Icons.lock_outline_rounded) — с маской и кнопкой «глаз».
- «Забыли пароль?» — на вкладке Login, цвет `accentDeep`, обёрнут в
  `InkWell` с `AppRadii.brR1`.
- Главная кнопка `_PrimaryButton` (54px, `AppColor.accent`, pill)
  — «Войти» / «Создать аккаунт».
- `DividerWithText('или через')`.
- Два `SignInButton`: Google (белая карточка) и Apple (тёмная). Оба
  пока с `onPressed: () {}` — заглушки.

### Действия
- Переключение вкладки — `cubit.setSegmentedControlState`.
- Отправка формы:
  - Клиентская валидация: email-regex, `password.length >= 6`, для Register
    дополнительно non-empty name (`AuthCubit._validate`).
  - Login → `cubit.signIn()` → `FirebaseAuth.signInWithEmailAndPassword`,
    плюс открытие/инициализация master key (см. итерация 4).
  - Register → `cubit.signUp()` → создание пользователя +
    `user.updateDisplayName` + запись в `users/{uid}` `{name, email, createdAt}`,
    инициализация security envelope.
  - На успехе: `Navigator.pushAndRemoveUntil(HomePage.route(), (_) => false)`.
  - На ошибке: `MessageDialog.show(cubit.state.authErrorMessage)`;
    `FirebaseAuthException.code` мапится в человекочитаемый текст
    через `_mapAuthError`.

### Что ещё можно улучшить
- Google / Apple login — всё ещё заглушки (B-015).

---

## 3. HomePage (корневой экран после логина)
**Файл:** `lib/screens/home/home.dart`

### UI
- `Scaffold(backgroundColor: AppColor.bg, extendBody: true)` —
  body уходит под нижнюю «плавающую» нав-таблетку.
- Body — `IndexedStack` с тремя вкладками: `DevicesScreen` /
  `MessagesListScreen` (по умолчанию `_selectedIndex = 1`) / `SettingsScreen`.
  IndexedStack сохраняет состояние вкладок при переключении.
- **Bottom-nav**: `PillTabBar` (плавающая «таблетка» с тенью) —
  активный таб заливается `accent` и раскрывает label («Устройства»,
  «Сообщения», «Настройки»), неактивные — только иконка `inkTertiary`.

### Логика
- `initState` → `_requestPermissions()` запрашивает `Permission.sms` и
  `Permission.notification` (на Android; на iOS — early-return).
- `WidgetsBinding.addPostFrameCallback` один раз дёргает
  `CheckDeviceCubit.checkDevice()` (через флаг `_didRequestInitialDeviceCheck`,
  чтобы не перезапускать при ребилдах).
- `MultiBlocListener` слушает `CheckDeviceCubit` → при
  `DeviceSettingStatus.showModal` открывает `DeviceSettingsModal`.
- `MultiBlocProvider` в `HomePage.route()` поднимает auth-scoped
  `FcmCubit` и `MessagesListCubit` (с inject-ом `MessagesRepository()`).

### Проблемы
- Все три вкладки монтируются сразу через `IndexedStack` — это
  снимает проблему с потерей state, но память тратится с первого кадра.

---

## 4. DevicesScreen (вкладка 0)
**Файл:** `lib/screens/devices/screen/devices_screen.dart`

### UI
- `WarmHeader(eyebrow: …, title: 'Устройства', trailing: _AddButton)`.
  Eyebrow подсчитывает количество устройств:
  «Подключите свой первый телефон» / «N устройств в синхронизации».
- `_AddButton` — pill-кнопка `accent` с иконкой `add_rounded` и текстом
  «Добавить»; по тапу открывает `DeviceSettingsModal.show()` (без `device`).
- Список — `ListView.separated(separatorBuilder: SizedBox(height: 14))` с
  карточками `DeviceWidget`.
- Pull-to-refresh: `RefreshIndicator(color: accent, onRefresh: updateDevice)`.

### DeviceWidget
**Файл:** `lib/screens/devices/widget/device_widget.dart`

- Карточка `Material(color: surface, borderRadius: AppRadii.brR4)` с
  `AppShadows.s` и тонкой границей.
- `_online` вычисляется как `dateUpdateInfo` < 15 минут назад. Если
  device offline, вся карточка идёт через `Opacity(0.78)`.
- **Header (верхняя часть)**:
  - `_PhoneThumbnail` 56×72 — стилизованная мини-копия телефона
    (рамка `accentSoft` + чёрный экран + цветной inset, который для
    online-устройства градиентный `accent → accentDeep`, для offline
    — серый `inkSecondary`).
  - Название устройства (`titleSm`), бейдж «ГЛАВНОЕ» (`accentSoft`/
    `accentDeep`) если `isMainDevice`.
  - OS-label под именем (`iOS` / `Android`).
  - `_StatusPill` — pill «В сети» (`successSoft`) с зелёным dot и
    спред-shadow, либо «Был {relative}» (`bgAlt`) c серым dot.
  - В правом верхнем углу — `Icons.more_horiz_rounded` (визуальный hint).
- **Footer (нижняя часть)**:
  - Контейнер `AppColor.bgAlt`, скруглённые низы радиусом `AppRadii.r4`,
    верхняя `Border` `AppColor.divider`.
  - Внутри — `DeviceInfoWidget(device, online)`.
- По тапу — `DeviceSettingsModal.show(device: ...)`.

### DeviceInfoWidget — stats grid
**Файл:** `lib/screens/devices/widget/device_info_widget.dart`

- Три колонки в одной строке:
  1. **Battery** (если есть `batteryLevel`) — иконка + проценты + тонкий
     прогресс-бар, цвет градиентом по уровню заряда.
  2. **Signal** (если есть `networkType`) — иконка-«столбики» сигнала +
     тип сети (LTE / 5G / Wi-Fi…).
  3. **Sync** — иконка sync + статус «В реал-тайм» / «—».
- Если ни заряда, ни сети — placeholder.

### Состояния (DeviceStatus)
- `initial` / `loading` → `CircularProgressIndicator(color: accent)`.
- `error` → `_ErrorView` («Не удалось загрузить» + кнопка «Повторить»).
- `empty` → `_EmptyView` (`accentSoft` круг с иконкой `smartphone_rounded`,
  заголовок «Пока нет устройств», подсказка «Войдите в Simply на другом
  телефоне…»).
- `loaded` → `RefreshIndicator` + `ListView.separated`.

---

## 5. MessagesListScreen (вкладка 1, default)
**Файл:** `lib/screens/messages_list/screen/messages_list_screen.dart`

### UI
- `WarmHeader(eyebrow, title: 'Сообщения', trailing: _ProfileBubble)`.
  Eyebrow динамический:
  - 0 unread, 0 total → «Здесь будут ваши SMS».
  - 0 unread, N total → «N в архиве».
  - K unread → «K новых · сегодня».
- `_ProfileBubble` — круглая 44×44 «таблетка» с градиентом и иконкой `person_outline_rounded`.
- `WarmSearchField(hint: 'Поиск по сообщениям', onChanged: cubit.setQuery)`.
- `_FilterChips` — горизонтальный `SingleChildScrollView` из `WarmChip`-ов:
  «Все» (с total), «Непрочитанные» (с unread), «Коды», «Банки», «Доставка»
  (`MessagesFilter` enum).
- Список — `ListView.builder` с `MessagesListWidget`-ами,
  `padding.bottom: 100` (под плавающую PillTabBar).

### MessagesListWidget
**Файл:** `lib/screens/messages_list/widget/messages_list_widget.dart`

- `Material(borderRadius: AppRadii.brR3)` + `InkWell`.
- Если непрочитан — лёгкая подсветка фона `accent.withValues(alpha: 0.06)` +
  правая «капля» 8×8 `accent` со спред-shadow.
- `AvatarWithIndicator` — буквенный аватар на цвете из `avatarPalette`
  (стабильный hash от `title`), с маленьким platform-бейджем
  (`phone_iphone_rounded` / `phone_android_rounded`) в углу, если у
  conversation есть `sourcePlatform`.
- В заголовке диалога — название отправителя + опциональный
  `_CategoryTag` (мини-pill `bgAlt` с категорией).
- Справа сверху — `formatRelativeShort()` от даты последнего сообщения
  (стиль `caption(inkTertiary)`).
- Превью последнего сообщения — `bodySm(inkSecondary/Tertiary)` в
  две строки.
- Если в превью найден код (`CodeExtractor.extract`) — рисуется
  `_CodeChip` с моноширинным кодом и иконкой copy; по тапу — копирование
  в буфер + SnackBar «Код N скопирован» на тёмном `AppColor.ink` фоне.
- По тапу на саму строку → `markConversationRead(id)` →
  `MessageDetailsScreen.route(...)`.

### Обновление данных
- Список диалогов подписан на Firestore `snapshots()`.
- Поиск/фильтрация — клиентская, через `state.filteredItems` в
  `MessagesListCubit`.
- `RefreshIndicator(color: accent)` оставлен как ручной retry.

### Состояния (CubitListView не используется)
- `state.isLoading && items.isEmpty` → `_LoadingView` (центральный
  `CircularProgressIndicator(color: accent)`).
- `state.hasError` → `_ErrorView` («Не удалось загрузить» + «Повторить»).
- `filtered.isEmpty` → `_EmptyView` с разной копией под фильтр и
  непустой `state.query` («Ничего не найдено», «Всё прочитано», …).

---

## 6. MessageDetailsScreen (переписка с одним отправителем)
**Файл:** `lib/screens/message_details/screen/message_details_screen.dart`

### UI
- `BackgroundWidget` (плоский `AppColor.bg`).
- `AppBarWidget` с:
  - back-кнопкой (`showBackButton: true`).
  - leading = `AvatarWithIndicator(title, size: 40, devicePlatform)`.
  - title = имя отправителя.
  - subtitle = строка «● SMS [· с iPhone / · с Android]» с зелёным dot
    `success` 6×6.
  - trailing = `_DotsButton` (круглая кнопка `more_horiz_rounded` без
    действия).
- Список — `ListView.builder`, первый элемент — `_InfoBanner`
  («Simply пересылает SMS с устройства и автоматически копирует найденные
  коды в буфер обмена.»), дальше — сообщения.
- Между сообщениями разных дней — `_DateDivider` с
  `formatChatDivider()` (например, «Сегодня», «Вчера», «12 апреля»).

### _MessageBubble
- Прямоугольная карточка `surface` со ступенчатыми углами
  (`topLeft: 6, topRight: 22, bottomLeft: 22, bottomRight: 22`),
  `AppShadows.s` + тонкая граница.
- Сам текст — `bodyM(ink)`.
- Под bubble — время отправки `formatTime()` стиль `caption(inkTertiary)`.

### _CodeBlock — auto-detected OTP
- `CodeExtractor.extract(text)` — heuristic, ищет коды длиной 4–8 цифр
  с привязкой к cue-словам («код», «code», «otp», «verification», …),
  чтобы убрать ложные срабатывания на номера заказов и суммы.
- Если найден — внутри bubble показывается отдельный card
  (`color: bg`, тонкая `accent.withAlpha(0.4)` рамка) с надписью «Найден код»,
  моноширинным кодом (4-4 разделение пробелом) и pill-кнопкой `accent`
  «Копировать». По тапу — `Clipboard.setData` + SnackBar «Код скопирован».

### Состояния
- `loading + items.isEmpty` → центрированный спиннер.
- `hasError` → `_ErrorView`.
- `isLoaded && items.isEmpty` → `_EmptyView` («Сообщений нет», иконка
  `inbox_outlined` в круге `accentSoft`).
- Иначе → `RefreshIndicator` + `_MessagesList`.

---

## 7. DeviceSettingsModal (bottom-sheet)
**Файл:** `lib/screens/devices/settings/device_settings_modal.dart`
**Виджет:** `lib/screens/devices/settings/device_settings_widget.dart`

### UI
- `BottomSheet` с `AppColor.bg`, скруглением `28`. Высота — 78% экрана
  (95% на маленьких).
- Drag-handle 36×4 `bgAlt`.
- Заголовок: «Настройки устройства» / «Новое устройство»
  (стиль `title(ink)`).
- Подзаголовок: «Выберите, какие данные показывать в приложении и какие
  функции активировать.» (`bodySm(inkTertiary)`).
- Три `BuildSwitchTile` (warm-style: pill background `bgAlt`, активный
  `accent` toggle):
  1. **Отправка SMS** — назначить устройство «главным».
  2. **Показ сети** — показывать тип сети и качество сигнала в Devices.
  3. **Уровень заряда** — показывать заряд в Devices.
- `_PrimaryAction` (`accent`, 52px) — «Сохранить».
- `_DangerAction` (`danger.withValues(alpha: 0.10)`, 48px) — «Удалить
  устройство», виден только в edit-режиме.

### Логика
- `CheckDeviceCubit.saveSettingDevice` читает актуальные `battery` /
  `network`, обновляет `is_main_device` (с batch-снятием флага у
  остальных устройств — итерация 4) через
  `DeviceRepository.addBatteryAndNetworkStatus`.
- В edit-режиме после сохранения — `DeviceCubit.updateDevice()`
  и `Navigator.pop()`.
- На delete — `DeviceCubit.deleteDevice(deviceId)` + `pop`.

### Stable deviceId
- Прежний баг с дрейфом `Build.ID` закрыт (B-022 / B-023):
  `deviceId` хранится в `flutter_secure_storage` и переиспользуется.

---

## 8. SettingsScreen (вкладка 2)
**Файл:** `lib/screens/settings/settings_screen.dart`

### UI
- `Column(stretch)` с `WarmHeader('Аккаунт и приложение', 'Настройки')`.
- `ListView` с `padding.bottom: 100` под нижнюю PillTabBar.

### _ProfileCard
- Белая карточка `AppRadii.brR4` + `AppShadows.s`.
- Слева — кружок 56×56 с градиентом `accent → accentDeep` и **инициалами**
  (вычисляются из `displayName` или `email`, fallback `?`).
- В центре — имя (`titleSm(ink)`) и `email` (`bodySm(inkTertiary)`).
- Справа — кнопка `edit_outlined` 36×36 на `bgAlt` (визуальная
  заглушка, без действия).

### _PremiumBanner
- Прямоугольный градиент `accentDeep → accent`, `AppShadows.accent`.
- Иконка `workspace_premium_rounded` в полупрозрачном кружке.
- Текст «Simply Premium» / «Снимите лимиты на устройства и историю.»
- Pill-кнопка «Открыть» (белый фон, текст `accentDeep`) — пока
  без действия.

### _Group / _SectionTitle
Карточки `surface` с `AppRadii.brR3`, разделители `_Divider` с отступом
`60` слева. Внутри — `SettingsRow`-ы (`lib/screens/settings/widget/setting_widget.dart`)
с `IconTile`, заголовком, подзаголовком, опциональной правой стрелкой и
pill-бейджем «Soon», если `comingSoon: true`.

- **Аккаунт**:
  - Профиль (Soon)
  - Уведомления (Soon)
  - Язык (Soon, синяя иконка)
- **Помощь**:
  - Политика конфиденциальности → `PrivacyPolicyScreen`
    (зелёная иконка `shield_outlined`).
  - Связаться с нами → `ContactUsScreen` (иконка `support_agent_rounded`,
    `accentSoft` / `accentDeep`).

### _LogoutButton
- Розовый блок `danger.withValues(alpha: 0.10)` с иконкой `logout_rounded`
  и текстом «Выйти из аккаунта» (стиль `button(danger)`).
- По тапу — `ConfirmationDialog` («Выйти из аккаунта?», кнопки «Выйти»/«Отмена»).
- На подтверждении: `splashCubit.signOut()` →
  `pushAndRemoveUntil(AuthScreen.route())`. ✅ Не пересоздаёт корневой `MyApp`
  (B-008 закрыт).

### Подвал
- `Center(Text('Создано с ♥ командой Simply', AppTextStyle.caption(inkTertiary)))`.

---

## 9. PrivacyPolicyScreen
**Файл:** `lib/screens/privacy_policy/screen/privacy_policy_screen.dart`

### UI
- `BackgroundWidget` + `AppBarWidget('Политика конфиденциальности', back)`.
- Сверху — плашка `accentSoft` с иконкой `schedule_rounded`:
  «Готовим документ. Пока это заглушка — не используйте приложение в
  публичных каналах.».
- Дальше — раздел «Что будет в политике» с белой карточкой и буллетами
  (что собираем, как храним, права пользователя, контакт).

### Статус
- Заглушка. Текст политики **отсутствует** — блокер для публикации в
  App Store / Google Play (S-004).

---

## 10. ContactUsScreen
**Файл:** `lib/screens/contact_us/screen/contact_us_screen.dart`

### UI
- `BackgroundWidget` + `AppBarWidget('Связаться с нами', back)`.
- `ListView` с заголовком «На связи» (`h1(ink)`) и подзаголовком
  «Выберите удобный способ связи — мы ответим в рабочее время.».
- Три `_ContactCard` (белая карточка `surface`, цветная иконка-таблетка
  слева, заголовок + subtitle + стрелка):
  - Почта → `mailto:weeidlone@gmail.com` (accentSoft / accentDeep).
  - Сайт → `https://weeidl.com` (синие тона).
  - Соцсети → `https://www.instagram.com/weeidl` (фиолетовые тона).
- Раздел «Команда» с `_TeamMember(name: 'Artur Rustamov',
  role: 'Founder & CEO', initials: 'AR')` — карточка с градиентным
  кружком, именем и ролью.

### Поведение
- `_launchUrl` использует `LaunchMode.externalApplication`. При неудаче
  — SnackBar «Не удалось открыть $url» (B-024 закрыт).
- URL и email пока захардкожены.

---

## 11. DeviceSettingsModal: первый запуск
**Триггер**: `CheckDeviceCubit.checkDevice()` вызывается в
`HomePageState.initState` через `addPostFrameCallback`. Если на сервере
не найдено устройство с текущим `stable deviceId` И платформа — Android,
модалка открывается.

### Поток
1. Считывается / создаётся `deviceId` через `flutter_secure_storage`.
2. Сохраняется базовая инфо об устройстве (userId, deviceId, deviceName,
   platform).
3. Открывается модалка настроек.

### Что закрыто (vs прежний UX)
- Логика больше не опирается на `is_new_device` в `SharedPreferences`
  (B-022 / B-023).
- При выборе нового main device остальные устройства снимаются с этого
  флага в одном batch (`DeviceRepository.addBatteryAndNetworkStatus`).
- Модалка больше не теряется из-за гонки навигации (открывается под
  `MultiBlocListener` в HomePage, а не из SplashScreen напрямую).

---

## 12. Компоненты, которые переиспользуются

### Дизайн-токены и примитивы
- **`themes/colors.dart`** — `AppColor` (warm coral палитра + ink-шкала +
  `avatarPalette` для буквенных аватарок).
- **`themes/text_style.dart`** — `AppTextStyle.{display,h1,title,titleSm,
  bodyM,bodySm,bodySmBold,button,caption,captionUpper,micro,codeMono,…}`,
  все на Manrope.
- **`themes/radii.dart`** — `AppRadii.{r1..r4,pill}` + готовые
  `BorderRadius` (`brR1..brR4`, `brPill`).
- **`themes/shadows.dart`** — `AppShadows.{s,m,accent}`.
- **`screens/widget/warm/warm_header.dart`** — eyebrow + title + trailing
  для верха каждого экрана.
- **`warm_chip.dart`** — round pill для фильтров (active/inactive).
- **`warm_search_field.dart`** — input с иконкой поиска и round-bordered
  стилем.
- **`warm_card.dart`** — обобщённая карточка `surface + brR3 + shadow.s`.
- **`pill_tab_bar.dart`** — плавающая нижняя нав-таблетка (активный таб
  заливается `accent` + раскрывает label).
- **`icon_tile.dart`** — квадратная иконка-таблетка с настраиваемыми
  background/foreground (default `accentSoft / accentDeep`).

### Общие виджеты
- **`background_widget.dart`** — `Scaffold(bg)` + `SafeArea(bottom: false)`
  + опциональный `appBar` / `bottomBar`. Платформенная ветка
  `bottom: !Platform.isIOS` убрана; поведение выровнено для iOS и Android
  (B-035 закрыт).
- **`app_bar_widget.dart`** — round-back-кнопка + title + опциональные
  leading/subtitle/trailing (использует `AppShadows.s`).
- **`rounded_button.dart`** — обёртка над `ElevatedButton` без вложенного
  `InkWell` (B-030 закрыт).
- **`sign_in_button.dart`** — карточка-кнопка для Google/Apple (icon
  asset + label + кастомный `backgroundColor`/`textColor`).
- **`dialogs/{message,confirmation,modal}_dialog.dart`** — переоформлены
  под warm стиль; `ModalDialog` остаётся базой для двух остальных.
- **`divider_with_text.dart`** — горизонтальный divider с текстом по
  центру (используется в Auth: «или через»).
- **`permissions/permissions_service.dart`** — singleton (фактически
  не вызывается; разрешения запрашиваются напрямую в `HomePage` и
  `FcmCubit`).

### Утилиты
- **`utils/code_extractor.dart`** — `CodeExtractor.extract(text)` для
  поиска OTP-кодов (cue-words + 4–8-значный numeric pattern, чтобы
  не цеплять номера заказов).
- **`extensions.dart`** — `formatRelativeShort()`, `formatChatDivider()`,
  `formatTime()`, `formatDateTime()` для дат.

### Существующее, но фактически не используется
- **`screens/common/cubit_list_view.dart` (`CubitListView`)** — после
  редизайна ни один экран его больше не подключает (Messages/Devices
  переписаны на собственные `BlocBuilder` + `ListView.builder`).
- **`screens/widget/custom_progress_indicator.dart`** — не вызывается
  ни из одного места после удаления старого `DeviceInfoWidget` API.
- **`AvatarWithIndicator`** теперь рисует буквенный аватар на цвете из
  `avatarPalette` + опциональный platform-бейдж в углу
  (без SVG-заглушки `profile.svg`).

---

## Что отсутствует как экран / функциональность

| Отсутствует | Приоритет |
|-------------|-----------|
| Экран «Edit Profile» | средний |
| Экран «Language» (gen-l10n с EN/RU) | высокий |
| Экран «Push Notification» (управление) | средний |
| Поток «Forgot Password» — базовый готов (e-mail reset), UI отдельного экрана — желателен | низкий |
| Экран «Onboarding» (что такое Simply, зачем нужны права) | высокий |
| Экран «No network / offline» | средний |
| Реальный backend для категорий conversation (`category` уже в модели, но populating нет) | низкий |
| Настройки уведомлений per-sender | низкий |
| Экран статистики (сколько SMS переслано) | низкий |
| Темная тема (warm-палитра пока только light) | средний |
