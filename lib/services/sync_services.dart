import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../models/queue_item.dart';
import '../models/note.dart';

class SyncService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Box<QueueItem> queueBox = Hive.box<QueueItem>('queue');
  final Box<Note> noteBox = Hive.box<Note>('notes');

  Future<void> processQueue() async {
    print("\n ===== SYNC STARTED =====");
    print(" Queue size        : ${queueBox.length}");

    int successCount = 0;
    int failCount = 0;

    for (var item in queueBox.values.toList()) {
      try {
        print("\nProcessing        : ${item.action}");

        await _processItem(item);

        // Success → remove from queue
        queueBox.delete(item.id);
        successCount++;

        print("Synced            : ${item.action}");
      } catch (e) {
        print(" Failed            : ${item.action}");

        // Retry once with backoff
        if (item.retryCount < 1) {
          item.retryCount += 1;
          queueBox.put(item.id, item);

          print(" Retrying in 2 sec : ${item.action}");

          await Future.delayed(const Duration(seconds: 2));

          try {
            await _processItem(item);

            queueBox.delete(item.id);
            successCount++;

            print(" Retry Success     : ${item.action}");
          } catch (e) {
            failCount++;
            print(" Retry Failed      : ${item.action}");
          }
        } else {
          failCount++;
        }

        // 🔹 Summary per failure
        print("\n --- PARTIAL SUMMARY ---");
        print(" Success            : $successCount");
        print(" Failed             : $failCount");
        print(" Remaining Queue   : ${queueBox.length}");
      }
    }

    print("\n ===== FINAL SUMMARY =====");
    print("Total Success      : $successCount");
    print(" Total Failed       : $failCount");
    print(" Final Queue Size  : ${queueBox.length}");
    print(" ===== SYNC ENDED =====\n");
  }

  Future<void> _processItem(QueueItem item) async {
    switch (item.action) {
      case "add_note":
        await _addNoteToServer(item);
        break;

      case "like_note":
        await _likeNoteOnServer(item);
        break;
    }
  }

  Future<void> _addNoteToServer(QueueItem item) async {
    final data = item.data;

    // Using ID as document ID → prevents duplicates
    await firestore.collection('notes').doc(data['id']).set({
      "content": data['content'],
      "updatedAt": data['updatedAt'],
      "isLiked": false,
    });
  }

  Future<void> _likeNoteOnServer(QueueItem item) async {
    final data = item.data;

    await firestore.collection('notes').doc(data['id']).set({
      "isLiked": data['isLiked'],
      "updatedAt": data['updatedAt'],
    }, SetOptions(merge: true));
  }
}
