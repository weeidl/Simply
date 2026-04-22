# Simply — Баги, проблемы и доработки

Документ структурирован по приоритету. Каждый пункт — **что не так**, **где**
(файл:строка) и **что делать**. При исправлении обновляйте статус.

Обозначения: 🔴 критично · 🟠 важно · 🟡 средне · 🟢 косметика.

Статусы: без пометки — open; `✅ FIXED (итерация N)` — закрыто. См.
оперативный журнал в `06_FIX_PROGRESS.md`.

Актуализация: статусы ниже синхронизированы с текущим локальным состоянием
репозитория. Если проблема закрыта лишь частично, это явно отмечено в тексте.

## Сводка Итерации 1 (закрыто)

🔴 B-001, B-002, B-006, B-007, B-008 · 🟠 B-010, B-011, B-012, B-013, B-014,
B-016, B-017, B-018, B-019, B-020, B-021, B-024, B-025 · 🟡 B-030, B-031,
B-032, B-036, B-037, B-038, B-041, B-043 · 🟢 B-050.
Частично закрыто: B-033, B-047, B-048, B-049. Security: S-005 (частично).

Добавлен отдельный раздел Android-toolchain: переход на Gradle 8.7 / AGP 8.6.0
/ Kotlin 2.1.0 / Java 17 (устранял ошибку `Unsupported class file major version 65`
от Java 21 в Android Studio).

## Сводка Итерации 2 (закрыто)

🔴 B-051 (фоновые SMS не доходили до приложения — fixed 2026-04-22).

---

## 🔴 Критичные баги логики

### B-001. Двойной/неконтролируемый инкремент `unread_messages_count` · ✅ FIXED (итерация 1)
**Файл**: `lib/models/messages.dart:24`
```dart
'unread_messages_count': FieldValue.increment(1),
```
`Messages.toJson()` жёстко встраивает `increment(1)` в каждую запись. При
`sendMessageFirebase()` (`lib/repositories/messages_repository.dart:65`) этот
JSON пишется в `messages/{address}` с `merge: true`. Всё нормально, пока
это новое сообщение. Но если использовать `Messages.toJson()` где-то ещё
(например, для `addMessagesBackground`) — счётчик инкрементируется без смысла.

**Как исправить**: вынести инкремент из модели в репозиторий
(метод `sendMessageFirebase` должен явно собирать map с `increment(1)`).
Модель должна быть POCO-DTO.

---

### B-002. Дубликаты сообщений в `MessagesListCubit.initStream` · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/messages_list/cubit/messages_list_cubit.dart:21`
```dart
void initStream() {
  UpdateMessageStream.stream.listen((event) async {
    final response = await messagesRepository.fetchMessages();
    emit(state.copyWith(
      items: [...state.items, ...response.items],   // ❌ конкатенация к старому
      lastDocument: response.lastDocument,          // ❌ сбивает пагинацию
      ...
    ));
  });
}
```
При получении нового SMS мы заново грузим первую страницу и клеим к старому
списку — каждое сообщение из первой страницы появится дважды.

**Актуально**: в текущем коде `MessagesListCubit` уже заменяет `items`
свежим ответом (`items: response.items`), а не конкатенирует его со старым
списком. Переход на `Firestore.snapshots()` всё ещё остаётся отдельной задачей
из B-003.

---

### B-003. Нет live-обновления на других устройствах
**Файл**: `lib/bloc/update_message_stream.dart` + `messages_list_cubit.dart`

`UpdateMessageStream` — это `StreamController.broadcast()` **внутри процесса**.
Он срабатывает только когда SMS приходит на устройство с запущенным приложением.
На iPhone, который читает переписку Android-устройства, новые сообщения
появляются только после pull-to-refresh.

**Как исправить**: перейти на `FirebaseFirestore.snapshots()` в
`MessagesRepository.fetchMessages` (вернуть `Stream<PaginatedResponse>` или
отдельный `watchMessages()`), в cubit держать Firestore-подписку.

---

### B-004. `FcmCubit` не регистрируется для приёма push-ов, нет VAPID/APNs сетапа
**Файл**: `lib/screens/home/cubit/fcm_cubit.dart`

`FirebaseMessaging.instance.requestPermission()` вызывается, но:
- `FirebaseMessaging.onMessage.listen(...)` отсутствует → push-уведомления
  пропадают без следа.
- `onBackgroundMessage` регистрируется в `main.dart`, но хендлер — пустая
  функция.
- Токен FCM (`getToken()`) никуда не сохраняется → на сервере нечем таргетить.

