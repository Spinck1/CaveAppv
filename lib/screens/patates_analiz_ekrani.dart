import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/fiyat_simulasyonu.dart';
import '../theme/app_theme.dart';

class PatatesAnalizEkrani extends StatefulWidget {
  final bool isEmbedded;

  const PatatesAnalizEkrani({super.key, this.isEmbedded = false});

  @override
  State<PatatesAnalizEkrani> createState() => _PatatesAnalizEkraniState();
}

class _PatatesAnalizEkraniState extends State<PatatesAnalizEkrani> {
  late List<GunlukVeri> _veriler;

  // Grafiğin toplam genişliği (365 günü rahat göstermek için)
  final double _chartWidth = 5000.0;
  // Y ekseni genişliği (sol taraftaki sabit alan)
  final double _yAxisWidth = 46.0;

  @override
  void initState() {
    super.initState();
    // Tamamen statik ve tutarlı veriyi çekiyoruz
    _veriler = FiyatSimulasyonu.uret365GunlukVeri();
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: widget.isEmbedded
          ? null
          : const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            if (!widget.isEmbedded) _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (!widget.isEmbedded) _buildBilgiKarti(),
                  if (!widget.isEmbedded) const SizedBox(height: 20),
                  _buildAdvancedFiyatGrafigi(),
                  const SizedBox(height: 20),
                  _buildPuanGrafigi(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) return content;
    return Scaffold(body: content);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Patates Fiyat Analizi',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBilgiKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: AppTheme.accentColor,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Profesyonel Analiz Modülü',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'İBB Hal Fiyatları (Taze ve Beklemiş Patates) baz alınarak oluşturulmuş 365 günlük simülasyon. Grafiği kaydırabilir ve çift parmakla yakınlaştırabilirsiniz.',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Y-Axis ve Advanced Tooltip barındıran Profesyonel Fiyat Grafiği
  Widget _buildAdvancedFiyatGrafigi() {
    return Container(
      height: 400, // Tooltip'in sığması için daha yüksek
      padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fiyat Karşılaştırması (1 Yıl)',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₺ / kg',
                  style: TextStyle(
                    color: AppTheme.textMuted.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                // 1. Kaydırılabilir Grafik (Veriler ve X ekseni)
                Positioned.fill(
                  left:
                      _yAxisWidth, // Y Ekseninin kapladığı alan kadar sağdan başla
                  child: ClipRect(
                    // Taşan kısımları gizle
                    child: InteractiveViewer(
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 0.5,
                      maxScale: 3.0,
                      boundaryMargin: EdgeInsets.zero,
                      child: SizedBox(
                        width: _chartWidth,
                        child: LineChart(_fiyatGrafigiData(showYAxis: false)),
                      ),
                    ),
                  ),
                ),

                // 2. Sabit Y Ekseni (Sadece sol tarafta durur)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _yAxisWidth,
                  child: Container(
                    color: const Color(
                      0xFF152238,
                    ), // Arka planla uyuşan renk (Y ekseni okunabilir olsun diye)
                    child: LineChart(
                      _fiyatGrafigiData(showYAxis: true, isYAxisOnly: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lejant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLejantItem('Piyasa (Taze)', const Color(0xFF4CAF50)),
              _buildLejantItem(
                'Bizim Patates',
                AppTheme.accentColor,
                isBold: true,
              ),
              _buildLejantItem('Piyasa (Normal)', const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  /// Fiyat grafiğinin veri modeli (Sticky Y-Axis için iki kez çağrılıyor)
  LineChartData _fiyatGrafigiData({
    required bool showYAxis,
    bool isYAxisOnly = false,
  }) {
    return LineChartData(
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show:
            !isYAxisOnly, // Y ekseni sadece yazıları göstersin, ızgarayı değil
        drawVerticalLine: true,
        verticalInterval: 30, // 30 günde bir dikey çizgi
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppTheme.textMuted.withValues(alpha: 0.1),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: AppTheme.textMuted.withValues(alpha: 0.05),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: !isYAxisOnly, // Y ekseni kolonunda X yazıları olmasın
            reservedSize: 30,
            interval: 30, // 30 günde bir tarih yaz
            getTitlesWidget: (value, meta) {
              if (value == meta.max) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${value.toInt()}. Gün',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: showYAxis, // Y ekseni açık/kapalı
            interval: 5,
            reservedSize: _yAxisWidth,
            getTitlesWidget: (value, meta) {
              if (!showYAxis) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '₺${value.toInt()}',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: !isYAxisOnly,
        border: Border(
          bottom: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.2)),
          left: BorderSide.none,
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      ),
      minX: 1,
      maxX: 365,
      minY: 5,
      maxY: 35,
      // Advanced Tooltip
      lineTouchData: LineTouchData(
        enabled: !isYAxisOnly,
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final textStyle = TextStyle(
                color: touchedSpot.bar.color ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );

              String prefix = '';
              if (touchedSpot.barIndex == 0) prefix = 'Taze: ';
              if (touchedSpot.barIndex == 1) prefix = 'Normal: ';
              if (touchedSpot.barIndex == 2) prefix = 'Bizim: ';

              return LineTooltipItem(
                '$prefix₺${touchedSpot.y.toStringAsFixed(2)}',
                textStyle,
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: isYAxisOnly
          ? [] // Sadece Y ekseniyse çizgilere gerek yok
          : [
              // 1. Taze Patates Çizgisi (Yeşil)
              LineChartBarData(
                spots: _veriler
                    .map((v) => FlSpot(v.gun.toDouble(), v.tazeFiyat))
                    .toList(),
                isCurved: true,
                color: const Color(0xFF4CAF50),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
              // 2. Normal/Beklemiş Patates Çizgisi (Turuncu)
              LineChartBarData(
                spots: _veriler
                    .map((v) => FlSpot(v.gun.toDouble(), v.normalFiyat))
                    .toList(),
                isCurved: true,
                color: const Color(0xFFFF9800),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
              // 3. Bizim Patatesimizin Fiyat Çizgisi (Mavi/Accent)
              LineChartBarData(
                spots: _veriler
                    .map((v) => FlSpot(v.gun.toDouble(), v.bizimFiyat))
                    .toList(),
                isCurved: true,
                color: AppTheme.accentColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                ),
              ),
            ],
    );
  }

  /// Puan Grafiği (Basitleştirilmiş haliyle)
  Widget _buildPuanGrafigi() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Satış Puanı Düşüşü',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: SizedBox(
                width: _chartWidth,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ), // Basit görünüm için gizledik
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${value.toInt()}. Gün',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 1,
                    maxX: 365,
                    minY: 0,
                    maxY: 100,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots
                              .map(
                                (spot) => LineTooltipItem(
                                  'Puan: ${spot.y.toStringAsFixed(1)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              .toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _veriler
                            .map((v) => FlSpot(v.gun.toDouble(), v.satisPuani))
                            .toList(),
                        isCurved: true,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFFFFCA28),
                            Color(0xFFFF5252),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4CAF50).withValues(alpha: 0.2),
                              const Color(0xFFFFCA28).withValues(alpha: 0.2),
                              const Color(0xFFFF5252).withValues(alpha: 0.2),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLejantItem(String baslik, Color renk, {bool isBold = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          baslik,
          style: TextStyle(
            color: isBold ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
