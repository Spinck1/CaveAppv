import 'package:flutter/material.dart';
import '../models/urun_partisi.dart';
import '../models/depo.dart';
import '../models/fiyat_simulasyonu.dart';
import '../theme/app_theme.dart';

class UrunGirisEkrani extends StatefulWidget {
  final List<Depo> depolar;
  final Map<String, List<UrunPartisi>> depoUrunleri;
  final Function(Map<String, List<UrunPartisi>>) onKaydet;

  const UrunGirisEkrani({
    super.key,
    required this.depolar,
    required this.depoUrunleri,
    required this.onKaydet,
  });

  @override
  State<UrunGirisEkrani> createState() => _UrunGirisEkraniState();
}

class _UrunGirisEkraniState extends State<UrunGirisEkrani> {
  late Map<String, List<UrunPartisi>> _depoUrunleri;
  String? _secilenDepoId;

  @override
  void initState() {
    super.initState();
    _depoUrunleri = Map.from(widget.depoUrunleri);
    if (widget.depolar.isNotEmpty) {
      _secilenDepoId = widget.depolar.first.id;
    }
  }

  List<UrunPartisi> get _mevcutPartiler =>
      _secilenDepoId == null ? [] : (_depoUrunleri[_secilenDepoId] ?? []);

  Depo? get _secilenDepo {
    if (_secilenDepoId == null) return null;
    try {
      return widget.depolar.firstWhere((d) => d.id == _secilenDepoId);
    } catch (_) {
      return null;
    }
  }

  Color _puanRengi(double puan) {
    if (puan >= 80) return const Color(0xFF4CAF50);
    if (puan >= 60) return const Color(0xFF8BC34A);
    if (puan >= 40) return const Color(0xFFFFCA28);
    if (puan >= 20) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }

  String _formatSure(Duration sure) {
    if (sure.inDays > 0) return '${sure.inDays}g ${sure.inHours % 24}s';
    if (sure.inHours > 0) return '${sure.inHours}s ${sure.inMinutes % 60}dk';
    return '${sure.inMinutes}dk';
  }

