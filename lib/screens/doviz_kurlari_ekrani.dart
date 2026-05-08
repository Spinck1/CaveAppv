import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class DovizKurlariEkrani extends StatefulWidget {
  const DovizKurlariEkrani({super.key});

  @override
  State<DovizKurlariEkrani> createState() => _DovizKurlariEkraniState();
}

class _DovizKurlariEkraniState extends State<DovizKurlariEkrani> {
  final CurrencyService _currencyService = CurrencyService();
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshRates();
    // 30 saniyede bir otomatik yenileme
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshRates();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshRates() async {
    setState(() => _loading = true);
    await _currencyService.fetchRates();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('TCMB CANLI DÖVİZ KURLARI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshRates,
            icon: Icon(LucideIcons.refreshCw, size: 20, color: _loading ? AppTheme.textMuted : AppTheme.primaryColor),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 24),
            _buildCurrencyCard('USD / TRY', _currencyService.usdTry, LucideIcons.dollarSign, Colors.blue),
            const SizedBox(height: 16),
            _buildCurrencyCard('EUR / TRY', _currencyService.eurTry, LucideIcons.euro, Colors.orange),
            const SizedBox(height: 32),
            _buildBusinessDecisionCard(),
            const Spacer(),
            _buildLastUpdateInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _currencyService.isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _currencyService.isConnected ? Colors.green : Colors.red, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            _currencyService.isConnected ? LucideIcons.wifi : LucideIcons.wifiOff,
            color: _currencyService.isConnected ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            _currencyService.isConnected ? 'TCMB Sunucusuna Bağlı' : 'Bağlantı Kesildi!',
            style: TextStyle(
              color: _currencyService.isConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(String pair, double rate, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Text(pair, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          Text(rate.toStringAsFixed(4), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildBusinessDecisionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.1), AppTheme.accentColor.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.briefcase, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 12),
              Text('İŞ KARARI TETİKLEYİCİSİ', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Lojistik Maliyet Optimizasyonu',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Uluslararası taşımacılık birim maliyeti, güncel kur (${_currencyService.usdTry.toStringAsFixed(2)}) üzerinden dinamik olarak hesaplanmaktadır. Kur artışı durumunda sistem otomatik olarak "Bekle" veya "Güzergah Değiştir" önerisi üretir.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdateInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Son Güncelleme: ${_currencyService.lastUpdate.hour.toString().padLeft(2, '0')}:${_currencyService.lastUpdate.minute.toString().padLeft(2, '0')}:${_currencyService.lastUpdate.second.toString().padLeft(2, '0')}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Veriler TCMB üzerinden 30 saniyede bir otomatik yenilenir.', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
