from flask import Blueprint, jsonify, request
from analysis.analyzer import load_data, get_skill_stats
from analysis.ml_predictor import predict_placement, get_feature_importance, train_model

analytics_bp = Blueprint("analytics", __name__, url_prefix="/api/analytics")


@analytics_bp.route("/skills", methods=["GET"])
def skills():
    """GET /api/analytics/skills — skill gap analysis"""
    df = load_data()
    return jsonify(get_skill_stats(df))


@analytics_bp.route("/predict", methods=["POST"])
def predict():
    """
    POST /api/analytics/predict
    Body JSON:
    {
      "cgpa": 8.5,
      "backlogs": 0,
      "projects": 3,
      "internship": true,
      "skills": ["Python", "SQL", "React"]
    }
    """
    body = request.get_json(silent=True)
    if not body:
        return jsonify({"error": "JSON body required"}), 400

    required = ["cgpa", "backlogs", "projects", "internship", "skills"]
    missing = [f for f in required if f not in body]
    if missing:
        return jsonify({"error": f"Missing fields: {missing}"}), 400

    try:
        result = predict_placement(
            cgpa=float(body["cgpa"]),
            backlogs=int(body["backlogs"]),
            projects=int(body["projects"]),
            internship=bool(body["internship"]),
            skills=list(body["skills"]),
        )
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@analytics_bp.route("/feature-importance", methods=["GET"])
def feature_importance():
    """GET /api/analytics/feature-importance — ML model feature weights"""
    return jsonify(get_feature_importance())


@analytics_bp.route("/train", methods=["POST"])
def retrain():
    """POST /api/analytics/train — retrain the ML model"""
    accuracy = train_model()
    return jsonify({"message": "Model retrained successfully", "accuracy": accuracy})
