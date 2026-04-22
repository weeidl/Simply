# Simply — Полная карта экранов и их содержимого

Цель документа — описать КАЖДЫЙ экран приложения, что в нём отображается,
какие действия доступны пользователю и какая логика за ним стоит. Используйте
как «компас» при доработке.

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
- Пустой `Scaffold` с `CircularProgressIndicator()` (material-стандарт, без кастома).
- Установка `SystemUiOverlayStyle` (белая системная панель).

### Логика
- `SplashCubit` подписан на `FirebaseAuth.authStateChanges()`.
- При `AuthAuthenticated` → `HomePage.route()` через `pushReplacement` + запуск
  `CheckDeviceCubit.checkDevice()`.
- При `AuthUnauthenticated` → `AuthScreen.route()` через `pushReplacement`
  (Splash больше не остаётся в стеке — B-007 закрыт).

### Недостатки UX
- Нет логотипа приложения (есть `assets/simply.png` и `assets/flash.png`, но не
  используются здесь).
- При первом запуске видно дефолтный индикатор Flutter → выглядит непрофессионально.

---

## 2. AuthScreen (Login / Register)
**Файл:** `lib/screens/auth/screen/auth_screen.dart`

### UI
- Оранжевый фон сверху, белая скруглённая карточка снизу.
- Заголовок: «Welcome back!» / «Welcome!» (меняется в зависимости от вкладки).
- Подзаголовок: «First you need to log in…» / «To get started, create your account».
- **CustomSegmentedControl**: две вкладки — `Login` / `Register`.
- Поля формы:
  - В режиме Register: `Full Name` (Icons.person).
  - `E-Mail` (Icons.email).
  - `Password` (Icons.lock) — маскируется по умолчанию; кнопка «глаз» появляется
    только при фокусе.
- «Forget password?» — на вкладке Login, ✅ кликабелен, триггерит
  `AuthCubit.sendPasswordReset()` → `FirebaseAuth.sendPasswordResetEmail`.
  Если e-mail пустой/невалидный — показывается SnackBar с подсказкой.
- Кнопка `Login` / `Register` (зелёная).
- Разделитель «Or auth with».
- Кнопки `Google`, `Apple` — **заглушки** (`onPressed: () {}`).

### Действия
- Переключение вкладки — `cubit.setSegmentedControlState`.
- Отправка формы:
  - Клиентская валидация: email-regex, `password.length >= 6`, для Register
    дополнительно non-empty name (`AuthCubit._validate`).
  - Login → `cubit.signIn()` → `FirebaseAuth.signInWithEmailAndPassword`.
  - Register → `cubit.signUp()` → создание пользователя +
    `user.updateDisplayName` + запись в `users/{uid}`
    `{name, email, createdAt}`.
  - На успехе: `Navigator.pushAndRemoveUntil(HomePage.route(), (_) => false)`.
  - На ошибке: `MessageDialog.show(cubit.state.authErrorMessage)`;
    `FirebaseAuthException.code` отображается как читаемый текст
    (`Wrong email or password`, `Account with this email already exists`, …)
    через `_mapAuthError`.

### Что ещё можно улучшить
- Focus на пароле показывает кнопку «глаз» только пока поле в фокусе — мелкий
  баг UX.
- `TextEditingController` живёт в `AuthState`, `Equatable` не используется —
  `BlocBuilder` перерисует всё на каждое изменение (оптимизация второго порядка).
- Google / Apple login — всё ещё заглушки.

---

## 3. HomePage (корневой экран после логина)
**Файл:** `lib/screens/home/home.dart`

### UI
- Scaffold с цветом фона, зависящим от вкладки (оранжевый для Messages, белый
  для остальных).
- Кастомный bottom-nav из трёх `GestureDetector` — Devices / Message / Settings.
- Тело — `_tabs[_selectedIndex]`.

### Логика
- `initState` → `requestPermissions()` запрашивает `Permission.sms` и
  `Permission.notification` (на Android; на iOS — no-op). Результат sms
  логируется, UX не блокирует доступ в приложение.
- Слушает `CheckDeviceCubit` → при `showModal` открывает
  `DeviceSettingsModal`.

### Проблемы
- Все три вкладки монтируются одновременно и не переиспользуют `PageView`/
  `IndexedStack` — при переключении состояние не сохраняется (но т.к. все
  используют singleton-cubit из MultiBlocProvider, это условно работает).
- Нет `dispose` у `_tabs`.

---

## 4. DevicesScreen (вкладка 0)
**Файл:** `lib/screens/devices/screen/devices_screen.dart`

### UI
- Заголовок «Devices».
- Кнопка «+» (оранжевая) — ✅ открывает `DeviceSettingsModal.show()`
  (без `device` = добавить / настроить текущее устройство).
- Список `DeviceWidget` для каждого устройства пользователя.
- Pull-to-refresh подгружает актуальные данные.

### DeviceWidget / DeviceInfoWidget
- Картинка (android.png / iphone.png) — выбирается по `device.platform`
  (единый источник правды в `DeviceInfoWidget._imageAsset`).
