## Weather API Integration - How It Works

### 🌤️ Files Created/Modified

1. **[weather_service.dart](lib/api/weather_service.dart)** - Weather API service
2. **[plant.dart](lib/game_internals/plant.dart)** - Updated with weather integration
3. **[weather_info_widget.dart](lib/shared/weather_info_widget.dart)** - UI widget to display weather

---

## 📡 How the Weather API Works

### APIs Used:

#### 🌤️ **Open-Meteo** (Weather Data - Free, No API Key!)
- **Base URL**: `https://api.open-meteo.com/v1/forecast`
- **Data Retrieved**:
  - Temperature (°C)
  - Humidity (%)
  - Rainfall (mm)
  - Wind speed (km/h)
  - Weather code (WMO standard)

#### 🌫️ **WAQI (World Air Quality Index)** (Air Quality Data - Free Demo Access!)
- **Base URL**: `https://api.waqi.info/feed/ljubljana/?token=demo`
- **Data Retrieved**:
  - Air Quality Index (AQI)
  - PM2.5 concentration (µg/m³)
- **Why Ljubljana?**: Uses city name for air quality stations in Slovenia

### Example API Calls:
```dart
// Get weather for Ljubljana (default location)
final weather = await WeatherService().getDefaultLocationWeather();

// Get weather for any location
final weather = await WeatherService().getWeather(
  latitude: 46.0569,  // Ljubljana coordinates
  longitude: 14.5058,
);
```

### Data Processing:
- **Time Matching**: Hourly data is matched to current weather time by finding the closest hour
- **Air Quality**: Combined from WAQI API with emoji indicators  
- **Humidity**: Now correctly displays real values (was showing 0% due to time matching bug)

---

## 🌱 How Weather Affects Plant Growth

### 1. **Growth Multiplier** (Key Mechanic)
The `growthMultiplier` adjusts how fast plants grow based on conditions:

```
Base growth speed × Weather multiplier = Actual growth speed
```

**How it's calculated:**
- **Temperature impact**: Optimal 15-25°C
  - Below 5°C or above 35°C → 50% speed
  - Below 10°C or above 30°C → 80% speed
  
- **Humidity impact**: Optimal 40-70%
  - Too dry (<30%) or too wet (>85%) → 70% speed
  
- **Wind impact**: High winds stress plants
  - Wind > 30 km/h → 60% speed
  
- **Rainfall impact**: Heavy rain damages plants
  - Rain > 50mm → 80% speed

**Example**: 
- Perfect weather → 100% growth speed (plants grow normally)
- Hot, dry, windy day → ~34% growth speed (plants grow much slower)

### 2. **Watering Needs** (Game Mechanic)
Dynamic watering recommendations based on weather:

```
Base need (0.5) + temperature impact + humidity impact - rain - wind impact
```

**Scale**: 0.0 to 1.0
- 💧 < 0.2: No watering needed (it rained)
- 💧💧 0.4-0.6: Moderate watering
- 💧💧💧💧 > 0.8: Heavy watering (very hot/dry)

---

## 💻 Using the Weather System in Your Code

### Get Current Weather
```dart
final weather = await WeatherService().getDefaultLocationWeather();
if (weather != null) {
  print('Temperature: ${weather.temperature}°C');
  print('Is it raining? ${weather.isRaining}');
  print('Growth multiplier: ${weather.growthMultiplier}');
}
```

### Get Growth Stage Adjusted by Weather
```dart
// Async version that considers weather
final adjustedStage = await plant.getWeatherAdjustedGrowthStage();

// Compare with normal stage
final normalStage = plant.growthStage;
```

### Get Watering Recommendation
```dart
final recommendation = await plant.getWateringRecommendation();
// Returns: "💧💧 Moderate watering\nWeatherData(...)"
```

### Display in UI
```dart
WeatherInfoWidget()  // Shows full weather details and impact on plants
```

---

## 🎮 Gameplay Integration Ideas

1. **Weather-based challenges**
   - "Grow a plant during a drought"
   - "Keep plants healthy during a storm"

2. **Dynamic watering strategy**
   - Players must water MORE on hot days
   - Rain days are "free" watering days

3. **Plant selection**
   - Different plants prefer different weather
   - Use Perenual API data + weather to recommend plants

4. **City building impact**
   - Green zones thrive during rain
   - Wither during drought

5. **Real-world connection**
   - Use device location for actual local weather
   - Makes game feel connected to real world

---

## 🔄 Caching System

Weather data is cached for **5 minutes** to:
- Reduce API calls (avoid hitting rate limits)
- Save battery/data
- Keep consistent weather across gameplay

```dart
// Same weather returned within 5 minutes
await WeatherService().getWeather(...);  // API call
await WeatherService().getWeather(...);  // Cached response
```

---

## 📊 Weather Code Reference (WMO Standard)

- **0-1**: Clear/Mainly clear
- **2-3**: Partly cloudy/Overcast
- **51-67**: Drizzle/Rain
- **71-86**: Snow
- **80-82**: Rain showers
- **85-86**: Snow showers

The app categorizes these into:
- `isRaining` (codes 51-67)
- `isVeryHot` (temp > 30°C)
- `isFreezing` (temp < 0°C)

---

## 🌫️ Air Quality Index (AQI) Reference

Air quality data comes from **WAQI (World Air Quality Index)** using the AQI standard:

### AQI Levels & Meanings:
- **😊 Good (0-50)**: Air quality is satisfactory, little to no risk
- **😐 Moderate (51-100)**: Acceptable air quality, moderate health concern for sensitive individuals
- **😷 Bad (101+)**: Unhealthy air quality, health risk for everyone

### Display Format:
- Shows only emoji + AQI number (e.g., "😐 80") 
- Uses Noto Color Emoji font for proper emoji rendering

## 🚀 Next Steps

To see it in action:
1. Add `WeatherInfoWidget()` to your UI
2. Or use `plant.getWateringRecommendation()` in plant displays
3. Modify default location (currently Paris) to use device location
4. Integrate with real game mechanics to affect gameplay

