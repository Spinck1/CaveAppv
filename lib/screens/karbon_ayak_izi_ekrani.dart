import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/depo.dart';
import '../services/carbon_service.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';

class KarbonAyakIziEkrani extends StatefulWidget {
  final List<Depo> depolar;

  const KarbonAyakIziEkrani({super.key, required this.depolar});

  @override
  State<KarbonAyakIziEkrani> createState() => _KarbonAyakIziEkraniState();
}

class _KarbonAyakIziEkraniState extends State<KarbonAyakIziEkrani> {
  Depo? _secilenDepo;
  final TextEditingController _varisController = TextEditingController();
  final TextEditingController _miktarController = TextEditingController(
    text: '20',
  );
  String _secilenArac = 'Tır (Kara)';
  String? _onerilenArac;

  bool _hesaplaniyor = false;
  List<Map<String, dynamic>> _rotaSecenekleri = [];
  LatLng? _varisKoord;
  String? _hata;
  Map<String, dynamic>? _apiSonuclari;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.depolar.isNotEmpty) {
      _secilenDepo = widget.depolar.first;
      _onerilenArac = CarbonService.suggestOptimalVehicle(
        20,
        _secilenDepo!.lat != null
            ? LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!)
            : null,
        null,
      );
    } else {
      _onerilenArac = 'Tır (Kara)';
    }
    _secilenArac = _onerilenArac!;
  }

  void _onMiktarChanged(String value) {
    final miktar = double.tryParse(value) ?? 0;
    final start = _secilenDepo != null
        ? LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!)
        : null;
    setState(() {
      _onerilenArac = CarbonService.suggestOptimalVehicle(
        miktar,
        start,
        _varisKoord,
      );
    });
  }

  Future<void> _hesapla({LatLng? manualDest}) async {
    if (_secilenDepo == null || _secilenDepo!.lat == null) {
      setState(() => _hata = 'Lütfen geçerli konumu olan bir depo seçin.');
      return;
    }

    setState(() {
      _hesaplaniyor = true;
      _hata = null;
      _rotaSecenekleri = [];
    });

    try {
      LatLng? destCoord = manualDest;
      if (destCoord == null && _varisController.text.isNotEmpty) {
        destCoord = await CarbonService.getCoordinatesFromAddress(
          _varisController.text,
        );
      }

      if (destCoord == null) {
        setState(() {
          _hata = 'Lütfen haritadan bir nokta seçin veya adres girin.';
          _hesaplaniyor = false;
        });
        return;
      }

      final start = LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!);
      final options = await CarbonService.getRouteOptions(start, destCoord);

      // API'den canlı hesaplama al (Hackathon Kuralı)
      final apiData = await CarbonService.calculateCarbonViaApi(
        start: start,
        end: destCoord,
        weight: double.tryParse(_miktarController.text) ?? 20,
        vehicle: _secilenArac,
      );

      setState(() {
        _varisKoord = destCoord;
        _rotaSecenekleri = options;
        _apiSonuclari = apiData;
        _hesaplaniyor = false;
        // Rota hesaplandıktan sonra öneriyi güncelle
        _onerilenArac = CarbonService.suggestOptimalVehicle(
          double.tryParse(_miktarController.text) ?? 20,
          start,
          destCoord,
        );
      });

      if (_varisKoord != null && _secilenDepo?.lat != null) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(
              LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!),
              _varisKoord!,
            ),
            padding: const EdgeInsets.all(50),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _hata = 'Bağlantı hatası: API çalışıyor mu kontrol edin.';
        _hesaplaniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'COĞRAFİ KARBON ANALİZİ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // HARİTA BÖLÜMÜ
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _secilenDepo?.lat != null
                        ? LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!)
                        : const LatLng(38.62, 34.71),
                    initialZoom: 13,
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: (tapPosition, point) {
                      setState(() => _varisKoord = point);
                      _hesapla(manualDest: point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.caveapp',
                    ),
                    if (_rotaSecenekleri.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points:
                                _rotaSecenekleri[0]['points'] as List<LatLng>,
                            color: Colors.blue,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_secilenDepo?.lat != null)
                          Marker(
                            point: LatLng(
                              _secilenDepo!.lat!,
                              _secilenDepo!.lng!,
                            ),
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "Depo",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.factory,
                                  color: AppTheme.primaryColor,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        if (_varisKoord != null)
                          Marker(
                            point: _varisKoord!,
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "Hedef",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.mapPin,
                                  color: AppTheme.dangerColor,
                                  size: 35,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _buildFloatingSearch(),
                ),
                if (_hesaplaniyor)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ANALİZ PANELİ
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(),
                    if (_hata != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hata!,
                          style: const TextStyle(
                            color: AppTheme.dangerColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildConfigPanel(),
                    const SizedBox(height: 24),

                    // SONUÇLAR (Her zaman görünür, veri yoksa 0 gösterir)
                    _buildMainResults(),

                    if (_rotaSecenekleri.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'GÜZERGAH DETAYLARI',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.milestone,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'En Kısa Karayolu Rotası (OSRM)',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${(_rotaSecenekleri[0]['distanceKm'] as double).toStringAsFixed(1)} km • ${(_rotaSecenekleri[0]['durationMin'] as double).toStringAsFixed(0)} dk',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    _buildMathFormulaSection(),
                    const SizedBox(height: 24),
                    _buildDetailedMethodology(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.leaf, color: Colors.green, size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Karbon Ayak İzi Analizi',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                'Lojistik süreçlerinizin çevresel etkisini ölçün',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Depo>(
                  value: _secilenDepo,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    'Çıkış Deposu',
                    LucideIcons.warehouse,
                  ),
                  dropdownColor: AppTheme.surfaceColor,
                  items: widget.depolar
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            d.ad,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _secilenDepo = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _miktarController,
                  keyboardType: TextInputType.number,
                  onChanged: _onMiktarChanged,
                  decoration: _inputDecoration(
                    'Miktar (Ton)',
                    LucideIcons.package,
                  ),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _secilenArac,
            isExpanded: true,
            decoration: _inputDecoration(
              'Lojistik Seçeneği',
              LucideIcons.truck,
            ),
            dropdownColor: AppTheme.surfaceColor,
            items: CarbonService.emissionFactors.keys
                .map(
                  (arac) => DropdownMenuItem(
                    value: arac,
                    child: Text(
                      arac,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _secilenArac = v);
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _hesapla(),
              icon: const Icon(LucideIcons.calculator, size: 18),
              label: const Text(
                'ANALİZİ BAŞLAT',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  color: AppTheme.primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sistem Önerisi: $_onerilenArac',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResults() {
    double distance = 0;
    double footprint = 0;
    double fuel = 0;
    int trees = 0;
    bool isApiData = false;

    if (_apiSonuclari != null) {
      distance = (_apiSonuclari!['distance_km'] as num).toDouble();
      footprint = (_apiSonuclari!['carbon_kg'] as num).toDouble();
      fuel = (_apiSonuclari!['fuel_liters'] as num).toDouble();
      trees = (_apiSonuclari!['trees_needed'] as num).toInt();
      isApiData = true;
    } else if (_rotaSecenekleri.isNotEmpty) {
      final rota = _rotaSecenekleri[0];
      distance = rota['distanceKm'] as double;
      footprint = CarbonService.calculateFootprint(
        distanceKm: distance,
        weightTons: double.tryParse(_miktarController.text) ?? 0,
        vehicle: _secilenArac,
      );
      fuel = CarbonService.calculateFuel(distance, _secilenArac);
      trees = CarbonService.calculateTrees(footprint);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900.withValues(alpha: 0.9),
            Colors.green.shade700.withValues(alpha: 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isApiData)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.yellow, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Formüllerle Yapılmıştır.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Text(
            'TOPLAM KARBON SALINIMI',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                footprint == 0 ? '0.0' : footprint.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'kg CO2',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCurrencyValue(
                  '₺',
                  (footprint * 0.07 * CurrencyService().eurTry),
                ),
                const SizedBox(width: 16),
                _buildCurrencyValue(
                  '\$',
                  (footprint *
                      0.07 *
                      CurrencyService().eurTry /
                      CurrencyService().usdTry),
                ),
                const SizedBox(width: 16),
                _buildCurrencyValue('€', (footprint * 0.07)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bu CO2\'yi atmosferden yok etmek için gereken maliyet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '(TCMB Kurları ve EU ETS - €0.07/kg üzerinden)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: _buildBigStat(
                  LucideIcons.droplets,
                  '${fuel.toStringAsFixed(0)} L',
                  'Yakıt',
                ),
              ),
              Flexible(
                child: _buildBigStat(
                  LucideIcons.trees,
                  '$trees Adet',
                  'Ağaç Dikimi',
                ),
              ),
              Flexible(
                child: _buildBigStat(
                  LucideIcons.milestone,
                  '${distance.toStringAsFixed(0)} km',
                  'Mesafe',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMathFormulaSection() {
    final rota = _rotaSecenekleri.isNotEmpty ? _rotaSecenekleri[0] : null;
    final km = rota != null
        ? (rota['distanceKm'] as double).toStringAsFixed(1)
        : 'X';
    final ton = _miktarController.text.isEmpty ? 'Y' : _miktarController.text;
    final coef = CarbonService.emissionFactors[_secilenArac]?.toString() ?? 'Z';
    final baseCoef =
        CarbonService.vehicleBaseEmissions[_secilenArac]?.toString() ?? 'W';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                LucideIcons.calculator,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'HESAPLAMA FORMÜLÜ',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                child: Text(
                  '(${km}km × ${ton}t × $coef) + (${km}km × ${baseCoef}) = ${rota != null ? CarbonService.calculateFootprint(distanceKm: rota['distanceKm'], weightTons: double.tryParse(_miktarController.text) ?? 0, vehicle: _secilenArac).toStringAsFixed(1) : "?"} kg CO2',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '* Formül: (Mesafe × Ağırlık × Katsayı) + (Mesafe × Araç Baz Emisyonu)',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMethodology() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'METODOLOJİ VE STANDARTLAR',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _methodItem(
          '1. Karbon Emisyonu',
          'Taşımacılıkta oluşan karbon ayak izi, IPCC 2024 (Hükümetlerarası İklim Değişikliği Paneli) tarafından belirlenen araç başı birim emisyon katsayıları kullanılarak dinamik olarak hesaplanır.',
        ),
        _methodItem(
          '2. Yakıt Verimliliği',
          'Araç tiplerine göre atanan ortalama yakıt tüketim verileri (L/km), katedilen mesafe ile çarpılarak tahmini toplam yakıt sarfiyatı bulunur.',
        ),
        _methodItem(
          '3. Karbon Nötrleme',
          '1 yetişkin ağacın yılda ortalama 20 kg CO2 emdiği kabul edilerek, lojistik sürecin etkisini nötrlemek için gereken ağaç sayısı tamsayıya yuvarlanır.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _coefRow('Hava Kargo', '0.500 kg/ton-km', '12.0 L/km'),
              _coefRow('Tır (Kara)', '0.100 kg/ton-km', '0.35 L/km'),
              _coefRow('Demiryolu', '0.030 kg/ton-km', '0.15 L/km'),
              _coefRow('Deniz Yolu', '0.015 kg/ton-km', '0.05 L/km'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coefRow(String v, String c, String f) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            v,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$c | $f',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _methodItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: _varisController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Varış noktası ara...',
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(
              LucideIcons.search,
              size: 18,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => _hesapla(),
          ),
        ),
        onSubmitted: (_) => _hesapla(),
      ),
    );
  }

  Widget _buildCurrencyValue(String symbol, double value) {
    return Column(
      children: [
        Text(
          symbol,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(icon, size: 16, color: AppTheme.primaryColor),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
