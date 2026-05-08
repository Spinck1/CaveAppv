import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'ayarlar_ekrani.dart';

class BildirimlerEkrani extends StatelessWidget {
  const BildirimlerEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          t('Bildirim Merkezi'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: NotificationService.bildirimler.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 64,
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('Henüz bildirim yok'),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: NotificationService.bildirimler.length,
              itemBuilder: (context, index) {
                final b = NotificationService.bildirimler[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppTheme.panelDecoration(blur: 5),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: b.kritikMi
                          ? AppTheme.dangerColor.withValues(alpha: 0.2)
                          : AppTheme.primaryLight,
                      child: Icon(
                        b.kritikMi ? Icons.warning_rounded : Icons.info_rounded,
                        color: b.kritikMi
                            ? AppTheme.dangerColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(
                      b.baslik,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          b.icerik,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${b.tarih.day}/${b.tarih.month}/${b.tarih.year} ${b.tarih.hour}:${b.tarih.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
