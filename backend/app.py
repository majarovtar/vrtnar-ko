import os
import json
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# Data storage
DATA_FILE = os.path.join(os.path.dirname(__file__), 'soil_readings.json')
soil_readings = []

def load_readings():
    """Load readings from JSON file."""
    global soil_readings
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, 'r') as f:
                soil_readings = json.load(f)
            print(f"Loaded {len(soil_readings)} readings from disk")
        except Exception as e:
            print(f"Error loading readings: {e}")
            soil_readings = []
    else:
        soil_readings = []

def save_readings():
    """Save readings to JSON file."""
    try:
        with open(DATA_FILE, 'w') as f:
            json.dump(soil_readings, f, indent=2)
    except Exception as e:
        print(f"Error saving readings: {e}")

# Load existing readings on startup
load_readings()

@app.route('/api/soil-humidity', methods=['POST'])
def receive_soil_humidity():
    """
    Receive soil humidity data from ESP32 sensor.
    
    Expected JSON payload:
    {
        "humidity": 65,
        "timestamp": 1234567890
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "success": False,
                "message": "No JSON data provided"
            }), 400
        
        # Validate required fields
        if 'humidity' not in data:
            return jsonify({
                "success": False,
                "message": "Missing 'humidity' field"
            }), 400
        
        # Extract data
        humidity = data.get('humidity')
        device_timestamp = data.get('timestamp')
        
        # Validate humidity value
        if not isinstance(humidity, (int, float)) or humidity < 0 or humidity > 100:
            return jsonify({
                "success": False,
                "message": "Humidity must be a number between 0 and 100"
            }), 400
        
        # Create reading record
        reading = {
            "id": len(soil_readings) + 1,
            "humidity": humidity,
            "device_timestamp": device_timestamp,
            "server_timestamp": datetime.utcnow().isoformat(),
            "received_at": datetime.now().isoformat()
        }
        
        # Store reading
        soil_readings.append(reading)
        
        # Save to disk
        save_readings()
        
        # Log the reading
        print(f"[{reading['received_at']}] Soil humidity received: {humidity}% (Total: {len(soil_readings)})")
        
        return jsonify({
            "success": True,
            "message": "Humidity data received successfully",
            "reading_id": reading['id']
        }), 201
    
    except Exception as e:
        print(f"Error processing soil humidity: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Error processing request: {str(e)}"
        }), 500


@app.route('/api/soil-humidity', methods=['GET'])
def get_soil_humidity():
    """
    Retrieve stored soil humidity readings.
    
    Query parameters:
    - limit: Number of readings to return (default: 100, max: 1000)
    - offset: Number of readings to skip (default: 0)
    """
    try:
        limit = request.args.get('limit', default=100, type=int)
        offset = request.args.get('offset', default=0, type=int)
        
        # Validate parameters
        limit = min(max(limit, 1), 1000)
        offset = max(offset, 0)
        
        # Get readings
        paginated_readings = soil_readings[offset:offset + limit]
        
        return jsonify({
            "success": True,
            "total_readings": len(soil_readings),
            "returned": len(paginated_readings),
            "offset": offset,
            "limit": limit,
            "readings": paginated_readings
        }), 200
    
    except Exception as e:
        print(f"Error retrieving soil humidity: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Error retrieving readings: {str(e)}"
        }), 500


@app.route('/api/soil-humidity/latest', methods=['GET'])
def get_latest_reading():
    """Get the most recent soil humidity reading."""
    try:
        if not soil_readings:
            return jsonify({
                "success": True,
                "message": "No readings available yet",
                "reading": None
            }), 200
        
        latest = soil_readings[-1]
        
        return jsonify({
            "success": True,
            "reading": latest
        }), 200
    
    except Exception as e:
        print(f"Error retrieving latest reading: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Error retrieving reading: {str(e)}"
        }), 500


@app.route('/api/soil-humidity/average', methods=['GET'])
def get_average_humidity():
    """
    Get average humidity over a time period.
    
    Query parameters:
    - count: Number of recent readings to average (default: 10, max: 500)
    """
    try:
        count = request.args.get('count', default=10, type=int)
        count = min(max(count, 1), 500)
        
        if not soil_readings:
            return jsonify({
                "success": True,
                "message": "No readings available yet",
                "average": None
            }), 200
        
        recent_readings = soil_readings[-count:]
        average = sum(r['humidity'] for r in recent_readings) / len(recent_readings)
        
        return jsonify({
            "success": True,
            "average_humidity": round(average, 2),
            "readings_count": len(recent_readings)
        }), 200
    
    except Exception as e:
        print(f"Error calculating average: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Error calculating average: {str(e)}"
        }), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        "status": "OK",
        "service": "Soil Humidity API",
        "total_readings": len(soil_readings)
    }), 200


@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "success": False,
        "message": "Endpoint not found"
    }), 404


@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({
        "success": False,
        "message": "Method not allowed"
    }), 405


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'
    host = os.getenv('HOST', '0.0.0.0')
    
    print(f"Starting Soil Humidity API on {host}:{port}")
    app.run(host=host, port=port, debug=debug)
