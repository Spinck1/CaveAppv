import 'package:flutter/material.dart';
import '../models/piyasa_degeri.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import 'urun_analiz_ekrani.dart';
import 'ayarlar_ekrani.dart';

class PiyasaEkrani extends StatefulWidget {
  final List<PiyasaDegeri> piyasalar;
  final List<Sirket> sirketler;

  const PiyasaEkrani({
    super.key,
    required this.piyasalar,
    required this.sirketler,
  });

  @override
  State<PiyasaEkrani> createState() => _PiyasaEkraniState();
}

class _PiyasaEkraniState extends State<PiyasaEkrani>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _secilenKategori = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PiyasaDegeri> get _filtrelenmis {
    if (_secilenKategori == 'Tümü') return widget.piyasalar;
    return widget.piyasalar
        .where((p) => p.kategori == _secilenKategori)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Üst bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppTheme.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t('Piyasa & Alıcılar'),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(text: '📊 ${t('Piyasa')}'),
                    Tab(text: '🏢 ${t('Alıcılar')}'),
                    Tab(text: '📈 ${t('Analiz')}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPiyasaTab(),
                    _buildSirketTab(),
                    const UrunAnalizEkrani(isEmbedded: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPiyasaTab() {
    final kategoriler = [
      t('Tümü'),
      t('Sebze'),
      t('Meyve'),
      t('Tahıl'),
      t('Bakliyat'),
    ];
    // Map selected translated category back to data category for filtering
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kategoriler.length,
            itemBuilder: (_, i) {
              final k = kategoriler[i];
              final s = k == _secilenKategori;
              return GestureDetector(
                onTap: () => setState(() => _secilenKategori = k),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: s ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: s ? AppTheme.primaryLight : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    k,
                    style: TextStyle(
                      color: s ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtrelenmis.length,
            itemBuilder: (_, i) {
              final p = _filtrelenmis[i];
              final artis = p.degisimYuzdesi >= 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (artis
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF5252))
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        artis
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: artis
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF5252),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(p.urunAdi),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            t(p.kategori),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₺${p.guncelFiyat.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\$${(p.guncelFiyat / CurrencyService().usdTry).toStringAsFixed(2)} | €${(p.guncelFiyat / CurrencyService().eurTry).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${artis ? '+' : ''}${p.degisimYuzdesi.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: artis
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF5252),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSirketTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.sirketler.length,
      itemBuilder: (_, i) {
        final s = widget.sirketler[i];
        Color katRenk;
        if (s.kategori.contains('Premium')) {
          katRenk = const Color(0xFFFFD700);
        } else if (s.kategori.contains('A Kalite')) {
          katRenk = const Color(0xFF4CAF50);
        } else if (s.kategori.contains('B Kalite')) {
          katRenk = const Color(0xFF42A5F5);
        } else if (s.kategori.contains('Standart')) {
          katRenk = const Color(0xFFFF9800);
        } else {
          katRenk = AppTheme.textMuted;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: katRenk.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.logoIcon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.ad,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t(s.ulke),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: katRenk.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        t(s.kategori),
                        style: TextStyle(
                          color: katRenk,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppTheme.lightColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${t('Min Puan')}: ${s.minPuan.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.monetization_on_rounded,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${t('Fiyat Çarpanı')}: x${s.birimFiyatCarpani.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: s.ilgiAlanlari
                      .map(
                        (u) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t(u),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
