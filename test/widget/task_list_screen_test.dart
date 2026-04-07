import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:codeant/domain/entities/task_entity.dart';
import 'package:codeant/domain/repositories/task_repository_interface.dart';
import 'package:codeant/presentation/providers/task_provider.dart';
import 'package:codeant/presentation/screens/task_list_screen.dart';
import 'package:codeant/core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// A fake repository that returns two predefined tasks.
// ---------------------------------------------------------------------------

class _FakeTaskRepository implements TaskRepositoryInterface {
  final List<TaskEntity> _store = [
    TaskEntity(
      id: 'w-1',
      title: 'Widget Test Task 1',
      description: 'First task for widget testing',
      priority: TaskPriority.high,
      createdAt: DateTime(2025, 1, 1),
    ),
    TaskEntity(
      id: 'w-2',
      title: 'Widget Test Task 2',
      description: 'Second task',
      priority: TaskPriority.low,
      createdAt: DateTime(2025, 1, 2),
    ),
  ];

  @override
  Future<List<TaskEntity>> getAllTasks() async => List.of(_store);

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    _store.add(task);
    return task;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final i = _store.indexWhere((t) => t.id == task.id);
    _store[i] = task;
    return task;
  }

  @override
  Future<bool> deleteTask(String id) async {
    _store.removeWhere((t) => t.id == id);
    return true;
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async =>
      _store.where((t) => t.id == id).firstOrNull;
}

// ---------------------------------------------------------------------------
// Helper to pump the widget tree with the required Provider.
// ---------------------------------------------------------------------------

Widget _buildTestApp(TaskProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.light,
      home: const TaskListScreen(),
    ),
  );
}

/// Widget tests for [TaskListScreen].
void main() {
  late _FakeTaskRepository fakeRepo;
  late TaskProvider provider;

  setUp(() {
    fakeRepo = _FakeTaskRepository();
    provider = TaskProvider(repository: fakeRepo);
  });

  testWidgets('TaskListScreen shows loading then task cards',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(provider));

    // Initially the screen shows a progress indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // After the async load completes, tasks appear.
    await tester.pumpAndSettle();

    expect(find.text('Widget Test Task 1'), findsOneWidget);
    expect(find.text('Widget Test Task 2'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Tapping checkbox toggles task completion', (tester) async {
    await tester.pumpWidget(_buildTestApp(provider));
    await tester.pumpAndSettle();

    // Find the first checkbox and tap it.
    final checkbox = find.byType(Checkbox).first;
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // After toggling, the task should be completed.
    // We verify via the provider state.
    final task = provider.tasks.firstWhere((t) => t.id == 'w-2');
    expect(task.isCompleted, isTrue);
  });

  testWidgets('FAB navigates to form screen', (tester) async {
    await tester.pumpWidget(_buildTestApp(provider));
    await tester.pumpAndSettle();

    // Tap the floating action button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // The form screen shows "New Task" in the app bar.
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Title *'), findsOneWidget);
  });
}

