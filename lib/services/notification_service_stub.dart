import 'package:flutter/material.dart';

class Bildirim {
  final String baslik;
  final String icerik;
  final DateTime tarih;
  final bool kritikMi;

  Bildirim({
    required this.baslik,
    required this.icerik,
    required this.tarih,
    this.kritikMi = false,
  });
}

class NotificationService {
  static final List<Bildirim> bildirimler = [];

  static Future<void> initialize() async {
    // Initial notifications if any
  }

  static Future<void> showNotification(
    BuildContext context,
    String title,
    String body, {
    bool isKritik = false,
  }) async {
    // Save to list
    bildirimler.insert(
      0,
      Bildirim(
        baslik: title,
        icerik: body,
        tarih: DateTime.now(),
        kritikMi: isKritik || title.toLowerCase().contains('kritik'),
      ),
    );

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title\n$body"),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isKritik || title.toLowerCase().contains('kritik')
            ? Colors.red.shade800
            : null,
      ),
    );
  }
}
