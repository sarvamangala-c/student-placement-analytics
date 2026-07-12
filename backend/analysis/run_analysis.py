"""
Standalone script — run to verify all analysis functions work.
Usage:  python backend/analysis/run_analysis.py
"""

import json
from analyzer import (
    load_data,
    get_dashboard_summary,
    get_department_stats,
    get_company_stats,
    get_salary_distribution,
    get_cgpa_distribution,
    get_monthly_trend,
    get_gender_stats,
    get_skill_stats,
)

df = load_data()
print(f"Loaded {len(df)} students\n")

print("=== DASHBOARD SUMMARY ===")
print(json.dumps(get_dashboard_summary(df), indent=2))

print("\n=== DEPARTMENT STATS ===")
print(json.dumps(get_department_stats(df), indent=2))

print("\n=== TOP 5 COMPANIES ===")
print(json.dumps(get_company_stats(df)[:5], indent=2))

print("\n=== SALARY DISTRIBUTION ===")
print(json.dumps(get_salary_distribution(df), indent=2))

print("\n=== CGPA DISTRIBUTION ===")
print(json.dumps(get_cgpa_distribution(df), indent=2))

print("\n=== MONTHLY TREND ===")
print(json.dumps(get_monthly_trend(df), indent=2))

print("\n=== GENDER STATS ===")
print(json.dumps(get_gender_stats(df), indent=2))

print("\n=== SKILL GAP ===")
skill_data = get_skill_stats(df)
print("Top 10 skills overall:")
print(json.dumps(skill_data["top_skills_overall"][:10], indent=2))
print("Missing skills in unplaced students:")
print(json.dumps(skill_data["missing_skills_in_unplaced"], indent=2))
