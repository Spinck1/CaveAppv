import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/depo.dart';
import '../theme/app_theme.dart';
import '../utils/orientation_manager.dart';

class HaritaEkrani extends StatefulWidget {
  final List<Depo> depolar;
  final Function(Depo) onDepoEkle;

  const HaritaEkrani({
    super.key,
    required this.depolar,
    required this.onDepoEkle,
  });

  @override
  State<HaritaEkrani> createState() => _HaritaEkraniState();
}

class _HaritaEkraniState extends State<HaritaEkrani> {
  final MapController _mapController = MapController();
  Depo? _secilenDepo;
  LatLng? _hedefNoktasi;
  List<LatLng> _rotaNoktalar = [];
  double _mesafe = 0;
  double _sure = 0;
  bool _rotaYukleniyor = false;
  bool _depoEkleModu = false;

  @override
  void initState() {
    super.initState();
    OrientationManager.setAllOrientations();
  }

  @override
  void dispose() {
    OrientationManager.setPortraitOnly();
    super.dispose();
  }

  Future<void> _rotaHesapla(LatLng basla, LatLng bitis) async {
    setState(() {
      _rotaYukleniyor = true;
      _mesafe = 0;
      _sure = 0;
      _rotaNoktalar = [];
    });

    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${basla.longitude},${basla.latitude};${bitis.longitude},${bitis.latitude}?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];

          if (geometry != null && geometry['coordinates'] != null) {
            final coordinates = geometry['coordinates'] as List;
            final mesafe = (route['distance'] as num) / 1000;
            final sure = (route['duration'] as num) / 60;

            final List<LatLng> noktalar = [];
            for (var coord in coordinates) {
              if (coord is List && coord.length == 2) {
                noktalar.add(LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble()));
              }
            }

