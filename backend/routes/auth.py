"""
Simple in-memory auth — replace with DB-backed auth for production.
Users are hardcoded for demo purposes.
"""

from flask import Blueprint, jsonify, request

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

# Demo credentials — in production use hashed passwords in a DB
USERS = {
    "admin": {"password": "admin123", "role": "admin", "name": "Admin User"},
}


@auth_bp.route("/login", methods=["POST"])
def login():
    """
    POST /api/auth/login
    Body: { "username": "admin", "password": "admin123" }
    Returns: { "token": "...", "role": "admin", "name": "..." }
    """
    body = request.get_json(silent=True)
    if not body:
        return jsonify({"error": "JSON body required"}), 400

    username = body.get("username", "").strip().lower()
    password = body.get("password", "")

    user = USERS.get(username)
    if not user or user["password"] != password:
        return jsonify({"error": "Invalid username or password"}), 401

    # Simple demo token — use JWT in production
    token = f"demo-token-{username}-2024"

    return jsonify({
        "token": token,
        "role": user["role"],
        "name": user["name"],
        "username": username,
    })


@auth_bp.route("/logout", methods=["POST"])
def logout():
    """POST /api/auth/logout"""
    return jsonify({"message": "Logged out successfully"})


@auth_bp.route("/me", methods=["GET"])
def me():
    """
    GET /api/auth/me
    Header: Authorization: Bearer <token>
    """
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Authorization header missing"}), 401

    token = auth_header.split(" ")[1]

    # Decode demo token
    for username, user in USERS.items():
        if token == f"demo-token-{username}-2024":
            return jsonify({"username": username, "role": user["role"], "name": user["name"]})

    return jsonify({"error": "Invalid token"}), 401
