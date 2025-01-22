import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/providers/task_provider.dart';
import 'package:task_management_app/services/notification.dart';

class TaskDetailScreen extends ConsumerWidget {
  final int taskId;

  TaskDetailScreen({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskProvider).firstWhere((t) => t.id == taskId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context, ref, task);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Due Date:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  task.dueDate != null ? '${task.dueDate!.day}-${task.dueDate!.month}-${task.dueDate!.year}' : 'No due date',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Priority:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  task.priority.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  task.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    fontSize: 16,
                    color: task.isCompleted ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(taskProvider.notifier).toggleTaskCompletion(task.id!);
                    //
                    // taskNotifier.toggleTaskCompletion(task.id!);
                    showNotification(
                      'Task Status Changed',
                      'Task "${task.title}" has been updated.',
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    task.isCompleted ? Icons.undo : Icons.check,
                  ),
                  label: Text(
                    task.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showEditTaskDialog(context, ref, task);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    final dueDateProvider = StateProvider<DateTime?>((ref) => task.dueDate);

    await showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final dueDate = ref.watch(dueDateProvider);

            return AlertDialog(
              title: const Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        ref.read(dueDateProvider.notifier).state = selectedDate;
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dueDate != null ? 'Due Date: ${dueDate.day}-${dueDate.month}-${dueDate.year}' : 'Select Due Date',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final updatedTask = task.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: ref.read(dueDateProvider),
                    );
                    ref.read(taskProvider.notifier).updateTask(updatedTask);
                    showNotification(
                      'Task Updated',
                      'Task "${titleController.text}" has been updated.',
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete the task "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(taskProvider.notifier).deleteTask(task.id!);
              showNotification(
                'Task Deleted',
                'Task "${task.title}" has been deleted.',
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
