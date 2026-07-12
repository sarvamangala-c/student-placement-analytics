import React, { useEffect, useState } from "react";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, Cell,
} from "recharts";
import { getCompanies, getCompanyStudents } from "../services/api";
import Spinner from "../components/Spinner";
import KpiCard from "../components/KpiCard";

const COLORS = [
  "#3b82f6","#10b981","#f59e0b","#f43f5e","#8b5cf6",
  "#06b6d4","#ec4899","#84cc16","#f97316","#6366f1",
];

export default function Companies() {
  const [companies, setCompanies]     = useState([]);
  const [loading, setLoading]         = useState(true);
  const [selected, setSelected]       = useState(null);
  const [studs, setStuds]             = useState([]);
  const [studsLoading, setStudsLoading] = useState(false);
  const [search, setSearch]           = useState("");

  useEffect(() => {
    getCompanies()
      .then((r) => setCompanies(r.data.companies || []))
      .finally(() => setLoading(false));
  }, []);

  function handleSelectCompany(company) {
    setSelected(company);
    setStudsLoading(true);
    getCompanyStudents(company.company)
      .then((r) => setStuds(r.data.students || []))
      .catch(() => setStuds([]))
      .finally(() => setStudsLoading(false));
  }

  const filtered = companies.filter((c) =>
    c.company.toLowerCase().includes(search.toLowerCase())
  );
  const top10 = [...companies].slice(0, 10);

  if (loading) return <Spinner />;

  const totalHired = companies.reduce((a, c) => a + c.students_hired, 0);
  const maxPkg     = Math.max(...companies.map((c) => c.max_package_lpa));
  const avgPkg     = companies.length
    ? (companies.reduce((a, c) => a + c.avg_package_lpa * c.students_hired, 0) / totalHired).toFixed(2)
    : 0;

  return (
    <div className="page">
      <div className="page-title">Company Analytics</div>
      <div className="page-subtitle">Hiring stats across all recruiting companies</div>

      {/* KPIs */}
      <div className="kpi-grid">
        <KpiCard icon="🏢" label="Companies"       value={companies.length}      color="blue"  sub="Total recruiters" />
        <KpiCard icon="🎓" label="Students Hired"  value={totalHired}            color="green" sub="Total placements" />
        <KpiCard icon="💰" label="Avg Package"     value={`₹${avgPkg} LPA`}     color="amber" sub="Weighted average" />
        <KpiCard icon="🏆" label="Highest Offer"   value={`₹${maxPkg} LPA`}     color="indigo" sub="Best package" />
      </div>

      {/* Top-10 bar chart */}
      <div className="card" style={{ marginBottom: 20 }}>
        <h3 style={{ fontSize: ".9rem", fontWeight: 600, marginBottom: 16 }}>Top 10 Hiring Companies</h3>
        <ResponsiveContainer width="100%" height={280}>
          <BarChart data={top10} layout="vertical" margin={{ left: 20, right: 20 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" horizontal={false} />
            <XAxis type="number" tick={{ fontSize: 12 }} />
            <YAxis type="category" dataKey="company" tick={{ fontSize: 12 }} width={120} />
            <Tooltip formatter={(v) => [`${v} students`, "Hired"]} />
            <Bar dataKey="students_hired" name="Students Hired" radius={[0,4,4,0]}>
              {top10.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Company table */}
      <div className="card">
        <div className="input-group" style={{ marginBottom: 14 }}>
          <input
            className="input"
            style={{ maxWidth: 300 }}
            type="text"
            placeholder="🔍 Filter companies…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <span style={{ fontSize: ".85rem", color: "#64748b", marginLeft: 4 }}>
            {filtered.length} companies
          </span>
        </div>

        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>Company</th>
                <th>Students Hired</th>
                <th>Avg Package</th>
                <th>Max Package</th>
                <th>Min Package</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((c, i) => (
                <tr key={c.company}>
                  <td style={{ color: "#94a3b8" }}>{i + 1}</td>
                  <td style={{ fontWeight: 600 }}>{c.company}</td>
                  <td>
                    <span className="badge badge-blue">{c.students_hired}</span>
                  </td>
                  <td style={{ fontWeight: 500 }}>₹{c.avg_package_lpa} LPA</td>
                  <td style={{ color: "#16a34a", fontWeight: 600 }}>₹{c.max_package_lpa} LPA</td>
                  <td style={{ color: "#64748b" }}>₹{c.min_package_lpa} LPA</td>
                  <td></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Company students drawer */}
      {selected && (
        <div className="card" style={{ marginTop: 20 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
            <h3 style={{ fontSize: ".95rem", fontWeight: 700 }}>
              {selected.company} — {selected.students_hired} student{selected.students_hired !== 1 ? "s" : ""}
            </h3>
            <button className="btn btn-secondary" style={{ padding: "4px 10px", fontSize: ".78rem" }}
              onClick={() => setSelected(null)}>
              ✕ Close
            </button>
          </div>

          {studsLoading ? <Spinner /> : (
            <div className="table-wrapper">
              <table>
                <thead>
                  <tr>
                    <th>Name</th><th>Dept</th><th>CGPA</th><th>Package</th><th>Month</th>
                  </tr>
                </thead>
                <tbody>
                  {studs.map((s) => (
                    <tr key={s.id}>
                      <td style={{ fontWeight: 500 }}>{s.name}</td>
                      <td><span className="badge badge-blue">{s.department}</span></td>
                      <td style={{ fontWeight: 600 }}>{s.cgpa}</td>
                      <td style={{ color: "#1d4ed8", fontWeight: 600 }}>₹{s.package_lpa} LPA</td>
                      <td style={{ color: "#64748b" }}>{s.placement_month}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