            setState(() {
              _rotaNoktalar = noktalar;
              _mesafe = mesafe;
              _sure = sure;
              _rotaYukleniyor = false;
            });
          } else {
            setState(() => _rotaYukleniyor = false);
          }
        } else {
          setState(() => _rotaYukleniyor = false);
        }
      } else {
        setState(() => _rotaYukleniyor = false);
      }
    } catch (e) {
      setState(() => _rotaYukleniyor = false);
    }
  }

  void _depoSec(Depo depo) {
    setState(() {
      _secilenDepo = depo;
      _hedefNoktasi = null;
      _mesafe = 0;
      _sure = 0;
      _rotaNoktalar = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${depo.ad} başlangıç olarak seçildi')),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) async {
    if (_depoEkleModu) {
      _yeniDepoDialogGoster(point);
      return;
    }

    if (_secilenDepo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir depo seç!')),
      );
      return;
    }

    setState(() {
      _hedefNoktasi = point;
      _rotaNoktalar = [];
    });

    await _rotaHesapla(LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!), point);
  }

  void _yeniDepoDialogGoster(LatLng konum) {
    final adController = TextEditingController();
    final konumController = TextEditingController();
    double kapasite = 1000;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Row(
            children: [
              Icon(Icons.add_location_alt, color: AppTheme.primaryColor),
              SizedBox(width: 10),
              Text('Yeni Depo Ekle', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${konum.latitude.toStringAsFixed(5)}, ${konum.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Depo Adı',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.warehouse, color: AppTheme.primaryColor, size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.surfaceLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: konumController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Konum Adı (İsteğe bağlı)',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.place, color: AppTheme.primaryColor, size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.surfaceLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.storage, color: AppTheme.accentColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Kapasite: ${kapasite.toStringAsFixed(0)} ton',
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Slider(
                  value: kapasite,
                  min: 100,
                  max: 10000,
                  divisions: 99,
                  label: '${kapasite.toStringAsFixed(0)} t',
                  activeColor: AppTheme.primaryColor,
                  inactiveColor: AppTheme.surfaceLight,
                  onChanged: (v) => setDialogState(() => kapasite = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text('Ekle', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (adController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Depo adı boş olamaz!')),
                  );
                  return;
                }
                final yeniDepo = Depo(
                  id: 'depo_${DateTime.now().millisecondsSinceEpoch}',
                  ad: adController.text.trim(),
                  konum: konumController.text.trim().isNotEmpty
                      ? konumController.text.trim()
                      : '${konum.latitude.toStringAsFixed(4)}, ${konum.longitude.toStringAsFixed(4)}',
                  kapasite: kapasite,
                  sicaklik: 0,
                  nem: 0,
                  isik: 0,
                  lat: konum.latitude,
                  lng: konum.longitude,
                );
                widget.onDepoEkle(yeniDepo);
                setState(() => _depoEkleModu = false);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${yeniDepo.ad} başarıyla eklendi!'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _depoDetayDialog(Depo depo) {
    double kapasite = depo.kapasite;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Row(
            children: [
              const Icon(Icons.warehouse, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  depo.ad,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.place, color: AppTheme.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      depo.konum,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.surfaceLight),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.storage, color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Kapasite: ${kapasite.toStringAsFixed(0)} ton',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Slider(
                value: kapasite,
                min: 100,
                max: 10000,
                divisions: 99,
                label: '${kapasite.toStringAsFixed(0)} t',
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.surfaceLight,
                onChanged: (v) => setDialogState(() => kapasite = v),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.route, size: 18),
                  label: const Text('Başlangıç Noktası Yap'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _depoSec(depo);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () {
                setState(() => depo.kapasite = kapasite);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${depo.ad} kapasitesi güncellendi: ${kapasite.toStringAsFixed(0)} ton'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Depo Haritası'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(38.9637, 35.2433),
              initialZoom: 6,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.depo_yonetim',
              ),
              if (_rotaNoktalar.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _rotaNoktalar,
                      strokeWidth: 5.0,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_secilenDepo != null && _secilenDepo!.lat != null)
                    Marker(
                      point: LatLng(_secilenDepo!.lat!, _secilenDepo!.lng!),
                      width: 120,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => _depoDetayDialog(_secilenDepo!),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                _secilenDepo!.ad,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 30),
                          ],
                        ),
                      ),
                    ),
                  if (_hedefNoktasi != null)
                    Marker(
                      point: _hedefNoktasi!,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ...widget.depolar
                      .where((d) => d.lat != null && d.lng != null && (_secilenDepo == null || d.id != _secilenDepo!.id))
                      .map((depo) => Marker(
                            point: LatLng(depo.lat!, depo.lng!),
                            width: 120,
                            height: 60,
                            child: GestureDetector(
                              onTap: () => _depoDetayDialog(depo),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      depo.ad,
                                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.location_on, color: AppTheme.dangerColor, size: 30),
                                ],
                              ),
                            ),
                          )),
                ],
              ),
            ],
          ),

          // Depo ekleme modu bandı
          if (_depoEkleModu)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: AppTheme.primaryColor.withValues(alpha: 0.92),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Depo eklemek istediğiniz yere dokunun',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // Bilgi Paneli
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: _secilenDepo == null
                  ? const Text('Başlamak için bir depoyu seç', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📍 ${_secilenDepo!.ad}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        if (_rotaYukleniyor)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else if (_mesafe > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('📏 ${_mesafe.toStringAsFixed(1)} km | ⏱ ${_sure.toStringAsFixed(0)} dk',
                                style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600)),
                          )
                        else if (_hedefNoktasi != null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Hedef noktası seçildi, rota hesaplanıyor...', style: TextStyle(fontSize: 11)),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Hedef noktası seçmek için haritaya tıklayın', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _depoEkleModu = !_depoEkleModu),
        backgroundColor: _depoEkleModu ? AppTheme.dangerColor : AppTheme.primaryColor,
        icon: Icon(
          _depoEkleModu ? Icons.close : Icons.add_location_alt,
          color: Colors.white,
        ),
        label: Text(
          _depoEkleModu ? 'İptal' : 'Depo Ekle',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
