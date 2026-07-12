"""
Core data analysis module.
Loads students.csv and exposes functions used by Flask routes.
"""

import os
import pandas as pd
import numpy as np

# ── Load dataset ──────────────────────────────────────────────────────────────
DATA_PATH = os.path.join(os.path.dirname(__file__), "../../data/students.csv")


def load_data() -> pd.DataFrame:
    """Return a clean DataFrame from students.csv."""
    df = pd.read_csv(DATA_PATH)

    # Normalize column names
    df.columns = df.columns.str.strip().str.lower()

    # Convert numeric columns
    df["cgpa"] = pd.to_numeric(df["cgpa"], errors="coerce")
    df["package_lpa"] = pd.to_numeric(df["package_lpa"], errors="coerce")
    df["backlogs"] = pd.to_numeric(df["backlogs"], errors="coerce").fillna(0).astype(int)

    # Boolean helpers
    df["is_placed"] = df["company"].notna() & (df["company"].str.strip() != "")

    return df


# ── Dashboard summary ─────────────────────────────────────────────────────────
def get_dashboard_summary(df: pd.DataFrame) -> dict:
    """High-level KPI cards for the dashboard."""
    total = len(df)
    placed_df = df[df["is_placed"]]
    placed = len(placed_df)
    unplaced = total - placed

    placement_pct = round((placed / total) * 100, 2) if total else 0
    avg_package = round(placed_df["package_lpa"].mean(), 2) if not placed_df.empty else 0
    highest_package = round(placed_df["package_lpa"].max(), 2) if not placed_df.empty else 0
    lowest_package = round(placed_df["package_lpa"].min(), 2) if not placed_df.empty else 0
    median_package = round(placed_df["package_lpa"].median(), 2) if not placed_df.empty else 0

    return {
        "total_students": total,
        "placed_students": placed,
        "unplaced_students": unplaced,
        "placement_percentage": placement_pct,
        "average_package_lpa": avg_package,
        "highest_package_lpa": highest_package,
        "lowest_package_lpa": lowest_package,
        "median_package_lpa": median_package,
    }


# ── Department-wise placement ─────────────────────────────────────────────────
def get_department_stats(df: pd.DataFrame) -> list:
    """Placement counts and percentage per department."""
    result = []
    for dept, group in df.groupby("department"):
        total = len(group)
        placed = group["is_placed"].sum()
        pct = round((placed / total) * 100, 1) if total else 0
        avg_pkg = round(group[group["is_placed"]]["package_lpa"].mean(), 2)
        result.append({
            "department": dept,
            "total": int(total),
            "placed": int(placed),
            "unplaced": int(total - placed),
            "placement_percentage": pct,
            "avg_package_lpa": avg_pkg if not np.isnan(avg_pkg) else 0,
        })
    return sorted(result, key=lambda x: x["placed"], reverse=True)


# ── Company-wise hiring ───────────────────────────────────────────────────────
def get_company_stats(df: pd.DataFrame) -> list:
    """How many students each company hired and their avg/max package."""
    placed_df = df[df["is_placed"]].copy()
    placed_df["company"] = placed_df["company"].str.strip()

    result = []
    for company, group in placed_df.groupby("company"):
        result.append({
            "company": company,
            "students_hired": int(len(group)),
            "avg_package_lpa": round(group["package_lpa"].mean(), 2),
            "max_package_lpa": round(group["package_lpa"].max(), 2),
            "min_package_lpa": round(group["package_lpa"].min(), 2),
        })
    return sorted(result, key=lambda x: x["students_hired"], reverse=True)


# ── Salary distribution buckets ───────────────────────────────────────────────
def get_salary_distribution(df: pd.DataFrame) -> list:
    """Group placed students into salary range buckets."""
    placed_df = df[df["is_placed"]].copy()
    bins = [0, 4, 6, 8, 10, 15, 25]
    labels = ["0–4 LPA", "4–6 LPA", "6–8 LPA", "8–10 LPA", "10–15 LPA", "15+ LPA"]
    placed_df["salary_range"] = pd.cut(
        placed_df["package_lpa"], bins=bins, labels=labels, right=True
    )
    dist = placed_df["salary_range"].value_counts().reindex(labels, fill_value=0)
    return [{"range": k, "count": int(v)} for k, v in dist.items()]