**Как исправить**: полноценный pipeline FCM — сохранить токен в
`devices/{uid}/items/{deviceId}.token`, подписать `onMessage`, `onMessageOpenedApp`,
реализовать показ сообщения через `flutter_local_notifications`.

---

### B-005. Release-сборка подписана debug-ключом
**Файл**: `android/app/build.gradle:60`
```
signingConfig signingConfigs.debug
```
**Приложение нельзя публиковать в Google Play**. Любой, имеющий ваш APK,
может выпустить «обновление» с тем же подписью.

**Как исправить**: создать `key.properties`, добавить в `.gitignore`,
настроить release-signing.

---

### B-051. Фоновые SMS не попадали в приложение · ✅ FIXED (итерация 2)
**Файлы**: `lib/bloc/notification/background_message.dart`, `lib/main.dart`.

Три независимых бага в одном месте:

1. **`FirebaseAuth.instance.currentUser` был null в фоновом изоляте.**
   `another_telephony` запускает `onBackgroundMessage` в отдельном Dart-изоляте.
   Сразу после `Firebase.initializeApp()` `currentUser` ещё не гидратирован из
   нативного SDK, поэтому `FirebaseApi.userId` возвращал null. Путь Firestore
   собирался как `user_messages/null/messages/...` вместо
   `user_messages/<uid>/messages/...`. Записи не падали (`firestore.rules`
   разрешал всё), но UI читает из правильного uid и сообщения «исчезали».

2. **Отсутствовал `@pragma('vm:entry-point')`.** В release-сборке tree-shaker
   может вырезать top-level callback, который вызывается из нативного кода.

3. **Firestore-вызовы без `await`.** Фоновый изолят могли убить до того, как
   запись дойдёт до сервера.

**Как исправлено**: полный рерайт `background_message.dart` с
`@pragma('vm:entry-point')`, ожиданием `authStateChanges().firstWhere((u) =>
u != null)` с 5-сек таймаутом, явной сборкой пути через `user.uid`, `await`
на всех Firestore-вызовах. `@pragma('vm:entry-point')` также добавлен к
`_firebaseMessagingBackground` в `main.dart`.

**Как проверить регрессию**: свернуть приложение, отправить тестовую SMS,
убедиться что запись попала в `user_messages/<твой-uid>/messages/...`, а не
в `user_messages/null/...`.

---

### B-006. `.idea/` и `.flutter-plugins-dependencies` в git · ✅ FIXED (итерация 1)
**Файл**: `.gitignore` — есть строка `.idea/`, но файлы могли попасть
в историю раньше. Исторически `.flutter-plugins-dependencies` был закоммичен.

**Актуально**: локально `.flutter-plugins-dependencies` ещё может существовать
как игнорируемый артефакт Flutter, но в индекс git файл больше не входит; `.idea/`
тоже не трекается.

---

## 🟠 Важные баги

### B-007. `SplashScreen` использует `push` (не `pushReplacement`) для `AuthScreen` · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/splash/splash_screen.dart:26`

При logout / перелогине Splash остаётся в стеке навигации, при back с
AuthScreen пользователь возвращается на крутящийся индикатор.

**Как исправить**: `Navigator.pushReplacement(context, AuthScreen.route())`.

---

### B-008. Logout: `MyApp` вложен в `MaterialApp` · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/settings/settings_screen.dart:33-39`
```dart
navigator.pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const MyApp()), // ❌ MyApp внутри MaterialApp
  (route) => false,
);
```
Создаётся вложенный `MaterialApp` → двойные `Theme`, double `Navigator`,
неопределённое поведение при deep-link.

**Как исправить**: после logout навигировать на `SplashScreen` или сразу
`AuthScreen.route()`; корневой `MyApp` не трогать.

---

### B-009. `fetch()` в `build()` — анти-паттерн
**Файл**:
- `lib/screens/common/cubit_list_view.dart:38-40`

В `DevicesScreen` этот анти-паттерн уже убран: initial-fetch перенесён в
`initState`. Но `CubitListView` всё ещё вызывает `context.read<C>().fetch()`
прямо внутри `build()`. Если состояние вернётся в `initial`, это может дать
повторный запрос и лишние ребилды.

**Как исправить**: вызывать `fetch()` один раз в `initState` соответствующего
StatefulWidget или в конструкторе cubit-а (как сделано в
`MessagesListCubit`/`MessageDetailsCubit`).

---

