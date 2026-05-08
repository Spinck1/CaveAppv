import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../models/fiyat_simulasyonu.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import 'ayarlar_ekrani.dart';

class UrunAnalizEkrani extends StatefulWidget {
  final bool isEmbedded;

  const UrunAnalizEkrani({super.key, this.isEmbedded = false});

  @override
  State<UrunAnalizEkrani> createState() => _UrunAnalizEkraniState();
}

class _UrunAnalizEkraniState extends State<UrunAnalizEkrani> {
  final List<String> _urunler = ['Patates', 'Limon', 'Greyfurt'];
  late String _secilenUrun;
  late List<GunlukVeri> _veriler;

  @override
  void initState() {
    super.initState();
    _secilenUrun = _urunler.first;
    _veriler = FiyatSimulasyonu.uret365GunlukVeri(_secilenUrun);
  }

  void _urunDegistir(String urun) {
    setState(() {
      _secilenUrun = urun;
      _veriler = FiyatSimulasyonu.uret365GunlukVeri(urun);
    });
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
                  _buildUrunSecici(),
                  const SizedBox(height: 20),
                  _buildFiyatGrafigi(),
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
              'Ürün Analizi',
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
      child: Column(
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
                t('Profesyonel Analiz Modülü'),
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
            '365 günlük ürün fiyatı ve satış puanı analizleri.',
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

  Widget _buildUrunSecici() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.crop_square_rounded,
            color: AppTheme.accentColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _secilenUrun,
                isExpanded: true,
                dropdownColor: AppTheme.cardBackground,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                ),
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppTheme.primaryLight,
                ),
                items: _urunler
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) _urunDegistir(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiyatGrafigi() {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(top: 16, right: 8, bottom: 16, left: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t('Fiyat Trendleri')} ($_secilenUrun)',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
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
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.textMuted.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 90,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}g',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          '₺${value.toInt()}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 365,
                minY:
                    [
                      _veriler.map((v) => v.tazeFiyat).reduce(min),
                      _veriler.map((v) => v.normalFiyat).reduce(min),
                      _veriler.map((v) => v.bizimFiyat).reduce(min),
                    ].reduce(min) -
                    2,
                maxY:
                    [
                      _veriler.map((v) => v.tazeFiyat).reduce(max),
                      _veriler.map((v) => v.normalFiyat).reduce(max),
                      _veriler.map((v) => v.bizimFiyat).reduce(max),
                    ].reduce(max) +
                    2,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => LineTooltipItem(
                            '₺${spot.y.toStringAsFixed(2)}\n\$${(spot.y / CurrencyService().usdTry).toStringAsFixed(2)} | €${(spot.y / CurrencyService().eurTry).toStringAsFixed(2)}',
                            TextStyle(
                              color: spot.bar.color ?? Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _veriler
                        .where((v) => v.gun % 3 == 0)
                        .map((v) => FlSpot(v.gun.toDouble(), v.tazeFiyat))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: _veriler
                        .where((v) => v.gun % 3 == 0)
                        .map((v) => FlSpot(v.gun.toDouble(), v.normalFiyat))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFFFF9800),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: _veriler
                        .where((v) => v.gun % 3 == 0)
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
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(t('Piyasa'), const Color(0xFF4CAF50)),
              _buildLegendItem(t('Normal'), const Color(0xFFFF9800)),
              _buildLegendItem(t('Satış Puanı'), AppTheme.accentColor),
            ],
          ),
        ],
      ),
    );
  }

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
          Text(
            t('Satış Puanı Eğilimi'),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
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
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 90,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${value.toInt()}g',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10,
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
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => LineTooltipItem(
                            'Puan: ${spot.y.toStringAsFixed(1)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _veriler
                        .where((v) => v.gun % 3 == 0)
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
                    barWidth: 3,
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
        ],
      ),
    );
  }

  Widget _buildLegendItem(String baslik, Color renk) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          baslik,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
