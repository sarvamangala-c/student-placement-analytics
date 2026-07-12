import React from "react";

/**
 * @param {string} label
 * @param {string|number} value
 * @param {string} [sub]
 * @param {"blue"|"green"|"red"|"amber"|"indigo"} [color]
 * @param {string} [icon]
 */
export default function KpiCard({ label, value, sub, color = "blue", icon }) {
  return (
    <div className={`kpi-card ${color}`}>
      <div className="kpi-label">{icon && <span style={{ marginRight: 4 }}>{icon}</span>}{label}</div>
      <div className="kpi-value">{value}</div>
      {sub && <div className="kpi-sub">{sub}</div>}
    </div>
  );
}
