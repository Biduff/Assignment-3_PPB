# Awesome Notifications with Firebase in Flutter Apps
### Edward Samuel Susanto
### 5025221046

In this project I applied awesome notification in a basic CRUD function using firebase as the database. 

### I used refrence from these sources to create the logging, register, and notification services:
1. https://github.com/agusbudi/mobile-programming/tree/main/09.%20Firebase%20Auth
2. https://github.com/agusbudi/mobile-programming/tree/main/10.%20Awesome%20Notifications

### I make changes on the second_screen.dart, these changes created an interface like below:
![image](https://github.com/user-attachments/assets/85d8a938-e6d9-43b3-9828-b2320e4b4635)

### As you can see in the interface there is already data created, which is being inputted and synchronized to the firebase as well:
![image](https://github.com/user-attachments/assets/a528cb85-d515-43af-94f9-d0f5adabe644)
![image](https://github.com/user-attachments/assets/d9615489-ab72-4f08-8627-1a8bcec79ceb)

### The notification will pop up every time the user add, update, or delete data.
##1. Add User
```
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
```
![image](https://github.com/user-attachments/assets/56266640-132f-4f60-af15-b95d9ff8b30a)

##2. Update User
```
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
```
![image](https://github.com/user-attachments/assets/82db8414-e539-4b62-badd-57b4eabf71b3)

##3. Delete User
```
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
```
![image](https://github.com/user-attachments/assets/c08474b6-9ef5-4ce9-ab9a-2823063734a2)
