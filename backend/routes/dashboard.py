from flask import Blueprint, jsonify
from analysis.analyzer import (
    load_data,
    get_dashboard_summary,
    get_department_stats,
    get_salary_distribution,
    get_cgpa_distribution,
    get_monthly_trend,
    get_gender_stats,
    get_cgpa_vs_package,
)

dashboard_bp = Blueprint("dashboard", __name__, url_prefix="/api/dashboard")


@dashboard_bp.route("/summary", methods=["GET"])
def summary():
    """GET /api/dashboard/summary — KPI cards"""
    df = load_data()
    return jsonify(get_dashboard_summary(df))


@dashboard_bp.route("/departments", methods=["GET"])
def departments():
    """GET /api/dashboard/departments — department-wise placement"""
    df = load_data()
    return jsonify(get_department_stats(df))


@dashboard_bp.route("/salary-distribution", methods=["GET"])
def salary_distribution():
    """GET /api/dashboard/salary-distribution"""
    df = load_data()
    return jsonify(get_salary_distribution(df))


@dashboard_bp.route("/cgpa-distribution", methods=["GET"])
def cgpa_distribution():
    """GET /api/dashboard/cgpa-distribution"""
    df = load_data()
    return jsonify(get_cgpa_distribution(df))


@dashboard_bp.route("/monthly-trend", methods=["GET"])
def monthly_trend():
    """GET /api/dashboard/monthly-trend"""
    df = load_data()
    return jsonify(get_monthly_trend(df))


@dashboard_bp.route("/gender-stats", methods=["GET"])
def gender_stats():
    """GET /api/dashboard/gender-stats"""
    df = load_data()
    return jsonify(get_gender_stats(df))


@dashboard_bp.route("/cgpa-vs-package", methods=["GET"])
def cgpa_vs_package():
    """GET /api/dashboard/cgpa-vs-package — scatter plot data"""
    df = load_data()
    return jsonify(get_cgpa_vs_package(df))
