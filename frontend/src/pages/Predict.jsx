import React, { useState } from "react";
import { predictPlacement } from "../services/api";

const DEFAULT = { cgpa: "", backlogs: "", projects: "", internship: false, skills: "" };

export default function Predict() {
  const [form, setForm]       = useState(DEFAULT);
  const [result, setResult]   = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState("");

  function handleChange(e) {
    const { name, value, type, checked } = e.target;
    setForm((f) => ({ ...f, [name]: type === "checkbox" ? checked : value }));
    setResult(null); setError("");
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.cgpa || form.backlogs === "" || form.projects === "") {
      setError("Please fill in CGPA, Backlogs, and Projects.");
      return;
    }
    setLoading(true); setError("");
    try {
      const skillList = form.skills.split(",").map((s) => s.trim()).filter(Boolean);
      const { data } = await predictPlacement({
        cgpa:       parseFloat(form.cgpa),
        backlogs:   parseInt(form.backlogs, 10),
        projects:   parseInt(form.projects, 10),
        internship: form.internship,
        skills:     skillList,
      });
      setResult(data);
    } catch (err) {
      setError(err?.response?.data?.error || "Prediction failed. Is the backend running?");
    } finally {
      setLoading(false);
    }
  }

  const placed = result?.prediction === "Placed";

  return (
    <div className="page">
      <div className="page-title">Placement Predictor</div>
      <div className="page-subtitle">ML-powered prediction — enter student profile to estimate placement probability</div>

      <div style={{ maxWidth: 560 }}>
        <div className="card">
          {error && <div className="alert-error">{error}</div>}

          <form onSubmit={handleSubmit}>
            <div className="predict-grid">
              <div>
                <label style={{ display: "block", fontSize: ".8rem", fontWeight: 600, color: "#475569", marginBottom: 6 }}>
                  CGPA (0–10)
                </label>
                <input name="cgpa" type="number" min="0" max="10" step="0.1"
                  className="input" placeholder="e.g. 8.5"
                  value={form.cgpa} onChange={handleChange} />
              </div>

              <div>
                <label style={{ display: "block", fontSize: ".8rem", fontWeight: 600, color: "#475569", marginBottom: 6 }}>
                  Active Backlogs
                </label>
                <input name="backlogs" type="number" min="0" max="20"
                  className="input" placeholder="e.g. 0"
                  value={form.backlogs} onChange={handleChange} />
              </div>

              <div>
                <label style={{ display: "block", fontSize: ".8rem", fontWeight: 600, color: "#475569", marginBottom: 6 }}>
                  Projects Completed
                </label>
                <input name="projects" type="number" min="0" max="20"
                  className="input" placeholder="e.g. 3"
                  value={form.projects} onChange={handleChange} />
              </div>

              <div style={{ display: "flex", alignItems: "center", gap: 10, paddingTop: 24 }}>
                <input type="checkbox" id="internship" name="internship"
                  checked={form.internship} onChange={handleChange}
                  style={{ width: 16, height: 16, cursor: "pointer" }} />
                <label htmlFor="internship" style={{ fontSize: ".875rem", fontWeight: 500, color: "#334155", cursor: "pointer" }}>
                  Has Internship Experience
                </label>
              </div>
            </div>

            <div style={{ marginTop: 16 }}>
              <label style={{ display: "block", fontSize: ".8rem", fontWeight: 600, color: "#475569", marginBottom: 6 }}>
                Skills (comma-separated)
              </label>
              <input name="skills" type="text"
                className="input"
                placeholder="e.g. Python, SQL, React, Java"
                value={form.skills} onChange={handleChange} />
              <p style={{ fontSize: ".74rem", color: "#94a3b8", marginTop: 4 }}>
                Each skill counts — more skills = higher skill_count feature
              </p>
            </div>

            <button type="submit" className="btn btn-primary" style={{ marginTop: 20, width: "100%", justifyContent: "center", padding: "11px" }} disabled={loading}>
              {loading ? "Predicting…" : "🤖 Predict Placement"}
            </button>
          </form>

          {result && (
            <div className={`predict-result ${placed ? "placed" : "unplaced"}`}>
              <div className="pred-label">Prediction Result</div>
              <div className="pred-value" style={{ color: placed ? "#15803d" : "#dc2626" }}>
                {placed ? "✅ Likely Placed" : "❌ At Risk"}
              </div>
              <div className="pred-prob">
                Placement Probability: <strong>{result.probability}%</strong>
              </div>
              <div style={{ fontSize: ".78rem", color: "#64748b", marginTop: 8 }}>
                Model accuracy: {result.model_accuracy}% (trained on 100 students)
              </div>
            </div>
          )}
        </div>

        <div className="card" style={{ marginTop: 16, fontSize: ".8rem", color: "#475569" }}>
          <div style={{ fontWeight: 700, marginBottom: 8, fontSize: ".875rem", color: "#0f172a" }}>
            ℹ️ How it works
          </div>
          <p style={{ lineHeight: 1.7 }}>
            A <strong>Random Forest</strong> classifier trained on 100 student records uses five features:
            CGPA, backlogs, number of projects, internship experience, and skill count to predict whether
            a student is likely to be placed. The probability score reflects the model's confidence.
          </p>
        </div>
      </div>
    </div>
  );
}
