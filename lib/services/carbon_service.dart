import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CarbonService {
  // OSRM Public API (Open Source Routing Machine)
  static const String _osrmBaseUrl =
      'https://router.project-osrm.org/route/v1/driving'; //map için
  // Nominatim Public API (Geocoding)
  static const String _nominatimBaseUrl =
      'https://nominatim.openstreetmap.org/search'; //map için

  /// Emisyon katsayıları (kg CO2 / ton-km)
  /// Kaynak: Hackathon Gereksinimleri / IPCC
  static const Map<String, double> emissionFactors = {
    'Hava Kargo': 0.500,
    'Tır (Kara)': 0.100,
    'Demiryolu': 0.030,
    'Deniz Yolu': 0.015,
  };

  // Yerel Python API Adresi (Hackathon Kuralı için oluşturuldu)
  static const String _localApiUrl = 'http://127.0.0.1:5000';

  /// Adresten koordinat bulma (Nominatim)
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // Önce yerel API'yi dene
      final response = await http
          .get(
            Uri.parse(
              '$_localApiUrl/geocode?address=${Uri.encodeComponent(address)}',
            ),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LatLng(data['lat'], data['lng']);
      }
    } catch (e) {
      // Yerel API kapalıysa doğrudan Nominatim'e git (Yedek)
      try {
        final response = await http.get(
          Uri.parse(
            '$_nominatimBaseUrl?q=${Uri.encodeComponent(address)}&format=json&limit=1',
          ),
          headers: {'User-Agent': 'CaveApp_Hackathon_Project'},
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            return LatLng(
              double.parse(data[0]['lat']),
              double.parse(data[0]['lon']),
            );
          }
        }
      } catch (e2) {
        print('Geocoding error: $e2');
      }
    }
    return null;
  }

  /// İki nokta arasındaki yol seçeneklerini getirme (OSRM)
  /// İki nokta arasındaki yol seçeneklerini getirme (OSRM)
  static Future<List<Map<String, dynamic>>> getRouteOptions(
    LatLng start,
    LatLng end,
  ) async {
    try {
      // Bazı OSRM sunucuları alternatives için sayı alabilir, 3 adet istiyoruz.
      final url =
          '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&alternatives=3';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(
            data['routes'].map((r) {
              List<LatLng> points = [];
              if (r['geometry'] != null &&
                  r['geometry']['coordinates'] != null) {
                for (var coord in r['geometry']['coordinates']) {
                  points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
                }
              }
              return {
                'distanceKm': (r['distance'] ?? 0) / 1000.0,
                'durationMin': (r['duration'] ?? 0) / 60.0,
                'points': points,
              };
            }),
          );
        }
      }
    } catch (e) {
      print('Routing error: $e');
    }

    // Yedek: Sadece kuş uçuşu
    final Distance distance = const Distance();
    final d = distance.as(LengthUnit.Kilometer, start, end).toDouble();
    return [
      {
        'distanceKm': d,
        'durationMin': d * 1.2,
        'polyline': '',
        'points': [start, end],
      },
    ];
  }

  /// Yük miktarına ve coğrafi konuma göre en mantıklı araç önerisi
  static String suggestOptimalVehicle(
    double weightTons,
    LatLng? start,
    LatLng? end,
  ) {
    if (start == null || end == null) return 'Tır (Kara)';

    final Distance distanceCalc = const Distance();
    final distanceKm = distanceCalc.as(LengthUnit.Kilometer, start, end);

    // Liman Şehirleri (Yaklaşık Koordinatlar)
    final ports = [
      LatLng(38.4237, 27.1428), // İzmir
      LatLng(36.8121, 34.6415), // Mersin
      LatLng(41.0082, 28.9784), // İstanbul
      LatLng(41.2867, 36.33), // Samsun
      LatLng(36.5833, 36.1667), // İskenderun
    ];

    bool isNearPort(LatLng loc) {
      return ports.any(
        (p) => distanceCalc.as(LengthUnit.Kilometer, loc, p) < 150,
      ); // 150km port etki alanı
    }

    // Çok kısa mesafe ise sadece Tır
    if (distanceKm < 100) return 'Tır (Kara)';

    // Deniz Yolu: Her iki nokta da limana yakınsa ve mesafe uzaksa
    if (distanceKm > 400 && isNearPort(start) && isNearPort(end)) {
      return 'Deniz Yolu';
    }

    // Demiryolu: Mesafe orta-uzun ise ve yük fazlaysa
    if (distanceKm > 200 && weightTons > 30) {
      return 'Demiryolu';
    }

    // Hava Kargo: Çok uzak mesafe ve düşük ağırlık (Hızlı teslimat senaryosu)
    if (distanceKm > 800 && weightTons < 5) {
      return 'Hava Kargo';
    }

    return 'Tır (Kara)';
  }

  /// Yakıt tüketim katsayıları (Litre / km)
  static const Map<String, double> fuelFactors = {
    'Hava Kargo': 12.0, // Uçak (basitleştirilmiş)
    'Tır (Kara)': 0.35,
    'Demiryolu': 0.15,
    'Deniz Yolu': 0.05,
  };

  /// Karbon Ayak İzi Hesaplama (kg CO2)
  /// Formül: (Mesafe * Ağırlık * Katsayı) + (Mesafe * Araç_Baz_Emisyonu)
  static double calculateFootprint({
    required double distanceKm,
    required double weightTons,
    required String vehicle,
  }) {
    final factor = emissionFactors[vehicle] ?? 0.1;
    final baseFactor = vehicleBaseEmissions[vehicle] ?? 0.2;

    return (distanceKm * weightTons * factor) + (distanceKm * baseFactor);
  }

  /// Araçların boş ağırlık/seyir emisyonları (kg CO2 / km)
  static const Map<String, double> vehicleBaseEmissions = {
    'Hava Kargo': 1.500,
    'Tır (Kara)': 0.250,
    'Demiryolu': 0.100,
    'Deniz Yolu': 0.050,
  };

  /// Tahmini yakıt tüketimi (Litre)
  static double calculateFuel(double distanceKm, String vehicle) {
    return distanceKm * (fuelFactors[vehicle] ?? 0.2);
  }

  /// Python API üzerinden dinamik hesaplama (Hackathon Kuralı)
  static Future<Map<String, dynamic>?> calculateCarbonViaApi({
    required LatLng start,
    required LatLng end,
    required double weight,
    required String vehicle,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_localApiUrl/calculate_carbon'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'start_lat': start.latitude,
              'start_lng': start.longitude,
              'end_lat': end.latitude,
              'end_lng': end.longitude,
              'weight': weight,
              'vehicle': vehicle,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('API Calculation error: $e');
    }
    return null;
  }

  /// Gerekli ağaç sayısı (1 yetişkin ağaç yılda ~20kg CO2 emer)
  static int calculateTrees(double kgCo2) {
    return (kgCo2 / 20).ceil();
  }
}
