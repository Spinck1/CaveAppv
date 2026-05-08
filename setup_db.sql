-- ============================================================
-- CaveApp - ArduinoDB Veritabanı İçin SQL Script
-- ============================================================
-- Bu script test verilerini ve tabloları kontrol eder
-- ============================================================

USE ArduinoDB;
GO

-- Mevcut test kullanıcılarını kontrol et ve ekle
IF NOT EXISTS (SELECT 1 FROM Kullanicilar WHERE KullaniciAdi = 'admin')
BEGIN
    PRINT 'admin kullanıcısı eklenmiyor...';
    INSERT INTO Kullanicilar (KullaniciAdi, Sifre) VALUES ('admin', '123456');
    PRINT 'OK: admin kullanıcısı eklendi';
END
ELSE
BEGIN
    PRINT 'admin kullanıcısı zaten var - şifre kontrol ediliyor...';
    UPDATE Kullanicilar SET Sifre = '123456' WHERE KullaniciAdi = 'admin';
    PRINT 'OK: admin şifresi 123456 olarak ayarlandı';
END;

GO

-- Mevcut test deposu ekle
DECLARE @AdminUserID INT;
SELECT @AdminUserID = KullaniciID FROM Kullanicilar WHERE KullaniciAdi = 'admin';

IF NOT EXISTS (SELECT 1 FROM Depolar WHERE KullaniciID = @AdminUserID AND DepoIsmi = 'Test Depo')
BEGIN
    PRINT 'Test Depo ekleniyor...';
    INSERT INTO Depolar (KullaniciID, SensorID, DepoIsmi, Kapasite, Doluluk)
    VALUES (@AdminUserID, 1, 'Test Depo', 10000, 5000);
    PRINT 'OK: Test Depo eklendi';
END
ELSE
BEGIN
    PRINT 'Test Depo zaten var';
END;

GO

-- Veritabanı tabloları ve verileri kontrol et
PRINT '';
PRINT '=========================================';
PRINT 'Veritabanı Durumu:';
PRINT '=========================================';

SELECT 
    'Kullanicilar' as [Tablo],
    COUNT(*) as [Kayıt Sayısı]
FROM Kullanicilar

UNION ALL

SELECT 
    'Depolar' as [Tablo],
    COUNT(*) as [Kayıt Sayısı]
FROM Depolar

UNION ALL

SELECT 
    'Girdiler' as [Tablo],
    COUNT(*) as [Kayıt Sayısı]
FROM Girdiler;

GO

PRINT '';
PRINT 'Kullanıcılar:';
SELECT KullaniciID, KullaniciAdi, Sifre FROM Kullanicilar;

GO

PRINT '';
PRINT 'Depolar:';
SELECT DepoID, KullaniciID, SensorID, DepoIsmi, Kapasite, Doluluk FROM Depolar;

GO

PRINT '';
PRINT '✅ Script Tamamlandı!';
