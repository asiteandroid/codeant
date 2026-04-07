import 'package:flutter_test/flutter_test.dart';

import 'package:codeant/domain/entities/task_entity.dart';
import 'package:codeant/data/datasources/local_task_datasource.dart';
import 'package:codeant/data/models/task_model.dart';
import 'package:codeant/data/repositories/task_repository.dart';

/// Unit tests for [TaskRepository] backed by [LocalTaskDatasource].
void main() {
  late LocalTaskDatasource datasource;
  late TaskRepository repository;

  setUp(() {
    datasource = LocalTaskDatasource();
    repository = TaskRepository(datasource: datasource);
  });

  group('TaskRepository', () {
    test('getAllTasks returns seeded dummy data', () async {
      final tasks = await repository.getAllTasks();

      // The datasource seeds 4 sample tasks
      expect(tasks, isNotEmpty);
      expect(tasks.length, 4);
    });

    test('addTask persists a new task and it appears in getAllTasks', () async {
      final newTask = TaskEntity(
        id: 'test-new-1',
        title: 'Write integration tests',
        description: 'Cover the full add-edit-delete flow.',
        priority: TaskPriority.high,
        createdAt: DateTime.now(),
      );

      final added = await repository.addTask(newTask);
      expect(added.id, 'test-new-1');
      expect(added.title, 'Write integration tests');

      final all = await repository.getAllTasks();
      expect(all.any((t) => t.id == 'test-new-1'), isTrue);
    });

    test('updateTask modifies an existing task', () async {
      // Grab one of the seeded tasks
      final tasks = await repository.getAllTasks();
      final original = tasks.first;

      final updated = original.copyWith(title: 'Updated title');
      final result = await repository.updateTask(updated);

      expect(result.title, 'Updated title');

      final fetched = await repository.getTaskById(original.id);
      expect(fetched?.title, 'Updated title');
    });

    test('deleteTask removes the task', () async {
      final removed = await repository.deleteTask('seed-1');
      expect(removed, isTrue);

      final tasks = await repository.getAllTasks();
      expect(tasks.any((t) => t.id == 'seed-1'), isFalse);
    });

    test('deleteTask returns false for non-existent id', () async {
      final removed = await repository.deleteTask('does-not-exist');
      expect(removed, isFalse);
    });
  });

  group('TaskModel', () {
    test('round-trips through JSON correctly', () {
      final model = TaskModel(
        id: 'json-1',
        title: 'JSON round trip',
        description: 'Desc',
        isCompleted: true,
        priority: TaskPriority.high,
        createdAt: DateTime(2025, 1, 15),
        dueDate: DateTime(2025, 2, 1),
      );

      final json = model.toJson();
      final restored = TaskModel.fromJson(json);

      expect(restored.id, model.id);
      expect(restored.title, model.title);
      expect(restored.isCompleted, model.isCompleted);
      expect(restored.priority, TaskPriority.high);
      expect(restored.dueDate, DateTime(2025, 2, 1));
    });
  });
}

