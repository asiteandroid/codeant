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

  /// DUPLICATION: Same date format string used in _DueDatePicker (task_form_screen.dart).
  /// Should extract to a shared utility/extension.
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// DUPLICATION: Same priority→color mapping as _getPriorityColor in task_form_screen.dart.
  /// Should be a shared utility function.
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

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      // BUG: No confirmDismiss — accidental swipes delete permanently
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red, // BUG: Hardcoded color instead of theme.colorScheme.error
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

  /// DUPLICATION: Builds subtitle with inline date formatting.
  /// The date format logic is copy-pasted from _DueDatePicker in task_form_screen.dart.
  Widget? _buildSubtitle() {
    final parts = <String>[];
    if (task.description.isNotEmpty) {
      parts.add(task.description);
    }
    if (task.dueDate != null) {
      // DUPLICATION: Same DateFormat.yMMMd() call exists in task_form_screen.dart _DueDatePicker
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

