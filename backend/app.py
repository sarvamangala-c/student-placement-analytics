"""
Student Placement Analytics — Flask Backend
Run:  python app.py
"""

import json
import numpy as np
from flask import Flask, jsonify
from flask.json.provider import DefaultJSONProvider
from flask_cors import CORS

from routes.dashboard import dashboard_bp
from routes.students import students_bp
from routes.companies import companies_bp
from routes.analytics import analytics_bp
from routes.auth import auth_bp


class NumpyJSONProvider(DefaultJSONProvider):
    """Serialize numpy types so Flask's jsonify doesn't choke."""
    def default(self, obj):
        if isinstance(obj, (np.integer,)):
            return int(obj)
        if isinstance(obj, (np.floating,)):
            return float(obj)
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        if isinstance(obj, np.bool_):
            return bool(obj)
        return super().default(obj)


def create_app() -> Flask:
    app = Flask(__name__)
    app.json_provider_class = NumpyJSONProvider
    app.json = NumpyJSONProvider(app)
    app.config["JSON_SORT_KEYS"] = False

    # Allow React dev server (port 3000) to call the API
    CORS(app, resources={r"/api/*": {"origins": ["http://localhost:3000"]}})

    # Register blueprints
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(students_bp)
    app.register_blueprint(companies_bp)
    app.register_blueprint(analytics_bp)
    app.register_blueprint(auth_bp)

    # Health check
    @app.route("/api/health")
    def health():
        return jsonify({"status": "ok", "service": "Student Placement Analytics API"})

    # 404 handler
    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"error": "Endpoint not found"}), 404

    # 500 handler
    @app.errorhandler(500)
    def server_error(e):
        return jsonify({"error": "Internal server error"}), 500

    return app


if __name__ == "__main__":
    app = create_app()
    print("Starting Student Placement Analytics API...")
    print("API running at: http://localhost:5000")
    print("\nAvailable endpoints:")
    print("  GET  /api/health")
    print("  POST /api/auth/login")
    print("  GET  /api/dashboard/summary")
    print("  GET  /api/dashboard/departments")
    print("  GET  /api/dashboard/salary-distribution")
    print("  GET  /api/dashboard/cgpa-distribution")
    print("  GET  /api/dashboard/monthly-trend")
    print("  GET  /api/dashboard/gender-stats")
    print("  GET  /api/dashboard/cgpa-vs-package")
    print("  GET  /api/students/")
    print("  GET  /api/students/<id>")
    print("  GET  /api/companies/")
    print("  GET  /api/companies/<name>/students")
    print("  GET  /api/analytics/skills")
    print("  POST /api/analytics/predict")
    print("  GET  /api/analytics/feature-importance")
    app.run(debug=True, port=5000)
