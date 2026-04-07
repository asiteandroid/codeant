import 'package:flutter_test/flutter_test.dart';

import 'package:codeant/domain/entities/task_entity.dart';
import 'package:codeant/domain/repositories/task_repository_interface.dart';
import 'package:codeant/presentation/providers/task_provider.dart';

// ---------------------------------------------------------------------------
// A simple fake repository for deterministic unit tests.
// No code generation or mockito needed for this straightforward case.
// ---------------------------------------------------------------------------

class FakeTaskRepository implements TaskRepositoryInterface {
  final List<TaskEntity> _store = [];
  bool shouldThrow = false;

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    if (shouldThrow) throw Exception('Simulated failure');
    return List.of(_store);
  }

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    if (shouldThrow) throw Exception('Simulated failure');
    _store.add(task);
    return task;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    if (shouldThrow) throw Exception('Simulated failure');
    final i = _store.indexWhere((t) => t.id == task.id);
    if (i == -1) throw Exception('Not found');
    _store[i] = task;
    return task;
  }

  @override
  Future<bool> deleteTask(String id) async {
    if (shouldThrow) throw Exception('Simulated failure');
    final len = _store.length;
    _store.removeWhere((t) => t.id == id);
    return _store.length < len;
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    if (shouldThrow) throw Exception('Simulated failure');
    return _store.where((t) => t.id == id).firstOrNull;
  }
}

/// Unit tests for [TaskProvider].
void main() {
  late FakeTaskRepository fakeRepo;
  late TaskProvider provider;

  setUp(() {
    fakeRepo = FakeTaskRepository();
    provider = TaskProvider(repository: fakeRepo);
  });

  group('TaskProvider', () {
    test('initial status is initial', () {
      expect(provider.status, TaskListStatus.initial);
      expect(provider.tasks, isEmpty);
    });

    test('loadTasks transitions to loaded with empty list', () async {
      await provider.loadTasks();

      expect(provider.status, TaskListStatus.loaded);
      expect(provider.tasks, isEmpty);
    });

    test('addTask creates a task and reloads the list', () async {
      await provider.addTask(title: 'First task');

      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'First task');
      expect(provider.status, TaskListStatus.loaded);
    });

    test('toggleTaskCompletion flips isCompleted', () async {
      await provider.addTask(title: 'Toggle me');
      final id = provider.tasks.first.id;

      expect(provider.tasks.first.isCompleted, isFalse);

      await provider.toggleTaskCompletion(id);
      expect(provider.tasks.first.isCompleted, isTrue);

      await provider.toggleTaskCompletion(id);
      expect(provider.tasks.first.isCompleted, isFalse);
    });

    test('deleteTask removes the task from the list', () async {
      await provider.addTask(title: 'Delete me');
      expect(provider.tasks.length, 1);

      final id = provider.tasks.first.id;
      await provider.deleteTask(id);

      expect(provider.tasks, isEmpty);
    });

    test('loadTasks sets error status on repository failure', () async {
      fakeRepo.shouldThrow = true;

      await provider.loadTasks();

      expect(provider.status, TaskListStatus.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('addTask sets error status on repository failure', () async {
      fakeRepo.shouldThrow = true;

      await provider.addTask(title: 'Will fail');

      expect(provider.status, TaskListStatus.error);
      expect(provider.errorMessage, contains('Failed to add task'));
    });
  });
}

