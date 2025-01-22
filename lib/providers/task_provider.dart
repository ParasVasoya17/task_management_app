import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/services/task_database.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  Future<void> fetchTasks({String sortBy = 'createdAt', bool ascending = true}) async {
    final tasks = await TaskDatabase.instance.getTasks(sortBy: sortBy, ascending: ascending);
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    final taskId = await TaskDatabase.instance.createTask(task);
    task = task.copyWith(id: taskId); // After adding task, assign the ID
    state = [...state, task];
  }

  Future<void> updateTask(Task task) async {
    await TaskDatabase.instance.updateTask(task);
    state = [
      for (var t in state)
        if (t.id == task.id) task else t,
    ];
  }

  Future<void> toggleTaskCompletion(int taskId) async {
    final task = state.firstWhere((task) => task.id == taskId);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await TaskDatabase.instance.updateTask(updatedTask);
    state = [
      for (var t in state)
        if (t.id == taskId) updatedTask else t,
    ];
  }

  Future<void> deleteTask(int taskId) async {
    await TaskDatabase.instance.deleteTask(taskId);
    state = state.where((task) => task.id != taskId).toList();
  }
}
