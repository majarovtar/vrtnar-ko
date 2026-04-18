# Soil Humidity Sensor Setup

## Hardware Requirements
- ESP32 board (LOLIN C3 Mini configured in platformio.ini)
- Capacitive soil moisture sensor
- USB cable for programming

## Wiring
Connect the soil moisture sensor to the ESP32:
- **VCC** → 3.3V
- **GND** → GND
- **AO (Analog Output)** → GPIO 34 (ADC pin)

## Configuration

Before uploading, update the following constants in `src/main.cpp`:

### WiFi Credentials
```cpp
const char* ssid = "YOUR_SSID";
const char* password = "YOUR_PASSWORD";
```

### Backend Configuration
```cpp
const char* backendUrl = "http://YOUR_BACKEND_IP:PORT/api/soil-humidity";
```

Replace:
- `YOUR_BACKEND_IP` with your backend server IP address
- `PORT` with the port number (typically 8000, 8080, 3000, etc.)

### Sensor Calibration (Optional)
The code maps sensor values to 0-100% humidity. If needed, adjust:
```cpp
const int DRY = 4095;    // Value when soil is dry
const int WET = 0;       // Value when soil is wet
```

To calibrate:
1. Read the raw ADC value when soil is completely dry
2. Read the raw ADC value when soil is completely wet
3. Update DRY and WET constants accordingly

## Building and Uploading

Using PlatformIO CLI:
```bash
cd soil3
platformio run --target upload
```

Or use PlatformIO IDE in VS Code.

## Operation

Once uploaded, the device will:
1. Connect to WiFi on startup
2. Read soil moisture every 2 minutes
3. Send readings to the backend as JSON:
```json
{
  "humidity": 65,
  "timestamp": 1234567890
}
```

Monitor the serial output at 115200 baud to see debug messages.

## Expected API Response

Your backend should accept POST requests at `/api/soil-humidity` and return HTTP 200 or 201 on success.

Example response:
```json
{
  "success": true,
  "message": "Humidity data received"
}
```
