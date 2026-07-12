import React, { useEffect, useState, useCallback } from "react";
import { getStudents } from "../services/api";
import Spinner from "../components/Spinner";

const DEPTS = ["", "CSE", "IT", "ECE", "EEE", "MECH"];

function downloadCSV(students) {
  const headers = ["ID", "Name", "Gender", "Department", "CGPA", "Backlogs", "Internship", "Projects", "Skills", "Company", "Package (LPA)", "Month", "Year"];
  const rows = students.map((s) => [
    s.id, s.name, s.gender, s.department, s.cgpa, s.backlogs,
    s.internship, s.projects, `"${s.skills || ""}"`,
    s.company || "—", s.package_lpa || "—", s.placement_month || "—", s.placement_year || "—",
  ]);
  const csv = [headers, ...rows].map((r) => r.join(",")).join("\n");
  const blob = new Blob([csv], { type: "text/csv" });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement("a");
  a.href = url; a.download = "students.csv"; a.click();
  URL.revokeObjectURL(url);
}

export default function Students() {
  const [students, setStudents]   = useState([]);
  const [loading, setLoading]     = useState(true);
  const [search, setSearch]       = useState("");
  const [dept, setDept]           = useState("");
  const [placed, setPlaced]       = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");

  // Debounce search
  useEffect(() => {
    const t = setTimeout(() => setDebouncedSearch(search), 400);
    return () => clearTimeout(t);
  }, [search]);

  const fetchStudents = useCallback(() => {
    setLoading(true);
    const params = {};
    if (dept)            params.department = dept;
    if (placed !== "")   params.placed     = placed;
    if (debouncedSearch) params.search     = debouncedSearch;
    getStudents(params)
      .then((r) => setStudents(r.data.students || []))
      .finally(() => setLoading(false));
  }, [dept, placed, debouncedSearch]);

  useEffect(() => { fetchStudents(); }, [fetchStudents]);

  return (
    <div className="page">
      <div className="page-title">Students</div>
      <div className="page-subtitle">Browse, filter, and export student placement records</div>

      {/* Filters */}
      <div className="card" style={{ marginBottom: 20 }}>
        <div className="input-group" style={{ flexWrap: "wrap", gap: 10 }}>
          <input
            className="input"
            style={{ maxWidth: 280 }}
            type="text"
            placeholder="🔍 Search by name, skill, or company…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />

          <select className="input" style={{ maxWidth: 160 }} value={dept} onChange={(e) => setDept(e.target.value)}>
            <option value="">All Departments</option>
            {DEPTS.filter(Boolean).map((d) => <option key={d} value={d}>{d}</option>)}
          </select>

          <select className="input" style={{ maxWidth: 160 }} value={placed} onChange={(e) => setPlaced(e.target.value)}>
            <option value="">All Students</option>
            <option value="true">Placed Only</option>
            <option value="false">Unplaced Only</option>
          </select>

          <button className="btn btn-secondary" onClick={() => { setSearch(""); setDept(""); setPlaced(""); }}>
            Clear
          </button>

          <button className="btn btn-primary" style={{ marginLeft: "auto" }} onClick={() => downloadCSV(students)} disabled={students.length === 0}>
            ⬇ Download CSV
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="card">
        <div style={{ marginBottom: 12, fontSize: ".85rem", color: "#64748b" }}>
          Showing <strong>{students.length}</strong> student{students.length !== 1 ? "s" : ""}
        </div>

        {loading ? <Spinner /> : (
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Name</th>
                  <th>Gender</th>
                  <th>Dept</th>
                  <th>CGPA</th>
                  <th>Backlogs</th>
                  <th>Internship</th>
                  <th>Skills</th>
                  <th>Company</th>
                  <th>Package</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {students.length === 0 ? (
                  <tr><td colSpan={11} style={{ textAlign: "center", padding: "40px", color: "#94a3b8" }}>No students found.</td></tr>
                ) : students.map((s) => (
                  <tr key={s.id}>
                    <td style={{ color: "#94a3b8" }}>{s.id}</td>
                    <td style={{ fontWeight: 500 }}>{s.name}</td>
                    <td>{s.gender}</td>
                    <td><span className="badge badge-blue">{s.department}</span></td>
                    <td>
                      <span style={{ fontWeight: 600, color: s.cgpa >= 8.5 ? "#16a34a" : s.cgpa >= 7 ? "#d97706" : "#dc2626" }}>
                        {s.cgpa}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${s.backlogs === 0 ? "badge-green" : "badge-red"}`}>
                        {s.backlogs}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${s.internship === "Yes" ? "badge-green" : "badge-slate"}`}>
                        {s.internship || "No"}
                      </span>
                    </td>
                    <td style={{ maxWidth: 200, fontSize: ".78rem", color: "#64748b" }}>
                      {s.skills
                        ? s.skills.split(",").slice(0, 3).map((sk) => (
                            <span key={sk} className="badge badge-slate" style={{ marginRight: 3, marginBottom: 2 }}>{sk.trim()}</span>
                          ))
                        : "—"}
                    </td>
                    <td style={{ fontWeight: 500 }}>{s.company || <span style={{ color: "#94a3b8" }}>—</span>}</td>
                    <td style={{ fontWeight: 600, color: "#1d4ed8" }}>
                      {s.package_lpa ? `₹${s.package_lpa} LPA` : <span style={{ color: "#94a3b8" }}>—</span>}
                    </td>
                    <td>
                      <span className={`badge ${s.is_placed ? "badge-green" : "badge-red"}`}>
                        {s.is_placed ? "Placed" : "Unplaced"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
