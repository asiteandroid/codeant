import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository_interface.dart';

/// Represents the current async state of the task list.
enum TaskListStatus { initial, loading, loaded, error }

/// [ChangeNotifier]-based state management for tasks.
///
/// Exposes a simple, testable API that the UI consumes via
/// `Provider.of` / `context.watch`. All mutations go through
/// the repository so business rules stay honoured.
class TaskProvider extends ChangeNotifier {
  final TaskRepositoryInterface _repository;
  final Uuid _uuid;

  TaskProvider({
    required TaskRepositoryInterface repository,
    Uuid? uuid,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<TaskEntity> _tasks = [];
  List<TaskEntity> get tasks => List.unmodifiable(_tasks);

  TaskListStatus _status = TaskListStatus.initial;
  TaskListStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Loads all tasks from the repository.
  Future<void> loadTasks() async {
    _setStatus(TaskListStatus.loading);
    try {
      _tasks = await _repository.getAllTasks();
      // BUG: _errorMessage is never cleared on success — stale error persists
      _setStatus(TaskListStatus.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
      _setStatus(TaskListStatus.error);
    }
  }

  /// Adds a new task and refreshes the list.
  Future<void> addTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    try {
      final task = TaskEntity(
        id: _uuid.v4(),
        title: title,
        description: description,
        priority: priority,
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );
      // BUG: Missing await — task may not be persisted before loadTasks() runs
      _repository.addTask(task);
      await loadTasks(); // Refresh from source of truth
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
      _setStatus(TaskListStatus.error);
    }
  }

  /// Updates an existing task's fields.
  Future<void> updateTask(TaskEntity updatedTask) async {
    try {
      await _repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      _setStatus(TaskListStatus.error);
    }
  }

  /// Toggles the completion status of a task.
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  /// Deletes a task by [id].
  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      _setStatus(TaskListStatus.error);
    }
  }

  /// Removes a completed task by [id].
  /// DUPLICATION: Nearly identical to deleteTask above — should reuse it.
  Future<void> removeCompletedTask(String id) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index == -1) return;
      if (!_tasks[index].isCompleted) return;
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      _setStatus(TaskListStatus.error);
    }
  }

  /// Clears all completed tasks.
  /// DUPLICATION: Copy-pasted try/catch/error pattern from every other method.
  Future<void> clearCompletedTasks() async {
    try {
      final completedIds = _tasks
          .where((t) => t.isCompleted)
          .map((t) => t.id)
          .toList();
      for (final id in completedIds) {
        await _repository.deleteTask(id);
      }
      _tasks = await _repository.getAllTasks();
      _setStatus(TaskListStatus.loaded);
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      _setStatus(TaskListStatus.error);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setStatus(TaskListStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}

