import time
import logging
from datetime import datetime
from flask import Flask, jsonify, request, g

app = Flask(__name__)

# Configure logging for CloudWatch (stdout)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)


@app.before_request
def start_timer():
    """Record request start time for latency calculation."""
    g.start_time = time.time()


@app.after_request
def log_request(response):
    """Log every request with method, path, status, and latency."""
    latency_ms = (time.time() - g.start_time) * 1000
    logger.info(
        f"{request.method} {request.path} - {response.status_code} - {latency_ms:.1f}ms"
    )
    return response


@app.route('/')
def hello():
    """Main endpoint."""
    return jsonify({
        "message": "Hello from ECS Fargate!",
        "service": "proj2-app"
    })


@app.route('/health')
def health():
    """Health check endpoint for ALB."""
    return jsonify({
        "status": "ok",
        "timestamp": datetime.utcnow().isoformat()
    })


if __name__ == '__main__':
    logger.info('Starting Flask application on port 8080')
    app.run(host='0.0.0.0', port=8080)
