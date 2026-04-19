#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "secrets.h"

// WiFi credentials from secrets.h
const char* ssid = WIFI_SSID;
const char* password = WIFI_PASSWORD;

// Backend configuration from secrets.h
const String backendUrl = String("http://") + BACKEND_IP + ":" + BACKEND_PORT + "/api/soil-humidity";rduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "FRIevent";
const char* password = "1program3R";

// Backend configuration
const char* backendUrl = "http://10.32.242.156:5000/api/soil-humidity";

// Sensor configuration
const int SOIL_SENSOR_PIN = 4;  // ADC pin for soil moisture sensor (GPIO4 on LOLIN C3 Mini)
const unsigned long READ_INTERVAL = 30 * 1000;  // 30 seconds in milliseconds
unsigned long lastReadTime = 0;

// Function declarations
void connectToWiFi();
void readAndSendSoilHumidity();
int readSoilMoisture();
bool sendHumidityData(int humidity);

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\nStarting Soil Humidity Sensor...");
  
  // Configure the ADC pin
  pinMode(SOIL_SENSOR_PIN, INPUT);
  
  // Connect to WiFi
  connectToWiFi();
}

void loop() {
  // Check if it's time to read and send data
  unsigned long currentTime = millis();
  if (currentTime - lastReadTime >= READ_INTERVAL) {
    lastReadTime = currentTime;
    readAndSendSoilHumidity();
  }
  
  delay(1000);  // Small delay to prevent watchdog issues
}

void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  Serial.print("Password length: ");
  Serial.println(strlen(password));
  
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();  // Clear any previous connection
  delay(100);
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 60) {
    delay(500);
    Serial.print(".");
    attempts++;
    
    // Print status every 10 attempts
    if (attempts % 10 == 0) {
      Serial.print(" (");
      Serial.print(WiFi.status());
      Serial.print(") ");
    }
  }
  
  Serial.println();
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("WiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("Failed to connect to WiFi");
    Serial.print("Final WiFi status: ");
    Serial.println(WiFi.status());
    Serial.println("Status codes: 0=IDLE, 1=CONNECTING, 2=CONNECTED, 3=FAIL, 4=LOST, 6=DISCONNECTED");
  }
}

void readAndSendSoilHumidity() {
  Serial.println("\n--- Reading soil humidity ---");
  
  int humidity = readSoilMoisture();
  Serial.print("Soil moisture level: ");
  Serial.println(humidity);
  
  if (WiFi.status() == WL_CONNECTED) {
    if (sendHumidityData(humidity)) {
      Serial.println("Data sent successfully!");
    } else {
      Serial.println("Failed to send data");
    }
  } else {
    Serial.println("WiFi not connected, retrying...");
    connectToWiFi();
  }
}

int readSoilMoisture() {
  // Read analog value from sensor
  int rawValue = analogRead(SOIL_SENSOR_PIN);
  
  // Convert to percentage (0-100)
  // Adjust these values based on your sensor's dry and wet readings
  const int DRY = 4095;    // Value when soil is dry
  const int WET = 0;       // Value when soil is wet
  
  int humidity = map(rawValue, DRY, WET, 0, 100);
  humidity = constrain(humidity, 0, 100);
  
  Serial.print("Raw ADC value: ");
  Serial.println(rawValue);
  
  return humidity;
}

bool sendHumidityData(int humidity) {
  HTTPClient http;
  
  // Create JSON payload
  JsonDocument doc;
  doc["humidity"] = humidity;
  doc["timestamp"] = millis() / 1000;  // Seconds since boot
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  Serial.print("Sending JSON: ");
  Serial.println(jsonString);
  
  http.begin(backendUrl);
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.POST(jsonString);
  
  Serial.print("HTTP Response code: ");
  Serial.println(httpResponseCode);
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.print("Response: ");
    Serial.println(response);
  }
  
  http.end();
  
  return (httpResponseCode == 200 || httpResponseCode == 201);
}