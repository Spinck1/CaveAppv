import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
    'baslik': baslik,
    'icerik': icerik,
    'tarih': tarih.toIso8601String(),
    'kritikMi': kritikMi,
  };

  factory Bildirim.fromJson(Map<String, dynamic> json) => Bildirim(
    baslik: json['baslik'],
    icerik: json['icerik'],
    tarih: DateTime.parse(json['tarih']),
    kritikMi: json['kritikMi'] ?? false,
  );
}

class NotificationService {
  static final List<Bildirim> bildirimler = [];
  static const String _key = 'bildirimler';
  // Callback to notify AnaEkran when a new notification arrives
  static VoidCallback? onYeniBildirim;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final List decoded = jsonDecode(data);
        bildirimler.clear();
        bildirimler.addAll(decoded.map((b) => Bildirim.fromJson(b)).toList());
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(bildirimler.map((b) => b.toJson()).toList());
      await prefs.setString(_key, data);
    } catch (e) {
      debugPrint("Error saving notifications: $e");
    }
  }

  static Future<void> showNotification(
    String title,
    String body, {
    bool isKritik = false,
  }) async {
    bildirimler.insert(
      0,
      Bildirim(
        baslik: title,
        icerik: body,
        tarih: DateTime.now(),
        kritikMi: isKritik || title.toLowerCase().contains('kritik'),
      ),
    );
    await _save();
    // Trigger UI refresh instead of snackbar
    onYeniBildirim?.call();
  }
}
