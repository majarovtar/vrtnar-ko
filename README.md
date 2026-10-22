# Vrtnar.ko 🌱 DragonHack 2026 entry

A Flutter gardening app prototype for tracking your real-life garden, and improving your food self-sufficiency.

Made for beginners at gardening: How do you plant a tomato? When do you water it? What is my friend planting, and can I get a sample?

Plant a digital tomato alongside your physical one - the app will tell you whether to put it in the sun or shade, when to water it, and if it's safe for your pets. 

The repo also includes a physical soil-humidity sensor (ESP32) and a small Flask
backend that collects its readings: The sensor will alarm you when the plant needs watering.

Visit the Marketplace (prototype) to share and receive plant seedlings, visit the City to see your friends' gardens and cheer them on (prototype), or pay your respects to the dead plants you failed to keep alive, in the Graveyard.


https://github.com/user-attachments/assets/16cfa0f6-fffb-4a62-9454-b5dd279d74b5

https://github.com/user-attachments/assets/8d37ef11-00c2-47d8-892a-979c0ce2209e


<img width="1470" height="749" alt="Screenshot 2026-10-22 at 15 13 57" src="https://github.com/user-attachments/assets/b1783994-a6d4-447a-b3eb-9afe850525a5" />

<img width="1461" height="702" alt="Screenshot 2026-10-22 at 16 03 28" src="https://github.com/user-attachments/assets/94348bca-51ae-423d-98a1-8bceaf3bfc8e" />

<img width="1470" height="744" alt="Screenshot 2026-10-22 at 13 52 36" src="https://github.com/user-attachments/assets/8c4bb16e-2196-436e-8885-882fa8899e85" />


## The game

- **Card-based planting** — pick seeds and plant them on a board
  (`lib/game_internals`, `lib/play_session`).
- **Growth over time** — plants progress through `seedling → sprout →
  flowering → mature` stages (`lib/game_internals/plant.dart`), with growth
  speed adjusted by live weather data.
- **Real weather integration** — `lib/api/weather_service.dart` fetches
  temperature, humidity, rainfall, wind and air quality from the
  [Open-Meteo](https://open-meteo.com/) API and derives a growth multiplier
  (extreme heat/cold slows growth, rain helps, etc.).
- **Real plant data** — `lib/api/perenual_service.dart` looks up plant/species
  details (watering needs, sunlight, growth rate, toxicity, pests, ...) from
  the [Perenual](https://perenual.com/) API for custom seeds.
- **Soil humidity alerts** — `lib/api/soil_humidity_service.dart` and
  `lib/play_session/soil_humidity_alert.dart` surface readings from the
  physical sensor (via the backend) so you know when to water.
- **City view** — a small town (`lib/city`) with buildings you can visit:
  your home/balcony, friends' homes, a marketplace, a public garden and a
  cemetery for plants that didn't make it.
- **Calendar** — track planting/watering history across day/week/month views
  (`lib/calendar`).
- **Persistence & settings** — player progress and settings are saved via
  `shared_preferences` (`lib/player_progress`, `lib/settings`).
- **Audio** — background music and sound effects via `audioplayers`
  (`lib/audio`).

## Running the app

```bash
flutter pub get
flutter run -d chrome   # or a connected device/emulator
```

## Soil humidity sensor + backend (optional)

The game can display live soil humidity from a real sensor:

1. **Backend** (`backend/`) — a Flask API that receives readings from the
   ESP32 and serves them to the app.
   ```bash
   cd backend
   pip install -r requirements.txt
   python app.py
   ```
   See `backend/README.md` for the full API reference (endpoints for
   posting readings, fetching the latest/average humidity, health checks).

2. **Sensor firmware** (`soil3/`) — PlatformIO project for an ESP32 with a
   capacitive soil moisture sensor, posting readings to the backend every 2
   minutes. See `soil3/SETUP.md` for wiring, WiFi/backend configuration and
   calibration.

The Flutter app talks to the backend via `lib/api/soil_humidity_service.dart`;
this piece is optional — the game runs fine without a sensor attached.

## Tech stack

- Flutter / Dart, `go_router` for navigation, `provider` for state
- `http` for REST calls to Open-Meteo, Perenual and the soil humidity backend
- `shared_preferences` for local persistence, `audioplayers` for sound
- Backend: Python/Flask + `flask-cors`
- Sensor: ESP32 (PlatformIO/C++)