### B-010. `DeviceInfoWidget.imageDevice()` определяет платформу по имени · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/devices/widget/device_info_widget.dart:19-25`
```dart
if (device.deviceName == 'iPhone 15') return 'iphone.png';
else return 'android.png';
```
Любой iPhone, кроме «iPhone 15», покажется как Android-устройство. А в
`device_widget.dart:12-18` логика другая — по `device.platform`. **Два места
конфликтуют**.

**Как исправить**: оставить проверку по `device.platform == 'ios'`.

---

### B-011. `CustomProgressIndicator` для Mobile data всегда 80% · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/devices/widget/device_info_widget.dart:78-82`
```dart
CustomProgressIndicator(
  textProgress: device.networkType!,
  title: 'Mobile data',
  progress: 80,   // ❌ магическое число
),
```
Реальная сила сигнала не передаётся. Либо показывать только тип сети
(LTE / 5G), либо читать `signalStrength`.

---

### B-012. `DeviceState.empty` показывает спиннер · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/devices/screen/devices_screen.dart:72-78`

Для пустого списка показывается тот же `SpinKitFadingCube`, что и для
`loading` / `initial` → бесконечный «грузится» для пользователя без устройств.

**Как исправить**: добавить placeholder «No devices yet» + CTA «Add your phone».

---

### B-013. Кнопка «+» на DevicesScreen без обработчика · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/devices/screen/devices_screen.dart:34-36`
```dart
onPressed: () async {
  // context.read<DeviceCubit>().updateInfoMainDevice();
},
```
Пустой callback — UX-фантом. Пользователь не может добавить устройство
вручную; единственный способ — поставить приложение на другое устройство
и авторизоваться.

---

### B-014. «Forget password?» не кликается · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/auth/screen/auth_screen.dart:139-146`

Текст обёрнут в обычный `Text`, без `GestureDetector`/`InkWell`.

---

### B-015. Google / Apple login-кнопки — заглушки
**Файл**: `lib/screens/auth/screen/auth_screen.dart:208, 216`
```dart
onPressed: () {},
```
Реальная интеграция (`google_sign_in`, `sign_in_with_apple`) не подключена,
хотя в маркетинге она «есть».

---

### B-016. Нет валидации email / password · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/auth/cubit/auth_cubit.dart`

Пустые строки отправляются в Firebase, ошибка ловится в `catch (e)` и
показывается общее «Failed to sign in». Пользователь не видит причины.

**Как исправить**: валидация regexp на клиенте + показ реального
`FirebaseAuthException.code` (`user-not-found`, `wrong-password`,
`email-already-in-use`…).

---

### B-017. `AuthCubit.signUp` не записывает пользователя в `users` коллекцию · ✅ FIXED (итерация 1)
**Файл**: `auth_cubit.dart:39-57`

Имя сохраняется только в `displayName` Firebase Auth. Если потом понадобится
показать Full Name на `SettingsScreen` — данных нет. В `SettingsScreen`
имя вообще **захардкожено**.

**Как исправить**: после `createUserWithEmailAndPassword` вызвать
`firebaseApi.setUserData(uid, {name, email, createdAt})`.

---

### B-018. Имя пользователя захардкожено на `SettingsScreen` · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/settings/settings_screen.dart:74`
```dart
Text('Artur Rustamov', ...)
```
Это фамилия автора. **Показывается всем пользователям приложения**.

---

### B-019. `DeviceRepository.fetch()` помечен `Future<List<Device>>?` (nullable-future) · ✅ FIXED (итерация 1)
**Файл**: `lib/repositories/device_repository.dart:45`
```dart
Future<List<Device>>? fetch() async { ... }
```
Future сам по себе не может быть null у async-функции. Сигнатура сбивает с толку
и ломает type-safety для вызывающих.

---

### B-020. `DeviceRepository.getTokensForAllDevices` не фильтрует по userId · ✅ FIXED (итерация 1)
**Файл**: `lib/repositories/device_repository.dart:22-43`

Метод принимает `userId`, но внутри использует `_firebaseApi.itemsCollection`,
которая привязывается к **текущему авторизованному** `userId`. Параметр
игнорируется. Название метода тоже вводит в заблуждение («all devices»
подразумевает все устройства всех пользователей).

---

### B-021. `FirebaseApi.currentUser` кэширует `User`, но не чистит при смене · ✅ FIXED (итерация 1)
**Файл**: `lib/repositories/firebase_api.dart:9-17`

