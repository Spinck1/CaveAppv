from flask import Flask, request, jsonify
import requests
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Flutter Web/Mobile erişimi için CORS izni

# Emisyon Katsayıları (Hackathon Gereksinimleri)
EMISSION_FACTORS = {
    'Hava Kargo': 0.500,
    'Tır (Kara)': 0.100,
    'Demiryolu': 0.030,
    'Deniz Yolu': 0.015
}

# Yakıt Katsayıları (L/km)
FUEL_FACTORS = {
    'Hava Kargo': 12.0,
    'Tır (Kara)': 0.35,
    'Demiryolu': 0.15,
    'Deniz Yolu': 0.05
}

# Araç Baz Emisyonları (Boş ağırlık kg CO2/km)
VEHICLE_BASE_EMISSIONS = {
    'Hava Kargo': 1.500,
    'Tır (Kara)': 0.250,
    'Demiryolu': 0.100,
    'Deniz Yolu': 0.050
}

@app.route('/calculate_carbon', methods=['POST'])
def calculate_carbon():
    """
    Dinamik Karbon Ayak İzi Hesaplama API'si
    """
    data = request.json
    start_lat = data.get('start_lat')
    start_lng = data.get('start_lng')
    end_lat = data.get('end_lat')
    end_lng = data.get('end_lng')
    weight = data.get('weight', 20)  # Ton
    vehicle = data.get('vehicle', 'Tır (Kara)')

    if not all([start_lat, start_lng, end_lat, end_lng]):
        return jsonify({'error': 'Eksik koordinat verisi'}), 400

    try:
        # 1. OSRM üzerinden dinamik mesafe hesaplama
        osrm_url = f"https://router.project-osrm.org/route/v1/driving/{start_lng},{start_lat};{end_lng},{end_lat}?overview=false"
        response = requests.get(osrm_url)
        route_data = response.json()

        if route_data.get('routes'):
            distance_km = route_data['routes'][0]['distance'] / 1000.0
            
            # 2. Karbon Ayak İzi Hesaplama
            # (Mesafe * Ağırlık * Katsayı) + (Mesafe * Araç_Baz_Emisyonu)
            factor = EMISSION_FACTORS.get(vehicle, 0.100)
            base_factor = VEHICLE_BASE_EMISSIONS.get(vehicle, 0.200)
            carbon_kg = (distance_km * weight * factor) + (distance_km * base_factor)
            
            # 3. Yakıt Tüketimi
            fuel_factor = FUEL_FACTORS.get(vehicle, 0.35)
            fuel_liters = distance_km * fuel_factor
            
            # 4. Ağaç Sayısı (1 ağaç = 20kg CO2/yıl)
            trees = int(carbon_kg / 20) + 1

            return jsonify({
                'distance_km': round(distance_km, 2),
                'carbon_kg': round(carbon_kg, 2),
                'fuel_liters': round(fuel_liters, 2),
                'trees_needed': trees,
                'vehicle': vehicle,
                'methodology': "[(Mesafe x Ağırlık x Katsayı) + (Mesafe x Baz Emisyon)]"
            })
        else:
            return jsonify({'error': 'Rota bulunamadı'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/geocode', methods=['GET'])
def geocode():
    """
    Adresten koordinat bulma (Nominatim)
    """
    address = request.args.get('address')
    if not address:
        return jsonify({'error': 'Adres belirtilmedi'}), 400
    
    try:
        url = f"https://nominatim.openstreetmap.org/search?q={address}&format=json&limit=1"
        headers = {'User-Agent': 'CaveApp_API'}
        response = requests.get(url, headers=headers)
        data = response.json()
        
        if data:
            return jsonify({
                'lat': float(data[0]['lat']),
                'lng': float(data[0]['lon']),
                'display_name': data[0]['display_name']
            })
        return jsonify({'error': 'Konum bulunamadı'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("CaveApp Karbon Ayak İzi API'si 5001 portunda çalışıyor...")
    app.run(port=5001, debug=True)
