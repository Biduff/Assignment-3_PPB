import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_firewall/services/notification_services.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final CollectionReference _notesCollection =
  FirebaseFirestore.instance.collection('notes');

  Future<void> _addNote() async {
    final title = _titleController.text.trim();
    final publisher = _publisherController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isNotEmpty && publisher.isNotEmpty && description.isNotEmpty) {
      await _notesCollection.add({
        'title': title,
        'publisher': publisher,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _publisherController.clear();
      _descriptionController.clear();

      await NotificationService.createNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Note Added',
        body: 'You added "$title" by $publisher.',
      );
    }
  }

  Future<void> _editNote(String id, Map<String, dynamic> oldData) async {
    final titleCtrl = TextEditingController(text: oldData['title']);
    final publisherCtrl = TextEditingController(text: oldData['publisher']);
    final descriptionCtrl = TextEditingController(text: oldData['description']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: publisherCtrl, decoration: const InputDecoration(labelText: 'Publisher')),
              TextField(controller: descriptionCtrl, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newTitle = titleCtrl.text.trim();
              final newPublisher = publisherCtrl.text.trim();
              final newDescription = descriptionCtrl.text.trim();

              if (newTitle.isNotEmpty && newPublisher.isNotEmpty && newDescription.isNotEmpty) {
                await _notesCollection.doc(id).update({
                  'title': newTitle,
                  'publisher': newPublisher,
                  'description': newDescription,
                });

                await NotificationService.createNotification(
                  id: DateTime.now().millisecondsSinceEpoch % 100000,
                  title: 'Note Updated',
                  body: 'Updated note "$newTitle".',
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(String id, String title) async {
    await _notesCollection.doc(id).delete();

    await NotificationService.createNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Note Deleted',
      body: 'Deleted note "$title".',
    );
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
        leading: IconButton(
            onPressed: navigateHome,
            icon: const Icon(Icons.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _publisherController,
              decoration: const InputDecoration(labelText: 'Publisher', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addNote,
              child: const Text('Add Note'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notesCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text('Error loading notes');
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(data['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Publisher: ${data['publisher'] ?? ''}"),
                              Text("Description: ${data['description'] ?? ''}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editNote(doc.id, data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteNote(doc.id, data['title'] ?? ''),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
