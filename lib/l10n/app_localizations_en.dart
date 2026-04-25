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
  String get profile => 'Profile';

  @override
  String get profileEditButton => 'Edit Profile';

  @override
  String get profileEditing => 'Editing';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Push, sounds, quiet hours';

  @override
  String get language => 'Language';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirmation => 'Sign out of account?';

  @override
  String get logoutConfirmButton => 'Sign Out';

  @override
  String get cancel => 'Cancel';

  @override
  String get devices => 'Devices';

  @override
  String get messages => 'Messages';

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
  String get profileNameSubtitle => 'Name, avatar, contact info';

  @override
  String get simpplyPremium => 'Simply Premium';

  @override
  String get premiumDescription => 'Remove limits on devices and history.';

  @override
  String get open => 'Open';

  @override
  String get account => 'Account';

  @override
  String get help => 'Help';

  @override
  String get madeWithLove => 'Made with love by weeidl';

  @override
  String get code => 'Code';

  @override
  String get coming => 'Coming Soon';

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
  String get delete => 'Delete';

  @override
  String get readAll => 'Read All';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deleteTitle => 'Delete';

  @override
  String get deleteConfirmation => 'Delete selected conversations?';

  @override
  String deleteConfirmationSingle(String name) {
    return 'Delete conversation $name?';
  }

  @override
  String get messagesWillDisappear => 'Messages will disappear from this list.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get keep => 'Keep';

  @override
  String get selectedConversationsDeleted => 'Selected conversations deleted';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get noMessages => 'No messages';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get retry => 'Retry';

  @override
  String get copy => 'Copy';

  @override
  String get copySender => 'Copy sender address';

  @override
  String get senderCopied => 'Sender copied';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get hideHint => 'Hide hint';

  @override
  String get howSimplyWorks => 'How Simply Works';

  @override
  String get codeFromMessage => 'Code from Message';

  @override
  String source(String label) {
    return 'Source: $label';
  }

  @override
  String get noCodes => 'No codes found';

  @override
  String get noDelivery => 'No delivery messages';

  @override
  String get noBanks => 'No bank messages';

  @override
  String get noDevices => 'No devices yet';

  @override
  String get addDevicesHint =>
      'Connect Android as a sender or iPhone as receive-only device.';

  @override
  String get addButton => 'Add';

  @override
  String get editDevice => 'Edit Device';

  @override
  String get newDevice => 'New Device';

  @override
  String get save => 'Save';

  @override
  String get smsForwarding => 'SMS Forwarding';

  @override
  String get networkDisplay => 'Network Display';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get networkTypeInfo =>
      'Card will show network type and signal quality';

  @override
  String get batteryInfo => 'Device section will show current battery level';

  @override
  String get allowForwarding => 'Allow SMS forwarding from this device';

  @override
  String get online => 'online';

  @override
  String get offline => 'offline';

  @override
  String get receiving => 'receiving';

  @override
  String get online2 => 'online';

  @override
  String get receiveOnly => 'Receive only';

  @override
  String get protected => 'protected';

  @override
  String get iphoneInfo =>
      'For iPhone we only show name, platform and device status.';

  @override
  String get deleteDevice => 'Delete Device';

  @override
  String get deleteDeviceWarning =>
      'The device will disappear from the list, but can be reconnected later.';

  @override
  String lowBattery(int count) {
    return 'Low battery · $count';
  }

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String lastActivity(String time) {
    return 'Last activity $time';
  }

  @override
  String get lowBatteryStatus => 'low';

  @override
  String get mediumBatteryStatus => 'medium';

  @override
  String get normalBatteryStatus => 'normal';

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
  String get allDevices => 'ALL DEVICES';

  @override
  String get personalData => 'PERSONAL DATA';

  @override
  String get categoryAuto => 'Category will be auto-determined from the text.';

  @override
  String get hello => 'Hello!';

  @override
  String get createAccount => 'Create Account';

  @override
  String get loginTab => 'Sign In';

  @override
  String get signupTab => 'Sign Up';

  @override
  String get fullName => 'Full Name';

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
  String get resetPasswordSent => 'Password reset link sent';

  @override
  String get resetPasswordError => 'Failed to send password reset email';

  @override
  String get quickStart => 'A few seconds — and you\'re in Simply';

  @override
  String get loginDescription => 'Sign in to continue forwarding SMS';

  @override
  String get permissions =>
      'Choose what data to display in the app and which features to enable.';

  @override
  String get yourName => 'Your name';

  @override
  String get saveProfile => 'Profile updated';

  @override
  String get saveError => 'Failed to save, please try again';

  @override
  String get changeEmailInfo => 'Change email through support.';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get contactUsDescription =>
      'Choose a convenient way to contact us — we\'ll respond during business hours.';

  @override
  String get website => 'Website';

  @override
  String get social => 'Social Media';

  @override
  String get team => 'Team';

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
  String get search => 'Search messages';

  @override
  String get today => 'TODAY';

  @override
  String get allRead => 'All Read';

  @override
  String get noNewMessages => 'No new messages.';

  @override
  String get notFound => 'Nothing found';

  @override
  String get tryChangingQuery => 'Try changing your query or reset the filter.';

  @override
  String get yourSms => 'Your SMS will appear here';

  @override
  String get hereAfterNotifications =>
      'They will appear here after notifications arrive.';

  @override
  String get hereWhenSmsArrives =>
      'They will appear here as soon as the device receives SMS.';

  @override
  String get onContact => 'On Contact';

  @override
  String get allLowercase => 'all';
}
