import 'dart:math' as math;

class UrunPartisi {
  String id;
  String urunAdi;
  double miktar; // kg
  String birim;
  double alisFiyati; // birim fiyat TL
  DateTime gelisTarihi;
  DateTime? sonPuanGuncelleme;

  // Geliş anındaki depo koşulları
  double gelisSicaklik;
  double gelisNem;
  double gelisIsik;

  // Anlık puanlama verileri
  double sicaklikPuani;
  double nemPuani;
  double makasPuani; // Eskiden isik/sure idi, şimdi makas
  double toplamPuan; // 0-100
  String kararDestekMesaji = ''; // Insight metni
  String? aciklama; // Kullanıcı açıklaması
  DateTime? kritikSicaklikBaslangici;
  double yasCezasi;
  double sonBorsaFiyati; // Son görülen piyasa değeri

  // Puan geçmişi (zaman damgalı)
  List<PuanKaydi> puanGecmisi;

  UrunPartisi({
    required this.id,
    required this.urunAdi,
    required this.miktar,
    this.birim = 'kg',
    required this.alisFiyati,
    DateTime? gelisTarihi,
    this.gelisSicaklik = 0,
    this.gelisNem = 0,
    this.gelisIsik = 0,
    this.sicaklikPuani = 30,
    this.nemPuani = 20,
    this.makasPuani = 50,
    this.toplamPuan = 100,
    this.sonPuanGuncelleme,
    this.kritikSicaklikBaslangici,
    this.yasCezasi = 0,
    double sonBorsaFiyati = 0,
    this.aciklama,
    List<PuanKaydi>? puanGecmisi,
  })  : gelisTarihi = gelisTarihi ?? DateTime.now(),
        sonBorsaFiyati = sonBorsaFiyati != 0 ? sonBorsaFiyati : alisFiyati * 1.2,
        puanGecmisi = puanGecmisi ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'urunAdi': urunAdi,
    'miktar': miktar,
    'birim': birim,
    'alisFiyati': alisFiyati,
    'gelisTarihi': gelisTarihi.toIso8601String(),
    'gelisSicaklik': gelisSicaklik,
    'gelisNem': gelisNem,
    'gelisIsik': gelisIsik,
    'toplamPuan': toplamPuan,
    'aciklama': aciklama,
    'puanGecmisi': puanGecmisi.map((p) => p.toJson()).toList(),
    'sonBorsaFiyati': sonBorsaFiyati,
  };

  factory UrunPartisi.fromJson(Map<String, dynamic> json) => UrunPartisi(
    id: json['id'],
    urunAdi: json['urunAdi'],
    miktar: (json['miktar'] ?? 0.0).toDouble(),
    birim: json['birim'] ?? 'kg',
    alisFiyati: (json['alisFiyati'] ?? 0.0).toDouble(),
    gelisTarihi: DateTime.parse(json['gelisTarihi']),
    gelisSicaklik: (json['gelisSicaklik'] ?? 0.0).toDouble(),
    gelisNem: (json['gelisNem'] ?? 0.0).toDouble(),
    gelisIsik: (json['gelisIsik'] ?? 0.0).toDouble(),
    toplamPuan: (json['toplamPuan'] ?? 100.0).toDouble(),
    aciklama: json['aciklama'],
    puanGecmisi: (json['puanGecmisi'] as List? ?? [])
        .map((p) => PuanKaydi.fromJson(p))
        .toList(),
    sonBorsaFiyati: (json['sonBorsaFiyati'] ?? 0.0).toDouble(),
  );

  /// Depodaki kalış süresi
  Duration get depodaKalisSuresi => DateTime.now().difference(gelisTarihi);

  /// Saat cinsinden kalış süresi
  double get depodaKalisSaati => depodaKalisSuresi.inMinutes / 60.0;

  /// Toplam maliyet
  double get toplamMaliyet => miktar * alisFiyati;

  double get tahminiSatisFiyati {
    // Puan yükseldikçe piyasa fiyatı üzerinden prim yapar
    // Eğer borsa fiyatı henüz gelmediyse alış fiyatı üzerinden tahmin et
    double temelFiyat = sonBorsaFiyati > 0 ? sonBorsaFiyati : alisFiyati * 1.2;
    double prim = (toplamPuan / 100) * 0.4; // %40'a kadar kalite primi
    return temelFiyat * (1.0 + prim);
  }

  /// Tahmini toplam gelir
  double get tahminiToplamGelir => miktar * tahminiSatisFiyati;

  /// Tahmini kar
  double get tahminiKar => tahminiToplamGelir - toplamMaliyet;

  /// Puan seviyesi etiketi
  String get puanSeviyesi {
    if (toplamPuan >= 85) return 'Premium';
    if (toplamPuan >= 70) return 'A Kalite';
    if (toplamPuan >= 50) return 'B Kalite';
    if (toplamPuan >= 30) return 'C Kalite';
    return 'Düşük';
  }

  void puanGuncelle(double depoSicaklik, double depoNem, double depoIsik, double tazeBorsaFiyati, double normalBorsaFiyati) {
    List<String> insights = [];
    yasCezasi = 0;
    
    // === YAŞ CEZASI (5 AY KONTROL) ===
    if (depodaKalisSuresi.inDays > 150) {
      yasCezasi = 20.0;
      insights.add(t('Aşırı beklemiş ürün (>5 ay), -20 İhracat Ceza Puanı!'));
    }

    // === SICAKLIK PUANLAMA (Max 30) ===
    double sicaklikCezasi = 0;
    bool isTohum = urunAdi.toLowerCase().contains('tohum') || urunAdi.toLowerCase().contains('ohum');
    
    if (isTohum) {
      // Tohumluk/Ohum Deposu: 2-4°C mükemmel
      if (depoSicaklik >= 2.0 && depoSicaklik <= 4.0) {
        sicaklikPuani = 30.0;
      } else {
        sicaklikCezasi = (depoSicaklik - 3.0).abs() * 5.0;
        sicaklikPuani = (30.0 - sicaklikCezasi).clamp(0, 30);
      }
    } else {
      // Normal Sofralık/Sanayilik: 6-8°C güzel
      if (depoSicaklik >= 6.0 && depoSicaklik <= 8.0) {
        sicaklikPuani = 30.0;
      } else if (depoSicaklik > 8.0 && depoSicaklik <= 10.0) {
        sicaklikCezasi = 5.0; // Ufak bir düşüş
        sicaklikPuani = (30.0 - sicaklikCezasi).clamp(0, 30);
      } else {
        sicaklikCezasi = (depoSicaklik - 7.0).abs() * 3.0;
        sicaklikPuani = (30.0 - sicaklikCezasi).clamp(0, 30);
      }
    }

    // Kritik Sıcaklık ve Tolerans (>10°C)
    if (depoSicaklik > 10.0) {
      insights.add(t('Sıcaklık 10°C üstünde! Filizlenme başlayabilir!'));
      kritikSicaklikBaslangici ??= DateTime.now();
      int gecenSaniye = DateTime.now().difference(kritikSicaklikBaslangici!).inSeconds;
      
      // 6 saat tolerans = 21600 saniye. 
      // Test için 60 saniye yapalım mı? Hayır, kullanıcı 6 saat dedi.
      if (gecenSaniye > 21600) { 
        int ekPeriyot = (gecenSaniye - 21600) ~/ 21600; // Her 6 saatte bir
        double ekCeza = 5.0 + (ekPeriyot * 5.0);
        sicaklikPuani = (sicaklikPuani - ekCeza).clamp(0, 30);
        insights.add(t('Kritik sıcaklık toleransı aşıldı! Ceza: -') + ekCeza.toStringAsFixed(0));
      }
    } else {
      kritikSicaklikBaslangici = null;
    }

    // === NEM PUANLAMA (Max 20) ===
    if (depoNem >= 90.0 && depoNem <= 95.0) {
      // Muazzam
      nemPuani = 20.0;
    } else if (depoNem > 95.0 && depoNem <= 98.0) {
      // Kabul edilebilir
      nemPuani = 18.0;
    } else if (depoNem > 98.0) {
      // Aşırı nem
      nemPuani = 10.0;
      insights.add(t('Aşırı nem uyarısı!'));
    } else if (depoNem < 85.0) {
      // Nem az
      nemPuani = 10.0;
      insights.add(t('Nem az uyarısı!'));
    } else if (depoNem >= 85.0 && depoNem < 90.0) {
      // Kabul edilebilir ama etkiler
      nemPuani = 15.0;
    }

    // === IŞIK PUANLAMA (Max 10 - MakasPuani içinde 50 üzerinden değerlendirelim) ===
    double isikPuaniDili = 0;
    if (depoIsik < 5.0) {
      isikPuaniDili = 10.0;
    } else if (depoIsik >= 5.0 && depoIsik <= 50.0) {
      isikPuaniDili = 8.0;
      insights.add(t('Işık sızıntısı var!'));
    } else {
      isikPuaniDili = 0.0;
      insights.add(t('KRİTİK: Işık seviyesi çok yüksek! Acil müdahale gerekli!'));
    }

    // === MEVSİMSEL MAKAS VE IŞIK BİRLEŞİMİ (Max 50) ===
    double makasCezasi = 0;
    bool isTaze = urunAdi.toLowerCase().contains('patates') && depodaKalisSuresi.inDays < 90;
    if (!isTaze) {
      double fiyatFarki = (tazeBorsaFiyati - normalBorsaFiyati).abs();
      if (fiyatFarki > 2.0) {
        makasCezasi = math.log(fiyatFarki) * 10.0;
      }
    }
    // Işık %20 (10 puan), Makas %80 (40 puan)
    makasPuani = (40.0 - makasCezasi).clamp(0, 40) + isikPuaniDili;

    // === TOPLAM PUAN ===
    toplamPuan = (sicaklikPuani + nemPuani + makasPuani - yasCezasi).clamp(0, 100);
    
    kararDestekMesaji = insights.isNotEmpty ? insights.join(' ') : t('Depo koşulları optimal.');

    sonPuanGuncelleme = DateTime.now();
    puanGecmisi.add(PuanKaydi(
      tarih: DateTime.now(),
      sicaklikPuani: sicaklikPuani,
      nemPuani: nemPuani,
      isikPuani: isikPuaniDili,
      surePuani: 0,
      toplamPuan: toplamPuan,
      depoSicaklik: depoSicaklik,
      depoNem: depoNem,
      depoIsik: depoIsik,
    ));
    if (puanGecmisi.length > 100) {
      puanGecmisi = puanGecmisi.sublist(puanGecmisi.length - 100);
    }
  }

  // Translation helper (Model içinde olması pek iyi değil ama mevcut yapıya uyum sağlıyoruz)
  String t(String key) => key;
}

