import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/queue_item.dart';

class QueueService {
  final Box<QueueItem> queueBox = Hive.box<QueueItem>('queue');
  final uuid = const Uuid();

  // Add action to queue
  void addToQueue(String action, Map<String, dynamic> data) {
    final item = QueueItem(
      id: uuid.v4(), // idempotency key
      action: action,
      data: data,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    queueBox.put(item.id, item);

    print(" Added to queue: ${item.action}");
    print(" Queue size: ${queueBox.length}");
  }

  List<QueueItem> getQueue() {
    return queueBox.values.toList();
  }

  void removeFromQueue(String id) {
    queueBox.delete(id);
    print(" Removed from queue");
    print(" Queue size: ${queueBox.length}");
  }
}