`_cachedUser` устанавливается в `get currentUser` и в `signIn`, сбрасывается
в `signOut`. Но `FirebaseApi` создаётся в каждом репозитории **новым
экземпляром** (`DeviceRepository` / `MessagesRepository`) → кэши не
синхронизированы. Проще использовать `_auth.currentUser` без кэша.

---

### B-022. `CheckDeviceCubit` может затереть `isMainDevice` другого устройства
**Файл**: `lib/screens/devices/add_new_device/check_device_cubit.dart:20-35`

Логика «если `is_new_device == null || true`» → при каждой переустановке
приложения вызывается модалка с `isSMSEnabled = true` по умолчанию, и при
save другое устройство теряет статус «главного» не автоматически — но
пользователь может его отметить по ошибке.

**Хуже**: комментарий в коде (строки 30-31):
```
// Проверить есть ли is_new_device в фаербейс, если нет то выводим модалку
// если маин девайс есть но нет сети и зарядки выводить кнопку ...
```
показывает, что логика **недоделана**: должна быть проверка на сервере,
а её нет.

---

### B-023. `deviceId` может меняться
**Файл**: `check_device_cubit.dart:67-90`

- Android: `androidInfo.id` — это `Build.ID` (прошивка). Меняется при
  обновлении ОС → создаются дубликаты.
- iOS: `identifierForVendor` меняется при переустановке приложения (если
  удалены все приложения от этого вендора).

**Как исправить**: сгенерировать UUID при первом запуске и сохранить в
`SharedPreferences`.

---

### B-024. `ContactUsScreen._launchUrl` бросает Exception · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/contact_us/screen/contact_us_screen.dart:18-23`

`throw Exception('Could not launch $url')` в async-колбэке без обработки →
необработанный Future-error, может упасть в crashlytics или повесить UI.

**Как исправить**: showSnackBar с сообщением об ошибке.

---

### B-025. `Workmanager` зарегистрирован, но задача пустая · ✅ FIXED (итерация 1)
**Файл**: `lib/main.dart:19-26, 34`
```dart
Workmanager().executeTask((task, inputData) async {
  // if (task == "sendFirebaseMessageTask") { ... }
  return Future.value(true);
});
```
Задача `sendFirebaseMessageTask` регистрируется в `FcmCubit._scheduleBackgroundTask`
(интервал 15 минут), но ничего не делает. Бесполезно жрёт батарею.

**Актуально**: регистрация `Workmanager` удалена из Dart-кода и пакет убран из
`pubspec.yaml`. После следующего полного refresh platform lockfiles стоит ещё
проверить, что stale references исчезли из iOS/desktop артефактов.

---

### B-026. Нет `FlutterLocalNotifications` канала для Android 13+
**Файл**: `fcm_cubit.dart:41-52`

На Android 13+ нужно запросить `Permission.notification`. Канал уведомлений
(`foreground_channel_id`) создаётся неявно. Пользователь на Android 13+
не увидит уведомление, если откажет в разрешении (сейчас код не проверяет).

---

### B-027. Foreground-service объявлен, но не запускается
**Файл**: `AndroidManifest.xml:51-54`

`<service android:name=".ForegroundService" .../>` — но такого класса в
`android/app/src/main/kotlin` **нет** (не приложено). При попытке запустить
Foreground service — краш.

**Проверить**: `ls android/app/src/main/kotlin/com/weeidl/simply/`

---

## 🟡 Средние проблемы

### B-028. `StandardListCubit.fetch` дважды вызывается на старте
Первый раз — из конструктора (`MessagesListCubit` строка 17 `fetch()`).
Второй — из `CubitListView` при `state.isInitial`. Фактически блокируется
race-condition'ом в `emit(loading)`, но оба запроса уходят к Firestore.

---

### B-029. `CubitListView.paginate` уходит в `hasNext: false` при пустой странице
**Файл**: `standard_list_cubit.dart:44-52`

Если первая страница не пустая, а вторая — пустая, `hasNext: hasNewItems`
ставит false. Но тогда `lastDocument` сохраняется старый → при `refresh()`
`hasNext` снова сбрасывается на `items.isNotEmpty` (не учитывая пагинацию).
Логика шаткая.

---

### B-030. `RoundedButton` создаёт вложенные `InkWell` + `ElevatedButton` · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/widget/rounded_button.dart:45-47`
```dart
InkWell(
  onTap: onPressed != null ? () {} : null,   // ❌ пустой handler
  child: ElevatedButton(onPressed: onPressed, ...)
)
```
`InkWell` с пустым `onTap` ловит ripple, но не даёт `ElevatedButton`
отобразить свой — визуальная каша, двойной «нажим».