class PuanKaydi {
  final DateTime tarih;
  final double sicaklikPuani;
  final double nemPuani;
  final double isikPuani;
  final double surePuani;
  final double toplamPuan;
  final double depoSicaklik;
  final double depoNem;
  final double depoIsik;

  PuanKaydi({
    required this.tarih,
    required this.sicaklikPuani,
    required this.nemPuani,
    required this.isikPuani,
    required this.surePuani,
    required this.toplamPuan,
    required this.depoSicaklik,
    required this.depoNem,
    required this.depoIsik,
  });

  Map<String, dynamic> toJson() => {
    'tarih': tarih.toIso8601String(),
    'sicaklikPuani': sicaklikPuani,
    'nemPuani': nemPuani,
    'isikPuani': isikPuani,
    'surePuani': surePuani,
    'toplamPuan': toplamPuan,
    'depoSicaklik': depoSicaklik,
    'depoNem': depoNem,
    'depoIsik': depoIsik,
  };

  factory PuanKaydi.fromJson(Map<String, dynamic> json) => PuanKaydi(
    tarih: DateTime.parse(json['tarih']),
    sicaklikPuani: (json['sicaklikPuani'] ?? 0.0).toDouble(),
    nemPuani: (json['nemPuani'] ?? 0.0).toDouble(),
    isikPuani: (json['isikPuani'] ?? 0.0).toDouble(),
    surePuani: (json['surePuani'] ?? 0.0).toDouble(),
    toplamPuan: (json['toplamPuan'] ?? 0.0).toDouble(),
    depoSicaklik: (json['depoSicaklik'] ?? 0.0).toDouble(),
    depoNem: (json['depoNem'] ?? 0.0).toDouble(),
    depoIsik: (json['depoIsik'] ?? 0.0).toDouble(),
  );
}
