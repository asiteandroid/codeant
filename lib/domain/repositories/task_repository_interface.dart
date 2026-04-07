import '../entities/task_entity.dart';

/// Abstract contract for task data operations.
///
/// This interface lives in the domain layer so that business logic
/// never depends on concrete data-source implementations.
/// The data layer provides the concrete implementation.
abstract class TaskRepositoryInterface {
  /// Returns all tasks, sorted by creation date (newest first).
  Future<List<TaskEntity>> getAllTasks();

  /// Persists a new task and returns it with a generated [id].
  Future<TaskEntity> addTask(TaskEntity task);

  /// Updates an existing task identified by [task.id].
  Future<TaskEntity> updateTask(TaskEntity task);

  /// Deletes the task with the given [id].
  /// Returns `true` if the task was found and deleted.
  Future<bool> deleteTask(String id);

  /// Returns a single task by [id], or `null` if not found.
  Future<TaskEntity?> getTaskById(String id);
}