**Как исправить**: убрать `InkWell`.

---

### B-031. Две несовместимые «системы» текстовых стилей · ✅ FIXED (итерация 1)
**Файлы**: `lib/themes/text_style.dart` (используется везде),
`lib/themes/app_typography.dart` (2 стиля, не используется нигде).

Выбрать одно, второе удалить.

---

### B-032. Комментарий `telephony` с абсолютным путём к локальной папке · ✅ FIXED (итерация 1)
**Файл**: `pubspec.yaml:41-42`
```yaml
#  telephony:
#    path: "/Users/weeidl/Documents/telephony"
```
Это утечка инфы о workspace автора. Удалить.

---

### B-033. Неиспользуемые зависимости — частично закрыто
**Файл**: `pubspec.yaml`
- Уже удалены из `pubspec.yaml`: `grpc`, `flutter_background_service`,
  `google_fonts`, `firebase_storage`, `workmanager`.
- `auto_size_text: 3.0.0` всё ещё используется на `AuthScreen`, так что это
  уже не «мёртвая» зависимость.
- `cupertino_icons: ^1.0.2` по-прежнему остаётся кандидатом на удаление, если
  проект окончательно не использует Cupertino-иконки.

Каждая зависимость = +размер бандла + риск CVE. Удалить лишнее.

---

### B-034. `flutter_lints: ^2.0.0` — устаревший
При SDK Flutter 3.24 рекомендуется `flutter_lints: ^5.0.0`.

---

### B-035. `BackgroundWidget` отключает `bottom SafeArea` на iOS
**Файл**: `lib/screens/widget/background_widget.dart:19`
```dart
bottom: !Platform.isIOS,
```
Текущий код отключает нижний `SafeArea` не на Android, а на iOS. Это значит,
что на iPhone контент может оказаться слишком близко к home indicator.

---

### B-036. `AppBarWidget` — `weight: 24` на Icon · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/widget/app_bar_widget.dart:33`

`Icon.weight` — для variable fonts. Для `Icons.arrow_back_ios` (стандартный
Material) неэффективно. Вероятно, имели в виду `size`.

---

### B-037. `NoMessagesAvailable` — размер SVG не задан · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/widget/place_holder/no_messages_available.dart:15-21`

`SvgPicture.asset` без `width`/`height` → может рендериться огромным.

---

### B-038. Опечатка `bacgraund_widget.dart` · ✅ FIXED (итерация 1)
**Файл**: `lib/screens/widget/background_widget.dart`

Правильно — `background_widget.dart`. Переименовать + обновить импорты.

---

### B-039. Устаревшие `Key? key` / `super(key: key)`
Во многих файлах используется старый стиль (`Key? key, this.x, ... : super(key: key)`).
В Dart 3 это `super.key`. Привести к единообразию (уже частично сделано).

---

### B-040. `formatDateTime()` ломается на будущих датах
**Файл**: `lib/extensions.dart:3-23`

`difference = now.difference(this)` для `this > now` даст отрицательные минуты.
`difference.inMinutes < 1` сработает и будущее сообщение покажется как
«Just now». Маловероятно, но возможно при рассинхроне часов.

---

### B-041. `SettingsScreen` — пункты-заглушки без визуального признака «скоро» · ✅ FIXED (итерация 1)
Edit Profile / Language / Push Notification не кликаются. Пользователь
тапает и ничего не происходит → фрустрация.

---

### B-042. `PrivacyPolicyScreen` = «Coming Soon»
Блокер для публикации в App Store / Google Play. Любое приложение, собирающее
SMS, ДОЛЖНО иметь политику конфиденциальности. Иначе — reject.

---

### B-043. Все тексты на английском, один — на русском · ✅ FIXED (итерация 1)
**Файл**: `lib/repositories/device_repository.dart:40`
```dart
log("Произошла ошибка при получении токенов устройств: $e");
```
Смесь языков в логах. Логи — тоже часть продукта при краш-репортах.

---

### B-044. Нет обработки HTTP-таймаутов / офлайна
Firestore-операции без `timeout()`. При плохой сети UI висит бесконечно.

---

### B-045. Нет тестов
Папки `test/` и `integration_test/` отсутствуют. В проекте ~30 файлов —
минимум unit-тесты на `StandardListCubit`, `AuthCubit`, экстеншены.

---

### B-046. `CubitListView` не диспозит `ScrollController`, если `widget.controller` — свой
**Файл**: `cubit_list_view.dart:107-112`

