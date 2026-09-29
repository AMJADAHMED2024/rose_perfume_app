// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<void> showWebNotification(String title, String? body) async {
  if (html.Notification.permission != 'granted') return;
  html.Notification(title, body: body);
}