- Название устройства.
- «SMS is being sent» — если `isMainDevice`.
- «Last seen: <время>» — если есть `dateUpdateInfo`.
- Круговой прогресс «Charge» — если есть `batteryLevel` (с `.clamp(0, 100)`).
- **Бейдж сети** (`_NetworkBadge`) — если есть `networkType`: иконка +
  тип сети (LTE / 5G / …) в pill-стиле. Магические 80% удалены (B-011 закрыт).
- Иконка `touch_app` — если нет ни заряда, ни сети.
- По тапу → `DeviceSettingsModal.show(device: ...)`.

### Состояния (DeviceStatus)
Enum почищен: `initial / loading / loaded / empty / error`.
- `initial` → `fetch()` триггерится из `initState` через
  `WidgetsBinding.addPostFrameCallback` (больше не из `build()`).
- `loading` → `SpinKitFadingCube`.
- `empty` → `_EmptyDevicesView` («No devices yet» + подсказка).
- `error` → `_ErrorView` с кнопкой Retry.
- `loaded` → `ListView` с `RefreshIndicator`.

---

## 5. MessagesListScreen (вкладка 1, default)
**Файл:** `lib/screens/messages_list/screen/messages_list_screen.dart`

### UI
- `BackgroundWidget` (оранжевый header + белый контент со скруглённым верхом).
- `AppBarWidget`: заголовок «Messages», иконка «people» (без действия).
- `BlocBuilder<MessagesListCubit, MessagesListState>`:
  - `placeHolder`: `NoMessagesAvailable` (SVG + текст).
  - `itemBuilder`: `MessagesListWidget` на каждую переписку-отправителя.

### MessagesListWidget
- `AvatarWithIndicator`:
  - Если `unreadMessagesCount == null` — аватар-заглушка (SVG profile).
  - Иначе — **рамка-кружок с числом** (без аватара → непонятный UX).
- Название (номер/имя отправителя).
- Дата последнего сообщения (`formatDateTime`).
- Текст последнего сообщения (maxLines=2).
- По тапу → `MessageDetailsScreen`; unread-счётчик сбрасывается через Firestore
  и приезжает обратно в UI уже из live stream.

### Обновление данных
- Список диалогов подписан на Firestore `snapshots()`.
- `RefreshIndicator` оставлен как ручной re-subscribe / retry.

### Текущее состояние
- Live-обновление между устройствами работает.
- Unread/read синхронизируется через Firestore, а не через локальный `setState`.
- Пагинация в этом экране пока убрана в пользу более простого и надёжного live flow.

---

## 6. MessageDetailsScreen (переписка с одним отправителем)
**Файл:** `lib/screens/message_details/screen/message_details_screen.dart`

### UI
- `BackgroundWidget` с заголовком = имя отправителя.
- Список `MessageDetailsWidget` (без аватаров, без группировки).
- Поле ввода ответа **отсутствует** (это не мессенджер, только просмотр).

### MessageDetailsWidget
- Дата сообщения (`formatFullDateTime`).
- «Пузырь» со светло-серым фоном, текст слева.
- **Авто-детект 6-значных кодов** (`\b\d{6}\b`) — выделяются оранжевым,
  по тапу копируются в буфер + SnackBar.
- `IntrinsicWidth` + `maxWidth` не ограничен — длинное сообщение рвёт вёрстку.

### Проблемы
- Список идёт сверху вниз (descending=true) — для мессенджера ожидаемо
  наоборот (новые снизу, `reverse: true` — закомментировано).
- Нет индикатора «нет сообщений» для редкого кейса.
- Regex `\b\d{6}\b` срабатывает на любые 6 цифр (номер заказа, сумма), ложные
  срабатывания — надо уточнить эвристику.

---

## 7. DeviceSettingsModal (bottom-sheet)
**Файл:** `lib/screens/devices/settings/device_settings_modal.dart` + `device_settings_widget.dart`

### UI
- Bottom-sheet, высота 85% экрана (95% на маленьких экранах).
- Заголовок «Setting Device» + подсказка.
- Три `BuildSwitchTile`:
  1. **Sending SMS** — назначить устройство «главным».
  2. **Display network** — показывать сеть в `Devices`.
  3. **Charging level** — показывать заряд в `Devices`.
- Кнопка **Save** (зелёная).
- Кнопка **Delete Device** (розовая, видна только если редактируем существующее
  устройство).

### Логика
- `CheckDeviceCubit.saveSettingDevice` читает актуальные `battery`/`network`
  и сохраняет через `DeviceRepository.addBatteryAndNetworkStatus`.
- **ПРОБЛЕМА**: `device.id` на Android (Build.ID) меняется при обновлении
  прошивки → одно и то же устройство может появиться дважды. На iOS
  `identifierForVendor` тоже может меняться при переустановке.

---

## 8. SettingsScreen (вкладка 2)
**Файл:** `lib/screens/settings/settings_screen.dart`

