import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'ana_ekran.dart';
import 'kayit_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _hatali = false;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _oturumKontrol();
  }

  Future<void> _oturumKontrol() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('aktifKullanici');
    if (user != null && user.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnaEkran()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _yukleniyor = false;
        });
      }
    }
  }

  void _girisYap() async {
    final kullaniciAdi = _userController.text.trim();
    final sifre = _passController.text.trim();

    // Önce Flask API'den gerçek kullanici_id almayı dene
    int? kullaniciId;
    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:5000/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'kullanici_adi': kullaniciAdi, 'sifre': sifre}),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['basarili'] == true) {
          kullaniciId = data['kullanici_id'] as int?;
        }
      }
    } catch (_) {
      // Sunucu kapalıysa yerel kontrol ile devam et
    }

    // Yerel yedek kontrol (Mehmet/123)
    final yerelBasarili = kullaniciAdi == 'Mehmet' && sifre == '123';

    if (kullaniciId != null || yerelBasarili) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aktifKullanici', kullaniciAdi);
      if (kullaniciId != null) {
        await prefs.setInt('kullaniciId', kullaniciId);
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnaEkran()),
        );
      }
    } else {
      setState(() => _hatali = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.shieldCheck, size: 64, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yönetici Girişi',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sisteme erişmek için bilgilerinizi girin',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    labelStyle: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    prefixIcon: const Icon(LucideIcons.user, color: AppTheme.primaryColor, size: 20),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    labelStyle: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    prefixIcon: const Icon(LucideIcons.lock, color: AppTheme.primaryColor, size: 20),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
                if (_hatali) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.alertCircle, color: AppTheme.dangerColor, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hatalı kullanıcı adı veya şifre!',
                            style: TextStyle(color: AppTheme.dangerColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _girisYap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: const Text('SİSTEME GİRİŞ YAP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KayitEkrani()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('KAYIT OL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}