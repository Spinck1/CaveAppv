import 'package:flutter/material.dart';
import '../models/depo.dart';
import '../theme/app_theme.dart';

class DepoDuzenleEkrani extends StatefulWidget {
  final List<Depo> depolar;
  final Function(List<Depo>) onKaydet;

  const DepoDuzenleEkrani({
    super.key,
    required this.depolar,
    required this.onKaydet,
  });

  @override
  State<DepoDuzenleEkrani> createState() => _DepoDuzenleEkraniState();
}

class _DepoDuzenleEkraniState extends State<DepoDuzenleEkrani> {
  late List<Depo> _depolar;

  @override
  void initState() {
    super.initState();
    _depolar = List.from(widget.depolar);
  }

  void _depoEkle() {
    showDialog(
      context: context,
      builder: (context) {
        final adController = TextEditingController();
        final konumController = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Yeni Depo Ekle',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Depo Adı',
                  prefixIcon: Icon(
                    Icons.warehouse_rounded,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: konumController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Konum',
                  prefixIcon: Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (adController.text.isNotEmpty) {
                  setState(() {
                    final yeniDepo = Depo(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      ad: adController.text,
                      konum: konumController.text,
                    );
                    yeniDepo.rastgeleVeriUret();
                    _depolar.add(yeniDepo);
                  });
                  widget.onKaydet(_depolar);
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _depoGuncelle(int index) {
    final depo = _depolar[index];
    final adController = TextEditingController(text: depo.ad);
    final konumController = TextEditingController(text: depo.konum);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Depo Düzenle',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Depo Adı',
                  prefixIcon: Icon(
                    Icons.warehouse_rounded,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: konumController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Konum',
                  prefixIcon: Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (adController.text.isNotEmpty) {
                  setState(() {
                    _depolar[index] = depo.copyWith(
                      ad: adController.text,
                      konum: konumController.text,
                    );
                  });
                  widget.onKaydet(_depolar);
                  Navigator.pop(context);
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  void _depoSil(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Depoyu Sil',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${_depolar[index].ad}" deposunu silmek istediğinizden emin misiniz?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () {
              setState(() {
                _depolar.removeAt(index);
              });
              widget.onKaydet(_depolar);
              Navigator.pop(context);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Üst bar
              Padding(
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
                    const Text(
                      'Depo Düzenleme',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Depo listesi
              Expanded(
                child: _depolar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warehouse_outlined,
                              size: 64,
                              color: AppTheme.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz depo eklenmedi',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni depo eklemek için + butonuna dokunun',
                              style: TextStyle(
                                color: AppTheme.textMuted.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _depolar.length,
                        itemBuilder: (context, index) {
                          final depo = _depolar[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryLight.withValues(
                                  alpha: 0.15,
                                ),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.warehouse_rounded,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                              title: Text(
                                depo.ad,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                depo.konum.isEmpty
                                    ? 'Konum belirtilmedi'
                                    : depo.konum,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      color: AppTheme.accentColor,
                                      size: 22,
                                    ),
                                    onPressed: () => _depoGuncelle(index),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_rounded,
                                      color: Colors.red.shade400,
                                      size: 22,
                                    ),
                                    onPressed: () => _depoSil(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _depoEkle,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Yeni Depo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
