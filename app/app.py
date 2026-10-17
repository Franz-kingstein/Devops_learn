import os
import socket
from datetime import datetime, timezone
from flask import Flask, render_template, jsonify

app = Flask(__name__)

# Read version from environment variable with default
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0-dev")

# Capture deployment time at startup (simulates last deployment time).
# timezone.utc keeps this warning-free on Python 3.12+ (utcnow() is deprecated).
DEPLOYMENT_TIME = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


@app.route("/")
def index():
    """Render the main page with version, hostname, and deployment time."""
    hostname = socket.gethostname()
    return render_template(
        "index.html",
        version=APP_VERSION,
        hostname=hostname,
        deployment_time=DEPLOYMENT_TIME,
    )


@app.route("/health")
def health():
    """Health check endpoint returning JSON."""
    return jsonify({"status": "ok", "version": APP_VERSION})


if __name__ == "__main__":
    # Run on all interfaces for container/VM access
    app.run(host="0.0.0.0", port=5000, debug=True)
