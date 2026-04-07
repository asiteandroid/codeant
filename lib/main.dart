import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/task_list_screen.dart';

void main() {
  runApp(const TaskManagerApp());
}

/// Root widget.
///
/// Sets up the dependency graph:
///   TaskRepository → TaskProvider → widget tree
///
/// Using [ChangeNotifierProvider] ensures the provider is disposed
/// automatically when the widget tree is torn down.
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(repository: TaskRepository()),
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const TaskListScreen(),
      ),
    );
  }
}
