# CaveApp — Mağara Depo Yönetim Sistemi

Nevşehir/Kapadokya bölgesindeki mağara depolarını dijital olarak yönetmek için geliştirilmiş Flutter uygulaması.

---

## Ne İşe Yarıyor?

Çiftçiler ve toptancılar patates, limon, greyfurt gibi tarım ürünlerini doğal mağaralarda soğuk hava deposu olarak kullanarak depolayıp fiyatlar yükselince satıyor. CaveApp bu süreci uçtan uca yönetiyor:

- Mağara içindeki sıcaklık, nem ve ışık verilerini IoT sensörlerle gerçek zamanlı izler
- Ürünlerin depo koşullarına göre "satılabilirlik puanı" hesaplar
- Piyasa fiyatlarını takip ederek en karlı satış zamanını gösterir
- Tüm depolar harita üzerinde görüntülenir, depolar arası rota hesaplanır

---

## Özellikler

### Kullanıcı Sistemi
- Kayıt ve giriş (Flask backend)
- Her kullanıcının depo ve ürün verisi birbirinden bağımsız

### IoT Sensör Takibi (Arduino)
- Sıcaklık, nem, ışık değerleri anlık izleme
- Kritik eşik uyarıları:
  - Sıcaklık > 20°C → Kritik sıcaklık uyarısı
  - Sıcaklık < 2°C → Donma riski
  - Nem < %70 veya > %96 → Çürüme riski
  - Işık > 600 lux → Yeşillenme riski

### Depo Yönetimi
- Harita üzerinde GPS konumuyla yeni depo ekleme
- Kapasite (ton) takibi ve doluluk oranı
- Depolar arası mesafe ve rota hesaplama (OpenStreetMap / OSRM)

### Ürün Takibi
- Depoya ürün girişi (ürün adı, miktar, alış fiyatı)
- Sensör verileri + borsa fiyatına göre ürün puan hesaplama
- Satış özeti ve geçmiş kayıtlar

### Piyasa & Fiyat
- Anlık borsa fiyat simülasyonu
- Döviz kurları takibi
- İhracat puanı raporu

### Diğer
- Bildirim sistemi (kritik uyarılar anlık iletilir)
- Karbon ayak izi hesaplama
- Türkçe / İngilizce dil desteği

---

## Teknik Yapı

```
Flutter App  (Android / iOS / Web)
       ↕
Flask Backend  (Python)  —  localhost:5000
       ↕
Arduino / IoT Sensör  (Sıcaklık · Nem · Işık)
```

| Katman | Teknoloji |
|--------|-----------|
| Mobil & Web Arayüz | Flutter / Dart |
| Backend API | Python Flask |
| Lokal Veri | SharedPreferences (kullanıcıya özel) |
| Harita | OpenStreetMap + flutter_map |
| Rota Hesaplama | OSRM API |
| Grafikler | fl_chart |
| Sensör | Arduino → Flask → Uygulama |

---

## Kurulum

### Backend (Flask)
```bash
pip install flask
python app.py
```
Sunucu `http://127.0.0.1:5000` adresinde çalışır.

### Flutter Uygulaması

> **ÖNEMLİ:** Projeyi ilk indirdiğinizde terminale mutlaka `flutter pub get` yazın!

```bash
flutter pub get
flutter run
```

---

## Hedef Kullanıcı

Nevşehir/Kapadokya'daki mağara depolarında tarım ürünü depolayan çiftçiler ve tarım kooperatifleri. Uygulama, ürünlerin doğru koşullarda saklanmasını ve en yüksek piyasa fiyatında satılmasını sağlar.

---

## Hackathon Ekibi

Kapadokya Hackathon — 2026 Breaking Code
