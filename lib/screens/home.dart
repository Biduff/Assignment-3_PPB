import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:test_firewall/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigateSecond(context) {
    Navigator.pushReplacementNamed(context, 'second');
  }

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
        actions: [
          if (user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.person),
              onSelected: (value) {
                if (value == 'logout') {
                  logout(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'email',
                  enabled: false,
                  child: Text(user.email ?? 'No Email'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton(
            onPressed: () async {
              await NotificationService.createNotification(
                id: 1,
                title: 'Default Notification',
                body: 'This is a basic notification.',
                summary: 'A simple test',
              );
            },
            child: const Text('Default Notification'),
          ),
          OutlinedButton(
            onPressed: () async {
              await NotificationService.createNotification(
                id: 2,
                title: 'Inbox Notification',
                body: 'This is an inbox-style notification.',
                summary: 'Summary here',
                notificationLayout: NotificationLayout.Inbox,
              );
            },
            child: const Text('Inbox Notification'),
          ),
          OutlinedButton(
            onPressed: () async {
              await NotificationService.createNotification(
                id: 3,
                title: 'Progress Notification',
                body: 'Downloading...',
                summary: 'Progress status',
                notificationLayout: NotificationLayout.ProgressBar,
              );
            },
            child: const Text('Progress Notification'),
          ),
          OutlinedButton(
            onPressed: () async {
              await NotificationService.createNotification(
                id: 4,
                title: 'Big Image Notification',
                body: 'Here’s a notification with an image!',
                summary: 'Image summary',
                notificationLayout: NotificationLayout.BigPicture,
                bigPicture: 'https://picsum.photos/300/200',
              );
            },
            child: const Text('Big Image Notification'),
          ),
          OutlinedButton(
            onPressed: () async {
              await NotificationService.createNotification(
                id: 5,
                title: 'With Action Button',
                body: 'Tap the button in this notification.',
                payload: {'navigate': 'true'},
                actionButtons: [
                  NotificationActionButton(
                    key: 'open_button',
                    label: 'Open Screen',
                    actionType: ActionType.Default,
                  )
                ],
              );
            },
            child: const Text('Action Button Notification'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateSecond(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
