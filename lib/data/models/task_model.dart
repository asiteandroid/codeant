import '../../domain/entities/task_entity.dart';

/// Data-layer model that knows how to serialize/deserialize.
///
/// Extends [TaskEntity] semantics with JSON conversion methods,
/// keeping the domain entity free of serialization concerns.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.isCompleted,
    super.priority,
    required super.createdAt,
    super.dueDate,
  });

  /// Constructs a [TaskModel] from a JSON map.
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  /// Convenience: create a [TaskModel] from a domain [TaskEntity].
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
    );
  }
}