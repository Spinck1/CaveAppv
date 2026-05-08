import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class AyarlarEkrani extends StatefulWidget {
  final Function(String) onDilDegistir;
  final String mevcutDil;

  const AyarlarEkrani({
    super.key,
    required this.onDilDegistir,
    required this.mevcutDil,
  });

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  late String _secilenDil;

  @override
  void initState() {
    super.initState();
    _secilenDil = widget.mevcutDil;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          t('Ayarlar'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.panelDecoration(blur: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t('Dil Seçimi'),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _dilSecenegi('tr', '🇹🇷', 'Türkçe'),
                const SizedBox(height: 8),
                _dilSecenegi('en', '🇬🇧', 'English'),
                const SizedBox(height: 8),
                _dilSecenegi('de', '🇩🇪', 'Deutsch'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.panelDecoration(blur: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t('Hakkında'),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t('Nevşehir Doğal Mağara Depo Yönetim Sistemi'),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dilSecenegi(String kod, String bayrak, String isim) {
    final secili = _secilenDil == kod;
    return GestureDetector(
      onTap: () async {
        setState(() => _secilenDil = kod);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('dil', kod);
        widget.onDilDegistir(kod);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: secili
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.scaffoldBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: secili ? AppTheme.primaryColor : AppTheme.surfaceLight,
            width: secili ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(bayrak, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isim,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (secili)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ÇOKLU DİL DESTEĞİ (TR/EN/DE)
// ============================================
String _aktifDil = 'tr';

void dilAyarla(String dil) {
  _aktifDil = dil;
}

String t(String anahtar) {
  final ceviriler = _ceviriler[anahtar];
  if (ceviriler == null) return anahtar;
  return ceviriler[_aktifDil] ?? ceviriler['tr'] ?? anahtar;
}

final Map<String, Map<String, String>> _ceviriler = {
  // Genel / Ayarlar
  'Ayarlar': {'tr': 'Ayarlar', 'en': 'Settings', 'de': 'Einstellungen'},
  'Dil Seçimi': {'tr': 'Dil Seçimi', 'en': 'Language', 'de': 'Sprache'},
  'Hakkında': {'tr': 'Hakkında', 'en': 'About', 'de': 'Über'},
  'Nevşehir Doğal Mağara Depo Yönetim Sistemi': {
    'tr': 'Nevşehir Doğal Mağara Depo Yönetim Sistemi',
    'en': 'Nevşehir Natural Cave Warehouse Management System',
    'de': 'Nevşehir Natürliches Höhlenlager-Verwaltungssystem',
  },
  'Nevşehir Depo': {
    'tr': 'Nevşehir Depo',
    'en': 'Nevşehir Warehouse',
    'de': 'Nevşehir Lager',
  },

  // Ana Sayfa
  'Hoş geldiniz': {'tr': 'Hoş geldiniz', 'en': 'Welcome', 'de': 'Willkommen'},
  'Mağara Depoları Yönetimi': {
    'tr': 'Mağara Depoları Yönetimi',
    'en': 'Cave Warehouse Management',
    'de': 'Höhlenlager-Verwaltung',
  },
  'Depo': {'tr': 'Depo', 'en': 'Warehouse', 'de': 'Lager'},
  'Kapasite': {'tr': 'Kapasite', 'en': 'Capacity', 'de': 'Kapazität'},
  'Dolu': {'tr': 'Dolu', 'en': 'Full', 'de': 'Voll'},
  'Sıcaklık': {'tr': 'Sıcaklık', 'en': 'Temperature', 'de': 'Temperatur'},
  'Nem': {'tr': 'Nem', 'en': 'Humidity', 'de': 'Feuchtigkeit'},
  'Işık': {'tr': 'Işık', 'en': 'Light', 'de': 'Licht'},
  'Toplam': {'tr': 'Toplam', 'en': 'Total', 'de': 'Gesamt'},
  'Ort': {'tr': 'Ort', 'en': 'Avg', 'de': 'Durch'},
  'Depo Doluluk Durumu (%)': {
    'tr': 'Depo Doluluk Durumu (%)',
    'en': 'Warehouse Occupancy (%)',
    'de': 'Lagerbelegung (%)',
  },
  'Canlı Depo Haritası': {
    'tr': 'Canlı Depo Haritası',
    'en': 'Live Warehouse Map',
    'de': 'Live-Lagerkarte',
  },
  'Depo bulunamadı': {
    'tr': 'Depo bulunamadı',
    'en': 'No warehouse found',
    'de': 'Kein Lager gefunden',
  },

  // Drawer
  'Ana Sayfa': {'tr': 'Ana Sayfa', 'en': 'Home', 'de': 'Startseite'},
  'Depolar': {'tr': 'Depolar', 'en': 'Warehouses', 'de': 'Lager'},
  'Harita': {'tr': 'Harita', 'en': 'Map', 'de': 'Karte'},
  'İzleme': {'tr': 'İzleme', 'en': 'Monitoring', 'de': 'Überwachung'},
  'Raporlar': {'tr': 'Raporlar', 'en': 'Reports', 'de': 'Berichte'},
  'Bildirimler': {
    'tr': 'Bildirimler',
    'en': 'Notifications',
    'de': 'Benachrichtigungen',
  },
  'Satış Özeti': {
    'tr': 'Satış Özeti',
    'en': 'Sales Summary',
    'de': 'Verkaufsübersicht',
  },
  'Karbon Ayak İzi': {
    'tr': 'Karbon Ayak İzi',
    'en': 'Carbon Footprint',
    'de': 'CO2-Fußabdruck',
  },

  // Depo Yönetimi
  'Depo Yönetimi': {
    'tr': 'Depo Yönetimi',
    'en': 'Warehouse Management',
    'de': 'Lagerverwaltung',
  },
  'Henüz depo yok.': {
    'tr': 'Henüz depo yok.',
    'en': 'No warehouse yet.',
    'de': 'Noch kein Lager.',
  },
  'Kapat': {'tr': 'Kapat', 'en': 'Close', 'de': 'Schließen'},

  // Bildirimler
  'Bildirim Merkezi': {
    'tr': 'Bildirim Merkezi',
    'en': 'Notification Center',
    'de': 'Benachrichtigungszentrale',
  },
  'Henüz bildirim yok': {
    'tr': 'Henüz bildirim yok',
    'en': 'No notifications yet',
    'de': 'Noch keine Benachrichtigungen',
  },
  'Son Bildirimler': {
    'tr': 'Son Bildirimler',
    'en': 'Recent Notifications',
    'de': 'Letzte Benachrichtigungen',
  },
  'Tümünü Gör': {'tr': 'Tümünü Gör', 'en': 'View All', 'de': 'Alle anzeigen'},

  // Satış Özeti
  'Satış ve Stok Yönetimi': {
    'tr': 'Satış ve Stok Yönetimi',
    'en': 'Sales & Inventory',
    'de': 'Verkauf & Bestand',
  },
  'Önerilen Fiyatlar': {
    'tr': 'Önerilen Fiyatlar',
    'en': 'Suggested Prices',
    'de': 'Empfohlene Preise',
  },
  'Elden Satış Gir': {
    'tr': 'Elden Satış Gir',
    'en': 'Manual Sale Entry',
    'de': 'Manueller Verkauf',
  },
  'Önerilen Satış Fiyatları': {
    'tr': 'Önerilen Satış Fiyatları',
    'en': 'Suggested Sale Prices',
    'de': 'Empfohlene Verkaufspreise',
  },
  'Toplam Gelir': {
    'tr': 'Toplam Gelir',
    'en': 'Total Revenue',
    'de': 'Gesamterlös',
  },
  'Henüz satış kaydı yok': {
    'tr': 'Henüz satış kaydı yok',
    'en': 'No sales recorded yet',
    'de': 'Noch keine Verkäufe',
  },
  'Önerilen Fiyat': {
    'tr': 'Önerilen Fiyat',
    'en': 'Suggested Price',
    'de': 'Empf. Preis',
  },
  'Tahmini Gelir': {
    'tr': 'Tahmini Gelir',
    'en': 'Est. Revenue',
    'de': 'Gesch. Erlös',
  },
  'Tahmini Kar': {
    'tr': 'Tahmini Kar',
    'en': 'Est. Profit',
    'de': 'Gesch. Gewinn',
  },
  'Satılacak Miktar': {
    'tr': 'Satılacak Miktar',
    'en': 'Sale Quantity',
    'de': 'Verkaufsmenge',
  },
  'Birim Fiyatı (₺)': {
    'tr': 'Birim Fiyatı (₺)',
    'en': 'Unit Price (₺)',
    'de': 'Stückpreis (₺)',
  },
  'Satışı Tamamla': {
    'tr': 'Satışı Tamamla',
    'en': 'Complete Sale',
    'de': 'Verkauf abschließen',
  },
  'İptal': {'tr': 'İptal', 'en': 'Cancel', 'de': 'Abbrechen'},
  'Tümü': {'tr': 'Tümü', 'en': 'All', 'de': 'Alle'},
  'Depo Seçin': {
    'tr': 'Depo Seçin',
    'en': 'Select Warehouse',
    'de': 'Lager wählen',
  },
  'Satılacak Parti (Stok)': {
    'tr': 'Satılacak Parti (Stok)',
    'en': 'Lot to Sell (Stock)',
    'de': 'Charge zum Verkauf (Bestand)',
  },
  'satış': {'tr': 'satış', 'en': 'sales', 'de': 'Verkäufe'},

  // Ürün Giriş
  'Ürün Giriş': {
    'tr': 'Ürün Giriş',
    'en': 'Product Entry',
    'de': 'Produkteingabe',
  },
  'Yeni Ürün Partisi': {
    'tr': 'Yeni Ürün Partisi',
    'en': 'New Product Lot',
    'de': 'Neue Produktcharge',
  },
  'Bu depoda ürün partisi yok': {
    'tr': 'Bu depoda ürün partisi yok',
    'en': 'No product lots in this warehouse',
    'de': 'Keine Produktchargen in diesem Lager',
  },
  'Yeni Parti': {'tr': 'Yeni Parti', 'en': 'New Lot', 'de': 'Neue Charge'},
  'Miktar': {'tr': 'Miktar', 'en': 'Quantity', 'de': 'Menge'},
  'Alış Fiyatı (₺/birim)': {
    'tr': 'Alış Fiyatı (₺/birim)',
    'en': 'Purchase Price (₺/unit)',
    'de': 'Einkaufspreis (₺/Einheit)',
  },
  'Açıklama (opsiyonel)': {
    'tr': 'Açıklama (opsiyonel)',
    'en': 'Description (optional)',
    'de': 'Beschreibung (optional)',
  },
  'Partiyi Ekle': {
    'tr': 'Partiyi Ekle',
    'en': 'Add Lot',
    'de': 'Charge hinzufügen',
  },

  // Analiz / İzleme
  'Ürün Analizi': {
    'tr': 'Ürün Analizi',
    'en': 'Product Analysis',
    'de': 'Produktanalyse',
  },
  'Profesyonel Analiz Modülü': {
    'tr': 'Profesyonel Analiz Modülü',
    'en': 'Professional Analysis Module',
    'de': 'Professionelles Analysemodul',
  },
  'Piyasa & Alıcılar': {
    'tr': 'Piyasa & Alıcılar',
    'en': 'Market & Buyers',
    'de': 'Markt & Käufer',
  },
  'Satış Puanı Eğilimi': {
    'tr': 'Satış Puanı Eğilimi',
    'en': 'Sales Score Trend',
    'de': 'Verkaufswert-Trend',
  },
  'Fiyat Trendleri': {
    'tr': 'Fiyat Trendleri',
    'en': 'Price Trends',
    'de': 'Preistrends',
  },
  'Piyasa': {'tr': 'Piyasa', 'en': 'Market', 'de': 'Markt'},
  'Normal': {'tr': 'Normal', 'en': 'Normal', 'de': 'Normal'},
  'Satış Puanı': {
    'tr': 'Satış Puanı',
    'en': 'Sales Score',
    'de': 'Verkaufswert',
  },
  'Alıcılar': {'tr': 'Alıcılar', 'en': 'Buyers', 'de': 'Käufer'},
  'Analiz': {'tr': 'Analiz', 'en': 'Analysis', 'de': 'Analyse'},
  'Sebze': {'tr': 'Sebze', 'en': 'Vegetable', 'de': 'Gemüse'},
  'Meyve': {'tr': 'Meyve', 'en': 'Fruit', 'de': 'Obst'},
  'Tahıl': {'tr': 'Tahıl', 'en': 'Grain', 'de': 'Getreide'},
  'Bakliyat': {'tr': 'Bakliyat', 'en': 'Legume', 'de': 'Hülsenfrucht'},
  'Min Puan': {'tr': 'Min Puan', 'en': 'Min Score', 'de': 'Min. Punkte'},
  'Fiyat Çarpanı': {
    'tr': 'Fiyat Çarpanı',
    'en': 'Price Multiplier',
    'de': 'Preismultiplikator',
  },

  // Bildirim Mesajları
  'KRİTİK SICAKLIK': {
    'tr': 'KRİTİK SICAKLIK',
    'en': 'CRITICAL TEMPERATURE',
    'de': 'KRITISCHE TEMPERATUR',
  },
  'DONMA RİSKİ': {
    'tr': 'DONMA RİSKİ',
    'en': 'FREEZING RISK',
    'de': 'FROSTGEFAHR',
  },
  'DÜŞÜK NEM': {
    'tr': 'DÜŞÜK NEM',
    'en': 'LOW HUMIDITY',
    'de': 'NIEDRIGE FEUCHTIGKEIT',
  },
  'YÜKSEK NEM': {
    'tr': 'YÜKSEK NEM',
    'en': 'HIGH HUMIDITY',
    'de': 'HOHE FEUCHTIGKEIT',
  },
  'IŞIK UYARISI': {
    'tr': 'IŞIK UYARISI',
    'en': 'LIGHT WARNING',
    'de': 'LICHTWARNUNG',
  },
  'ile çok yüksek!': {
    'tr': 'ile çok yüksek!',
    'en': 'is too high!',
    'de': 'ist zu hoch!',
  },
  'seviyesine düştü!': {
    'tr': 'seviyesine düştü!',
    'en': 'has dropped!',
    'de': 'ist gefallen!',
  },
  'seviyesine düştü.': {
    'tr': 'seviyesine düştü.',
    'en': 'has dropped.',
    'de': 'ist gefallen.',
  },
  'Çürüme riski!': {
    'tr': 'Çürüme riski!',
    'en': 'Rot risk!',
    'de': 'Fäulnisgefahr!',
  },
  'Yeşillenme riski!': {
    'tr': 'Yeşillenme riski!',
    'en': 'Greening risk!',
    'de': 'Grünfärbungsgefahr!',
  },

  // Harita
  'Depo Haritası': {
    'tr': 'Depo Haritası',
    'en': 'Warehouse Map',
    'de': 'Lagerkarte',
  },
  'Yeni Depo Ekle': {
    'tr': 'Yeni Depo Ekle',
    'en': 'Add New Warehouse',
    'de': 'Neues Lager hinzufügen',
  },
  'Depo Adı': {'tr': 'Depo Adı', 'en': 'Warehouse Name', 'de': 'Lagername'},
  'Konum Adı': {'tr': 'Konum Adı', 'en': 'Location Name', 'de': 'Standortname'},
  'Ekle': {'tr': 'Ekle', 'en': 'Add', 'de': 'Hinzufügen'},

  // Raporlar / İhracat
  'İhracat Puanı': {
    'tr': 'İhracat Puanı',
    'en': 'Export Score',
    'de': 'Exportbewertung',
  },
  'İhracat Puanları': {
    'tr': 'İhracat Puanları',
    'en': 'Export Scores',
    'de': 'Exportbewertungen',
  },
  'Bu depoda henüz ürün yok': {
    'tr': 'Bu depoda henüz ürün yok',
    'en': 'No products in this warehouse yet',
    'de': 'Noch keine Produkte in diesem Lager',
  },
  'Önce Ürün Giriş ekranından ürün ekleyin': {
    'tr': 'Önce Ürün Giriş ekranından ürün ekleyin',
    'en': 'Add products from the Product Entry screen first',
    'de': 'Fügen Sie zuerst Produkte über die Produkteingabe hinzu',
  },
  'KARAR DESTEK & İHRACAT SKORU': {
    'tr': 'KARAR DESTEK & İHRACAT SKORU',
    'en': 'DECISION SUPPORT & EXPORT SCORE',
    'de': 'ENTSCHEIDUNGSHILFE & EXPORTSCORE',
  },
  'Toplam Parti': {
    'tr': 'Toplam Parti',
    'en': 'Total Lots',
    'de': 'Gesamtchargen',
  },
  'Toplam Miktar': {
    'tr': 'Toplam Miktar',
    'en': 'Total Quantity',
    'de': 'Gesamtmenge',
  },
  'Alıcı Eşleştirme': {
    'tr': 'Alıcı Eşleştirme',
    'en': 'Buyer Matching',
    'de': 'Käufer-Matching',
  },
  'Parti Bazlı Puanlar': {
    'tr': 'Parti Bazlı Puanlar',
    'en': 'Lot-Based Scores',
    'de': 'Chargenbasierte Punkte',
  },
  'Maliyet': {'tr': 'Maliyet', 'en': 'Cost', 'de': 'Kosten'},
  'Tah. Satış': {'tr': 'Tah. Satış', 'en': 'Est. Sale', 'de': 'Gesch. Verkauf'},
  'Tah. Kar': {'tr': 'Tah. Kar', 'en': 'Est. Profit', 'de': 'Gesch. Gewinn'},
  'aktif': {'tr': 'aktif', 'en': 'active', 'de': 'aktiv'},
  'pasif': {'tr': 'pasif', 'en': 'inactive', 'de': 'inaktiv'},
  'TOPLAM': {'tr': 'TOPLAM', 'en': 'TOTAL', 'de': 'GESAMT'},
  'parti': {'tr': 'parti', 'en': 'lots', 'de': 'Chargen'},
  'Haritaya dokunarak depo ekleyebilirsiniz': {
    'tr': 'Haritaya dokunarak depo ekleyebilirsiniz.',
    'en': 'Tap on the map to add a warehouse.',
    'de': 'Tippen Sie auf die Karte, um ein Lager hinzuzufügen.',
  },
  'Kaydet': {'tr': 'Kaydet', 'en': 'Save', 'de': 'Speichern'},

  // Depo Seçimi ve Yeni Özellikler
  'Depo Seçimi': {
    'tr': 'Depo Seçimi',
    'en': 'Warehouse Selection',
    'de': 'Lagerauswahl',
  },
  'Genel Durumu': {
    'tr': 'Genel Durumu',
    'en': 'General Status',
    'de': 'Allgemeiner Status',
  },
  'Genel Depo Durumu': {
    'tr': 'Genel Depo Durumu',
    'en': 'General Warehouse Status',
    'de': 'Allgemeiner Lagerstatus',
  },
  'Konum belirtilmedi': {
    'tr': 'Konum belirtilmedi',
    'en': 'Location not specified',
    'de': 'Standort nicht angegeben',
  },
  'CaveApp Yönetimi': {
    'tr': 'CaveApp Yönetimi',
    'en': 'CaveApp Management',
    'de': 'CaveApp Verwaltung',
  },
  'Doluluk': {'tr': 'Doluluk', 'en': 'Occupancy', 'de': 'Belegung'},

  // Ürün İsimleri
  'Patates': {'tr': 'Patates', 'en': 'Potatoes', 'de': 'Kartoffeln'},
  'Limon': {'tr': 'Limon', 'en': 'Lemon', 'de': 'Zitrone'},
  'Greyfurt': {'tr': 'Greyfurt', 'en': 'Grapefruit', 'de': 'Grapefruit'},
  'Soğan': {'tr': 'Soğan', 'en': 'Onion', 'de': 'Zwiebel'},
  'Domates': {'tr': 'Domates', 'en': 'Tomato', 'de': 'Tomate'},
  'Taze Patates': {
    'tr': 'Taze Patates',
    'en': 'Fresh Potatoes',
    'de': 'Frische Kartoffeln',
  },
  'Beklemiş Patates': {
    'tr': 'Beklemiş Patates',
    'en': 'Aged Potatoes',
    'de': 'Gelagerte Kartoffeln',
  },
  'Biber': {'tr': 'Biber', 'en': 'Pepper', 'de': 'Pfeffer'},
  'Elma': {'tr': 'Elma', 'en': 'Apple', 'de': 'Apfel'},
  'Üzüm': {'tr': 'Üzüm', 'en': 'Grape', 'de': 'Traube'},
  'Kayısı': {'tr': 'Kayısı', 'en': 'Apricot', 'de': 'Aprikose'},
  'Buğday': {'tr': 'Buğday', 'en': 'Wheat', 'de': 'Weizen'},
  'Arpa': {'tr': 'Arpa', 'en': 'Barley', 'de': 'Gerste'},
  'Nohut': {'tr': 'Nohut', 'en': 'Chickpea', 'de': 'Kichererbse'},
  'Mercimek': {'tr': 'Mercimek', 'en': 'Lentil', 'de': 'Linse'},
  'Fasulye': {'tr': 'Fasulye', 'en': 'Bean', 'de': 'Bohne'},

  // Şirket ve Ülkeler
  '🇩🇪 Almanya': {
    'tr': '🇩🇪 Almanya',
    'en': '🇩🇪 Germany',
    'de': '🇩🇪 Deutschland',
  },
  '🇳🇱 Hollanda': {
    'tr': '🇳🇱 Hollanda',
    'en': '🇳🇱 Netherlands',
    'de': '🇳🇱 Niederlande',
  },
  '🇮🇹 İtalya': {
    'tr': '🇮🇹 İtalya',
    'en': '🇮🇹 Italy',
    'de': '🇮🇹 Italien',
  },
  '🇬🇧 İngiltere': {
    'tr': '🇬🇧 İngiltere',
    'en': '🇬🇧 United Kingdom',
    'de': '🇬🇧 Großbritannien',
  },
  '🇹🇷 Türkiye': {
    'tr': '🇹🇷 Türkiye',
    'en': '🇹🇷 Turkey',
    'de': '🇹🇷 Türkei',
  },
  'Premium İhracat': {
    'tr': 'Premium İhracat',
    'en': 'Premium Export',
    'de': 'Premium Export',
  },
  'A Kalite İhracat': {
    'tr': 'A Kalite İhracat',
    'en': 'A Quality Export',
    'de': 'A-Qualität Export',
  },
  'İç Piyasa': {
    'tr': 'İç Piyasa',
    'en': 'Domestic Market',
    'de': 'Inlandsmarkt',
  },
  'B Kalite İhracat': {
    'tr': 'B Kalite İhracat',
    'en': 'B Quality Export',
    'de': 'B-Qualität Export',
  },
  'Standart': {'tr': 'Standart', 'en': 'Standard', 'de': 'Standard'},

  // Puanlama Mesajları
  'Aşırı beklemiş ürün (>5 ay), -20 İhracat Ceza Puanı!': {
    'tr': 'Aşırı beklemiş ürün (>5 ay), -20 İhracat Ceza Puanı!',
    'en': 'Extremely aged product (>5 months), -20 Export Penalty Points!',
    'de': 'Extrem gealtertes Produkt (>5 Monate), -20 Export-Strafpunkte!',
  },
  'Sıcaklık 10°C üstünde! Filizlenme başlayabilir!': {
    'tr': 'Sıcaklık 10°C üstünde! Filizlenme başlayabilir!',
    'en': 'Temperature above 10°C! Sprouting may start!',
    'de': 'Temperatur über 10°C! Keimung kann beginnen!',
  },
  'Kritik sıcaklık toleransı aşıldı! Ceza: -': {
    'tr': 'Kritik sıcaklık toleransı aşıldı! Ceza: -',
    'en': 'Critical temperature tolerance exceeded! Penalty: -',
    'de': 'Kritische Temperaturtoleranz überschritten! Strafe: -',
  },
  'Aşırı nem uyarısı!': {
    'tr': 'Aşırı nem uyarısı!',
    'en': 'Excessive humidity warning!',
    'de': 'Warnung vor übermäßiger Feuchtigkeit!',
  },
  'Nem az uyarısı!': {
    'tr': 'Nem az uyarısı!',
    'en': 'Low humidity warning!',
    'de': 'Warnung vor geringer Feuchtigkeit!',
  },
  'Işık sızıntısı var!': {
    'tr': 'Işık sızıntısı var!',
    'en': 'Light leakage detected!',
    'de': 'Lichteinfall festgestellt!',
  },
  'KRİTİK: Işık seviyesi çok yüksek! Acil müdahale gerekli!': {
    'tr': 'KRİTİK: Işık seviyesi çok yüksek! Acil müdahale gerekli!',
    'en': 'CRITICAL: Light level too high! Urgent intervention required!',
    'de': 'KRITISCH: Lichtpegel zu hoch! Dringendes Eingreifen erforderlich!',
  },
  'Sıcaklık Puanı': {
    'tr': 'Sıcaklık Puanı',
    'en': 'Temperature Score',
    'de': 'Temperatur-Punkte',
  },
  'Nem Puanı': {
    'tr': 'Nem Puanı',
    'en': 'Humidity Score',
    'de': 'Feuchtigkeits-Punkte',
  },
  'Mevsimsel Makas': {
    'tr': 'Mevsimsel Makas',
    'en': 'Seasonal Spread',
    'de': 'Saisonale Spanne',
  },
  'Puan': {'tr': 'Puan', 'en': 'Score', 'de': 'Punkte'},
  'altında veya ürün tercihi uyumsuz.': {
    'tr': 'altında veya ürün tercihi uyumsuz.',
    'en': 'below or product preference mismatch.',
    'de': 'darunter veya Produktpräferenz stimmt nicht überein.',
  },
  'Alıcı aktif durumda.': {
    'tr': 'Alıcı aktif durumda.',
    'en': 'Buyer is active.',
    'de': 'Käufer ist aktiv.',
  },
  'Puanınıza göre hesaplanan önerilen birim fiyatları:': {
    'tr': 'Puanınıza göre hesaplanan önerilen birim fiyatları:',
    'en': 'Recommended unit prices based on your score:',
    'de': 'Empfohlene Stückpreise basierend auf Ihrer Punktzahl:',
  },
  'Geçersiz miktar! Stoktan büyük olamaz.': {
    'tr': 'Geçersiz miktar! Stoktan büyük olamaz.',
    'en': 'Invalid quantity! Cannot exceed stock.',
    'de': 'Ungültige Menge! Kann den Lagerbestand nicht überschreiten.',
  },
  'Depoda satılacak stok bulunmuyor!': {
    'tr': 'Depoda satılacak stok bulunmuyor!',
    'en': 'No stock available to sell!',
    'de': 'Kein Lagerbestand zum Verkauf verfügbar!',
  },
  'Depoda ürün bulunmuyor!': {
    'tr': 'Depoda ürün bulunmuyor!',
    'en': 'No products in warehouse!',
    'de': 'Keine Produkte im Lager!',
  },
  'ŞİMDİ SAT': {'tr': 'ŞİMDİ SAT', 'en': 'SELL NOW', 'de': 'JETZT VERKAUFEN'},
  'BEKLE': {'tr': 'BEKLE', 'en': 'WAIT', 'de': 'WARTEN'},
  'Ürün kalitesi düşüyor, hemen satılması önerilir.': {
    'tr': 'Ürün kalitesi düşüyor, hemen satılması önerilir.',
    'en': 'Product quality is dropping, immediate sale recommended.',
    'de': 'Produktqualität sinkt, sofortiger Verkauf empfohlen.',
  },
  'Fiyat zirveye yakın, değerlendirmek için uygun zaman.': {
    'tr': 'Fiyat zirveye yakın, değerlendirmek için uygun zaman.',
    'en': 'Price is near peak, good time to evaluate.',
    'de': 'Preis ist nahe am Höchststand, gute Zeit zum Auswerten.',
  },
  'tarihinde beklenen fiyat': {
    'tr': 'tarihinde beklenen fiyat',
    'en': 'expected price on',
    'de': 'erwarteter Preis am',
  },
  'Ocak': {'tr': 'Ocak', 'en': 'Jan', 'de': 'Jan'},
  'Şubat': {'tr': 'Şubat', 'en': 'Feb', 'de': 'Feb'},
  'Mart': {'tr': 'Mart', 'en': 'Mar', 'de': 'Mär'},
  'Nisan': {'tr': 'Nisan', 'en': 'Apr', 'de': 'Apr'},
  'Mayıs': {'tr': 'Mayıs', 'en': 'May', 'de': 'Mai'},
  'Haziran': {'tr': 'Haziran', 'en': 'Jun', 'de': 'Jun'},
  'Temmuz': {'tr': 'Temmuz', 'en': 'Jul', 'de': 'Jul'},
  'Ağustos': {'tr': 'Ağustos', 'en': 'Aug', 'de': 'Aug'},
  'Eylül': {'tr': 'Eylül', 'en': 'Sep', 'de': 'Sep'},
  'Ekim': {'tr': 'Ekim', 'en': 'Oct', 'de': 'Okt'},
  'Kasım': {'tr': 'Kasım', 'en': 'Nov', 'de': 'Nov'},
  'Aralık': {'tr': 'Aralık', 'en': 'Dec', 'de': 'Dez'},
};
