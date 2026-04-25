import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/bloc/locale/locale_state.dart';
import 'package:simply/services/ui_preferences_service.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final UiPreferencesService _preferencesService;

  LocaleCubit({UiPreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? UiPreferencesService(),
        super(LocaleState.initial(WidgetsBinding.instance.window.locale));

  Future<void> init() async {
    final savedLanguage = await _preferencesService.readSavedLanguage();
    if (savedLanguage != null) {
      emit(state.copyWith(locale: Locale(savedLanguage)));
    }
  }

  Future<void> setLocale(String languageCode) async {
    await _preferencesService.saveSavedLanguage(languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  bool isEnglish() => state.locale.languageCode == 'en';

  bool isRussian() => state.locale.languageCode == 'ru';
}
