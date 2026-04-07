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

  @override
  Future<bool> deleteTask(String id) => _datasource.delete(id);

  @override
  Future<TaskEntity?> getTaskById(String id) => _datasource.getById(id);
}