  void _yeniPartiEkle() {
    if (_secilenDepo == null) return;
    final miktarCtrl = TextEditingController();
    final fiyatCtrl = TextEditingController();
    final aciklamaCtrl = TextEditingController();
    String birim = 'kg';
    String secilenUrun = 'Patates';
    DateTime secilenTarih = DateTime.now();
    final List<String> urunler = [
      'Patates',
      'Limon',
      'Greyfurt',
      'Soğan',
      'Domates',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart_rounded,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Yeni Ürün Partisi',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Depo: ${_secilenDepo!.ad} • ${_secilenDepo!.sicaklik.toStringAsFixed(1)}°C  %${_secilenDepo!.nem.toStringAsFixed(0)}  ${_secilenDepo!.isik.toStringAsFixed(0)}lux',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                // Ürün Adı Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A3F60)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: secilenUrun,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardBackground,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppTheme.primaryLight,
                      ),
                      items: urunler
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.inventory_2_rounded,
                                    size: 20,
                                    color: AppTheme.primaryLight,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(u),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setS(() => secilenUrun = v ?? secilenUrun),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tarih Seçici
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: secilenTarih,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.primaryColor,
                            onPrimary: Colors.white,
                            surface: AppTheme.cardBackground,
                            onSurface: AppTheme.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setS(() => secilenTarih = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A3F60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppTheme.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Geliş Tarihi: ${secilenTarih.day.toString().padLeft(2, '0')}/${secilenTarih.month.toString().padLeft(2, '0')}/${secilenTarih.year}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: miktarCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Miktar',
                          prefixIcon: Icon(
                            Icons.scale_rounded,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A3F60)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: birim,
                            isExpanded: true,
                            dropdownColor: AppTheme.cardBackground,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            items: ['kg', 'ton', 'adet', 'çuval']
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(b),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setS(() => birim = v ?? birim),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fiyatCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Alış Fiyatı (₺/birim)',
                    prefixIcon: Icon(
                      Icons.payments_rounded,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aciklamaCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (opsiyonel)',
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                      color: AppTheme.primaryLight,
                    ),
                    hintText: 'Örn: Niğde Bor ilçesinden alındı',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final m = double.tryParse(miktarCtrl.text);
                      final f = double.tryParse(fiyatCtrl.text);
                      if (m != null && f != null && m > 0) {
                        final p = UrunPartisi(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          urunAdi: secilenUrun,
                          miktar: m,
                          birim: birim,
                          alisFiyati: f,
                          gelisTarihi: secilenTarih,
                          gelisSicaklik: _secilenDepo!.sicaklik,
                          gelisNem: _secilenDepo!.nem,
                          gelisIsik: _secilenDepo!.isik,
                          aciklama: aciklamaCtrl.text.isNotEmpty
                              ? aciklamaCtrl.text
                              : null,
                        );
                        final sonGun =
                            FiyatSimulasyonu.uret365GunlukVeri().last;
                        p.puanGuncelle(
                          _secilenDepo!.sicaklik,
                          _secilenDepo!.nem,
                          _secilenDepo!.isik,
                          sonGun.tazeFiyat,
                          sonGun.normalFiyat,
                        );
                        setState(() {
                          _depoUrunleri.putIfAbsent(_secilenDepoId!, () => []);
                          _depoUrunleri[_secilenDepoId]!.add(p);
                        });
                        widget.onKaydet(_depoUrunleri);
                        Navigator.pop(ctx);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Partiyi Ekle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    const Expanded(
                      child: Text(
                        'Ürün Giriş',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                child: _mevcutPartiler.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_rounded,
                              size: 64,
                              color: AppTheme.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bu depoda ürün partisi yok',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _mevcutPartiler.length,
                        itemBuilder: (_, i) =>
                            _buildPartiKarti(_mevcutPartiler[i], i),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.depolar.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _yeniPartiEkle,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Yeni Parti',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildPartiKarti(UrunPartisi p, int idx) {
    final c = _puanRengi(p.toplamPuan);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c, width: 3),
                    color: c.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      p.toplamPuan.toStringAsFixed(0),
                      style: TextStyle(
                        color: c,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.urunAdi,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.puanSeviyesi,
                              style: TextStyle(
                                color: c,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.miktar} ${p.birim} • Alış: ₺${p.alisFiyati.toStringAsFixed(2)}/${p.birim}',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Depoda: ${_formatSure(p.depodaKalisSuresi)}',
                        style: TextStyle(
                          color: AppTheme.textMuted.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _depoUrunleri[_secilenDepoId]?.removeAt(idx);
                    });
                    widget.onKaydet(_depoUrunleri);
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _chip(
                      '🌡️ Sıcaklık',
                      p.sicaklikPuani,
                      30,
                      AppTheme.temperatureColor,
                    ),
                    const SizedBox(width: 6),
                    _chip('💧 Nem', p.nemPuani, 30, AppTheme.humidityColor),
                    const SizedBox(width: 6),
                    _chip('☀️ Makas', p.makasPuani, 50, AppTheme.lightColor),
                    const SizedBox(width: 6),
                    _chip('⏱️ Süre', 0, 20, const Color(0xFF9C27B0)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Maliyet: ₺${p.toplamMaliyet.toStringAsFixed(2)}',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    Text(
                      'Tahmini: ₺${p.tahminiSatisFiyati.toStringAsFixed(2)}/${p.birim}',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String l, double p, double m, Color c) => Expanded(
    child: Column(
      children: [
        Text(l, style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          '${p.toStringAsFixed(1)}/$m',
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (p / m).clamp(0, 1),
            backgroundColor: c.withValues(alpha: 0.1),
            color: c,
            minHeight: 3,
          ),
        ),
      ],
    ),
  );
}
