import 'dart:math';
import 'urun_partisi.dart';
import 'piyasa_degeri.dart';

class Depo {
  String id;
  String ad;
  String konum;
  double sicaklik; // Derece
  double nem; // Nem yüzdesi
  double isik; // Işık seviyesi (lux)
  DateTime sonGuncelleme;
  bool bacalarAcik;
  bool bacaUyarisi;
  double? lat;
  double? lng;
  double kapasite; // Ton cinsinden

  Depo({
    required this.id,
    required this.ad,
    this.konum = '',
    this.sicaklik = 0,
    this.nem = 0,
    this.isik = 0,
    DateTime? sonGuncelleme,
    this.bacalarAcik = true,
    this.bacaUyarisi = false,
    this.lat,
    this.lng,
    this.kapasite = 500,
  }) : sonGuncelleme = sonGuncelleme ?? DateTime.now();

  // Rastgele sensör verileri üret (ileride Arduino'dan gelecek)
  void rastgeleVeriUret() {
    final random = Random();
    sicaklik = 0 + random.nextDouble() * 35; // 0-35 derece arası (Donma senaryosu için 0'dan başlıyor)
    nem = 30 + random.nextDouble() * 50; // %30-80 arası
    isik = 100 + random.nextDouble() * 900; // 100-1000 lux arası
    
    // Baca Kontrol Mantığı (Optimizasyon)
    if (sicaklik < 3.0) {
      bacalarAcik = false;
      bacaUyarisi = true;
    } else if (sicaklik >= 3.0 && !bacalarAcik) {
      bacalarAcik = true;
      bacaUyarisi = false; // Optimizasyon sağlandı
    }
    
    sonGuncelleme = DateTime.now();
  }

  // Depodaki ürünlerin puanlarını güncelle
  void urunPuanlariniGuncelle(List<UrunPartisi> partiler, List<PiyasaDegeri> piyasalar) {
    // Patates fiyatlarını bulalım (makas puanı için)
    double tazeFiyat = 25.0;
    double normalFiyat = 20.0;
    try {
      tazeFiyat = piyasalar.firstWhere((p) => p.urunAdi == 'Taze Patates').guncelFiyat;
      normalFiyat = piyasalar.firstWhere((p) => p.urunAdi == 'Beklemiş Patates').guncelFiyat;
    } catch (e) { /* varsayılanlar kullanılır */ }

    for (var parti in partiler) {
      // Bu partinin piyasa değerini bulalım
      double borsaFiyati = 0;
      try {
        // Tam eşleşme ara
        borsaFiyati = piyasalar.firstWhere((p) => p.urunAdi == parti.urunAdi).guncelFiyat;
      } catch (e) {
        // Kısmi eşleşme ara (Patates, Limon vb.)
        try {
          borsaFiyati = piyasalar.firstWhere((p) => parti.urunAdi.contains(p.urunAdi)).guncelFiyat;
        } catch (e2) {
          borsaFiyati = parti.alisFiyati * 1.2;
        }
      }
      
      parti.sonBorsaFiyati = borsaFiyati;
      parti.puanGuncelle(sicaklik, nem, isik, tazeFiyat, normalFiyat);
    }
  }

  Depo copyWith({
    String? id,
    String? ad,
    String? konum,
    double? sicaklik,
    double? nem,
    double? isik,
    double? lat,
    double? lng,
    double? kapasite,
  }) {
    return Depo(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      konum: konum ?? this.konum,
      sicaklik: sicaklik ?? this.sicaklik,
      nem: nem ?? this.nem,
      isik: isik ?? this.isik,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      kapasite: kapasite ?? this.kapasite,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'konum': konum,
    'lat': lat,
    'lng': lng,
    'kapasite': kapasite,
    'bacalarAcik': bacalarAcik,
  };

  factory Depo.fromJson(Map<String, dynamic> json) => Depo(
    id: json['id'],
    ad: json['ad'],
    konum: json['konum'] ?? '',
    lat: (json['lat'] ?? json['haritaX'])?.toDouble(),
    lng: (json['lng'] ?? json['haritaY'])?.toDouble(),
    kapasite: (json['kapasite'] ?? 500.0).toDouble(),
    bacalarAcik: json['bacalarAcik'] ?? true,
  );
}
