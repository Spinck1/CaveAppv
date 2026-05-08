import 'dart:math';
import 'fiyat_simulasyonu.dart';

class PiyasaDegeri {
  String urunAdi;
  double guncelFiyat; // TL/kg
  double degisimYuzdesi; // Son değişim %
  String kategori;
  String birim;
  DateTime sonGuncelleme;

  PiyasaDegeri({
    required this.urunAdi,
    required this.guncelFiyat,
    this.degisimYuzdesi = 0,
    required this.kategori,
    this.birim = 'TL/kg',
    DateTime? sonGuncelleme,
  }) : sonGuncelleme = sonGuncelleme ?? DateTime.now();

  bool get artista => degisimYuzdesi > 0;
  bool get dususte => degisimYuzdesi < 0;
}

class Sirket {
  String ad;
  String ulke;
  String kategori;
  double minPuan; // Minimum kabul ettikleri ihracat puanı
  double birimFiyatCarpani; // Puan çarpanı
  String logoIcon;
  List<String> ilgiAlanlari;
  bool organikSertifikaGerekli;
  bool dusukIsikGerekli;
  bool sabitNemIstiyor;
  double? minNem;
  double? maxNem;

  Sirket({
    required this.ad,
    required this.ulke,
    required this.kategori,
    required this.minPuan,
    required this.birimFiyatCarpani,
    this.logoIcon = '🏢',
    required this.ilgiAlanlari,
    this.organikSertifikaGerekli = false,
    this.dusukIsikGerekli = false,
    this.sabitNemIstiyor = false,
    this.minNem,
    this.maxNem,
  });

  bool urunuAlirMi(double puan, String urunAdi) {
    return puan >= minPuan && ilgiAlanlari.any((u) => urunAdi.toLowerCase().contains(u.toLowerCase()));
  }

  bool iklimKosullariUygunMu(double nem, double isik) {
    if (sabitNemIstiyor) {
      if (minNem == null || maxNem == null) return false;
      if (nem < minNem! || nem > maxNem!) return false;
    }
    if (dusukIsikGerekli) {
      if (isik > 300) return false;
    }
    return true;
  }

  bool aktifMi(double puan, String urunAdi, double nem, double isik) {
    return urunuAlirMi(puan, urunAdi) && iklimKosullariUygunMu(nem, isik);
  }

  double teklifFiyati(double birimFiyat, double puan) {
    if (puan < minPuan) return 0;
    double puanCarpani = 1.0 + (puan / 100) * birimFiyatCarpani;
    return birimFiyat * puanCarpani;
  }
}

class PiyasaVerisi {
  static final Random _random = Random();

  /// Örnek piyasa değerleri oluştur
  static List<PiyasaDegeri> ornekPiyasaDegerleri() {
    final sonGun = FiyatSimulasyonu.uret365GunlukVeri().last;

    return [
      PiyasaDegeri(urunAdi: 'Taze Patates', guncelFiyat: sonGun.tazeFiyat, degisimYuzdesi: 2.3, kategori: 'Sebze'),
      PiyasaDegeri(urunAdi: 'Beklemiş Patates', guncelFiyat: sonGun.normalFiyat, degisimYuzdesi: -1.5, kategori: 'Sebze'),
      PiyasaDegeri(urunAdi: 'Limon', guncelFiyat: 31.80, degisimYuzdesi: -0.6, kategori: 'Meyve'),
      PiyasaDegeri(urunAdi: 'Greyfurt', guncelFiyat: 28.40, degisimYuzdesi: 1.2, kategori: 'Meyve'),
      PiyasaDegeri(urunAdi: 'Soğan', guncelFiyat: 8.75, degisimYuzdesi: -1.5, kategori: 'Sebze'),
      PiyasaDegeri(urunAdi: 'Domates', guncelFiyat: 18.90, degisimYuzdesi: 5.1, kategori: 'Sebze'),
      PiyasaDegeri(urunAdi: 'Biber', guncelFiyat: 22.30, degisimYuzdesi: 3.8, kategori: 'Sebze'),
      PiyasaDegeri(urunAdi: 'Elma', guncelFiyat: 15.60, degisimYuzdesi: -0.8, kategori: 'Meyve'),
      PiyasaDegeri(urunAdi: 'Üzüm', guncelFiyat: 28.40, degisimYuzdesi: 4.2, kategori: 'Meyve'),
      PiyasaDegeri(urunAdi: 'Kayısı', guncelFiyat: 35.00, degisimYuzdesi: 1.9, kategori: 'Meyve'),
      PiyasaDegeri(urunAdi: 'Buğday', guncelFiyat: 9.20, degisimYuzdesi: -2.1, kategori: 'Tahıl'),
      PiyasaDegeri(urunAdi: 'Arpa', guncelFiyat: 7.80, degisimYuzdesi: 0.5, kategori: 'Tahıl'),
      PiyasaDegeri(urunAdi: 'Nohut', guncelFiyat: 45.00, degisimYuzdesi: 1.2, kategori: 'Bakliyat'),
      PiyasaDegeri(urunAdi: 'Mercimek', guncelFiyat: 38.50, degisimYuzdesi: -0.3, kategori: 'Bakliyat'),
      PiyasaDegeri(urunAdi: 'Fasulye', guncelFiyat: 52.00, degisimYuzdesi: 2.7, kategori: 'Bakliyat'),
    ];
  }

