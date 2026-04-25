// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Simply';

  @override
  String get settingsHeaderEyebrow => 'Account & App';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get help => 'Help';

  @override
  String get madeWithLove => 'Made with love by weeidl';

  @override
  String get profile => 'Profile';

  @override
  String get profileEditButton => 'Edit Profile';

  @override
  String get profileEditing => 'Editing';

  @override
  String get profileNameSubtitle => 'Name, avatar, contact info';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get memberSince => 'Member Since';

  @override
  String get user => 'User';

  @override
  String get noEmail => 'No email';

  @override
  String get yourName => 'Your name';

  @override
  String get saveProfile => 'Profile updated';

  @override
  String get saveError => 'Failed to save, please try again';

  @override
  String get profileNameEmptyError => 'Name cannot be empty';

  @override
  String get profileSessionExpiredError =>
      'Session expired, please sign in again';

  @override
  String get changeEmailInfo => 'Change email through support.';

  @override
  String get personalData => 'PERSONAL DATA';

  @override
  String get protected => 'protected';

  @override
  String get language => 'Language';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get languageChangedHint => 'Language will change immediately';

  @override
  String get languageChangedDesc =>
      'All text in the app will be displayed in the selected language.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Push, sounds, quiet hours';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyWhat => 'What will be in the policy';

  @override
  String get privacyDataCollected => 'What data is collected';

  @override
  String get privacyDataUsage => 'How it is used';

  @override
  String get privacyYourRights => 'Your rights and control';

  @override
  String get privacySecurity => 'Security and encryption measures';

  @override
  String get privacyContact => 'Contact for requests';

  @override
  String get documentPlaceholder =>
      'Preparing document. This is a placeholder — do not use in public channels.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsTitle => 'Get in Touch';

  @override
  String get contactUsDescription =>
      'Choose a convenient way to contact us — we\'ll respond during business hours.';

  @override
  String get mailContact => 'Email';

  @override
  String get website => 'Website';

  @override
  String get social => 'Social Media';

  @override
  String get team => 'Team';

  @override
  String get failedToOpenLink => 'Failed to open link';

  @override
  String get simpplyPremium => 'Simply Premium';

  @override
  String get premiumDescription => 'Remove limits on devices and history.';

  @override
  String get open => 'Open';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirmation => 'Sign out of account?';

  @override
  String get logoutConfirmButton => 'Sign Out';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get coming => 'Coming Soon';

  @override
  String get retry => 'Retry';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get copy => 'Copy';

  @override
  String get devices => 'Devices';

  @override
  String get devicesEyebrowEmpty => 'Connect your first phone';

  @override
  String devicesEyebrow(int count, int senders) {
    return '$count devices · $senders sending SMS';
  }

  @override
  String get allDevices => 'ALL DEVICES';

  @override
  String get mainBadge => 'MAIN';

  @override
  String get deviceActionsTooltip => 'Device Actions';

  @override
  String get online => 'online';

  @override
  String get offline => 'offline';

  @override
  String get receiving => 'receiving';

  @override
  String lastSeenAt(String time) {
    return 'was $time';
  }

  @override
  String get onlineFleetStatus => 'online';

  @override
  String offlineFleetCount(int count) {
    return '$count offline';
  }

  @override
  String get todayLabel => 'TODAY';

  @override
  String get batteryLabel => 'BATTERY';

  @override
  String get noData => 'no data';

  @override
  String get lowBatteryStatus => 'low';

  @override
  String get mediumBatteryStatus => 'medium';

  @override
  String get normalBatteryStatus => 'normal';

  @override
  String get autoSlot => 'auto';

  @override
  String get activeSimStatus => 'ACTIVE';

  @override
  String get readySimStatus => 'READY';

  @override
  String get receiveOnly => 'Receive only';

  @override
  String get iphoneInfo =>
      'For iPhone we only show name, platform and device status.';

  @override
  String get noDevices => 'No devices yet';

  @override
  String get addDevicesHint =>
      'Connect Android as a sender or iPhone as receive-only device.';

  @override
  String get addButton => 'Add';

  @override
  String get editDevice => 'Device Settings';

  @override
  String get newDevice => 'New Device';

  @override
  String get permissions =>
      'Choose what data to display in the app and which features to enable.';

  @override
  String get smsForwarding => 'SMS Forwarding';

  @override
  String get allowForwarding => 'Allow SMS forwarding from this device';

  @override
  String get networkDisplay => 'Network Display';

  @override
  String get networkTypeInfo =>
      'Card will show network type and signal quality';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get batteryInfo => 'Device section will show current battery level';

  @override
  String get deleteDevice => 'Delete Device';

  @override
  String get deleteDeviceWarning =>
      'The device will disappear from the list, but can be reconnected later.';

  @override
  String get deviceConfirmTitle => 'Device';

  @override
  String deleteDeviceFromList(String name) {
    return 'Delete $name from devices?';
  }

  @override
  String lowBattery(int count) {
    return 'Low battery · $count';
  }

  @override
  String lastActivity(String time) {
    return 'Last $time';
  }

  @override
  String get waitingFirstSms => 'Waiting for first SMS';

  @override
  String get connectSender => 'Connect sender';

  @override
  String get pinned => 'Pin expanded view';

  @override
  String get unpinned => 'Unpin expanded view';

  @override
  String get raiseAbove => 'Raise above';

  @override
  String get lowerBelow => 'Lower below';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get delete => 'Delete';

  @override
  String get messages => 'Messages';

  @override
  String messagesEyebrowArchive(int count) {
    return '$count in archive';
  }

  @override
  String messagesEyebrowUnread(int count) {
    return '$count new · today';
  }

  @override
  String get yourSms => 'Your SMS will appear here';

  @override
  String get search => 'Search messages';

  @override
  String get allFilter => 'All';

  @override
  String get unread => 'Unread';

  @override
  String get codes => 'Codes';

  @override
  String get banks => 'Banks';

  @override
  String get delivery => 'Delivery';

  @override
  String get filters => 'Filters';

  @override
  String get select => 'Select';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get readAll => 'Read All';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get markedReadToast => 'Selected conversations marked as read';

  @override
  String get conversationActionsSheet => 'Message Actions';

  @override
  String get conversationSelectedToast => 'Conversation selected';

  @override
  String get deleteTitle => 'Delete';

  @override
  String get deleteConfirmation => 'Delete selected conversations?';

  @override
  String selectedDialogsDisappear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations will disappear from the list.',
      one: '1 conversation will disappear from the list.',
    );
    return '$_temp0';
  }

  @override
  String get deleteButton => 'Delete All';

  @override
  String get keep => 'Keep';

  @override
  String get selectedConversationsDeleted => 'Selected conversations deleted';

  @override
  String get failedToDeleteMany => 'Failed to delete conversations';

  @override
  String deleteConfirmationSingle(String name) {
    return 'Delete conversation $name?';
  }

  @override
  String get messagesWillDisappear => 'Messages will disappear from this list.';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get noMessages => 'No messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get hereWhenSmsArrives =>
      'They will appear here as soon as the device receives SMS.';

  @override
  String get allRead => 'All Read';

  @override
  String get noNewMessages => 'No new messages.';

  @override
  String get noCodes => 'No codes found';

  @override
  String get codesHint => 'One-time code messages will appear here.';

  @override
  String get noBanks => 'No bank messages';

  @override
  String get categoryAuto => 'Category will be auto-determined from the text.';

  @override
  String get noDelivery => 'No delivery messages';

  @override
  String get deliveryHint =>
      'They\'ll appear when courier notifications arrive.';

  @override
  String get notFound => 'Nothing found';

  @override
  String get tryChangingQuery => 'Try changing your query or reset the filter.';

  @override
  String get hereAfterNotifications =>
      'They will appear here after notifications arrive.';

  @override
  String get code => 'Code';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get copySender => 'Copy sender address';

  @override
  String get senderCopied => 'Sender copied';

  @override
  String get hideHint => 'Hide hint';

  @override
  String get howSimplyWorks => 'How Simply Works';

  @override
  String get howSimplyWorksBody =>
      'Simply forwards SMS from the device and automatically copies found codes to clipboard.';

  @override
  String get codeFromMessage => 'Code from Message';

  @override
  String source(String label) {
    return 'Source: $label';
  }

  @override
  String get smsFromIphone => 'SMS · from iPhone';

  @override
  String get smsFromAndroid => 'SMS · from Android';

  @override
  String get hello => 'Hello!';

  @override
  String get createAccount => 'Create Account';

  @override
  String get loginTab => 'Sign In';

  @override
  String get signupTab => 'Sign Up';

  @override
  String get fullName => 'Name';

  @override
  String get emailField => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get signupButton => 'Create Account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginError => 'Failed to sign in';

  @override
  String get signupError => 'Failed to create account';

  @override
  String get loginErrorMessage => 'Failed to sign in';

  @override
  String get signupErrorMessage => 'Failed to create account';

  @override
  String get resetPasswordSent => 'Password reset link sent';

  @override
  String get resetPasswordError => 'Failed to send reset email';

  @override
  String get quickStart => 'A few seconds — and you\'re in Simply';

  @override
  String get loginDescription => 'Sign in to continue forwarding SMS';

  @override
  String get today => 'TODAY';

  @override
  String get allLowercase => 'all';

  @override
  String get justNow => 'just now';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String hoursShort(int count) {
    return '$count h';
  }

  @override
  String get yesterdayLowercase => 'yesterday';

  @override
  String todayAtTime(String time) {
    return 'Today · $time';
  }

  @override
  String yesterdayAtTime(String time) {
    return 'Yesterday · $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date · $time';
  }

  @override
  String get splashSubtitle => 'SMS forwarding between devices';

  @override
  String get permissionRequiredTitle => 'Permission Required';

  @override
  String permissionRequiredMessage(String permissionName) {
    return 'To function correctly, the app requires access to $permissionName. Please grant access.';
  }

  @override
  String get permissionPermanentlyDeniedTitle =>
      'Permission Permanently Denied';

  @override
  String permissionPermanentlyDeniedMessage(String permissionName) {
    return 'You have permanently denied access to $permissionName. Please grant access in the app settings.';
  }

  @override
  String get openSettings => 'Open Settings';

  @override
  String permissionRestrictedMessage(String permissionName) {
    return 'Access to $permissionName is restricted.';
  }

  @override
  String get copied => 'Copied';
}
