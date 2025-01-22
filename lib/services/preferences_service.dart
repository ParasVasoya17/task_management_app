import 'package:hive/hive.dart';

class PreferencesService {
  final Box _preferencesBox;

  PreferencesService(this._preferencesBox);

  bool get isDarkMode => _preferencesBox.get('isDarkMode', defaultValue: false);

  set setDarkMode(bool value) => _preferencesBox.put('isDarkMode', value);

  String get defaultSortOrder => _preferencesBox.get('defaultSortOrder', defaultValue: 'date');

  set setDefaultSortOrder(String value) => _preferencesBox.put('defaultSortOrder', value);
}
