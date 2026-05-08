import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/depo.dart';
import '../models/urun_partisi.dart';
import '../models/satis_kaydi.dart';

class DataService {
  static String _keyDepolar(String user) => 'depolar_$user';
  static String _keyDepoUrunleri(String user) => 'depo_urunleri_$user';
  static String _keySatislar(String user) => 'satislar_$user';

  static Future<void> saveAll({
    required List<Depo> depolar,
    required Map<String, List<UrunPartisi>> depoUrunleri,
    required List<SatisKaydi> satislar,
    required String kullanici,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final depolarJson = depolar.map((d) => d.toJson()).toList();
      await prefs.setString(_keyDepolar(kullanici), jsonEncode(depolarJson));

      final Map<String, dynamic> mappedUrunleri = {};
      depoUrunleri.forEach((key, value) {
        mappedUrunleri[key] = value.map((p) => p.toJson()).toList();
      });
      await prefs.setString(_keyDepoUrunleri(kullanici), jsonEncode(mappedUrunleri));

      final satislarJson = satislar.map((s) => s.toJson()).toList();
      await prefs.setString(_keySatislar(kullanici), jsonEncode(satislarJson));
    } catch (e) {
      debugPrint("DataService Save Error: $e");
    }
  }

  static Future<Map<String, dynamic>> loadAll({required String kullanici}) async {
    final prefs = await SharedPreferences.getInstance();

    List<Depo> depolar = [];
    Map<String, List<UrunPartisi>> depoUrunleri = {};
    List<SatisKaydi> satislar = [];

    try {
      final depolarStr = prefs.getString(_keyDepolar(kullanici));
      if (depolarStr != null) {
        final List decoded = jsonDecode(depolarStr);
        depolar = decoded
            .map((d) => Depo.fromJson(d as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint("Load Depolar Error: $e");
    }

    try {
      final urunleriStr = prefs.getString(_keyDepoUrunleri(kullanici));
      if (urunleriStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(urunleriStr);
        decoded.forEach((key, value) {
          if (value is List) {
            depoUrunleri[key] = value
                .map((p) => UrunPartisi.fromJson(p as Map<String, dynamic>))
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint("Load Urunler Error: $e");
    }

    try {
      final satislarStr = prefs.getString(_keySatislar(kullanici));
      if (satislarStr != null) {
        final List decoded = jsonDecode(satislarStr);
        satislar = decoded
            .map((s) => SatisKaydi.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint("Load Satislar Error: $e");
    }

    return {
      'depolar': depolar,
      'depoUrunleri': depoUrunleri,
      'satislar': satislar,
    };
  }
}
