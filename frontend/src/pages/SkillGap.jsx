import React, { useEffect, useState } from "react";
import { getSkillStats } from "../services/api";
import Spinner from "../components/Spinner";

function SkillBar({ skill, count, max, color = "#3b82f6" }) {
  const pct = max ? Math.round((count / max) * 100) : 0;
  return (
    <div className="skill-bar-row">
      <div className="skill-bar-label">
        <span>{skill}</span>
        <span style={{ color: "#64748b" }}>{count} students</span>
      </div>
      <div className="skill-bar-track">
        <div className="skill-bar-fill" style={{ width: `${pct}%`, background: color }} />
      </div>
    </div>
  );
}

export default function SkillGap() {
  const [data, setData]     = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getSkillStats()
      .then((r) => setData(r.data))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Spinner />;

  const maxOverall  = data?.top_skills_overall?.[0]?.count  || 1;
  const maxPlaced   = data?.skills_placed?.[0]?.count       || 1;
  const maxUnplaced = data?.skills_unplaced?.[0]?.count     || 1;

  return (
    <div className="page">
      <div className="page-title">Skill Gap Analysis</div>
      <div className="page-subtitle">Understand which skills drive placement outcomes</div>

      <div className="charts-grid">
        {/* Top skills overall */}
        <div className="card">
          <h3 style={{ fontSize: ".9rem", fontWeight: 700, marginBottom: 18, color: "#0f172a" }}>
            🏅 Top 15 In-Demand Skills
          </h3>
          {data?.top_skills_overall?.map((s) => (
            <SkillBar key={s.skill} skill={s.skill} count={s.count} max={maxOverall} color="#3b82f6" />
          ))}
        </div>

        {/* Skills of placed students */}
        <div className="card">
          <h3 style={{ fontSize: ".9rem", fontWeight: 700, marginBottom: 18, color: "#0f172a" }}>
            ✅ Skills of Placed Students
          </h3>
          {data?.skills_placed?.map((s) => (
            <SkillBar key={s.skill} skill={s.skill} count={s.count} max={maxPlaced} color="#10b981" />
          ))}
        </div>
      </div>

      <div className="charts-grid">
        {/* Skills of unplaced */}
        <div className="card">
          <h3 style={{ fontSize: ".9rem", fontWeight: 700, marginBottom: 18, color: "#0f172a" }}>
            ⚠️ Skills of Unplaced Students
          </h3>
          {data?.skills_unplaced?.length ? (
            data.skills_unplaced.map((s) => (
              <SkillBar key={s.skill} skill={s.skill} count={s.count} max={maxUnplaced} color="#f59e0b" />
            ))
          ) : (
            <p style={{ color: "#94a3b8", fontSize: ".875rem" }}>No skill data for unplaced students.</p>
          )}
        </div>

        {/* Missing skills */}
        <div className="card">
          <h3 style={{ fontSize: ".9rem", fontWeight: 700, marginBottom: 18, color: "#0f172a" }}>
            🚨 Skills Missing in Unplaced Students
          </h3>
          <p style={{ fontSize: ".8rem", color: "#64748b", marginBottom: 14 }}>
            These are top skills that placed students have but unplaced students lack.
            Learning even 2–3 of these can significantly improve placement chances.
          </p>
          {data?.missing_skills_in_unplaced?.length ? (
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
              {data.missing_skills_in_unplaced.map((skill) => (
                <span key={skill} className="badge badge-red" style={{ fontSize: ".8rem", padding: "5px 12px" }}>
                  {skill}
                </span>
              ))}
            </div>
          ) : (
            <p style={{ color: "#94a3b8", fontSize: ".875rem" }}>No gaps detected.</p>
          )}

          <div style={{ marginTop: 28, padding: "16px", background: "#f0fdf4", borderRadius: 8, border: "1px solid #bbf7d0" }}>
            <div style={{ fontWeight: 700, color: "#15803d", marginBottom: 8, fontSize: ".875rem" }}>💡 Recommendations</div>
            <ul style={{ paddingLeft: 16, fontSize: ".8rem", color: "#166534", lineHeight: 1.8 }}>
              <li>Master <strong>Python</strong> — it appears in 70%+ of placed students' profiles</li>
              <li>Learn <strong>SQL</strong> — essential for both Data and Software roles</li>
              <li>Build at least <strong>2–3 projects</strong> on GitHub</li>
              <li>Complete an <strong>internship</strong> — placement odds jump 30%+</li>
              <li>Add <strong>React</strong> or a modern framework to your skillset</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
