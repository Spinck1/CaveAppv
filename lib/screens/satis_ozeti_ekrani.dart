import 'package:flutter/material.dart';
import '../models/satis_kaydi.dart';
import '../models/urun_partisi.dart';
import '../models/fiyat_simulasyonu.dart';
import '../theme/app_theme.dart';
import '../services/currency_service.dart';
import 'ayarlar_ekrani.dart';

class SatisOzetiEkrani extends StatefulWidget {
  final List<SatisKaydi> satislar;
  final Map<String, List<UrunPartisi>> depoUrunleri;
  final List<String> depoAdlari;
  final Function(List<SatisKaydi>) onKaydet;
  final Function(Map<String, List<UrunPartisi>>) onDepoUrunleriGuncelle;

  const SatisOzetiEkrani({
    super.key,
    required this.satislar,
    required this.depoUrunleri,
    required this.depoAdlari,
    required this.onKaydet,
    required this.onDepoUrunleriGuncelle,
  });

  @override
  State<SatisOzetiEkrani> createState() => _SatisOzetiEkraniState();
}

class _SatisOzetiEkraniState extends State<SatisOzetiEkrani> {
  late List<SatisKaydi> _satislar;
  late Map<String, List<UrunPartisi>> _depoUrunleri;

  @override
  void initState() {
    super.initState();
    _satislar = List.from(widget.satislar);
    _depoUrunleri = Map.from(widget.depoUrunleri);
  }

  Map<String, dynamic> _getSatisOnerisi(UrunPartisi p) {
    final simVeriler = FiyatSimulasyonu.uret365GunlukVeri(p.urunAdi);
    final simdi = DateTime.now();
    final gunNo = simdi.difference(DateTime(simdi.year, 1, 1)).inDays + 1;

    // Önümüzdeki 60 gün içindeki en iyi fiyatı bulalım
    double maxFiyat = 0;
    int enIyiGun = gunNo;

    for (int i = 0; i < 60; i++) {
      int hedefGun = ((gunNo + i - 1) % 365);
      if (simVeriler[hedefGun].bizimFiyat > maxFiyat) {
        maxFiyat = simVeriler[hedefGun].bizimFiyat;
        enIyiGun = hedefGun + 1;
      }
    }

    // Mevcut durum
    bool simdiSat = false;
    String mesaj = "";

    // Puan düşükse veya mevcut fiyat max fiyata çok yakınsa şimdi sat
    if (p.toplamPuan < 50) {
      simdiSat = true;
      mesaj = t("Ürün kalitesi düşüyor, hemen satılması önerilir.");
    } else if (p.tahminiSatisFiyati >= maxFiyat * 0.96) {
      simdiSat = true;
      mesaj = t("Fiyat zirveye yakın, değerlendirmek için uygun zaman.");
    } else {
      simdiSat = false;
      final hedefTarih = DateTime(simdi.year, 1, 1).add(Duration(days: enIyiGun - 1));
      final aylar = [
        "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
      ];
      mesaj = "${hedefTarih.day} ${t(aylar[hedefTarih.month - 1])} ${t("tarihinde beklenen fiyat")}: ₺${maxFiyat.toStringAsFixed(2)}";
    }

    return {
      'simdiSat': simdiSat,
      'mesaj': mesaj,
      'enIyiGun': enIyiGun,
    };
  }

  double get _toplamGelir => _satislar.fold(0, (sum, s) => sum + s.toplamFiyat);

  List<UrunPartisi> get _tumPartiler {
    final list = <UrunPartisi>[];
    _depoUrunleri.forEach((_, partiler) => list.addAll(partiler));
    return list;
  }

