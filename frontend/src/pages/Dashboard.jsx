import React, { useEffect, useState } from "react";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend,
  LineChart, Line,
  ScatterChart, Scatter, ZAxis,
} from "recharts";
import {
  getDashboardSummary, getDepartmentStats, getSalaryDistribution,
  getCgpaDistribution, getMonthlyTrend, getGenderStats, getCgpaVsPackage,
} from "../services/api";
import KpiCard from "../components/KpiCard";
import Spinner from "../components/Spinner";

const PIE_COLORS = ["#3b82f6", "#f59e0b", "#10b981", "#f43f5e", "#8b5cf6"];
const BAR_COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#f43f5e", "#8b5cf6"];

function useData(fetcher) {
  const [data, setData]     = useState(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    fetcher().then((r) => setData(r.data)).finally(() => setLoading(false));
  }, []); // eslint-disable-line
  return { data, loading };
}

export default function Dashboard() {
  const summary  = useData(getDashboardSummary);
  const depts    = useData(getDepartmentStats);
  const salary   = useData(getSalaryDistribution);
  const cgpa     = useData(getCgpaDistribution);
  const monthly  = useData(getMonthlyTrend);
  const gender   = useData(getGenderStats);
  const scatter  = useData(getCgpaVsPackage);

  const loading = [summary, depts, salary, cgpa, monthly, gender, scatter].some((d) => d.loading);

  if (loading) return <Spinner />;

  const s = summary.data || {};

  return (
    <div className="page">
      <div className="page-title">Dashboard</div>
      <div className="page-subtitle">Overview of student placement statistics</div>

      {/* KPI Cards */}
      <div className="kpi-grid">
        <KpiCard icon="🎓" label="Total Students"      value={s.total_students}         color="blue"   sub="Enrolled" />
        <KpiCard icon="✅" label="Placed Students"     value={s.placed_students}        color="green"  sub={`${s.placement_percentage}% placed`} />
        <KpiCard icon="⏳" label="Unplaced Students"  value={s.unplaced_students}       color="red"    sub="Seeking placement" />
        <KpiCard icon="💰" label="Avg Package"         value={`₹${s.average_package_lpa} LPA`}  color="amber"  sub="Among placed" />
        <KpiCard icon="🏆" label="Highest Package"     value={`₹${s.highest_package_lpa} LPA`} color="indigo" sub="Best offer" />
        <KpiCard icon="📉" label="Median Package"      value={`₹${s.median_package_lpa} LPA`}  color="blue"   sub="50th percentile" />
      </div>

      {/* Row 1 */}
      <div className="charts-grid">
        {/* Department placements */}
        <div className="chart-card">
          <h3>Department-wise Placements</h3>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={depts.data} margin={{ left: -10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="department" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Bar dataKey="placed"   name="Placed"   fill="#3b82f6" radius={[4,4,0,0]} />
              <Bar dataKey="unplaced" name="Unplaced" fill="#f43f5e" radius={[4,4,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Salary distribution */}
        <div className="chart-card">
          <h3>Salary Distribution</h3>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={salary.data} margin={{ left: -10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="range" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="count" name="Students" fill="#10b981" radius={[4,4,0,0]}>
                {salary.data?.map((_, i) => (
                  <Cell key={i} fill={BAR_COLORS[i % BAR_COLORS.length]} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Row 2 */}
      <div className="charts-grid">
        {/* Monthly trend */}
        <div className="chart-card">
          <h3>Monthly Placement Trend</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={monthly.data} margin={{ left: -10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="month" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Line
                type="monotone" dataKey="placements" name="Placements"
                stroke="#3b82f6" strokeWidth={2} dot={{ r: 4 }} activeDot={{ r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* CGPA distribution */}
        <div className="chart-card">
          <h3>CGPA Distribution</h3>
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={cgpa.data} margin={{ left: -10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="range" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="count" name="Students" fill="#8b5cf6" radius={[4,4,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Row 3 */}
      <div className="charts-grid">
        {/* Gender placement pie */}
        <div className="chart-card">
          <h3>Gender-wise Placement</h3>
          <ResponsiveContainer width="100%" height={240}>
            <PieChart>
              <Pie
                data={gender.data}
                dataKey="placed"
                nameKey="gender"
                cx="50%" cy="50%"
                outerRadius={90}
                label={({ gender: g, placement_percentage: p }) => `${g} (${p}%)`}
                labelLine={false}
              >
                {gender.data?.map((_, i) => (
                  <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(val, name) => [val, "Placed"]} />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* CGPA vs Package scatter */}
        <div className="chart-card">
          <h3>CGPA vs Package (Scatter)</h3>
          <ResponsiveContainer width="100%" height={240}>
            <ScatterChart margin={{ left: -10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="cgpa"    name="CGPA"    type="number" domain={[6, 10]} tick={{ fontSize: 12 }} label={{ value: "CGPA", position: "insideBottomRight", offset: -4, fontSize: 11 }} />
              <YAxis dataKey="package" name="Package" type="number" tick={{ fontSize: 12 }} label={{ value: "LPA", angle: -90, position: "insideLeft", fontSize: 11 }} />
              <ZAxis range={[40, 40]} />
              <Tooltip cursor={{ strokeDasharray: "3 3" }} formatter={(v, n) => [n === "Package" ? `₹${v} LPA` : v, n]} />
              <Scatter data={scatter.data} fill="#3b82f6" fillOpacity={0.7} />
            </ScatterChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
