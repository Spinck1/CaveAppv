class SatisKaydi {
  String id;
  String depoAdi;
  String urunAdi;
  double miktar;
  String birim;
  double birimFiyat;
  double toplamFiyat;
  DateTime tarih;
  String? aciklama;

  SatisKaydi({
    required this.id,
    required this.depoAdi,
    required this.urunAdi,
    required this.miktar,
    this.birim = 'kg',
    required this.birimFiyat,
    double? toplamFiyat,
    DateTime? tarih,
    this.aciklama,
  })  : toplamFiyat = toplamFiyat ?? (miktar * birimFiyat),
        tarih = tarih ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'depoAdi': depoAdi,
    'urunAdi': urunAdi,
    'miktar': miktar,
    'birim': birim,
    'birimFiyat': birimFiyat,
    'toplamFiyat': toplamFiyat,
    'tarih': tarih.toIso8601String(),
    'aciklama': aciklama,
  };

  factory SatisKaydi.fromJson(Map<String, dynamic> json) => SatisKaydi(
    id: json['id'],
    depoAdi: json['depoAdi'],
    urunAdi: json['urunAdi'],
    miktar: (json['miktar'] ?? 0.0).toDouble(),
    birim: json['birim'] ?? 'kg',
    birimFiyat: (json['birimFiyat'] ?? 0.0).toDouble(),
    toplamFiyat: (json['toplamFiyat'] ?? 0.0).toDouble(),
    tarih: DateTime.parse(json['tarih']),
    aciklama: json['aciklama'],
  );
}
