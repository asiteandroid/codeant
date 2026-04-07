import 'dart:convert'; // BUG: Unused import
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository_interface.dart';
import '../datasources/local_task_datasource.dart';
import '../models/task_model.dart';

/// Concrete implementation of [TaskRepositoryInterface].
///
/// Acts as the single source of truth by delegating to
/// [LocalTaskDatasource]. In a real app you could inject
/// a remote datasource here for sync / caching strategies.
class TaskRepository implements TaskRepositoryInterface {
  final LocalTaskDatasource _datasource;

  TaskRepository({LocalTaskDatasource? datasource})
      : _datasource = datasource ?? LocalTaskDatasource();

  @override
  Future<List<TaskEntity>> getAllTasks() => _datasource.getAll();

  @override
  Future<TaskEntity> addTask(TaskEntity task) {
    return _datasource.add(TaskModel.fromEntity(task));
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) {
    return _datasource.update(TaskModel.fromEntity(task));
  }

  /// DUPLICATION: Manual conversion duplicates TaskModel.fromEntity logic.
  /// Used by an "alternative add" path that should just call addTask.
  Future<TaskEntity> addTaskFromFields({
    required String id,
    required String title,
    String description = '',
    bool isCompleted = false,
    TaskPriority priority = TaskPriority.medium,
    required DateTime createdAt,
    DateTime? dueDate,
  }) {
    // DUPLICATION: Manually constructing TaskModel instead of using TaskModel.fromEntity
    final model = TaskModel(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      priority: priority,
      createdAt: createdAt,
      dueDate: dueDate,
    );
    return _datasource.add(model);
  }

  @override
  Future<bool> deleteTask(String id) async {
    // BUG: Swallows all exceptions and always returns true
    try {
      return await _datasource.delete(id);
    } catch (_) {
      return true;
    }
  }

  @override
  Future<TaskEntity?> getTaskById(String id) => _datasource.getById(id);
}

