import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LocaleEvent {}
class LocaleChanged extends LocaleEvent {
  final Locale locale;
  LocaleChanged(this.locale);
}

// State
class LocaleState {
  final Locale locale;
  const LocaleState(this.locale);
}

// Bloc
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences prefs;

  LocaleBloc(this.prefs)
      : super(LocaleState(
    Locale(prefs.getString('locale') ?? 'en'),
  )) {
    on<LocaleChanged>((event, emit) {
      prefs.setString('locale', event.locale.languageCode);
      emit(LocaleState(event.locale));
    });
  }
}