import '../repositories/todo_repository.dart';
import 'todo_notification_service.dart';

class TodoMaintenanceService {
  TodoMaintenanceService(this._repo, this._notifications);

  final TodoRepository _repo;
  final TodoNotificationService _notifications;

  Future<void> runMaintenance() async {
    final lists = await _repo.watchAllLists().first;
    final today = DateTime.now();

    for (final list in lists) {
      final purged = await _repo.purgeAndArchiveCompletedBefore(list.id, today);
      if (purged > 0) {
        // Purged tasks already had reminders cancelled in repository.
      }
    }

    await _notifications.rescheduleAll(_repo);
  }

  Future<void> runMaintenanceForList(int listId) async {
    await _repo.purgeAndArchiveCompletedBefore(listId, DateTime.now());
  }
}
