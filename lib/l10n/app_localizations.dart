import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Simply'**
  String get appTitle;

  /// Settings screen header eyebrow
  ///
  /// In en, this message translates to:
  /// **'Account & App'**
  String get settingsHeaderEyebrow;

  /// Settings tab label and screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile screen title and settings option
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Button to edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// Profile editing screen title
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get profileEditing;

  /// Notifications settings option
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Push, sounds, quiet hours'**
  String get notificationsSubtitle;

  /// Language settings option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// Russian language name
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// Privacy policy screen and settings option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Contact us screen and settings option
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// Logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Sign out of account?'**
  String get logoutConfirmation;

  /// Logout confirm button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutConfirmButton;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Devices tab label
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// Messages tab label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Contact method
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Member since field label
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Default text when email is empty
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Profile settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Name, avatar, contact info'**
  String get profileNameSubtitle;

  /// Premium banner title
  ///
  /// In en, this message translates to:
  /// **'Simply Premium'**
  String get simpplyPremium;

  /// Premium banner description
  ///
  /// In en, this message translates to:
  /// **'Remove limits on devices and history.'**
  String get premiumDescription;

  /// Open button
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Account section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Help section title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Footer text
  ///
  /// In en, this message translates to:
  /// **'Made with love by weeidl'**
  String get madeWithLove;

  /// Code label in messages list
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Coming soon badge
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming;

  /// Unread messages filter
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Codes filter
  ///
  /// In en, this message translates to:
  /// **'Codes'**
  String get codes;

  /// Banks filter
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get banks;

  /// Delivery filter
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// Filters label
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Select button
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Read all button
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get readAll;

  /// Delete all button
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTitle;

  /// Delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete selected conversations?'**
  String get deleteConfirmation;

  /// Delete single conversation confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete conversation {name}?'**
  String deleteConfirmationSingle(String name);

  /// Delete warning text
  ///
  /// In en, this message translates to:
  /// **'Messages will disappear from this list.'**
  String get messagesWillDisappear;

  /// Delete confirm button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Keep button
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// Toast message for multiple deletions
  ///
  /// In en, this message translates to:
  /// **'Selected conversations deleted'**
  String get selectedConversationsDeleted;

  /// Toast message for single deletion
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// Error toast when delete fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// Empty state for messages
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Copy sender tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy sender address'**
  String get copySender;

  /// Toast when sender is copied
  ///
  /// In en, this message translates to:
  /// **'Sender copied'**
  String get senderCopied;

  /// Toast when code is copied
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// Hide hint button
  ///
  /// In en, this message translates to:
  /// **'Hide hint'**
  String get hideHint;

  /// Section title in message details
  ///
  /// In en, this message translates to:
  /// **'How Simply Works'**
  String get howSimplyWorks;

  /// Section title in message details
  ///
  /// In en, this message translates to:
  /// **'Code from Message'**
  String get codeFromMessage;

  /// Source label in message details
  ///
  /// In en, this message translates to:
  /// **'Source: {label}'**
  String source(String label);

  /// Empty state for codes filter
  ///
  /// In en, this message translates to:
  /// **'No codes found'**
  String get noCodes;

  /// Empty state for delivery filter
  ///
  /// In en, this message translates to:
  /// **'No delivery messages'**
  String get noDelivery;

  /// Empty state for banks filter
  ///
  /// In en, this message translates to:
  /// **'No bank messages'**
  String get noBanks;

  /// Empty state for devices
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevices;

  /// Hint to add devices
  ///
  /// In en, this message translates to:
  /// **'Connect Android as a sender or iPhone as receive-only device.'**
  String get addDevicesHint;

  /// Add device button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// Device settings title
  ///
  /// In en, this message translates to:
  /// **'Edit Device'**
  String get editDevice;

  /// New device settings title
  ///
  /// In en, this message translates to:
  /// **'New Device'**
  String get newDevice;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Device setting
  ///
  /// In en, this message translates to:
  /// **'SMS Forwarding'**
  String get smsForwarding;

  /// Device setting
  ///
  /// In en, this message translates to:
  /// **'Network Display'**
  String get networkDisplay;

  /// Device setting
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// Device setting description
  ///
  /// In en, this message translates to:
  /// **'Card will show network type and signal quality'**
  String get networkTypeInfo;

  /// Device setting description
  ///
  /// In en, this message translates to:
  /// **'Device section will show current battery level'**
  String get batteryInfo;

  /// Device setting description
  ///
  /// In en, this message translates to:
  /// **'Allow SMS forwarding from this device'**
  String get allowForwarding;

  /// Device status online
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;

  /// Device status offline
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// Device status receiving
  ///
  /// In en, this message translates to:
  /// **'receiving'**
  String get receiving;

  /// Device status online variant
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online2;

  /// Device status
  ///
  /// In en, this message translates to:
  /// **'Receive only'**
  String get receiveOnly;

  /// Device protection status
  ///
  /// In en, this message translates to:
  /// **'protected'**
  String get protected;

  /// iPhone limitation info
  ///
  /// In en, this message translates to:
  /// **'For iPhone we only show name, platform and device status.'**
  String get iphoneInfo;

  /// Delete device button
  ///
  /// In en, this message translates to:
  /// **'Delete Device'**
  String get deleteDevice;

  /// Delete device warning
  ///
  /// In en, this message translates to:
  /// **'The device will disappear from the list, but can be reconnected later.'**
  String get deleteDeviceWarning;

  /// Low battery indicator
  ///
  /// In en, this message translates to:
  /// **'Low battery · {count}'**
  String lowBattery(int count);

  /// Last seen indicator
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(String time);

  /// Last activity indicator
  ///
  /// In en, this message translates to:
  /// **'Last activity {time}'**
  String lastActivity(String time);

  /// Low battery status label
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get lowBatteryStatus;

  /// Medium battery status label
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get mediumBatteryStatus;

  /// Normal battery status label
  ///
  /// In en, this message translates to:
  /// **'normal'**
  String get normalBatteryStatus;

  /// Device status when waiting for first message
  ///
  /// In en, this message translates to:
  /// **'Waiting for first SMS'**
  String get waitingFirstSms;

  /// Device status when sender needed
  ///
  /// In en, this message translates to:
  /// **'Connect sender'**
  String get connectSender;

  /// Pin device action
  ///
  /// In en, this message translates to:
  /// **'Pin expanded view'**
  String get pinned;

  /// Unpin device action
  ///
  /// In en, this message translates to:
  /// **'Unpin expanded view'**
  String get unpinned;

  /// Device action
  ///
  /// In en, this message translates to:
  /// **'Raise above'**
  String get raiseAbove;

  /// Device action
  ///
  /// In en, this message translates to:
  /// **'Lower below'**
  String get lowerBelow;

  /// Device action
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// Device section header
  ///
  /// In en, this message translates to:
  /// **'ALL DEVICES'**
  String get allDevices;

  /// Personal data section header
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DATA'**
  String get personalData;

  /// Category info
  ///
  /// In en, this message translates to:
  /// **'Category will be auto-determined from the text.'**
  String get categoryAuto;

  /// Auth screen greeting for login
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// Auth screen greeting for signup
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Login tab label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTab;

  /// Signup tab label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTab;

  /// Full name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Email field placeholder
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailField;

  /// Password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// Signup button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupButton;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in'**
  String get loginError;

  /// Signup error message
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get signupError;

  /// Success message after password reset
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get resetPasswordSent;

  /// Error when sending reset password email
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email'**
  String get resetPasswordError;

  /// Quick start message on splash
  ///
  /// In en, this message translates to:
  /// **'A few seconds — and you\'re in Simply'**
  String get quickStart;

  /// Login screen description
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue forwarding SMS'**
  String get loginDescription;

  /// Permissions description
  ///
  /// In en, this message translates to:
  /// **'Choose what data to display in the app and which features to enable.'**
  String get permissions;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// Success toast when profile is saved
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get saveProfile;

  /// Error toast when save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save, please try again'**
  String get saveError;

  /// Email change info
  ///
  /// In en, this message translates to:
  /// **'Change email through support.'**
  String get changeEmailInfo;

  /// Contact us screen title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// Contact us screen description
  ///
  /// In en, this message translates to:
  /// **'Choose a convenient way to contact us — we\'ll respond during business hours.'**
  String get contactUsDescription;

  /// Contact method
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Contact method
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get social;

  /// Team section
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// Privacy policy section title
  ///
  /// In en, this message translates to:
  /// **'What will be in the policy'**
  String get privacyWhat;

  /// Privacy policy bullet point
  ///
  /// In en, this message translates to:
  /// **'What data is collected'**
  String get privacyDataCollected;

  /// Privacy policy bullet point
  ///
  /// In en, this message translates to:
  /// **'How it is used'**
  String get privacyDataUsage;

  /// Privacy policy bullet point
  ///
  /// In en, this message translates to:
  /// **'Your rights and control'**
  String get privacyYourRights;

  /// Privacy policy bullet point
  ///
  /// In en, this message translates to:
  /// **'Security and encryption measures'**
  String get privacySecurity;

  /// Privacy policy bullet point
  ///
  /// In en, this message translates to:
  /// **'Contact for requests'**
  String get privacyContact;

  /// Privacy policy placeholder text
  ///
  /// In en, this message translates to:
  /// **'Preparing document. This is a placeholder — do not use in public channels.'**
  String get documentPlaceholder;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get search;

  /// Date group header
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// Filter state
  ///
  /// In en, this message translates to:
  /// **'All Read'**
  String get allRead;

  /// Filter state description
  ///
  /// In en, this message translates to:
  /// **'No new messages.'**
  String get noNewMessages;

  /// Search empty state
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get notFound;

  /// Search empty state description
  ///
  /// In en, this message translates to:
  /// **'Try changing your query or reset the filter.'**
  String get tryChangingQuery;

  /// Empty state when no devices are set up
  ///
  /// In en, this message translates to:
  /// **'Your SMS will appear here'**
  String get yourSms;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'They will appear here after notifications arrive.'**
  String get hereAfterNotifications;

  /// Empty state description for codes
  ///
  /// In en, this message translates to:
  /// **'They will appear here as soon as the device receives SMS.'**
  String get hereWhenSmsArrives;

  /// Device status
  ///
  /// In en, this message translates to:
  /// **'On Contact'**
  String get onContact;

  /// All devices label
  ///
  /// In en, this message translates to:
  /// **'all'**
  String get allLowercase;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
