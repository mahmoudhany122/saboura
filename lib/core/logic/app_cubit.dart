import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/cache_helper.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  bool isDark = false;
  
  void changeTheme({bool? fromCache}) {
    if (fromCache != null) {
      isDark = fromCache;
      emit(AppThemeChanged());
    } else {
      isDark = !isDark;
      CacheHelper.setData(key: 'isDark', value: isDark).then((value) {
        emit(AppThemeChanged());
      });
    }
  }

  String languageCode = 'ar';

  void changeLanguage(String code) {
    languageCode = code;
    CacheHelper.setData(key: 'language', value: code).then((value) {
      emit(AppLanguageChanged());
    });
  }
}
