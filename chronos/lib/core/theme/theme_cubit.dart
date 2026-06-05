import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_themes.dart';

class ThemeCubit extends Cubit<ChronosTheme> {
  ThemeCubit() : super(AppThemes.all.first);

  void selectTheme(ChronosTheme theme) => emit(theme);
}
