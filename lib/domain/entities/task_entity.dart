/// Core task entity — the business object used across all layers.
///
/// This is a plain Dart class with no framework dependencies,
/// making it easy to test and reason about.
enum TaskPriority { low, medium, high }

class TaskEntity {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
  });

  /// Creates a copy with optional field overrides (immutable update pattern).
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}

