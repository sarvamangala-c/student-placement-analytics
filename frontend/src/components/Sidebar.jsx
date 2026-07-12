import React from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const NAV = [
  { to: "/dashboard",  icon: "📊", label: "Dashboard" },
  { to: "/students",   icon: "🎓", label: "Students" },
  { to: "/companies",  icon: "🏢", label: "Companies" },
  { to: "/skills",     icon: "🧠", label: "Skill Gap" },
  { to: "/predict",    icon: "🤖", label: "Predict" },
];

export default function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  function handleLogout() {
    logout();
    navigate("/login");
  }

  return (
    <aside className="sidebar">
      <div className="sidebar-logo">
        <div className="logo-title">📈 PlaceTrack</div>
        <div className="logo-sub">Placement Analytics</div>
      </div>

      <nav className="sidebar-nav">
        {NAV.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}
          >
            <span className="nav-icon">{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="user-info">
          <div className="user-name">{user?.name}</div>
          <div className="user-role">{user?.role === "admin" ? "Administrator" : "Student"}</div>
        </div>
        <button className="nav-item btn-logout" onClick={handleLogout}
          style={{ width: "100%", background: "transparent", border: "none", cursor: "pointer", color: "#f87171" }}>
          <span className="nav-icon">🚪</span> Logout
        </button>
      </div>
    </aside>
  );
}
