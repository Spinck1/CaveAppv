class UrunTuru {
  final String adi;
  final double minSicaklik;
  final double maxSicaklik;
  final double minNem;
  final double maxNem;
  final double maxIsik;

  const UrunTuru({
    required this.adi,
    required this.minSicaklik,
    required this.maxSicaklik,
    required this.minNem,
    required this.maxNem,
    required this.maxIsik,
  });

  bool sicaklikDisaCikti(double deger) =>
      deger < minSicaklik || deger > maxSicaklik;
  bool nemDisaCikti(double deger) => deger < minNem || deger > maxNem;
  bool isikDisaCikti(double deger) => deger > maxIsik;

  String kritikUyariMetni(String depoAdi) {
    return 'KRITIK UYARI: $depoAdi - $adi için kritik depo koşulları dışı!';
  }

  static UrunTuru fromUrunAdi(String urunAdi) {
    final adi = urunAdi.toLowerCase();
    if (adi.contains('limon')) return UrunTuru.limon;
    if (adi.contains('greyfurt')) return UrunTuru.greyfurt;
    if (adi.contains('patates')) return UrunTuru.patates;
    return UrunTuru.patates;
  }

  static const UrunTuru patates = UrunTuru(
    adi: 'Patates',
    minSicaklik: 4.0,
    maxSicaklik: 10.0,
    minNem: 85.0,
    maxNem: 90.0,
    maxIsik: 300.0,
  );

  static const UrunTuru limon = UrunTuru(
    adi: 'Limon',
    minSicaklik: 10.0,
    maxSicaklik: 12.0,
    minNem: 85.0,
    maxNem: 90.0,
    maxIsik: 250.0,
  );

  static const UrunTuru greyfurt = UrunTuru(
    adi: 'Greyfurt',
    minSicaklik: 12.0,
    maxSicaklik: 14.0,
    minNem: 85.0,
    maxNem: 90.0,
    maxIsik: 250.0,
  );
}