  void _oneriFiyatGoster() {
    final partiler = _tumPartiler;
    if (partiler.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Depoda ürün bulunmuyor!")));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                SizedBox(width: 10),
                Text(
                  t("Önerilen Satış Fiyatları"),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Puanınıza göre hesaplanan önerilen birim fiyatları:",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: partiler.length,
                itemBuilder: (context, index) {
                  final p = partiler[index];
                  final oneriFiyat = p.tahminiSatisFiyati;
                  final toplamGelir = p.miktar * oneriFiyat;
                  final kar = toplamGelir - p.toplamMaliyet;
                  final Color puanRenk = p.toplamPuan >= 70
                      ? const Color(0xFF4CAF50)
                      : p.toplamPuan >= 40
                      ? const Color(0xFFFF9800)
                      : const Color(0xFFFF5252);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.scaffoldBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: puanRenk.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: puanRenk, width: 2.5),
                                color: puanRenk.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: Text(
                                  p.toplamPuan.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: puanRenk,
                                    fontSize: 14,
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
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          t(p.urunAdi),
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: puanRenk.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          p.puanSeviyesi,
                                          style: TextStyle(
                                            color: puanRenk,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${p.miktar} ${p.birim} • Alış: ₺${p.alisFiyati.toStringAsFixed(2)}/${p.birim}",
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t("Önerilen Fiyat"),
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  "₺${oneriFiyat.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  "\$${(oneriFiyat / CurrencyService().usdTry).toStringAsFixed(2)} | €${(oneriFiyat / CurrencyService().eurTry).toStringAsFixed(2)}",
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  t("Tahmini Gelir"),
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  "₺${toplamGelir.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "\$${(toplamGelir / CurrencyService().usdTry).toStringAsFixed(2)} | €${(toplamGelir / CurrencyService().eurTry).toStringAsFixed(2)}",
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  t("Tahmini Kar"),
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  "₺${kar.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: kar >= 0
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFFF5252),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "\$${(kar / CurrencyService().usdTry).toStringAsFixed(2)} | €${(kar / CurrencyService().eurTry).toStringAsFixed(2)}",
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppTheme.surfaceLight),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final oneri = _getSatisOnerisi(p);
                            final bool simdiSat = oneri['simdiSat'];
                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (simdiSat
                                            ? const Color(0xFFFF5252)
                                            : const Color(0xFF4CAF50))
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (simdiSat
                                              ? const Color(0xFFFF5252)
                                              : const Color(0xFF4CAF50))
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        simdiSat
                                            ? Icons.flash_on_rounded
                                            : Icons.timer_rounded,
                                        size: 14,
                                        color: simdiSat
                                            ? const Color(0xFFFF5252)
                                            : const Color(0xFF4CAF50),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        simdiSat ? t("ŞİMDİ SAT") : t("BEKLE"),
                                        style: TextStyle(
                                          color: simdiSat
                                              ? const Color(0xFFFF5252)
                                              : const Color(0xFF4CAF50),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    oneri['mesaj'],
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _eldenSatisGir() {
    if (_depoUrunleri.isEmpty ||
        _depoUrunleri.values.every((list) => list.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Depoda satılacak stok bulunmuyor!")),
      );
      return;
    }

    String secilenDepoId = _depoUrunleri.keys.firstWhere(
      (k) => _depoUrunleri[k]!.isNotEmpty,
    );
    UrunPartisi secilenParti = _depoUrunleri[secilenDepoId]!.first;

    final miktarController = TextEditingController();
    final fiyatController = TextEditingController(
      text: secilenParti.tahminiSatisFiyati.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                t("Elden Satış Gir"),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: AppTheme.cardBackground,
                      isExpanded: true,
                      initialValue: secilenDepoId,
                      items: _depoUrunleri.keys
                          .where((k) => _depoUrunleri[k]!.isNotEmpty)
                          .map((k) {
                            final depoIdx = _depoUrunleri.keys.toList().indexOf(
                              k,
                            );
                            final depoAd = depoIdx < widget.depoAdlari.length
                                ? widget.depoAdlari[depoIdx]
                                : k;
                            return DropdownMenuItem(
                              value: k,
                              child: Text(
                                depoAd,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (val) {
                        if (val != null && _depoUrunleri[val]!.isNotEmpty) {
                          setDialogState(() {
                            secilenDepoId = val;
                            secilenParti = _depoUrunleri[val]!.first;
                            fiyatController.text = secilenParti
                                .tahminiSatisFiyati
                                .toStringAsFixed(2);
                          });
                        }
                      },
                      decoration: InputDecoration(labelText: t("Depo Seçin")),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UrunPartisi>(
                      dropdownColor: AppTheme.cardBackground,
                      isExpanded: true,
                      initialValue: secilenParti,
                      items: _depoUrunleri[secilenDepoId]!
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                "${t(p.urunAdi)} (${p.miktar} ${p.birim}) - %${p.toplamPuan.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            secilenParti = val;
                            fiyatController.text = secilenParti
                                .tahminiSatisFiyati
                                .toStringAsFixed(2);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: t("Satılacak Parti (Stok)"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Miktar ayarı slider + text field
                    Text(
                      "Stokta: ${secilenParti.miktar.toStringAsFixed(1)} ${secilenParti.birim}",
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: miktarController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: t("Satılacak Miktar"),
                        suffixText: secilenParti.birim,
                        suffixIcon: TextButton(
                          onPressed: () => miktarController.text = secilenParti
                              .miktar
                              .toStringAsFixed(1),
                          child: Text(
                            t("Tümü"),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fiyatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: t("Birim Fiyatı (₺)"),
                        helperText:
                            "Önerilen: ₺${secilenParti.tahminiSatisFiyati.toStringAsFixed(2)} | \$${(secilenParti.tahminiSatisFiyati / CurrencyService().usdTry).toStringAsFixed(2)} | €${(secilenParti.tahminiSatisFiyati / CurrencyService().eurTry).toStringAsFixed(2)}",
                        helperStyle: const TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    t("İptal"),
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                  onPressed: () {
                    double? m = double.tryParse(miktarController.text);
                    double? f = double.tryParse(fiyatController.text);
                    if (m != null &&
                        f != null &&
                        m > 0 &&
                        m <= secilenParti.miktar) {
                      final satis = SatisKaydi(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        depoAdi: "Elden Satış",
                        urunAdi: t(secilenParti.urunAdi),
                        miktar: m,
                        birim: secilenParti.birim,
                        birimFiyat: f,
                        aciklama: "Manuel Satış Eklendi",
                      );

                      setState(() {
                        _satislar.add(satis);
                        secilenParti.miktar -= m;
                        if (secilenParti.miktar <= 0) {
                          _depoUrunleri[secilenDepoId]!.remove(secilenParti);
                        }
                      });
                      widget.onKaydet(_satislar);
                      widget.onDepoUrunleriGuncelle(_depoUrunleri);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Geçersiz miktar! Stoktan büyük olamaz.",
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    t("Satışı Tamamla"),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _satisSil(int index) {
    setState(() => _satislar.removeAt(index));
    widget.onKaydet(_satislar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t("Satış ve Stok Yönetimi"),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Butonlar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _oneriFiyatGoster,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                      t("Önerilen Fiyatlar"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _eldenSatisGir,
                    icon: const Icon(
                      Icons.handshake_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      t("Elden Satış Gir"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Özet Kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t("Toplam Gelir"),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₺${_toplamGelir.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "\$${(_toplamGelir / CurrencyService().usdTry).toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "€${(_toplamGelir / CurrencyService().eurTry).toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "${_satislar.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      t("satış"),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Satış listesi
          Expanded(
            child: _satislar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t("Henüz satış kaydı yok"),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _satislar.length,
                    itemBuilder: (context, index) {
                      final satis = _satislar[_satislar.length - 1 - index];
                      final actualIndex = _satislar.length - 1 - index;
                      return Dismissible(
                        key: Key(satis.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _satisSil(actualIndex),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryLight.withValues(
                                alpha: 0.1,
                              ),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_rounded,
                                color: AppTheme.accentColor,
                              ),
                            ),
                            title: Text(
                              t(satis.urunAdi),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "${satis.miktar} ${satis.birim} • ${satis.depoAdi}",
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                if (satis.aciklama != null)
                                  Text(
                                    satis.aciklama!,
                                    style: TextStyle(
                                      color: AppTheme.textMuted.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Text(
                              "₺${satis.toplamFiyat.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
