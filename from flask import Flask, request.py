from flask import Flask, request, jsonify
from flask_cors import CORS
import pyodbc
from waitress import serve

app = Flask(__name__)
CORS(app)

# Sunucu ayarları
HOST = '0.0.0.0'  # Tüm IP adreslerinden bağlantı kabul et (emülatöre izin ver)
PORT = 5000

conn_str = (
    "Driver={SQL Server};"
    "Server=127.0.0.1,1433;"
    "Database=ArduinoDB;"
    "Trusted_Connection=yes;"
)

def save_to_db(s, n, i):
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Girdiler (SensorID, Sicaklik, Nem, IsikLux) VALUES (?, ?, ?, ?)",
            (1, s, n, i)
        )
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        print(f"Veritabanı hatası: {e}")
        return False

@app.route('/veri_al', methods=['GET'])
def veri_al():
    sicaklik = request.args.get('sicaklik')
    nem = request.args.get('nem')
    isik = request.args.get('isik')
    if sicaklik and nem:
        if save_to_db(sicaklik, nem, isik):
            return "Veri Basariyla Kaydedildi", 200
        else:
            return "Veritabanı Hatasi", 500
    return "Eksik Veri", 400


# --- YENİ EKLENEN KISIM: KAYIT OL (REGISTER) ---
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    k_adi = data.get('kullanici_adi')
    sifre = data.get('sifre')

    if not k_adi or not sifre:
        return jsonify({"basarili": False, "mesaj": "Kullanıcı adı ve şifre gereklidir!"}), 400

    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        
        # Kullanıcı zaten var mı kontrol et
        cursor.execute("SELECT KullaniciID FROM Kullanicilar WHERE KullaniciAdi = ?", (k_adi,))
        if cursor.fetchone():
            conn.close()
            return jsonify({"basarili": False, "mesaj": "Bu kullanıcı adı zaten alınmış!"}), 409
        
        # Yeni kullanıcıyı ekle
        cursor.execute("INSERT INTO Kullanicilar (KullaniciAdi, Sifre) VALUES (?, ?)", (k_adi, sifre))
        conn.commit()
        conn.close()

        return jsonify({"basarili": True, "mesaj": "Kayıt başarıyla tamamlandı!"}), 201
    except Exception as e:
        print(f"Kayıt hatası: {e}")
        return jsonify({"basarili": False, "mesaj": f"Hata: {str(e)}"}), 500


# --- YENİ EKLENEN KISIM: GİRİŞ YAP (LOGIN) ---
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    k_adi = data.get('kullanici_adi')
    sifre = data.get('sifre')

    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        
        # Kullanıcı veritabanında var mı kontrol et
        cursor.execute("SELECT KullaniciID FROM Kullanicilar WHERE KullaniciAdi = ? AND Sifre = ?", (k_adi, sifre))
        kullanici = cursor.fetchone()
        conn.close()

        if kullanici:
            # Başarılıysa KullaniciID'yi geri döndür
            return jsonify({"basarili": True, "kullanici_id": kullanici[0]}), 200
        else:
            return jsonify({"basarili": False, "mesaj": "Kullanıcı adı veya şifre hatalı!"}), 401
    except Exception as e:
        print(f"Login hatası: {e}")
        return jsonify({"basarili": False, "mesaj": f"Hata: {str(e)}"}), 500


# --- GÜNCELLENEN KISIM: SADECE KULLANICIYA AİT VERİLERİ GETİR ---
@app.route('/verileri_getir', methods=['GET'])
def verileri_getir():
    # Flutter'dan Kullanici ID'sini parametre olarak bekliyoruz
    kullanici_id = request.args.get('kullanici_id')
    
    if not kullanici_id:
        return jsonify({"error": "Kullanici ID gerekli"}), 400

    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        
        # INNER JOIN: Girdiler ve Sensors tablolarını birleştirerek 
        # sadece bu kullanıcıya tanımlı sensörün verilerini çekiyoruz
        sql_sorgusu = """
            SELECT g.ID, g.SensorID, g.Sicaklik, g.Nem, g.IsikLux, g.RecordedAt 
            FROM Girdiler g
            INNER JOIN Sensors s ON g.SensorID = s.SensorID
            WHERE s.KullaniciID = ?
            ORDER BY g.RecordedAt DESC
        """
        
        cursor.execute(sql_sorgusu, (kullanici_id,))
        
        columns = [column[0] for column in cursor.description]
        results = []
        for row in cursor.fetchall():
            # DateTime objesini JSON ile gönderilebilmesi için stringe çeviriyoruz
            row_dict = dict(zip(columns, row))
            if 'RecordedAt' in row_dict and row_dict['RecordedAt'] is not None:
                row_dict['RecordedAt'] = row_dict['RecordedAt'].strftime("%Y-%m-%d %H:%M:%S")
            results.append(row_dict)
            
        conn.close()
        return jsonify(results), 200
    except Exception as e:
        print(f"Veritabanı okuma hatası: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/son_veri', methods=['GET'])
def son_veri():
    """En son sensör okumasını döndür (tüm depolar için)."""
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute(
            "SELECT TOP 1 Sicaklik, Nem, IsikLux FROM Girdiler ORDER BY RecordedAt DESC"
        )
        row = cursor.fetchone()
        conn.close()
        if row:
            return jsonify({"Sicaklik": row[0], "Nem": row[1], "IsikLux": row[2]}), 200
        return jsonify({"error": "Henuz veri yok"}), 404
    except Exception as e:
        print(f"son_veri hatası: {e}")
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    print(f"Sunucu {HOST}:{PORT} adresinde baslatildi...")
    print(f"Flutter uygulaması http://{HOST}:{PORT} adresine bağlanmalı")
    serve(app, host=HOST, port=PORT)