import 'package:flutter/material.dart';
import '../models/urun_partisi.dart';
import '../models/piyasa_degeri.dart';
import '../models/depo.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import 'ayarlar_ekrani.dart';

class IhracatPuaniEkrani extends StatefulWidget {
  final List<Depo> depolar;
  final Map<String, List<UrunPartisi>> depoUrunleri;
  final List<Sirket> sirketler;

  const IhracatPuaniEkrani({
    super.key,
    required this.depolar,
    required this.depoUrunleri,
    required this.sirketler,
  });

  @override
  State<IhracatPuaniEkrani> createState() => _IhracatPuaniEkraniState();
}

class _IhracatPuaniEkraniState extends State<IhracatPuaniEkrani> {
  String? _secilenDepoId;

  @override
  void initState() {
    super.initState();
    if (widget.depolar.isNotEmpty) _secilenDepoId = widget.depolar.first.id;
  }

  List<UrunPartisi> get _partiler =>
      _secilenDepoId == null ? [] : (widget.depoUrunleri[_secilenDepoId] ?? []);

  double get _genelSkor {
    if (_partiler.isEmpty) return 0;
    double toplamAgirlikliPuan = 0;
    double toplamMiktar = 0;
    for (var p in _partiler) {
      toplamAgirlikliPuan += p.toplamPuan * p.miktar;
      toplamMiktar += p.miktar;
    }
    return toplamMiktar > 0 ? toplamAgirlikliPuan / toplamMiktar : 0;
  }

  Color _puanRengi(double puan) {
    if (puan >= 80) return const Color(0xFF4CAF50);
    if (puan >= 60) return const Color(0xFF8BC34A);
    if (puan >= 40) return const Color(0xFFFFCA28);
    if (puan >= 20) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }

  String _puanSeviyesi(double puan) {
    if (puan >= 85) return 'Premium';
    if (puan >= 70) return 'A Kalite';
    if (puan >= 50) return 'B Kalite';
    if (puan >= 30) return 'C Kalite';
    return 'Düşük';
  }

