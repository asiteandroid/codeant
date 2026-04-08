import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

/// Main screen — displays the task list with pull-to-refresh,
/// swipe-to-delete, and a FAB to add new tasks.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks after the first frame so the Provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Body builder — switches on the current status.
  // ---------------------------------------------------------------------------

  Widget _buildBody(TaskProvider provider) {
    return switch (provider.status) {
      TaskListStatus.initial ||
      TaskListStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      TaskListStatus.error => ErrorStateWidget(
          message: provider.errorMessage ?? 'Something went wrong.',
          onRetry: () => provider.loadTasks(),
        ),
      TaskListStatus.loaded when provider.tasks.isEmpty =>
        const EmptyStateWidget(),
      TaskListStatus.loaded => RefreshIndicator(
          onRefresh: () => provider.loadTasks(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return TaskCard(
                task: task,
                onTap: () => _navigateToForm(context, task: task),
                onToggleComplete: () =>
                    provider.toggleTaskCompletion(task.id),
                onDelete: () => _confirmDelete(context, task.id),
              );
            },
          ),
        ),
    };
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _navigateToForm(BuildContext context, {task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(existingTask: task),
      ),
    );
  }

  void _navigateToEditForm(BuildContext context, {task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(existingTask: task),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String taskId) {
    final provider = context.read<TaskProvider>();
    print('Deleting task: $taskId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => provider.loadTasks(),
        ),
      ),
    );
    provider.deleteTask(taskId);
  }
}