Логика `if (widget.controller == null)` корректна, но сама проверка
некорректно в `didUpdateWidget` — если пользователь передаст/сбросит
controller в рантайме, `_scrollController` не обновится.

---

## 🟢 Косметика

### B-047. Опечатки и смешанная кириллица/латиница в комментариях
- `check_device_cubit.dart:27-28` — русский код-комментарий всё ещё остался.
- Русский лог в `device_repository.dart` уже исправлен, но issue целиком ещё
  не закрыт из-за оставшихся комментариев.

---

### B-048. Много закомментированного кода — частично закрыто
- Уже удалены/почищены: `lib/screens/home/widget/app_bottom_bar.dart`,
  старые комментарии из `lib/main.dart` и `device_info_widget.dart`.
- Остались мелкие фрагменты, например `// errorText: ...` в
  `auth_screen.dart`, `// Replace with a suitable one Place Holder` и
  `// reverse: true,` в `message_details_screen.dart`, `// Icon(` в `home.dart`.

Удалить или перенести в issue.

---

### B-049. Несогласованные названия — частично закрыто
- `Messages` (модель переписки) vs `MessageDetails` (одно сообщение) —
  интуитивно наоборот и пока остаётся в коде.
- `bacgraund_widget.dart` уже переименован в `background_widget.dart`.
- `DeviceCubit.updateDevice` всё ещё обновляет список, а не одно устройство,
  поэтому имя метода остаётся неудачным.

---

### B-050. README пустой · ✅ FIXED (итерация 1)
**Файл**: `README.md` — стандартный Flutter-бойлерплейт. Для
open-source / передачи проекта — заменить описанием (см. `01_PRODUCT_OVERVIEW.md`).

---

## Предлагаемые новые фичи (рост продукта)

| Фича | Польза | Сложность |
|------|--------|-----------|
| End-to-end encryption (AES-256 с ключом из пароля) | критично для SMS (OTP-коды утекают в plaintext через Firestore) | S+ |
| Push-уведомление при новом SMS на iPhone | ключевой UX (сейчас надо открыть приложение) | M |
| Push-ответ («копировать код» прямо из нотификации) | — | M |
| Белый/чёрный список отправителей | приватность | S |
| Мульти-SIM поддержка | Android-specific | M |
| Экспорт SMS в CSV/JSON | аналитика | S |
| Веб-интерфейс на Firebase Hosting | доступ с ПК | L |
| Темная тема | UX | S |
| i18n (EN / RU) | рынок | M |
| Поиск по сообщениям | UX | S |
| Двухфакторка (TOTP) | безопасность | M |

---

## Сводка по файлам (исторический аудит, часть пунктов уже закрыта)

| Файл | Кол-во проблем |
|------|----------------|
| `models/messages.dart` | 1 крит |
| `messages_list_cubit.dart` | 1 крит |
| `update_message_stream.dart` | 1 крит |
| `fcm_cubit.dart` | 1 актуальный + 1 исторически закрытый (`push` pipeline остаётся, `Workmanager` удалён) |
| `settings_screen.dart` | 2 (логаут, хардкод имени) |
| `auth_screen.dart` | 4 (соцсети, forgot pass, валидация, UX) |
| `auth_cubit.dart` | 2 (нет users doc, нет error-codes) |
| `check_device_cubit.dart` | 4 (deviceId, iOS, недоделанная логика, isMainDevice) |
| `device_info_widget.dart` | 3 (дублирование, 80%, комментарии) |
| `device_repository.dart` | 3 (?, fetchAll, ru-лог) |
| `firebase_api.dart` | 2 (cache, dupe instance) |
| `cubit_list_view.dart` | 3 (fetch в build, dispose controller, pagination) |
| `rounded_button.dart` | 1 (двойной gesture) |
| `main.dart` | 1 актуальный + 1 исторически закрытый (`init FCM` неполный, `Workmanager` удалён) |
| `pubspec.yaml` | 5 (лишние deps, telephony коммент) |
| `AndroidManifest.xml` | 3 (дубль READ_PHONE_STATE, несуществующий сервис, location permission) |
| `build.gradle` | 1 (debug signing) |
| `PrivacyPolicyScreen` | 1 (блокер публикации) |
| `ContactUsScreen` | 1 (exception) |
| `background_widget.dart` | 1 (нижний `SafeArea` на iOS) |
| `extensions.dart` | 1 (future-dates) |

**Итого**: ≈ 50 обнаруженных проблем.
