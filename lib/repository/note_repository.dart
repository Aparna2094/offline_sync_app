import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:offline_sync_app/services/queue_service.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NoteRepository {
  final Box<Note> noteBox = Hive.box<Note>('notes');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final queueService = QueueService();
  final uuid = const Uuid();

  Future<List<Note>> fetchNotes() async {
    final localNotes = noteBox.values.toList();

    if (localNotes.isEmpty) {
      await _fetchFromServer();
      return noteBox.values.toList();
    }

    // TTL: refresh every 5 minutes
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastUpdated = localNotes.first.updatedAt;

    if (now - lastUpdated > 5 * 60 * 1000) {
      _fetchFromServer();
    }

    return localNotes;
  }

  Future<void> _fetchFromServer() async {
    try {
      final snapshot = await firestore.collection('notes').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final note = Note(
          id: doc.id,
          content: data['content'],
          updatedAt: data['updatedAt'],
          isLiked: data['isLiked'] ?? false,
        );

        // Save/update locally (Last Write Wins)
        noteBox.put(note.id, note);
      }

      print(" Sync from server completed");
    } catch (e) {
      print(" Fetch error: $e");
    }
  }

  // Add Note (Offline-first)
  Future<void> addNote(String content) async {
    final id = uuid.v4();

    final note = Note(
      id: id,
      content: content,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // 1. Save locally (instant UI)
    noteBox.put(id, note);

    // 2. Add to queue for sync
    queueService.addToQueue("add_note", {
      "id": id,
      "content": content,
      "updatedAt": note.updatedAt,
    });
  }

  Future<void> likeNote(String id) async {
    final note = noteBox.get(id);

    if (note == null) return;

    note.isLiked = !note.isLiked;

    // 1. Update locally
    noteBox.put(id, note);

    // 2. Add to queue
    queueService.addToQueue("like_note", {
      "id": id,
      "isLiked": note.isLiked,
      "updatedAt": DateTime.now().millisecondsSinceEpoch,
    });
  }
}
