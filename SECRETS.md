# Secrets Management

This project uses secrets files to store sensitive information like WiFi credentials and API keys.

## Files

### ESP32 Secrets (`soil3/include/secrets.h`)
Contains WiFi credentials and backend configuration for the soil sensor.

```cpp
#define WIFI_SSID "YourSSID"
#define WIFI_PASSWORD "YourPassword"
#define BACKEND_IP "192.168.1.100"
#define BACKEND_PORT 5000
```

**⚠️ IMPORTANT:** Update these values before uploading to your ESP32.

### Backend Secrets (`backend/.secrets`)
Contains backend server configuration.

```env
HOST=0.0.0.0
PORT=5000
DEBUG=False
```

## Setup Instructions

### 1. ESP32 WiFi Credentials
Edit `soil3/include/secrets.h`:
```cpp
#define WIFI_SSID "YourNetworkName"
#define WIFI_PASSWORD "YourPassword"
```

If connecting to a passwordless network:
```cpp
#define WIFI_PASSWORD ""
```

### 2. Backend IP
Update the backend IP in `soil3/include/secrets.h`:
```cpp
#define BACKEND_IP "10.32.242.156"  // Your computer's IP
```

### 3. Backend Configuration
Edit `backend/.secrets` if needed (optional - defaults work fine):
```env
PORT=5000  # Change if port is already in use
DEBUG=False  # Set to True for development
```

## Security

⚠️ **NEVER commit these files to git!**

Both `.secrets` files are in `.gitignore` to prevent accidentally uploading sensitive credentials.

### Checking git ignore is working:
```bash
git status
```

Should NOT show:
- `soil3/include/secrets.h`
- `backend/.secrets`
- `backend/soil_readings.json`

## Troubleshooting

### ESP32 not connecting to WiFi
1. Verify SSID and password in `soil3/include/secrets.h`
2. Check that the WiFi network is in range
3. Try connecting another device to verify network works
4. Monitor serial output: `platformio device monitor --baud 115200`

### Backend not reachable
1. Verify `BACKEND_IP` is correct (run `ifconfig | grep "inet "`)
2. Ensure backend is running: `python app.py`
3. Check firewall isn't blocking port 5000

### Connection drops
- Increase WiFi connection timeout in `connectToWiFi()` function
- Check WiFi signal strength
- Reduce READ_INTERVAL if needed
