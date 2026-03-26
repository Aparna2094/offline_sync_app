import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  bool isLiked;

  Note({
    required this.id,
    required this.content,
    required this.updatedAt,
    this.isLiked = false,
  });
}