### UI
- Header с оранжевым фоном:
  - Круглый аватар (SVG-заглушка).
  - ✅ Имя из `FirebaseAuth.currentUser.displayName` (fallback:
    `user.email` → `'User'`). Захардкоженное «Artur Rustamov» удалено.
  - ✅ Под именем — настоящий `email` пользователя.
  - Кнопка logout (SVG).
- Список пунктов меню (`SettingWidget` — text + SVG + стрелка, поддерживает
  флаг `comingSoon`, который добавляет pill-бейдж «Soon» и приглушает цвет):
  - **Edit Profile** — помечен Soon.
  - **Language** — помечен Soon.
  - **Push Notification** — помечен Soon.
  - **Privacy Policy** — открывает экран-заглушку.
  - **Contact Us** — открывает контактный экран.
- Подпись «Created by © Weeidl».

### Logout
- `ConfirmationDialog` → `SharedPreferences.setBool('is_new_device', true)` +
  `splashCubit.signOut()` → `pushAndRemoveUntil(AuthScreen.route())`.
  ✅ Больше не пересоздаём корневой `MyApp` (B-008 закрыт).

---

## 9. PrivacyPolicyScreen
**Файл:** `lib/screens/privacy_policy/screen/privacy_policy_screen.dart`

### UI
- «Coming Soon» + информационный блок о том, что будет в политике.
- Текст политики **отсутствует** — блокер для публикации в App Store / Google Play.

---

## 10. ContactUsScreen
**Файл:** `lib/screens/contact_us/screen/contact_us_screen.dart`

### UI
- Три карточки (email, сайт, соц-сети) — открываются через `url_launcher`.
- Блок «Our Team» с одним членом команды.

### Проблемы
- URL захардкожены (`weeidlone@gmail.com`, `weeidl.com`,
  `https://www.instagram.com/weeidl`).
- ✅ `launchUrl` теперь не бросает Exception: при ошибке показывается
  SnackBar «Could not open $url» (B-024 закрыт). Вызов идёт с
  `LaunchMode.externalApplication`.

---

## 11. DeviceSettingsModal: первый запуск
**Триггер**: `CheckDeviceCubit.checkDevice()` вызывается из `SplashScreen`
при успешной авторизации. Если в `SharedPreferences` нет флага
`is_new_device` (или он == true) И платформа — Android → модалка открывается.

### Поток
1. Сохраняется базовая инфо об устройстве (userId, deviceId, deviceName, platform).
2. Ставится `is_new_device = false`.
3. Открывается модалка настроек.

### Проблемы
- На iOS модалка не открывается (`return` после Platform.isIOS), но запись
  в Firestore уже сделана — **iOS-устройство будет в списке как «обычное»**,
  что корректно, но...
- Если пользователь удалит приложение и поставит заново — `is_new_device`
  удаляется, а запись устройства в Firestore уже есть → **перезапишется
  `isMainDevice` в то значение, что пришло из UI** (всегда `true` по умолчанию
  при новой модалке) → может «украсть» главную роль у другого устройства.

---

## 12. Компоненты, которые переиспользуются

- **BackgroundWidget** (`lib/screens/widget/background_widget.dart`) —
  оранжевый header + белый контент. На iOS SafeArea снизу не применяется
  (`bottom: !Platform.isIOS`). ✅ Файл переименован из `bacgraund_widget.dart`.
- **AppBarWidget** — заголовок + опциональная кнопка back (`size: 20` — B-036)
  и иконка people.
- **RoundedButton** — ✅ обёртка над `ElevatedButton` без лишнего `InkWell`
  (двойной gesture устранён, B-030 закрыт).
- **CubitListView<T, C>** — универсальный список с пагинацией, refresh,
  placeholder'ом и спиннером.
- **ConfirmationDialog / MessageDialog / ModalDialog** — 3 разных диалога,
  но `ModalDialog` используется в обоих — переплетённое API с 10+ опциональных
  параметров (план упростить в Итерации 2).
- **PermissionsService** — singleton для запроса разрешений (но фактически
  нигде не вызывается; разрешения запрашиваются напрямую в `HomePage` и
  `FcmCubit`).
- **SettingWidget** — row с иконкой/заголовком/стрелкой; параметр
  `comingSoon` рисует пилюлю «Soon» и делает элемент некликабельным.
- **NoMessagesAvailable** — placeholder 64×64 SVG + текст (размер SVG был
  не задан — B-037 закрыт).

---

## Что отсутствует как экран / функциональность

| Отсутствует | Приоритет |
|-------------|-----------|
| Экран «Edit Profile» | средний |
| Экран «Language» (i18n) | высокий |
| Экран «Push Notification» (управление) | средний |
| Поток «Forgot Password» — базовый готов (e-mail reset), UI отдельного экрана — желателен | низкий |
| Экран «Onboarding» (что такое Simply, зачем нужны права) | высокий |
| Экран «No network / offline» | средний |
| Поиск по сообщениям | низкий |
| Фильтр по отправителю | низкий |
| Настройки уведомлений per-sender | низкий |
| Экран статистики (сколько SMS переслано) | низкий |
| Шифрование сообщений end-to-end | КРИТИЧЕСКИЙ (см. SECURITY S-001) |
