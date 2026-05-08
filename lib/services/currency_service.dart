import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  double _usdTry = 45.05; // Gerçekçi Fallback
  double _eurTry = 52.66;
  DateTime _lastUpdate = DateTime.now();
  bool _isConnected = true;

  double get usdTry => _usdTry;
  double get eurTry => _eurTry;
  DateTime get lastUpdate => _lastUpdate;
  bool get isConnected => _isConnected;

  Future<void> fetchRates() async {
    // Web platformunda CORS sorunlarını aşmak için alternatif kaynaklar
    final sources = [
      // 1. Kaynak: TCMB (Proxy ile)
      () async {
        const String targetUrl = 'https://www.tcmb.gov.tr/kurlar/today.xml';
        const String proxyUrl = 'https://api.allorigins.win/raw?url=${targetUrl}';
        final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200 && response.body.contains('Tarih_Date')) {
          final body = utf8.decode(response.bodyBytes);
          final document = XmlDocument.parse(body);
          final currencies = document.findAllElements('Currency');
          for (var currency in currencies) {
            final code = currency.getAttribute('CurrencyCode');
            if (code == 'USD' || code == 'EUR') {
              final sellingNode = currency.findElements('ForexSelling').firstOrNull;
              if (sellingNode != null && sellingNode.innerText.isNotEmpty) {
                double value = double.parse(sellingNode.innerText.replaceAll(',', '.'));
                if (code == 'USD') _usdTry = value;
                if (code == 'EUR') _eurTry = value;
              }
            }
          }
          return true;
        }
        return false;
      },
      // 2. Kaynak: Open Exchange Rates (CORS Dostu)
      () async {
        final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/TRY')).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['result'] == 'success') {
            final rates = data['rates'];
            _usdTry = 1 / (rates['USD'] ?? 0.022);
            _eurTry = 1 / (rates['EUR'] ?? 0.019);
            return true;
          }
        }
        return false;
      },
      // 3. Kaynak: ExchangeRate-API (CORS Dostu)
      () async {
        final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/TRY')).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _usdTry = 1 / (data['rates']['USD'] ?? 0.022);
          _eurTry = 1 / (data['rates']['EUR'] ?? 0.019);
          return true;
        }
        return false;
      }
    ];

    bool success = false;
    for (var source in sources) {
      try {
        if (await source()) {
          success = true;
          break;
        }
      } catch (e) {
        print('Kaynak hatası, bir sonrakine geçiliyor...');
      }
    }

    if (success) {
      _lastUpdate = DateTime.now();
      _isConnected = true;
    } else {
      // Eğer hiçbiri çalışmazsa ama elimizde önceden veri varsa, tamamen kesildi demeyelim
      _isConnected = (DateTime.now().difference(_lastUpdate).inMinutes < 10);
    }
  }

  double convertToUsd(double tlAmount) => _usdTry > 0 ? tlAmount / _usdTry : 0;
  double convertToTl(double usdAmount) => usdAmount * _usdTry;
}
