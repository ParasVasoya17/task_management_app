import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/services/preferences_service.dart';

import '../services/task_database.dart';

final preferencesProvider = StateProvider<String>((ref) => 'createdAt');

final taskListProvider = FutureProvider<List<Task>>((ref) async {
  final sortBy = ref.watch(preferencesProvider);
  return TaskDatabase.instance.getTasks(sortBy: sortBy);
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final box = Hive.box('preferencesBox');
  return PreferencesService(box);
});
