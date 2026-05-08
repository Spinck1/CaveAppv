from flask import Flask, request, jsonify
from flask_cors import CORS
import pyodbc
import requests
from waitress import serve

app = Flask(__name__)
CORS(app)

HOST = '0.0.0.0'
PORT = 5000

conn_str = (
    "Driver={SQL Server};"
    "Server=127.0.0.1,1433;"
    "Database=ArduinoDB;"
    "Trusted_Connection=yes;"
)


def get_conn():
    return pyodbc.connect(conn_str)


# ── Sensör verisi kaydet (ESP32 tarafından çağrılır) ──────────────────────────
@app.route('/veri_al', methods=['GET'])
def veri_al():
    sicaklik = request.args.get('sicaklik')
    nem = request.args.get('nem')
    isik = request.args.get('isik')
    if not sicaklik or not nem:
        return "Eksik Veri", 400
    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Girdiler (SensorID, Sicaklik, Nem, IsikLux) VALUES (?, ?, ?, ?)",
            (1, sicaklik, nem, isik)
        )
        conn.commit()
        conn.close()
        return "Veri Basariyla Kaydedildi", 200
    except Exception as e:
        print(f"veri_al hatası: {e}")
        return "Veritabani Hatasi", 500


# ── Kayıt ol ──────────────────────────────────────────────────────────────────
@app.route('/register', methods=['POST'])
def register():
    data = request.json or {}
    k_adi = (data.get('kullanici_adi') or '').strip()
    sifre = (data.get('sifre') or '').strip()

    if not k_adi or not sifre:
        return jsonify({"basarili": False, "mesaj": "Kullanıcı adı ve şifre gereklidir!"}), 400

    try:
        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute("SELECT KullaniciID FROM Kullanicilar WHERE KullaniciAdi = ?", (k_adi,))
        if cursor.fetchone():
            conn.close()
            return jsonify({"basarili": False, "mesaj": "Bu kullanıcı adı zaten alınmış!"}), 409

        # Kullanıcıyı ekle
        cursor.execute(
            "INSERT INTO Kullanicilar (KullaniciAdi, Sifre) VALUES (?, ?)",
            (k_adi, sifre)
        )
        conn.commit()

        # Yeni kullanıcının ID'sini al
        cursor.execute("SELECT KullaniciID FROM Kullanicilar WHERE KullaniciAdi = ?", (k_adi,))
        yeni_id = cursor.fetchone()[0]

        # Kullanıcıya otomatik sensör ata
        cursor.execute(
            "INSERT INTO Sensors (SensorName, SensorType, KullaniciID) VALUES (?, ?, ?)",
            ('DHT22', 'Sıcaklık/Nem', yeni_id)
        )
        conn.commit()
        conn.close()

        return jsonify({
            "basarili": True,
            "mesaj": "Kayıt başarıyla tamamlandı!",
            "kullanici_id": yeni_id
        }), 201
    except Exception as e:
        print(f"register hatası: {e}")
        return jsonify({"basarili": False, "mesaj": f"Hata: {str(e)}"}), 500


# ── Giriş yap ─────────────────────────────────────────────────────────────────
@app.route('/login', methods=['POST'])
def login():
    data = request.json or {}
    k_adi = (data.get('kullanici_adi') or '').strip()
    sifre = (data.get('sifre') or '').strip()

    if not k_adi or not sifre:
        return jsonify({"basarili": False, "mesaj": "Kullanıcı adı ve şifre gereklidir!"}), 400

    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT KullaniciID, KullaniciAdi FROM Kullanicilar WHERE KullaniciAdi = ? AND Sifre = ?",
            (k_adi, sifre)
        )
        kullanici = cursor.fetchone()
        conn.close()

        if kullanici:
            return jsonify({
                "basarili": True,
                "kullanici_id": kullanici[0],
                "kullanici_adi": kullanici[1]
            }), 200
        else:
            return jsonify({"basarili": False, "mesaj": "Kullanıcı adı veya şifre hatalı!"}), 401
    except Exception as e:
        print(f"login hatası: {e}")
        return jsonify({"basarili": False, "mesaj": f"Hata: {str(e)}"}), 500


