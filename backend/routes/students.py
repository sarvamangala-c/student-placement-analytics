from flask import Blueprint, jsonify, request
from analysis.analyzer import load_data, get_students

students_bp = Blueprint("students", __name__, url_prefix="/api/students")


@students_bp.route("/", methods=["GET"])
def list_students():
    """
    GET /api/students/
    Query params:
      department  – CSE | IT | ECE | EEE | MECH
      placed      – true | false
      search      – name / skill / company keyword
    """
    department = request.args.get("department")
    placed = request.args.get("placed")
    search = request.args.get("search")

    df = load_data()
    students = get_students(df, department=department, placed=placed, search=search)
    return jsonify({"count": len(students), "students": students})


@students_bp.route("/<int:student_id>", methods=["GET"])
def get_student(student_id: int):
    """GET /api/students/<id> — single student record"""
    df = load_data()
    row = df[df["id"] == student_id]
    if row.empty:
        return jsonify({"error": "Student not found"}), 404
    import pandas as pd
    rec = {}
    for col in row.columns:
        val = row.iloc[0][col]
        if col == "is_placed":
            rec[col] = bool(val)
        elif pd.isna(val):
            rec[col] = None
        else:
            rec[col] = val
    return jsonify(rec)