# ── CGPA distribution ─────────────────────────────────────────────────────────
def get_cgpa_distribution(df: pd.DataFrame) -> list:
    """Count of students per CGPA bracket."""
    bins = [0, 6, 7, 8, 9, 10]
    labels = ["< 6", "6–7", "7–8", "8–9", "9–10"]
    df["cgpa_range"] = pd.cut(df["cgpa"], bins=bins, labels=labels, right=True)
    dist = df["cgpa_range"].value_counts().reindex(labels, fill_value=0)
    return [{"range": k, "count": int(v)} for k, v in dist.items()]


# ── Monthly placement trend ───────────────────────────────────────────────────
def get_monthly_trend(df: pd.DataFrame) -> list:
    """Number of placements per month (ordered calendar order)."""
    month_order = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December",
    ]
    placed_df = df[df["is_placed"]].copy()
    placed_df["placement_month"] = placed_df["placement_month"].str.strip()
    counts = placed_df["placement_month"].value_counts()
    result = []
    for m in month_order:
        if m in counts:
            result.append({"month": m, "placements": int(counts[m])})
    return result


# ── Gender-wise placement ─────────────────────────────────────────────────────
def get_gender_stats(df: pd.DataFrame) -> list:
    """Placement stats split by gender."""
    result = []
    for gender, group in df.groupby("gender"):
        total = len(group)
        placed = group["is_placed"].sum()
        result.append({
            "gender": gender,
            "total": int(total),
            "placed": int(placed),
            "placement_percentage": round((placed / total) * 100, 1) if total else 0,
        })
    return result


# ── CGPA vs Package correlation ───────────────────────────────────────────────
def get_cgpa_vs_package(df: pd.DataFrame) -> list:
    """Scatter data: each placed student's CGPA and package."""
    placed_df = df[df["is_placed"]][["name", "cgpa", "package_lpa", "department"]].copy()
    placed_df = placed_df.dropna()
    return placed_df.rename(columns={"package_lpa": "package"}).to_dict(orient="records")


# ── Skill gap analysis ────────────────────────────────────────────────────────
def get_skill_stats(df: pd.DataFrame) -> dict:
    """
    Returns:
      - top_skills_overall: top 15 skills across all students
      - skills_placed: top skills among placed students
      - skills_unplaced: top skills among unplaced students
      - missing_skills: skills that placed students have but unplaced students lack
    """
    def extract_skills(series: pd.Series) -> pd.Series:
        all_skills = []
        for entry in series.dropna():
            skills = [s.strip() for s in str(entry).split(",") if s.strip()]
            all_skills.extend(skills)
        return pd.Series(all_skills)

    all_skills = extract_skills(df["skills"])
    placed_skills = extract_skills(df[df["is_placed"]]["skills"])
    unplaced_skills = extract_skills(df[~df["is_placed"]]["skills"])

    top_overall = all_skills.value_counts().head(15)
    top_placed = placed_skills.value_counts().head(15)
    top_unplaced = unplaced_skills.value_counts().head(10)

    # Skills in top placed but absent/rare in unplaced
    placed_set = set(placed_skills.value_counts().head(20).index)
    unplaced_set = set(unplaced_skills.unique())
    missing = placed_set - unplaced_set

    return {
        "top_skills_overall": [{"skill": k, "count": int(v)} for k, v in top_overall.items()],
        "skills_placed": [{"skill": k, "count": int(v)} for k, v in top_placed.items()],
        "skills_unplaced": [{"skill": k, "count": int(v)} for k, v in top_unplaced.items()],
        "missing_skills_in_unplaced": sorted(list(missing)),
    }


# ── Students list (with optional filters) ─────────────────────────────────────
def get_students(
    df: pd.DataFrame,
    department: str = None,
    placed: str = None,
    search: str = None,
) -> list:
    """Return filtered student records."""
    result = df.copy()

    if department:
        result = result[result["department"].str.upper() == department.upper()]

    if placed is not None:
        flag = placed.lower() == "true"
        result = result[result["is_placed"] == flag]

    if search:
        q = search.lower()
        result = result[
            result["name"].str.lower().str.contains(q, na=False)
            | result["skills"].str.lower().str.contains(q, na=False)
            | result["company"].fillna("").str.lower().str.contains(q, na=False)
        ]

    # Serialize safely — preserve bool is_placed, replace NaN with None
    records = []
    for _, row in result.iterrows():
        rec = {}
        for col in result.columns:
            val = row[col]
            if col == "is_placed":
                rec[col] = bool(val)
            elif pd.isna(val):
                rec[col] = None
            else:
                rec[col] = val
        records.append(rec)
    return records
