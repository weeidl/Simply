# Simply — Execution Plan

Последнее обновление: **2026-04-22**

Этот файл нужен как практический план следующей серии правок. Он не заменяет
`03_BUGS_AND_ISSUES.md`, `04_SECURITY_AUDIT.md` и `05_ARCHITECTURE_IMPROVEMENTS.md`,
а собирает в одном месте именно те задачи, которые сейчас дают максимальный
выигрыш по стабильности, архитектуре и удобству дальнейшей разработки.

## Цели этой серии

1. Убрать локальный `UpdateMessageStream` и перейти на real-time обновление через
   Firestore snapshots.
2. Синхронизировать между устройствами не только новые сообщения, но и статус
   `read / unread`.
3. Стабилизировать идентичность устройства (`deviceId`) и сделать flow
   настройки устройства безопасным.
4. Привести жизненный цикл `FcmCubit` к корректной инициализации только после
   входа в аккаунт.
5. Закрыть несколько маленьких structural-долгов, пока код ещё компактный.

## Порядок выполнения

### Wave 1 — Messages first

Это первый и самый полезный блок. Он даёт live-обновления и одновременно
готовит код к дальнейшему росту.

- [x] Заменить `UpdateMessageStream` на Firestore `snapshots()`.
- [x] Сделать live-refresh списка диалогов между устройствами.
- [x] Сделать live-refresh экрана диалога между устройствами.
- [x] Синхронизировать `unread_messages_count` между устройствами без локального
      `setState`-обмана в ячейке списка.
- [x] Перевести запись входящего SMS на транзакционный сценарий:
      preview диалога + запись самого сообщения.
- [x] Переименовать модели:
      `Messages` → `Conversation`,
      `MessageDetails` → `Message`.
- [x] Удалить `lib/bloc/update_message_stream.dart`, если после рефакторинга он
      больше не нужен.

**Ожидаемый результат:** новое SMS, открытие диалога и сброс unread-счётчика
видны на другом устройстве без ручного refresh.

**Статус:** выполнено в текущем заходе. Для обратной совместимости со старой
историей сообщений поле даты пока оставлено в текущем формате хранения; полная
миграция на server timestamps, если понадобится, должна идти отдельным шагом.

### Wave 2 — Stable device identity

- [x] Ввести стабильный локально сохранённый `deviceId`, не зависящий от
      `androidInfo.id` / `identifierForVendor`.
- [x] Хранить этот `deviceId` в безопасном локальном storage.
- [x] Переписать `CheckDeviceCubit`, чтобы он не обращался к Android API на iOS.
- [x] Добавить `await` на сохранения устройства в Firestore.
- [x] Сделать flow first-run / edit-device предсказуемым и безопасным.
- [x] Подготовить базу под будущую защиту `main device` rewrite.

**Ожидаемый результат:** переустановка, обновление прошивки и повторный вход не
создают ложные новые устройства и не ломают привязку.

**Статус:** выполнено в текущем заходе. Stable device identity переехал в
`flutter_secure_storage`, first-run modal теперь стартует из `HomePage`, а
`DeviceRepository` безопаснее переключает `main device`.

### Wave 3 — Lifecycle and small structural fixes

- [x] Переинициализировать `FcmCubit` только в auth-валидной части приложения.
- [x] Убрать eager-init `FcmCubit` из корневого `MyApp`.
- [x] Перевести `HomePage` на `IndexedStack`, чтобы вкладки не зависели от
      побочных эффектов повторного монтирования.
- [x] Подправить `BackgroundWidget`/`SafeArea`, чтобы layout вел себя
      предсказуемо на всех экранах.

**Статус:** `FcmCubit` уже переведён в auth-scoped часть через `HomePage.route()`.
`IndexedStack` и `BackgroundWidget` SafeArea тоже уже применены.

**Ожидаемый результат:** чище жизненный цикл, меньше скрытых гонок, меньше
случайных ребилдов и монтажных эффектов.

### Wave 4 — Deferred, but prepared by previous work

- [ ] DI через `RepositoryProvider`.
- [ ] Дальнейшее упрощение list/cubit abstractions после перехода на streams.
- [ ] Дальнейшая чистка security и rules после стабилизации основного data flow.

## Какие файлы затронет ближайший заход

### Message flow

- `lib/repositories/messages_repository.dart`
- `lib/screens/messages_list/cubit/messages_list_cubit.dart`
- `lib/screens/message_details/cubit/message_details_cubit.dart`
- `lib/screens/messages_list/widget/messages_list_widget.dart`
- `lib/screens/messages_list/screen/messages_list_screen.dart`
- `lib/screens/message_details/screen/message_details_screen.dart`
- `lib/screens/message_details/widget/message_details_widget.dart`
- `lib/bloc/notification/background_message.dart`
- `lib/screens/home/cubit/fcm_cubit.dart`
- `lib/models/conversation.dart`
- `lib/models/message.dart`

### Device flow

- `lib/screens/devices/add_new_device/check_device_cubit.dart`
- `lib/repositories/device_repository.dart`
- `lib/models/device.dart`
- локальный storage/helper для стабильного `deviceId`

### App lifecycle / shell

- `lib/main.dart`
- `lib/screens/home/home.dart`
- `lib/screens/widget/background_widget.dart`

## Принципы выполнения

- Не трогать release-only задачи, если они не мешают текущей стабильности.
- Не усложнять ради абстракций раньше времени.
- Сначала убирать источники скрытого рассинхрона, потом косметику.
- Документация должна обновляться только по факту реально сделанных правок.

## Статус

Wave 1, Wave 2 и Wave 3 закрыты. Security/device продолжение вынесено в
`08_SECURITY_DEVICE_PLAN.md`.
