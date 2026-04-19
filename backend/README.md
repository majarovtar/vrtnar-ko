# Soil Humidity Backend API

A Flask-based REST API for receiving and storing soil humidity data from ESP32 sensors.

## Setup

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment (Optional)

Edit `.env` to customize:
```env
HOST=0.0.0.0
PORT=5000
DEBUG=False
```

### 3. Run the Server

```bash
python app.py
```

The server will start on `http://0.0.0.0:5000` (or whatever HOST and PORT you configure).

## API Endpoints

### POST /api/soil-humidity
Receive soil humidity data from ESP32 sensor.

**Request:**
```json
{
  "humidity": 65,
  "timestamp": 1234567890
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Humidity data received successfully",
  "reading_id": 1
}
```

---

### GET /api/soil-humidity
Retrieve paginated soil humidity readings.

**Query Parameters:**
- `limit` - Number of readings (default: 100, max: 1000)
- `offset` - Skip N readings (default: 0)

**Example:** `GET /api/soil-humidity?limit=50&offset=0`

**Response:**
```json
{
  "success": true,
  "total_readings": 150,
  "returned": 50,
  "offset": 0,
  "limit": 50,
  "readings": [
    {
      "id": 1,
      "humidity": 65,
      "device_timestamp": 1234567890,
      "server_timestamp": "2024-04-18T10:30:00.000000",
      "received_at": "2024-04-18T10:30:01.234567"
    },
    ...
  ]
}
```

---

### GET /api/soil-humidity/latest
Get the most recent soil humidity reading.

**Response:**
```json
{
  "success": true,
  "reading": {
    "id": 150,
    "humidity": 72,
    "device_timestamp": 1234567890,
    "server_timestamp": "2024-04-18T10:35:00.000000",
    "received_at": "2024-04-18T10:35:01.234567"
  }
}
```

---

### GET /api/soil-humidity/average
Get average humidity over recent readings.

**Query Parameters:**
- `count` - Number of recent readings to average (default: 10, max: 500)

**Example:** `GET /api/soil-humidity/average?count=20`

**Response:**
```json
{
  "success": true,
  "average_humidity": 68.5,
  "readings_count": 20
}
```

---

### GET /api/health
Health check endpoint.

**Response:**
```json
{
  "status": "OK",
  "service": "Soil Humidity API",
  "total_readings": 150
}
```

## Integration with ESP32

Update your ESP32 code with the correct backend URL:

```cpp
const char* backendUrl = "http://YOUR_LOCAL_IP:5000/api/soil-humidity";
```

Replace `YOUR_LOCAL_IP` with your computer/server IP address.

### Finding Your Local IP

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```bash
ipconfig
```

## Example cURL Requests

```bash
# Send humidity data
curl -X POST http://localhost:5000/api/soil-humidity \
  -H "Content-Type: application/json" \
  -d '{"humidity": 65, "timestamp": 1234567890}'

# Get last 100 readings
curl http://localhost:5000/api/soil-humidity

# Get latest reading
curl http://localhost:5000/api/soil-humidity/latest

# Get average of last 20 readings
curl http://localhost:5000/api/soil-humidity/average?count=20

# Health check
curl http://localhost:5000/api/health
```

## Storage

Currently, all readings are stored in memory. For production use with persistent storage, consider:

- PostgreSQL with SQLAlchemy ORM
- MongoDB with PyMongo
- InfluxDB for time-series data

## Running with Gunicorn (Production)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Troubleshooting

### ESP32 can't connect to backend
- Ensure your firewall allows incoming connections on port 5000
- Check that ESP32 and server are on the same network
- Verify the correct IP address in the ESP32 code

### Data not being received
- Check server logs for errors
- Verify JSON format matches the expected structure
- Ensure WiFi credentials on ESP32 are correct

### Port already in use
```bash
# Change PORT in .env or run:
PORT=5001 python app.py
```
