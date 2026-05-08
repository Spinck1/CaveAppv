import 'package:flutter/material.dart';
import '../models/depo.dart';
import '../theme/app_theme.dart';

class SensorKarti extends StatelessWidget {
  final IconData icon;
  final String baslik;
  final String deger;
  final String birim;
  final Color renk;
  final double? yuzde; // 0-100 arası ilerleme çubuğu için

  const SensorKarti({
    super.key,
    required this.icon,
    required this.baslik,
    required this.deger,
    required this.birim,
    required this.renk,
    this.yuzde,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // İkon ve başlık
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: renk, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            baslik,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Değer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                deger,
                style: TextStyle(
                  color: renk,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  birim,
                  style: TextStyle(
                    color: renk.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // İlerleme çubuğu
          if (yuzde != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (yuzde! / 100).clamp(0, 1),
                backgroundColor: renk.withValues(alpha: 0.1),
                color: renk,
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DepoKarti extends StatelessWidget {
  final Depo depo;

  const DepoKarti({super.key, required this.depo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Depo başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warehouse_rounded,
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      depo.ad,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (depo.konum.isNotEmpty)
                      Text(
                        depo.konum,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Durum göstergesi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Çevrimiçi',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // BACA DURUMU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: depo.bacaUyarisi ? Colors.red.withValues(alpha: 0.15) : AppTheme.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: depo.bacaUyarisi ? Colors.red.withValues(alpha: 0.3) : AppTheme.primaryLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  depo.bacalarAcik ? Icons.air_rounded : Icons.mode_standby_rounded,
                  color: depo.bacaUyarisi ? Colors.red : AppTheme.primaryLight,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  depo.bacalarAcik ? 'Bacalar Açık (Havalandırma Aktif)' : 'DONMA RİSKİ: Bacalar Kapatıldı!',
                  style: TextStyle(
                    color: depo.bacaUyarisi ? Colors.red : AppTheme.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sensör kartları
          Row(
            children: [
              Expanded(
                child: SensorKarti(
                  icon: Icons.thermostat_rounded,
                  baslik: 'SICAKLIK',
                  deger: depo.sicaklik.toStringAsFixed(1),
                  birim: '°C',
                  renk: AppTheme.temperatureColor,
                  yuzde: ((depo.sicaklik - 15) / 20 * 100).clamp(0, 100),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SensorKarti(
                  icon: Icons.water_drop_rounded,
                  baslik: 'NEM',
                  deger: depo.nem.toStringAsFixed(1),
                  birim: '%',
                  renk: AppTheme.humidityColor,
                  yuzde: depo.nem.clamp(0, 100),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SensorKarti(
                  icon: Icons.light_mode_rounded,
                  baslik: 'IŞIK',
                  deger: depo.isik.toStringAsFixed(0),
                  birim: 'lux',
                  renk: AppTheme.lightColor,
                  yuzde: (depo.isik / 10).clamp(0, 100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Son güncelleme
          Text(
            'Son güncelleme: ${_formatTarih(depo.sonGuncelleme)}',
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTarih(DateTime tarih) {
    return '${tarih.hour.toString().padLeft(2, '0')}:'
        '${tarih.minute.toString().padLeft(2, '0')}:'
        '${tarih.second.toString().padLeft(2, '0')}';
  }
}
