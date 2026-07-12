"""
Optional ML module — predicts placement probability for a student.
Uses a RandomForestClassifier trained on the existing dataset.
"""

import os
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

from .analyzer import load_data

_model: RandomForestClassifier = None
_dept_encoder: LabelEncoder = None
_accuracy: float = 0.0


def _build_features(df: pd.DataFrame) -> pd.DataFrame:
    """Engineer features for the ML model."""
    feat = df[["cgpa", "backlogs", "projects"]].copy()
    feat["internship"] = (df["internship"].str.strip().str.lower() == "yes").astype(int)
    feat["skill_count"] = (
        df["skills"]
        .fillna("")
        .apply(lambda x: len([s for s in x.split(",") if s.strip()]))
    )
    return feat


def train_model():
    """Train (or retrain) the placement predictor."""
    global _model, _dept_encoder, _accuracy

    df = load_data()
    X = _build_features(df)
    y = df["is_placed"].astype(int)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)

    _accuracy = round(accuracy_score(y_test, clf.predict(X_test)) * 100, 1)
    _model = clf
    return _accuracy


def predict_placement(
    cgpa: float,
    backlogs: int,
    projects: int,
    internship: bool,
    skills: list,
) -> dict:
    """
    Predict placement probability for a new student.

    Returns:
        probability  – 0-100 float
        prediction   – "Placed" | "Not Placed"
        model_accuracy – training accuracy %
    """
    global _model

    if _model is None:
        train_model()

    features = pd.DataFrame([{
        "cgpa": cgpa,
        "backlogs": backlogs,
        "projects": projects,
        "internship": int(internship),
        "skill_count": len(skills),
    }])

    prob = _model.predict_proba(features)[0][1]  # probability of class 1 (placed)
    prediction = "Placed" if prob >= 0.5 else "Not Placed"

    return {
        "probability": round(prob * 100, 1),
        "prediction": prediction,
        "model_accuracy": _accuracy,
    }


def get_feature_importance() -> list:
    """Return feature importance scores from the trained model."""
    global _model
    if _model is None:
        train_model()

    features = ["cgpa", "backlogs", "projects", "internship", "skill_count"]
    importances = _model.feature_importances_
    return sorted(
        [{"feature": f, "importance": round(float(i) * 100, 2)}
         for f, i in zip(features, importances)],
        key=lambda x: x["importance"],
        reverse=True,
    )
