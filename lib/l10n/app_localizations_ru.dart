// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Simply';

  @override
  String get settingsHeaderEyebrow => 'Аккаунт и приложение';

  @override
  String get settings => 'Настройки';

  @override
  String get profile => 'Профиль';

  @override
  String get profileEditButton => 'Редактировать профиль';

  @override
  String get profileEditing => 'Редактирование';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsSubtitle => 'Push, звуки, тихие часы';

  @override
  String get language => 'Язык';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get contactUs => 'Связаться с нами';

  @override
  String get logout => 'Выйти из аккаунта';

  @override
  String get logoutConfirmation => 'Выйти из аккаунта?';

  @override
  String get logoutConfirmButton => 'Выйти';

  @override
  String get cancel => 'Отмена';

  @override
  String get devices => 'Устройства';

  @override
  String get messages => 'Сообщения';

  @override
  String get name => 'Имя';

  @override
  String get email => 'Email';

  @override
  String get memberSince => 'С нами';

  @override
  String get user => 'Пользователь';

  @override
  String get noEmail => 'Без почты';

  @override
  String get profileNameSubtitle => 'Имя, аватар, контактные данные';

  @override
  String get simpplyPremium => 'Simply Premium';

  @override
  String get premiumDescription => 'Снимите лимиты на устройства и историю.';

  @override
  String get open => 'Открыть';

  @override
  String get account => 'Аккаунт';

  @override
  String get help => 'Помощь';

  @override
  String get madeWithLove => 'Создано с любовью weeidl';

  @override
  String get code => 'Код';

  @override
  String get coming => 'Скоро';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get codes => 'Коды';

  @override
  String get banks => 'Банки';

  @override
  String get delivery => 'Доставка';

  @override
  String get filters => 'Фильтры';

  @override
  String get select => 'Выбрать';

  @override
  String get delete => 'Удалить';

  @override
  String get readAll => 'Прочитать все';

  @override
  String get deleteAll => 'Удалить все';

  @override
  String get deleteTitle => 'Удаление';

  @override
  String get deleteConfirmation => 'Удалить выбранные диалоги?';

  @override
  String deleteConfirmationSingle(String name) {
    return 'Удалить диалог $name?';
  }

  @override
  String get messagesWillDisappear => 'Сообщения исчезнут из этого списка.';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get keep => 'Оставить';

  @override
  String get selectedConversationsDeleted => 'Выбранные диалоги удалены';

  @override
  String get conversationDeleted => 'Диалог удалён';

  @override
  String get failedToDelete => 'Не удалось удалить диалог';

  @override
  String get noMessages => 'Сообщений нет';

  @override
  String get failedToLoad => 'Не удалось загрузить';

  @override
  String get retry => 'Повторить';

  @override
  String get copy => 'Копировать';

  @override
  String get copySender => 'Скопировать адрес отправителя';

  @override
  String get senderCopied => 'Отправитель скопирован';

  @override
  String get codeCopied => 'Код скопирован';

  @override
  String get hideHint => 'Скрыть подсказку';

  @override
  String get howSimplyWorks => 'Как работает Simply';

  @override
  String get codeFromMessage => 'Код из сообщения';

  @override
  String source(String label) {
    return 'Источник: $label';
  }

  @override
  String get noCodes => 'Кодов не найдено';

  @override
  String get noDelivery => 'Нет сообщений о доставке';

  @override
  String get noBanks => 'Нет сообщений от банков';

  @override
  String get noDevices => 'Пока нет устройств';

  @override
  String get addDevicesHint =>
      'Подключите Android как отправителя или iPhone как устройство только для приёма.';

  @override
  String get addButton => 'Добавить';

  @override
  String get editDevice => 'Настройки устройства';

  @override
  String get newDevice => 'Новое устройство';

  @override
  String get save => 'Сохранить';

  @override
  String get smsForwarding => 'Отправка SMS';

  @override
  String get networkDisplay => 'Показ сети';

  @override
  String get batteryLevel => 'Уровень заряда';

  @override
  String get networkTypeInfo =>
      'В карточке отобразится тип сети и качество сигнала';

  @override
  String get batteryInfo =>
      'В разделе «Устройства» появится текущий уровень заряда';

  @override
  String get allowForwarding =>
      'Разрешить пересылать сообщения с этого устройства';

  @override
  String get online => 'в сети';

  @override
  String get offline => 'не в сети';

  @override
  String get receiving => 'приём';

  @override
  String get online2 => 'в сети';

  @override
  String get receiveOnly => 'Только получает сообщения';

  @override
  String get protected => 'защищено';

  @override
  String get iphoneInfo =>
      'Для iPhone показываем только имя, платформу и статус устройства.';

  @override
  String get deleteDevice => 'Удалить устройство';

  @override
  String get deleteDeviceWarning =>
      'Устройство исчезнет из списка, но его можно будет подключить снова.';

  @override
  String lowBattery(int count) {
    return 'Низкий заряд · $count';
  }

  @override
  String lastSeen(String time) {
    return 'был $time';
  }

  @override
  String lastActivity(String time) {
    return 'Посл. $time';
  }

  @override
  String get lowBatteryStatus => 'низкий';

  @override
  String get mediumBatteryStatus => 'средний';

  @override
  String get normalBatteryStatus => 'в норме';

  @override
  String get waitingFirstSms => 'Ждём первое SMS';

  @override
  String get connectSender => 'Подключите отправителя';

  @override
  String get pinned => 'Закрепить развёрнутый вид';

  @override
  String get unpinned => 'Открепить развёрнутый вид';

  @override
  String get raiseAbove => 'Поднять выше';

  @override
  String get lowerBelow => 'Опустить ниже';

  @override
  String get reconnect => 'Переподключить';

  @override
  String get allDevices => 'ВСЕ УСТРОЙСТВА';

  @override
  String get personalData => 'ЛИЧНЫЕ ДАННЫЕ';

  @override
  String get categoryAuto => 'Категория автоматически определится из текста.';

  @override
  String get hello => 'Привет!';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get loginTab => 'Вход';

  @override
  String get signupTab => 'Регистрация';

  @override
  String get fullName => 'Имя';

  @override
  String get emailField => 'E-mail';

  @override
  String get password => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get signupButton => 'Создать аккаунт';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginError => 'Не получилось войти';

  @override
  String get signupError => 'Не получилось создать аккаунт';

  @override
  String get resetPasswordSent => 'Ссылка для сброса пароля отправлена';

  @override
  String get resetPasswordError => 'Не удалось отправить письмо';

  @override
  String get quickStart => 'Несколько секунд — и вы в Simply';

  @override
  String get loginDescription => 'Войдите, чтобы продолжить пересылку SMS';

  @override
  String get permissions =>
      'Выберите, какие данные показывать в приложении и какие функции активировать.';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get saveProfile => 'Профиль обновлён';

  @override
  String get saveError => 'Не удалось сохранить, попробуйте позже';

  @override
  String get changeEmailInfo => 'Изменить email можно через поддержку.';

  @override
  String get contactUsTitle => 'Связаться с нами';

  @override
  String get contactUsDescription =>
      'Выберите удобный способ связи — мы ответим в рабочее время.';

  @override
  String get website => 'Сайт';

  @override
  String get social => 'Соцсети';

  @override
  String get team => 'Команда';

  @override
  String get privacyWhat => 'Что будет в политике';

  @override
  String get privacyDataCollected => 'Какие данные собираются';

  @override
  String get privacyDataUsage => 'Как они используются';

  @override
  String get privacyYourRights => 'Ваши права и контроль';

  @override
  String get privacySecurity => 'Меры безопасности и шифрование';

  @override
  String get privacyContact => 'Контакты для запросов';

  @override
  String get documentPlaceholder =>
      'Готовим документ. Пока это заглушка — не используйте приложение в публичных каналах.';

  @override
  String get search => 'Поиск по сообщениям';

  @override
  String get today => 'СЕГОДНЯ';

  @override
  String get allRead => 'Всё прочитано';

  @override
  String get noNewMessages => 'Новых сообщений нет.';

  @override
  String get notFound => 'Ничего не найдено';

  @override
  String get tryChangingQuery =>
      'Попробуйте изменить запрос или сбросить фильтр.';

  @override
  String get yourSms => 'Здесь будут ваши SMS';

  @override
  String get hereAfterNotifications =>
      'Они появятся здесь, когда придут на устройство.';

  @override
  String get hereWhenSmsArrives =>
      'Они появятся здесь, как только устройство получит SMS.';

  @override
  String get onContact => 'На связи';

  @override
  String get allLowercase => 'все';
}
