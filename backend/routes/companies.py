from flask import Blueprint, jsonify, request
from analysis.analyzer import load_data, get_company_stats

companies_bp = Blueprint("companies", __name__, url_prefix="/api/companies")


@companies_bp.route("/", methods=["GET"])
def list_companies():
    """
    GET /api/companies/
    Query params:
      limit – max companies to return (default: all)
    """
    df = load_data()
    stats = get_company_stats(df)

    limit = request.args.get("limit", type=int)
    if limit:
        stats = stats[:limit]

    return jsonify({"count": len(stats), "companies": stats})


@companies_bp.route("/<string:company_name>/students", methods=["GET"])
def company_students(company_name: str):
    """GET /api/companies/<name>/students — students hired by a specific company"""
    df = load_data()
    placed = df[df["is_placed"]]
    matched = placed[placed["company"].str.lower() == company_name.lower()]

    if matched.empty:
        return jsonify({"error": "Company not found or no students placed"}), 404

    records = matched.where(matched.notna(), other=None).to_dict(orient="records")
    return jsonify({"company": company_name, "count": len(records), "students": records})
