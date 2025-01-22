import 'package:flutter/material.dart';
import 'package:task_management_app/views/task_list_screen.dart';
import 'package:task_management_app/views/theme_switcher.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: TaskListScreen(),
      drawer: Drawer(
        child: ListView(
          children: [
            const ListTile(title: Text('Settings')),
            ThemeSwitcher(),
          ],
        ),
      ),
    );
  }
}
