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

  /// Settings tab and screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

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

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// Profile editing screen title
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get profileEditing;

  /// Profile settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Name, avatar, contact info'**
  String get profileNameSubtitle;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Member since label
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Fallback when email is empty
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// Success toast when profile saved
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get saveProfile;

  /// Error toast when save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save, please try again'**
  String get saveError;

  /// Profile validation error when name is empty
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get profileNameEmptyError;

  /// Profile update error when user session is missing
  ///
  /// In en, this message translates to:
  /// **'Session expired, please sign in again'**
  String get profileSessionExpiredError;

  /// Email change info
  ///
  /// In en, this message translates to:
  /// **'Change email through support.'**
  String get changeEmailInfo;

  /// Personal data section header
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DATA'**
  String get personalData;

  /// Email locked badge
  ///
  /// In en, this message translates to:
  /// **'protected'**
  String get protected;

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

  /// Language selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// Info banner title on language screen
  ///
  /// In en, this message translates to:
  /// **'Language will change immediately'**
  String get languageChangedHint;

  /// Info banner body on language screen
  ///
  /// In en, this message translates to:
  /// **'All text in the app will be displayed in the selected language.'**
  String get languageChangedDesc;

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

  /// Privacy policy screen and settings option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy section title
  ///
  /// In en, this message translates to:
  /// **'What will be in the policy'**
  String get privacyWhat;

  /// Privacy policy bullet
  ///
  /// In en, this message translates to:
  /// **'What data is collected'**
  String get privacyDataCollected;

  /// Privacy policy bullet
  ///
  /// In en, this message translates to:
  /// **'How it is used'**
  String get privacyDataUsage;

  /// Privacy policy bullet
  ///
  /// In en, this message translates to:
  /// **'Your rights and control'**
  String get privacyYourRights;

  /// Privacy policy bullet
  ///
  /// In en, this message translates to:
  /// **'Security and encryption measures'**
  String get privacySecurity;

  /// Privacy policy bullet
  ///
  /// In en, this message translates to:
  /// **'Contact for requests'**
  String get privacyContact;

  /// Privacy policy placeholder text
  ///
  /// In en, this message translates to:
  /// **'Preparing document. This is a placeholder — do not use in public channels.'**
  String get documentPlaceholder;

  /// Contact us settings option
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Contact us screen heading
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get contactUsTitle;

  /// Contact us screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a convenient way to contact us — we\'ll respond during business hours.'**
  String get contactUsDescription;

  /// Contact method: email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get mailContact;

  /// Contact method: website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Contact method: social
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get social;

  /// Team section
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// Toast when URL fails to open
  ///
  /// In en, this message translates to:
  /// **'Failed to open link'**
  String get failedToOpenLink;

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

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// Logout confirmation text
  ///
  /// In en, this message translates to:
  /// **'Sign out of account?'**
  String get logoutConfirmation;

  /// Confirm logout button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutConfirmButton;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Coming soon badge
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// Copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Devices tab label
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// Devices header when no devices
  ///
  /// In en, this message translates to:
  /// **'Connect your first phone'**
  String get devicesEyebrowEmpty;

  /// Devices header eyebrow
  ///
  /// In en, this message translates to:
  /// **'{count} devices · {senders} sending SMS'**
  String devicesEyebrow(int count, int senders);

  /// Device section header
  ///
  /// In en, this message translates to:
  /// **'ALL DEVICES'**
  String get allDevices;

  /// Main device badge label
  ///
  /// In en, this message translates to:
  /// **'MAIN'**
  String get mainBadge;

  /// Device menu tooltip
  ///
  /// In en, this message translates to:
  /// **'Device Actions'**
  String get deviceActionsTooltip;

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

  /// Device receive-only status
  ///
  /// In en, this message translates to:
  /// **'receiving'**
  String get receiving;

  /// Last seen relative time
  ///
  /// In en, this message translates to:
  /// **'was {time}'**
  String lastSeenAt(String time);

  /// Fleet badge online label
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get onlineFleetStatus;

  /// Fleet badge offline count
  ///
  /// In en, this message translates to:
  /// **'{count} offline'**
  String offlineFleetCount(int count);

  /// Today stat label
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayLabel;

  /// Battery stat label
  ///
  /// In en, this message translates to:
  /// **'BATTERY'**
  String get batteryLabel;

  /// Battery no data label
  ///
  /// In en, this message translates to:
  /// **'no data'**
  String get noData;

  /// Low battery status
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get lowBatteryStatus;

  /// Medium battery status
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get mediumBatteryStatus;

  /// Normal battery status
  ///
  /// In en, this message translates to:
  /// **'normal'**
  String get normalBatteryStatus;

  /// Auto SIM slot label
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get autoSlot;

  /// Active SIM status
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeSimStatus;

  /// Ready SIM status
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get readySimStatus;

  /// Receive only device type
  ///
  /// In en, this message translates to:
  /// **'Receive only'**
  String get receiveOnly;

  /// iPhone limitation info
  ///
  /// In en, this message translates to:
  /// **'For iPhone we only show name, platform and device status.'**
  String get iphoneInfo;

  /// Empty state for devices
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevices;

  /// Empty devices hint
  ///
  /// In en, this message translates to:
  /// **'Connect Android as a sender or iPhone as receive-only device.'**
  String get addDevicesHint;

  /// Add device button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// Edit device title
  ///
  /// In en, this message translates to:
  /// **'Device Settings'**
  String get editDevice;

  /// New device title
  ///
  /// In en, this message translates to:
  /// **'New Device'**
  String get newDevice;

  /// Device settings description
  ///
  /// In en, this message translates to:
  /// **'Choose what data to display in the app and which features to enable.'**
  String get permissions;

  /// Device setting
  ///
  /// In en, this message translates to:
  /// **'SMS Forwarding'**
  String get smsForwarding;

  /// Device setting description
  ///
  /// In en, this message translates to:
  /// **'Allow SMS forwarding from this device'**
  String get allowForwarding;

  /// Device setting
  ///
  /// In en, this message translates to:
  /// **'Network Display'**
  String get networkDisplay;

  /// Device setting description
  ///
  /// In en, this message translates to:
  /// **'Card will show network type and signal quality'**
  String get networkTypeInfo;

  /// Device setting
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// Device setting description
  ///
  /// In en, this message translates to:
  /// **'Device section will show current battery level'**
  String get batteryInfo;

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

  /// Device deletion dialog title
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceConfirmTitle;

  /// Confirm delete device
  ///
  /// In en, this message translates to:
  /// **'Delete {name} from devices?'**
  String deleteDeviceFromList(String name);

  /// Low battery insight chip
  ///
  /// In en, this message translates to:
  /// **'Low battery · {count}'**
  String lowBattery(int count);

  /// Last activity chip
  ///
  /// In en, this message translates to:
  /// **'Last {time}'**
  String lastActivity(String time);

  /// Device awaiting first SMS
  ///
  /// In en, this message translates to:
  /// **'Waiting for first SMS'**
  String get waitingFirstSms;

  /// No sender connected chip
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

  /// Device reorder action
  ///
  /// In en, this message translates to:
  /// **'Raise above'**
  String get raiseAbove;

  /// Device reorder action
  ///
  /// In en, this message translates to:
  /// **'Lower below'**
  String get lowerBelow;

  /// Device reconnect action
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Messages tab label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Messages header when no unread
  ///
  /// In en, this message translates to:
  /// **'{count} in archive'**
  String messagesEyebrowArchive(int count);

  /// Messages header with unread count
  ///
  /// In en, this message translates to:
  /// **'{count} new · today'**
  String messagesEyebrowUnread(int count);

  /// Messages header when empty
  ///
  /// In en, this message translates to:
  /// **'Your SMS will appear here'**
  String get yourSms;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get search;

  /// All messages filter chip
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// Unread filter chip
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Codes filter chip
  ///
  /// In en, this message translates to:
  /// **'Codes'**
  String get codes;

  /// Banks filter chip
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get banks;

  /// Delivery filter chip
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// Filters sheet title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Select action
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Delete all button
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// Mark all read button
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get readAll;

  /// Selection bar count label
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Toast after marking read
  ///
  /// In en, this message translates to:
  /// **'Selected conversations marked as read'**
  String get markedReadToast;

  /// Conversation actions sheet barrier label
  ///
  /// In en, this message translates to:
  /// **'Message Actions'**
  String get conversationActionsSheet;

  /// Toast when conversation selected
  ///
  /// In en, this message translates to:
  /// **'Conversation selected'**
  String get conversationSelectedToast;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTitle;

  /// Delete confirmation text
  ///
  /// In en, this message translates to:
  /// **'Delete selected conversations?'**
  String get deleteConfirmation;

  /// Plural delete warning
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conversation will disappear from the list.} other{{count} conversations will disappear from the list.}}'**
  String selectedDialogsDisappear(int count);

  /// Confirm delete all button
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteButton;

  /// Keep button
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// Toast after multi delete
  ///
  /// In en, this message translates to:
  /// **'Selected conversations deleted'**
  String get selectedConversationsDeleted;

  /// Error toast multi delete
  ///
  /// In en, this message translates to:
  /// **'Failed to delete conversations'**
  String get failedToDeleteMany;

  /// Single conversation delete confirm
  ///
  /// In en, this message translates to:
  /// **'Delete conversation {name}?'**
  String deleteConfirmationSingle(String name);

  /// Single delete warning
  ///
  /// In en, this message translates to:
  /// **'Messages will disappear from this list.'**
  String get messagesWillDisappear;

  /// Toast after single delete
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// Error toast single delete
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// Empty messages state
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// Empty state for all messages filter
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Empty state hint
  ///
  /// In en, this message translates to:
  /// **'They will appear here as soon as the device receives SMS.'**
  String get hereWhenSmsArrives;

  /// Unread filter empty state title
  ///
  /// In en, this message translates to:
  /// **'All Read'**
  String get allRead;

  /// Unread filter empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'No new messages.'**
  String get noNewMessages;

  /// Codes filter empty state
  ///
  /// In en, this message translates to:
  /// **'No codes found'**
  String get noCodes;

  /// Codes empty state hint
  ///
  /// In en, this message translates to:
  /// **'One-time code messages will appear here.'**
  String get codesHint;

  /// Banks filter empty state
  ///
  /// In en, this message translates to:
  /// **'No bank messages'**
  String get noBanks;

  /// Banks empty state hint
  ///
  /// In en, this message translates to:
  /// **'Category will be auto-determined from the text.'**
  String get categoryAuto;

  /// Delivery filter empty state
  ///
  /// In en, this message translates to:
  /// **'No delivery messages'**
  String get noDelivery;

  /// Delivery empty state hint
  ///
  /// In en, this message translates to:
  /// **'They\'ll appear when courier notifications arrive.'**
  String get deliveryHint;

  /// Search empty state
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get notFound;

  /// Search empty state hint
  ///
  /// In en, this message translates to:
  /// **'Try changing your query or reset the filter.'**
  String get tryChangingQuery;

  /// Empty state notification hint
  ///
  /// In en, this message translates to:
  /// **'They will appear here after notifications arrive.'**
  String get hereAfterNotifications;

  /// Code label
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Code copied toast
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// Copy sender chip
  ///
  /// In en, this message translates to:
  /// **'Copy sender address'**
  String get copySender;

  /// Sender copied toast
  ///
  /// In en, this message translates to:
  /// **'Sender copied'**
  String get senderCopied;

  /// Hide hint chip
  ///
  /// In en, this message translates to:
  /// **'Hide hint'**
  String get hideHint;

  /// How Simply works section title
  ///
  /// In en, this message translates to:
  /// **'How Simply Works'**
  String get howSimplyWorks;

  /// How Simply works description
  ///
  /// In en, this message translates to:
  /// **'Simply forwards SMS from the device and automatically copies found codes to clipboard.'**
  String get howSimplyWorksBody;

  /// Code from message section title
  ///
  /// In en, this message translates to:
  /// **'Code from Message'**
  String get codeFromMessage;

  /// Source chip label
  ///
  /// In en, this message translates to:
  /// **'Source: {label}'**
  String source(String label);

  /// iOS source label
  ///
  /// In en, this message translates to:
  /// **'SMS · from iPhone'**
  String get smsFromIphone;

  /// Android source label
  ///
  /// In en, this message translates to:
  /// **'SMS · from Android'**
  String get smsFromAndroid;

  /// Login greeting
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// Signup greeting
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Login tab
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTab;

  /// Signup tab
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTab;

  /// Full name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fullName;

  /// Email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailField;

  /// Password field
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

  /// Login error dialog title
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in'**
  String get loginError;

  /// Signup error dialog title
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get signupError;

  /// Login error fallback message
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in'**
  String get loginErrorMessage;

  /// Signup error fallback message
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get signupErrorMessage;

  /// Reset password success toast
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get resetPasswordSent;

  /// Reset password error fallback
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get resetPasswordError;

  /// Signup description
  ///
  /// In en, this message translates to:
  /// **'A few seconds — and you\'re in Simply'**
  String get quickStart;

  /// Login description
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue forwarding SMS'**
  String get loginDescription;

  /// Today date group header
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// All lowercase label
  ///
  /// In en, this message translates to:
  /// **'all'**
  String get allLowercase;

  /// Relative time: just now
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// Relative time in minutes (short)
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// Relative time in hours (short)
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String hoursShort(int count);

  /// Relative time: yesterday (lowercase)
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterdayLowercase;

  /// Chat divider for today with time
  ///
  /// In en, this message translates to:
  /// **'Today · {time}'**
  String todayAtTime(String time);

  /// Chat divider for yesterday with time
  ///
  /// In en, this message translates to:
  /// **'Yesterday · {time}'**
  String yesterdayAtTime(String time);

  /// Chat divider for arbitrary date with time
  ///
  /// In en, this message translates to:
  /// **'{date} · {time}'**
  String dateAtTime(String date, String time);

  /// Splash screen subtitle
  ///
  /// In en, this message translates to:
  /// **'SMS forwarding between devices'**
  String get splashSubtitle;

  /// Permission rationale dialog title
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequiredTitle;

  /// Permission rationale dialog body
  ///
  /// In en, this message translates to:
  /// **'To function correctly, the app requires access to {permissionName}. Please grant access.'**
  String permissionRequiredMessage(String permissionName);

  /// Permission permanently denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Permission Permanently Denied'**
  String get permissionPermanentlyDeniedTitle;

  /// Permission permanently denied dialog body
  ///
  /// In en, this message translates to:
  /// **'You have permanently denied access to {permissionName}. Please grant access in the app settings.'**
  String permissionPermanentlyDeniedMessage(String permissionName);

  /// Button to open app settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Toast shown when permission is restricted
  ///
  /// In en, this message translates to:
  /// **'Access to {permissionName} is restricted.'**
  String permissionRestrictedMessage(String permissionName);

  /// Default copied toast message
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;
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