  /// Piyasa değerlerini rastgele güncelle (simülasyon)
  static void piyasaGuncelle(List<PiyasaDegeri> piyasalar) {
    for (var piyasa in piyasalar) {
      if (piyasa.urunAdi.contains('Patates')) continue; // Patates grafikle senkronize kalsın, dalgalanmasın

      double degisim = (_random.nextDouble() - 0.45) * 3; // -1.35 ile +1.65 arası
      piyasa.degisimYuzdesi = double.parse(degisim.toStringAsFixed(1));
      piyasa.guncelFiyat = double.parse(
        (piyasa.guncelFiyat * (1 + degisim / 100)).clamp(1, 999).toStringAsFixed(2),
      );
      piyasa.sonGuncelleme = DateTime.now();
    }
  }

  /// Örnek şirketler
  static List<Sirket> ornekSirketler() {
    return [
      Sirket(
        ad: 'EuroFresh GmbH',
        ulke: '🇩🇪 Almanya',
        kategori: 'Premium İhracat',
        minPuan: 85,
        birimFiyatCarpani: 2.0,
        logoIcon: '🇩🇪',
        ilgiAlanlari: ['Limon', 'Greyfurt'],
        organikSertifikaGerekli: true,
        dusukIsikGerekli: true,
      ),
      Sirket(
        ad: 'GreenPort NL',
        ulke: '🇳🇱 Hollanda',
        kategori: 'A Kalite İhracat',
        minPuan: 80,
        birimFiyatCarpani: 1.8,
        logoIcon: '🇳🇱',
        ilgiAlanlari: ['Limon', 'Greyfurt'],
        sabitNemIstiyor: true,
        minNem: 85,
        maxNem: 90,
      ),
      Sirket(
        ad: 'CitrusIT',
        ulke: '🇮🇹 İtalya',
        kategori: 'Premium İhracat',
        minPuan: 90,
        birimFiyatCarpani: 1.9,
        logoIcon: '🇮🇹',
        ilgiAlanlari: ['Limon', 'Greyfurt'],
      ),
      Sirket(
        ad: 'AgriTrade UK Ltd',
        ulke: '🇬🇧 İngiltere',
        kategori: 'A Kalite İhracat',
        minPuan: 75,
        birimFiyatCarpani: 1.8,
        logoIcon: '🇬🇧',
        ilgiAlanlari: ['Patates', 'Elma', 'Kayısı'],
      ),
      Sirket(
        ad: 'FruitWorld BV',
        ulke: '🇳🇱 Hollanda',
        kategori: 'A Kalite İhracat',
        minPuan: 65,
        birimFiyatCarpani: 1.5,
        logoIcon: '🇳🇱',
        ilgiAlanlari: ['Domates', 'Biber', 'Üzüm'],
      ),
      Sirket(
        ad: 'İç Piyasa Toptancı',
        ulke: '🇹🇷 Türkiye',
        kategori: 'İç Piyasa',
        minPuan: 10,
        birimFiyatCarpani: 0.6,
        logoIcon: '🇹🇷',
        ilgiAlanlari: ['Patates', 'Soğan', 'Domates', 'Biber', 'Elma', 'Buğday'],
      ),
    ];
  }
}