  @override
  Widget build(BuildContext context) {
    final genelRenk = _puanRengi(_genelSkor);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
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
                        t('İhracat Puanı'),
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
              // Depo seçici
              if (widget.depolar.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.depolar.length,
                    itemBuilder: (_, i) {
                      final d = widget.depolar[i];
                      final s = d.id == _secilenDepoId;
                      return GestureDetector(
                        onTap: () => setState(() => _secilenDepoId = d.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: s
                                ? AppTheme.primaryColor
                                : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: s
                                  ? AppTheme.primaryLight
                                  : AppTheme.primaryLight.withValues(
                                      alpha: 0.15,
                                    ),
                              width: s ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            d.ad,
                            style: TextStyle(
                              color: s ? Colors.white : AppTheme.textMuted,
                              fontWeight: s ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _partiler.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: AppTheme.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('Bu depoda henüz ürün yok'),
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t('Önce Ürün Giriş ekranından ürün ekleyin'),
                              style: TextStyle(
                                color: AppTheme.textMuted.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Genel skor kartı
                          _buildGenelSkorKarti(genelRenk),
                          const SizedBox(height: 16),
                          // Uygun alıcılar
                          _buildAlicilarKarti(),
                          const SizedBox(height: 16),
                          // Parti listesi başlığı
                          Row(
                            children: [
                              const Icon(
                                Icons.list_alt_rounded,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${t('Parti Bazlı Puanlar')} (${_partiler.length} ${t('parti')})',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._partiler.asMap().entries.map(
                            (e) => _buildPartiDetay(e.value, e.key),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenelSkorKarti(Color renk) {
    // Dinamik İçgörü (Insight) Metni Belirleme
    String insightMesaji = 'Optimal: Depo koşulları stabil.';
    if (_partiler.isNotEmpty) {
      final ornekParti = _partiler.first;
      if (ornekParti.kararDestekMesaji.isNotEmpty) {
        insightMesaji = ornekParti.kararDestekMesaji;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [renk.withValues(alpha: 0.2), AppTheme.cardBackground],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: renk.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            t('KARAR DESTEK & İHRACAT SKORU'),
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          // Büyük animasyonlu skor göstergesi
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _genelSkor),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              Color animRenk = _puanRengi(value);
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: value / 100,
                      strokeWidth: 12,
                      backgroundColor: animRenk.withValues(alpha: 0.1),
                      color: animRenk,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          color: animRenk,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _puanSeviyesi(value),
                        style: TextStyle(
                          color: animRenk.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          // Insight Metni
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: renk.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: renk, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t(insightMesaji),
                    style: TextStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // İstatistikler
          Row(
            children: [
              _statKart(
                t('Toplam Parti'),
                '${_partiler.length}',
                Icons.inventory_rounded,
                AppTheme.primaryLight,
              ),
              const SizedBox(width: 10),
              _statKart(
                t('Toplam Miktar'),
                '${_partiler.fold<double>(0, (s, p) => s + p.miktar).toStringAsFixed(0)} kg',
                Icons.scale_rounded,
                AppTheme.humidityColor,
              ),
              const SizedBox(width: 10),
              _statKart(
                t('Tahmini Gelir'),
                '₺${_partiler.fold<double>(0, (s, p) => s + p.tahminiToplamGelir).toStringAsFixed(0)}',
                Icons.attach_money_rounded,
                AppTheme.accentColor,
                extra: '\$${(_partiler.fold<double>(0, (s, p) => s + p.tahminiToplamGelir) / CurrencyService().usdTry).toStringAsFixed(0)} | €${(_partiler.fold<double>(0, (s, p) => s + p.tahminiToplamGelir) / CurrencyService().eurTry).toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statKart(String baslik, String deger, IconData icon, Color renk, {String? extra}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: renk, size: 20),
            const SizedBox(height: 6),
            Text(
              deger,
              style: TextStyle(
                color: renk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (extra != null)
              Text(
                extra,
                style: TextStyle(color: renk.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 2),
            Text(
              baslik,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlicilarKarti() {
    final depo = widget.depolar.firstWhere(
      (d) => d.id == _secilenDepoId,
      orElse: () => widget.depolar.first,
    );
    final referansUrun = _partiler.isNotEmpty
        ? _partiler.first.urunAdi
        : 'Patates';
    final uygunSirketler = widget.sirketler;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.handshake_rounded,
                  color: AppTheme.accentColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  '${t('Alıcı Eşleştirme')} (${uygunSirketler.length})',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...uygunSirketler.map((s) {
            final aktif = s.aktifMi(
              _genelSkor,
              referansUrun,
              depo.nem,
              depo.isik,
            );
            final pasifNedeni = _aliciPasifNedeni(
              s,
              referansUrun,
              depo.nem,
              depo.isik,
            );
            Color katRenk;
            if (s.kategori.contains('Premium')) {
              katRenk = const Color(0xFFFFD700);
            } else if (s.kategori.contains('A Kalite')) {
              katRenk = const Color(0xFF4CAF50);
            } else if (s.kategori.contains('B Kalite')) {
              katRenk = const Color(0xFF42A5F5);
            } else {
              katRenk = AppTheme.textMuted;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(s.logoIcon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.ad,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${t(s.ulke)} • ${t(s.kategori)}',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        if (!aktif)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              t(pasifNedeni),
                              style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: katRenk.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      aktif ? t('aktif') : t('pasif'),
                      style: TextStyle(
                        color: katRenk,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _aliciPasifNedeni(Sirket s, String urunAdi, double nem, double isik) {
    if (!s.urunuAlirMi(_genelSkor, urunAdi)) {
      return '${t('Puan')} ${s.minPuan.toStringAsFixed(0)} ${t('altında veya ürün tercihi uyumsuz.')}';
    }
    if (!s.iklimKosullariUygunMu(nem, isik)) {
      return t('Alıcı koşulları sağlanmıyor.');
    }
    return t('Alıcı aktif durumda.');
  }

  Widget _buildPartiDetay(UrunPartisi p, int idx) {
    final c = _puanRengi(p.toplamPuan);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.15)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: AppTheme.textMuted,
        collapsedIconColor: AppTheme.textMuted,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c, width: 2.5),
                color: c.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  p.toplamPuan.toStringAsFixed(0),
                  style: TextStyle(
                    color: c,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t(p.urunAdi)} — ${p.miktar} ${p.birim}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${p.puanSeviyesi} • ₺${p.alisFiyati.toStringAsFixed(2)}/${p.birim}',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          // Detaylı puan tablosu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _puanSatir(
                  t('🌡️ Sıcaklık Puanı'),
                  p.sicaklikPuani,
                  30,
                  AppTheme.temperatureColor,
                ),
                const Divider(height: 12, color: Color(0xFF2A3F60)),
                _puanSatir(
                  t('💧 Nem Puanı'),
                  p.nemPuani,
                  20,
                  AppTheme.humidityColor,
                ),
                const Divider(height: 12, color: Color(0xFF2A3F60)),
                _puanSatir(
                  t('📈 Mevsimsel Makas'),
                  p.makasPuani,
                  50,
                  AppTheme.lightColor,
                ),
                const Divider(height: 12, color: Color(0xFF2A3F60)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.kararDestekMesaji,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16, color: Color(0xFF2A3F60)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('TOPLAM'),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${p.toplamPuan.toStringAsFixed(1)} / 100',
                      style: TextStyle(
                        color: c,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Mali bilgiler
          Row(
            children: [
              Expanded(
                child: _maliKart(
                  t('Maliyet'),
                  '₺${p.toplamMaliyet.toStringAsFixed(0)}',
                  const Color(0xFFFF9800),
                  usd: p.toplamMaliyet / CurrencyService().usdTry,
                  eur: p.toplamMaliyet / CurrencyService().eurTry,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _maliKart(
                  t('Tah. Satış'),
                  '₺${p.tahminiToplamGelir.toStringAsFixed(0)}',
                  AppTheme.accentColor,
                  usd: p.tahminiToplamGelir / CurrencyService().usdTry,
                  eur: p.tahminiToplamGelir / CurrencyService().eurTry,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _maliKart(
                  t('Tah. Kar'),
                  '₺${p.tahminiKar.toStringAsFixed(0)}',
                  p.tahminiKar >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                  usd: p.tahminiKar / CurrencyService().usdTry,
                  eur: p.tahminiKar / CurrencyService().eurTry,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Uygun alıcılar
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.sirketler
                .where((s) => s.urunuAlirMi(p.toplamPuan, p.urunAdi))
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${s.logoIcon} ${s.ad}',
                      style: TextStyle(
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
    );
  }

  Widget _puanSatir(String label, double puan, double max, Color renk) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (puan / max).clamp(0, 1),
              backgroundColor: renk.withValues(alpha: 0.1),
              color: renk,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 55,
          child: Text(
            '${puan.toStringAsFixed(1)}/$max',
            style: TextStyle(
              color: renk,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _maliKart(String baslik, String deger, Color renk, {double? usd, double? eur}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            baslik,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 9),
          ),
          const SizedBox(height: 4),
          Text(
            deger,
            style: TextStyle(
              color: renk,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (usd != null && eur != null)
            Text(
              '\$${usd.toStringAsFixed(0)} | €${eur.toStringAsFixed(0)}',
              style: TextStyle(color: renk.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
