import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:offline_sync_app/services/sync_services.dart';

import 'models/note.dart';
import 'models/queue_item.dart';
import 'repository/note_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(QueueItemAdapter());

  await Hive.openBox<Note>('notes');
  await Hive.openBox<QueueItem>('queue');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = NoteRepository();
  final controller = TextEditingController();
  final syncService = SyncService();

  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    final data = await repo.fetchNotes();
    setState(() {
      notes = data;
    });
  }

  void addNote() async {
    if (controller.text.trim().isEmpty) return;

    await repo.addNote(controller.text);
    controller.clear();
    loadNotes();
  }

  void likeNote(String id) async {
    await repo.likeNote(id);
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await syncService.processQueue();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sync completed")),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Write a note...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addNote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: notes.isEmpty
                ? const Center(
                    child: Text(
                      "No notes yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: notes.length,
                    itemBuilder: (_, index) {
                      final note = notes[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            title: Text(
                              note.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                note.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: note.isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => likeNote(note.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await syncService.processQueue();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sync completed")),
          );
        },
        icon: const Icon(Icons.cloud_upload),
        label: const Text("Sync"),
      ),
    );
  }
}
