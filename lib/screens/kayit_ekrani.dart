import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();

  bool _yukleniyor = false;
  bool _sifreGizli = true;
  bool _sifreOnayGizli = true;
  String? _hataMesaji;
  String? _basariMesaji;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  Future<void> _kayitOl() async {
    final kullaniciAdi = _userController.text.trim();
    final sifre = _passController.text.trim();
    final sifreOnay = _passConfirmController.text.trim();

    setState(() {
      _hataMesaji = null;
      _basariMesaji = null;
    });

    if (kullaniciAdi.isEmpty || sifre.isEmpty || sifreOnay.isEmpty) {
      setState(() => _hataMesaji = 'Tüm alanları doldurunuz!');
      return;
    }
    if (kullaniciAdi.length < 3) {
      setState(() => _hataMesaji = 'Kullanıcı adı en az 3 karakter olmalı!');
      return;
    }
    if (sifre.length < 4) {
      setState(() => _hataMesaji = 'Şifre en az 4 karakter olmalı!');
      return;
    }
    if (sifre != sifreOnay) {
      setState(() => _hataMesaji = 'Şifreler eşleşmiyor!');
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:5000/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'kullanici_adi': kullaniciAdi,
              'sifre': sifre,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['basarili'] == true) {
        setState(() => _basariMesaji = 'Kayıt başarılı! Giriş yapabilirsiniz.');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _hataMesaji = data['mesaj'] ?? 'Kayıt başarısız!');
      }
    } on Exception catch (e) {
      setState(() => _hataMesaji = 'Sunucuya bağlanılamadı: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? gizliDurum,
    VoidCallback? onGizliToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ? (gizliDurum ?? true) : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (gizliDurum ?? true) ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
                onPressed: onGizliToggle,
              )
            : null,
      ),
      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Yeni Hesap Oluştur'),
      ),
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
                  child: const Icon(LucideIcons.userPlus, size: 64, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sisteme kayıt olmak için bilgilerinizi girin',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildField(
                  controller: _userController,
                  label: 'Kullanıcı Adı',
                  icon: LucideIcons.user,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _passController,
                  label: 'Şifre',
                  icon: LucideIcons.lock,
                  obscure: true,
                  gizliDurum: _sifreGizli,
                  onGizliToggle: () => setState(() => _sifreGizli = !_sifreGizli),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _passConfirmController,
                  label: 'Şifre Tekrar',
                  icon: LucideIcons.lock,
                  obscure: true,
                  gizliDurum: _sifreOnayGizli,
                  onGizliToggle: () => setState(() => _sifreOnayGizli = !_sifreOnayGizli),
                ),

                if (_hataMesaji != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle, color: AppTheme.dangerColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _hataMesaji!,
                            style: const TextStyle(
                              color: AppTheme.dangerColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_basariMesaji != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle, color: AppTheme.successColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _basariMesaji!,
                            style: const TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
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
                    onPressed: _yukleniyor ? null : _kayitOl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: _yukleniyor
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'KAYIT OL',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Zaten hesabın var mı? Giriş yap',
                    style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
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
