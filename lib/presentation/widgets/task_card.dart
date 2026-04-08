import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';

/// Reusable card widget for displaying a single task in the list.
///
/// Accepts callbacks so the parent screen controls the behavior,
/// keeping this widget stateless and easy to test in isolation.
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('yMMMd');

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggleComplete(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? theme.colorScheme.onSurface.withAlpha(128)
                  : null,
            ),
          ),
          subtitle: _buildSubtitle(),
          trailing: _PriorityBadge(priority: task.priority),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget? _buildSubtitle() {
    final parts = <String>[];
    if (task.description.isNotEmpty) {
      parts.add(task.description);
    }
    if (task.dueDate != null) {
      parts.add('Due: ${DateFormat.yMMMd().format(task.dueDate!)}');
    }
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Small colored badge indicating the task priority.
class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      TaskPriority.high => ('High', Colors.red),
      TaskPriority.medium => ('Med', Colors.orange),
      TaskPriority.low => ('Low', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
