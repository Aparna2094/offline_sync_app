import 'package:hive/hive.dart';

part 'queue_item.g.dart';

@HiveType(typeId: 1)
class QueueItem {
  @HiveField(0)
  String id; // idempotency key

  @HiveField(1)
  String action; // add_note, like_note

  @HiveField(2)
  Map<String, dynamic> data;

  @HiveField(3)
  int retryCount;

  @HiveField(4)
  int createdAt;

  QueueItem({
    required this.id,
    required this.action,
    required this.data,
    this.retryCount = 0,
    required this.createdAt,
  });
}
