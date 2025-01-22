import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/providers/task_provider.dart';
import 'package:task_management_app/services/notification.dart';
import 'package:task_management_app/views/task_detail_screen.dart';

final dueDateProvider = StateProvider<DateTime?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    if (tasks.isEmpty) {
      ref.read(taskProvider.notifier).fetchTasks();
    }

    final searchQuery = ref.watch(searchQueryProvider);
    final filteredTasks = tasks
        .where((task) => task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddTaskDialog(context, ref);
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'By Date') {
                  ref.read(taskProvider.notifier).fetchTasks(
                        sortBy: 'createdAt',
                        ascending: true,
                      );
                } else if (value == 'By Priority') {
                  ref.read(taskProvider.notifier).fetchTasks(
                        sortBy: 'priority',
                        ascending: true,
                      );
                } else if (value == 'By Due Date') {
                  ref.read(taskProvider.notifier).fetchTasks(
                        sortBy: 'duedate',
                        ascending: true,
                      );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'By Date',
                  child: Text('Sort by Create Date'),
                ),
                const PopupMenuItem(
                  value: 'By Due Date',
                  child: Text('Sort by Due Date'),
                ),
                const PopupMenuItem(
                  value: 'By Priority',
                  child: Text('Sort by Priority'),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
                decoration: const InputDecoration(
                  labelText: 'Search tasks...',
                  hintText: 'Search by title or description',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        body: filteredTasks.isEmpty
            ? const Center(child: Text("No tasks available"))
            : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(task.description),
                      leading: GestureDetector(
                        onTap: () {
                          ref.read(taskProvider.notifier).toggleTaskCompletion(task.id!);
                        },
                        child: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditTaskDialog(context, ref, task);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ref.read(taskProvider.notifier).deleteTask(task.id!);
                              showNotification(
                                'Task Deleted',
                                'Task "${task.title}" has been Deleted.',
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(taskId: task.id!),
                          ),
                        );

                        // ref.read(taskProvider.notifier).toggleTaskCompletion(task.id!);
                        // showNotification(
                        //   'Task Status Changed',
                        //   'Task "${task.title}" has been updated.',
                        // );
                      },
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddTaskDialog(context, ref);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    ref.read(dueDateProvider.notifier).state = null;
    await showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final dueDate = ref.watch(dueDateProvider);

            return AlertDialog(
              title: const Text('Add New Task'),
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
                        initialDate: DateTime.now(),
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
                        dueDate != null ? 'Due Date: ${dueDate.toLocal().day} - ${dueDate.toLocal().month} - ${dueDate.toLocal().year}' : 'Select Due Date',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final newTask = Task(
                      title: titleController.text,
                      description: descriptionController.text,
                      createdAt: DateTime.now(),
                      dueDate: ref.read(dueDateProvider),
                      isCompleted: false,
                      priority: 1,
                    );
                    ref.read(taskProvider.notifier).addTask(newTask);
                    showNotification(
                      'Task Created',
                      'Task "${titleController.text}" has been created.',
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

  Future<void> _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);

    ref.read(dueDateProvider.notifier).state = task.dueDate;
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
                        dueDate != null ? 'Due Date: ${dueDate.toLocal().day} - ${dueDate.toLocal().month} - ${dueDate.toLocal().year}' : 'Select Due Date',
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
}
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:task_management_app/models/task.dart';
// import 'package:task_management_app/providers/task_provider.dart';
// import 'package:task_management_app/services/notification.dart';
//
// final dueDateProvider = StateProvider<DateTime?>((ref) => null);
//
// class TaskListScreen extends ConsumerStatefulWidget {
//   @override
//   _TaskListScreenState createState() => _TaskListScreenState();
// }
//
// class _TaskListScreenState extends ConsumerState<TaskListScreen> {
//   TextEditingController searchController = TextEditingController();
//   String searchQuery = '';
//
//   @override
//   Widget build(BuildContext context) {
//     final tasks = ref.watch(taskProvider);
//     if (tasks.isEmpty) {
//       ref.read(taskProvider.notifier).fetchTasks();
//     }
//
//     final filteredTasks = tasks
//         .where((task) => task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase()))
//         .toList();
//
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Task Management'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () {
//                 _showAddTaskDialog(context, ref);
//               },
//             ),
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'By Date') {
//                   ref.read(taskProvider.notifier).fetchTasks(sortBy: 'createdAt', ascending: true);
//                 } else if (value == 'By Priority') {
//                   ref.read(taskProvider.notifier).fetchTasks(sortBy: 'priority', ascending: true);
//                 } else if (value == 'By Due Date') {
//                   ref.read(taskProvider.notifier).fetchTasks(sortBy: 'duedate', ascending: true);
//                 }
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'By Date',
//                   child: Text('Sort by Create Date'),
//                 ),
//                 const PopupMenuItem(
//                   value: 'By Due Date',
//                   child: Text('Sort by Due Date'),
//                 ),
//                 const PopupMenuItem(
//                   value: 'By Priority',
//                   child: Text('Sort by Priority'),
//                 ),
//               ],
//             ),
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(50),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: TextField(
//                 controller: searchController,
//                 onChanged: (query) {
//                   setState(() {
//                     searchQuery = query;
//                   });
//                 },
//                 decoration: const InputDecoration(
//                   labelText: 'Search tasks...',
//                   hintText: 'Search by title or description',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         body: filteredTasks.isEmpty
//             ? const Center(child: Text("No tasks available"))
//             : ListView.builder(
//                 itemCount: filteredTasks.length,
//                 itemBuilder: (context, index) {
//                   final task = filteredTasks[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     child: ListTile(
//                       title: Text(
//                         task.title,
//                         style: TextStyle(
//                           decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
//                         ),
//                       ),
//                       subtitle: Text(task.description),
//                       leading: Icon(
//                         task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
//                         color: task.isCompleted ? Colors.green : Colors.grey,
//                       ),
//                       trailing: Wrap(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit),
//                             onPressed: () {
//                               _showEditTaskDialog(context, ref, task);
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete),
//                             onPressed: () {
//                               ref.read(taskProvider.notifier).deleteTask(task.id!);
//                               showNotification(
//                                 'Task Deleted',
//                                 'Task "${task.title}" has been Deleted.',
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       onTap: () {
//                         ref.read(taskProvider.notifier).toggleTaskCompletion(task.id!);
//                         showNotification(
//                           'Task Status Changed',
//                           'Task "${task.title}" has been updated.',
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             _showAddTaskDialog(context, ref);
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
//     final titleController = TextEditingController();
//     final descriptionController = TextEditingController();
//
//     ref.read(dueDateProvider.notifier).state = null;
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return Consumer(
//           builder: (context, ref, child) {
//             final dueDate = ref.watch(dueDateProvider);
//
//             return AlertDialog(
//               title: const Text('Add New Task'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: const InputDecoration(labelText: 'Title'),
//                   ),
//                   TextField(
//                     controller: descriptionController,
//                     decoration: const InputDecoration(labelText: 'Description'),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       final selectedDate = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2101),
//                       );
//                       if (selectedDate != null) {
//                         ref.read(dueDateProvider.notifier).state = selectedDate;
//                       }
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(top: 10),
//                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         dueDate != null ? 'Due Date: ${dueDate.toLocal().day} - ${dueDate.toLocal().month} - ${dueDate.toLocal().year}' : 'Select Due Date',
//                         style: const TextStyle(color: Colors.black54),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     final newTask = Task(
//                       title: titleController.text,
//                       description: descriptionController.text,
//                       createdAt: DateTime.now(),
//                       dueDate: ref.read(dueDateProvider),
//                       isCompleted: false,
//                       priority: 1,
//                     );
//                     ref.read(taskProvider.notifier).addTask(newTask);
//                     showNotification(
//                       'Task Created',
//                       'Task "${titleController.text}" has been created.',
//                     );
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Save'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) async {
//     final titleController = TextEditingController(text: task.title);
//     final descriptionController = TextEditingController(text: task.description);
//
//     ref.read(dueDateProvider.notifier).state = task.dueDate;
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return Consumer(
//           builder: (context, ref, child) {
//             final dueDate = ref.watch(dueDateProvider);
//
//             return AlertDialog(
//               title: const Text('Edit Task'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: const InputDecoration(labelText: 'Title'),
//                   ),
//                   TextField(
//                     controller: descriptionController,
//                     decoration: const InputDecoration(labelText: 'Description'),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       final selectedDate = await showDatePicker(
//                         context: context,
//                         initialDate: dueDate ?? DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2101),
//                       );
//                       if (selectedDate != null) {
//                         ref.read(dueDateProvider.notifier).state = selectedDate;
//                       }
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(top: 10),
//                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         dueDate != null ? 'Due Date: ${dueDate.toLocal().day} - ${dueDate.toLocal().month} - ${dueDate.toLocal().year}' : 'Select Due Date',
//                         style: const TextStyle(color: Colors.black54),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     final updatedTask = task.copyWith(
//                       title: titleController.text,
//                       description: descriptionController.text,
//                       dueDate: ref.read(dueDateProvider),
//                     );
//                     ref.read(taskProvider.notifier).updateTask(updatedTask);
//                     showNotification(
//                       'Task Updated',
//                       'Task "${titleController.text}" has been updated.',
//                     );
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Save'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
