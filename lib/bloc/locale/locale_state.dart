import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({required this.locale});

  factory LocaleState.initial(Locale systemLocale) {
    return LocaleState(
      locale:
          _isLocaleSupported(systemLocale) ? systemLocale : const Locale('en'),
    );
  }

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  static bool _isLocaleSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'ru';
  }

  @override
  List<Object?> get props => [locale];
}
