#include <WiFi.h>              // ESP8266WiFi.h yerine WiFi.h
#include <HTTPClient.h>        // ESP8266HTTPClient.h yerine HTTPClient.h
#include <DHT.h>

// --- AYARLAR ---
const char* ssid = "baris";
const char* password = "bd560954";

// Sunucu IP adresi (Python/Flask sunucun)
const String serverIP = "http://192.168.146.179:5000"; 

// --- PİN TANIMLARI (Senin devreye göre güncellendi) ---
#define DHTPIN 4       // DHT11 S ucu D4'te
#define DHTTYPE DHT11 
#define LDRPIN 34      // LDR ve Direnç birleşimi D34'te (Analog Pin)

const int ledKirmizi = 13; // D13
const int ledSari = 12;    // D12
const int ledYesil = 33;   // D33 (Söndürdüğümüz yeni yer)

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  
  pinMode(ledYesil, OUTPUT);
  pinMode(ledSari, OUTPUT);
  pinMode(ledKirmizi, OUTPUT);
  
  dht.begin();
  
  // WiFi Başlatma
  WiFi.begin(ssid, password);
  Serial.println("\n--- ESP32 SISTEM BASLATILDI ---");
  Serial.print("WiFi Baglaniyor...");
}

void loop() {
  // 1. VERİLERİ OKU
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  int isik = analogRead(LDRPIN); // ESP32'de 0-4095 arası döner

  // 2. SERİ MONİTÖR TAKİBİ
  Serial.println("---------------------------------");
  Serial.print("SICAKLIK : "); Serial.print(t); Serial.println(" *C");
  Serial.print("NEM      : "); Serial.print(h); Serial.println(" %");
  Serial.print("ISIK SEV.: "); Serial.println(isik);
  
  // 3. BAĞLANTI VE GÖNDERİM
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(ledYesil, LOW);
    digitalWrite(ledSari, HIGH); // WiFi yoksa Sarı yanar
    Serial.println(">>> WiFi Bekleniyor...");
    delay(1000);
  } 
  else {
    digitalWrite(ledSari, LOW);
    digitalWrite(ledYesil, HIGH); // WiFi varsa Yeşil yanar
    
    if (!isnan(h) && !isnan(t)) {
      HTTPClient http;
      WiFiClient client;
      
      // Tam URL oluşturma (Sorgu parametreleri ile)
      String url = serverIP + "/veri_al?sicaklik=" + String(t) + "&nem=" + String(h) + "&isik=" + String(isik);
      
      Serial.println(">>> Gonderiliyor: " + url);
      
      http.begin(client, url);
      int httpResponseCode = http.GET(); // GET isteği atar
      
      if (httpResponseCode > 0) {
        Serial.print(">>> BASARILI! Sunucu Yaniti: "); Serial.println(httpResponseCode);
        digitalWrite(ledKirmizi, LOW);
        
        // Başarı onayı: Yeşil LED hızlıca yanıp söner
        digitalWrite(ledYesil, LOW); delay(100); digitalWrite(ledYesil, HIGH);
      } else {
        Serial.print(">>> BAGLANTI HATASI: "); Serial.println(httpResponseCode);
        digitalWrite(ledKirmizi, HIGH); // Sunucuya ulaşamazsa Kırmızı yanar
      }
      http.end();
    } else {
      Serial.println(">>> SENSOR HATASI: Veri okunamadi!");
      digitalWrite(ledKirmizi, HIGH);
    }
    delay(5000); // 5 saniyede bir veri gönder
  }
}