# ── Kullanıcıya ait sensör verilerini getir ───────────────────────────────────
@app.route('/verileri_getir', methods=['GET'])
def verileri_getir():
    kullanici_id = request.args.get('kullanici_id')
    if not kullanici_id:
        return jsonify({"error": "kullanici_id gerekli"}), 400

    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT g.ID, g.SensorID, g.Sicaklik, g.Nem, g.IsikLux, g.RecordedAt
            FROM Girdiler g
            INNER JOIN Sensors s ON g.SensorID = s.SensorID
            WHERE s.KullaniciID = ?
            ORDER BY g.RecordedAt DESC
        """, (kullanici_id,))

        columns = [col[0] for col in cursor.description]
        results = []
        for row in cursor.fetchall():
            row_dict = dict(zip(columns, row))
            if row_dict.get('RecordedAt'):
                row_dict['RecordedAt'] = row_dict['RecordedAt'].strftime("%Y-%m-%d %H:%M:%S")
            results.append(row_dict)

        conn.close()
        return jsonify(results), 200
    except Exception as e:
        print(f"verileri_getir hatası: {e}")
        return jsonify({"error": str(e)}), 500


# ── En son sensör okuması ─────────────────────────────────────────────────────
@app.route('/son_veri', methods=['GET'])
def son_veri():
    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT TOP 1 Sicaklik, Nem, IsikLux, RecordedAt FROM Girdiler ORDER BY RecordedAt DESC"
        )
        row = cursor.fetchone()
        conn.close()
        if row:
            return jsonify({
                "Sicaklik": row[0],
                "Nem": row[1],
                "IsikLux": row[2],
                "RecordedAt": row[3].strftime("%Y-%m-%dT%H:%M:%S") if row[3] else None,
            }), 200
        return jsonify({"error": "Henüz veri yok"}), 404
    except Exception as e:
        print(f"son_veri hatası: {e}")
        return jsonify({"error": str(e)}), 500


# ── Kullanıcıya ait depo bilgisini getir ─────────────────────────────────────
@app.route('/depo_getir', methods=['GET'])
def depo_getir():
    kullanici_id = request.args.get('kullanici_id')
    if not kullanici_id:
        return jsonify({"error": "kullanici_id gerekli"}), 400

    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT DepoID, DepoIsmi, SensorID, Kapasite, Doluluk FROM Depolar WHERE KullaniciID = ?",
            (kullanici_id,)
        )
        columns = [col[0] for col in cursor.description]
        depolar = [dict(zip(columns, row)) for row in cursor.fetchall()]
        conn.close()
        return jsonify(depolar), 200
    except Exception as e:
        print(f"depo_getir hatası: {e}")
        return jsonify({"error": str(e)}), 500


EMISSION_FACTORS = {
    'Hava Kargo': 0.500,
    'Tır (Kara)': 0.100,
    'Demiryolu': 0.030,
    'Deniz Yolu': 0.015,
}
FUEL_FACTORS = {
    'Hava Kargo': 12.0,
    'Tır (Kara)': 0.35,
    'Demiryolu': 0.15,
    'Deniz Yolu': 0.05,
}
VEHICLE_BASE_EMISSIONS = {
    'Hava Kargo': 1.500,
    'Tır (Kara)': 0.250,
    'Demiryolu': 0.100,
    'Deniz Yolu': 0.050,
}


@app.route('/calculate_carbon', methods=['POST'])
def calculate_carbon():
    data = request.json
    start_lat = data.get('start_lat')
    start_lng = data.get('start_lng')
    end_lat = data.get('end_lat')
    end_lng = data.get('end_lng')
    weight = data.get('weight', 20)
    vehicle = data.get('vehicle', 'Tır (Kara)')

    if not all([start_lat, start_lng, end_lat, end_lng]):
        return jsonify({'error': 'Eksik koordinat verisi'}), 400

    try:
        osrm_url = (
            f"https://router.project-osrm.org/route/v1/driving/"
            f"{start_lng},{start_lat};{end_lng},{end_lat}?overview=false"
        )
        response = requests.get(osrm_url, timeout=10)
        route_data = response.json()

        if route_data.get('routes'):
            distance_km = route_data['routes'][0]['distance'] / 1000.0
            factor = EMISSION_FACTORS.get(vehicle, 0.100)
            base_factor = VEHICLE_BASE_EMISSIONS.get(vehicle, 0.200)
            carbon_kg = (distance_km * weight * factor) + (distance_km * base_factor)
            fuel_factor = FUEL_FACTORS.get(vehicle, 0.35)
            fuel_liters = distance_km * fuel_factor
            trees = int(carbon_kg / 20) + 1

            return jsonify({
                'distance_km': round(distance_km, 2),
                'carbon_kg': round(carbon_kg, 2),
                'fuel_liters': round(fuel_liters, 2),
                'trees_needed': trees,
                'vehicle': vehicle,
                'methodology': "[(Mesafe x Ağırlık x Katsayı) + (Mesafe x Baz Emisyon)]",
            })
        else:
            return jsonify({'error': 'Rota bulunamadı'}), 404
    except Exception as e:
        print(f"calculate_carbon hatası: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/geocode', methods=['GET'])
def geocode():
    address = request.args.get('address')
    if not address:
        return jsonify({'error': 'Adres belirtilmedi'}), 400

    try:
        url = f"https://nominatim.openstreetmap.org/search?q={address}&format=json&limit=1"
        response = requests.get(url, headers={'User-Agent': 'CaveApp_API'}, timeout=10)
        data = response.json()

        if data:
            return jsonify({
                'lat': float(data[0]['lat']),
                'lng': float(data[0]['lon']),
                'display_name': data[0]['display_name'],
            })
        return jsonify({'error': 'Konum bulunamadı'}), 404
    except Exception as e:
        print(f"geocode hatası: {e}")
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    print(f"Sunucu {HOST}:{PORT} adresinde başlatıldı...")
    serve(app, host=HOST, port=PORT)
