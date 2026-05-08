import 'dart:math';

class GunlukVeri {
  final int gun;
  final double tazeFiyat;
  final double normalFiyat;
  final double bizimFiyat; // Bekleme süresine göre azalan fiyat
  final double satisPuani; // 100'den başlayıp azalan puan

  GunlukVeri({
    required this.gun,
    required this.tazeFiyat,
    required this.normalFiyat,
    required this.bizimFiyat,
    required this.satisPuani,
  });
}

class FiyatSimulasyonu {
  static List<GunlukVeri> uret365GunlukVeri([String urunAdi = 'Patates']) {
    final adi = urunAdi.toLowerCase();
    if (adi.contains('limon')) {
      return _uret365GunlukVeri(urunAdi: 'Limon', baseTaze: 18.0, baseNormal: 12.5, puanBaslangic: 98.0, puanDip: 58.0, sezonFark: 3.5);
    }
    if (adi.contains('greyfurt')) {
      return _uret365GunlukVeri(urunAdi: 'Greyfurt', baseTaze: 20.0, baseNormal: 14.0, puanBaslangic: 97.0, puanDip: 55.0, sezonFark: 4.0);
    }
    return _uret365GunlukVeri(urunAdi: 'Patates', baseTaze: 22.0, baseNormal: 12.0, puanBaslangic: 100.0, puanDip: 40.0, sezonFark: 4.0);
  }

  static List<GunlukVeri> _uret365GunlukVeri({
    required String urunAdi,
    required double baseTaze,
    required double baseNormal,
    required double puanBaslangic,
    required double puanDip,
    required double sezonFark,
  }) {
    List<GunlukVeri> veriler = [];
    double mevcutPuan = puanBaslangic;
    double bizimFiyati = baseTaze;

    for (int i = 1; i <= 365; i++) {
      double dalgaRad = (i / 365) * 2 * pi;
      double sezonEtkisiTaze = sin(dalgaRad + pi) * sezonFark;
      double sezonEtkisiNormal = sin(dalgaRad + pi) * (sezonFark * 0.55);
      double mikroDalga = cos(i * 0.1) * 0.35;

      double gunlukTazeFiyat = (baseTaze + sezonEtkisiTaze + mikroDalga).clamp(12.0, 32.0);
      double gunlukNormalFiyat = (baseNormal + sezonEtkisiNormal + (mikroDalga * 0.45)).clamp(8.0, 22.0);

      if (i <= 14) {
        mevcutPuan = puanBaslangic;
      } else if (i <= 120) {
        mevcutPuan -= 0.18;
      } else if (i <= 240) {
        mevcutPuan -= 0.28;
      } else {
        mevcutPuan -= 0.12;
      }
      mevcutPuan = mevcutPuan.clamp(puanDip, puanBaslangic);

      double kaliteOrani = (mevcutPuan - puanDip) / (puanBaslangic - puanDip);
      if (kaliteOrani > 0) {
        bizimFiyati = gunlukNormalFiyat + ((gunlukTazeFiyat - gunlukNormalFiyat) * kaliteOrani);
      } else {
        double factor = (puanDip - mevcutPuan) / (puanBaslangic - puanDip);
        bizimFiyati = gunlukNormalFiyat * (1.0 - (factor * 0.3));
      }

      veriler.add(GunlukVeri(
        gun: i,
        tazeFiyat: double.parse(gunlukTazeFiyat.toStringAsFixed(2)),
        normalFiyat: double.parse(gunlukNormalFiyat.toStringAsFixed(2)),
        bizimFiyat: double.parse(bizimFiyati.toStringAsFixed(2)),
        satisPuani: double.parse(mevcutPuan.toStringAsFixed(2)),
      ));
    }
    return veriler;
  }
}
