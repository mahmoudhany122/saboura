part of 'app_cubit.dart';

@immutable
abstract class AppState {}

class AppInitial extends AppState {}

class AppThemeChanged extends AppState {}

class AppLanguageChanged extends AppState {}
