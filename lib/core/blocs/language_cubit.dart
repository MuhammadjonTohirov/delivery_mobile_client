import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/language_service.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final languageCode = await LanguageService.getLanguage();
    emit(Locale(languageCode));
  }

  Future<void> changeLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    emit(Locale(languageCode));
  }
}