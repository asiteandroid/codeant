import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

/// In-memory data source that simulates a local database.
///
/// In a production app this would be backed by SQLite, Hive, or
/// shared_preferences. The in-memory implementation makes it easy
/// to run and test without any native setup.
class LocalTaskDatasource {
  /// Internal store keyed by task ID for O(1) lookups.
  final Map<String, TaskModel> _store = {};

  /// Seed the store with sample data for demo / testing purposes.
  LocalTaskDatasource() {
    _seedDummyData();
  }

  // ---------------------------------------------------------------------------
  // CRUD operations
  // ---------------------------------------------------------------------------

  Future<List<TaskModel>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final tasks = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  Future<TaskModel?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _store[id];
  }

  Future<TaskModel> add(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store[task.id] = task;
    return task;
  }

  Future<TaskModel> update(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_store.containsKey(task.id)) {
      throw Exception('Task with id ${task.id} not found');
    }
    _store[task.id] = task;
    return task;
  }

  Future<bool> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.remove(id) != null;
  }

  // ---------------------------------------------------------------------------
  // Dummy data — gives the app something to show on first launch.
  // ---------------------------------------------------------------------------

  void _seedDummyData() {
    final now = DateTime.now();
    final samples = [
      TaskModel(
        id: 'seed-1',
        title: 'Set up CI/CD pipeline',
        description:
            'Configure GitHub Actions for automated testing and deployment.',
        priority: TaskPriority.high,
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 5)),
      ),
      TaskModel(
        id: 'seed-2',
        title: 'Write unit tests for TaskProvider',
        description: 'Cover add, update, delete, and error scenarios.',
        priority: TaskPriority.high,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TaskModel(
        id: 'seed-3',
        title: 'Design onboarding screens',
        description: 'Create wireframes in Figma for the first-run experience.',
        priority: TaskPriority.medium,
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 10)),
      ),
      TaskModel(
        id: 'seed-4',
        title: 'Update README with setup instructions',
        description: '',
        priority: TaskPriority.low,
        createdAt: now,
      ),
    ];
    for (final task in samples) {
      _store[task.id] = task;
    }
  }
}
