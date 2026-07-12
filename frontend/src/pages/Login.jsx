import React, { useState, useEffect } from "react";
import { useNavigate, Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import "./Login.css";

export default function Login() {
  const { user, login } = useAuth();
  const navigate = useNavigate();

  const [form, setForm]         = useState({ username: "", password: "" });
  const [error, setError]       = useState("");
  const [loading, setLoading]   = useState(false);
  const [showPw, setShowPw]     = useState(false);
  const [focused, setFocused]   = useState("");
  const [particles, setParticles] = useState([]);

  useEffect(() => {
    const pts = Array.from({ length: 18 }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      size: Math.random() * 3 + 1,
      dur: Math.random() * 10 + 8,
      delay: Math.random() * 6,
    }));
    setParticles(pts);
  }, []);

  if (user) return <Navigate to="/dashboard" replace />;

  function handleChange(e) {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setError("");
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.username || !form.password) {
      setError("Please enter both username and password.");
      return;
    }
    setLoading(true);
    try {
      await login(form.username.trim(), form.password);
      navigate("/dashboard", { replace: true });
    } catch (err) {
      setError(err?.response?.data?.error || "Invalid credentials. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  function quickFill(u, p) { setForm({ username: u, password: p }); setError(""); }

  const stats = [
    { icon: "🎓", value: "100+", label: "Students" },
    { icon: "🏢", value: "50+",  label: "Companies" },
    { icon: "✅", value: "80%",  label: "Placed" },
    { icon: "💰", value: "₹22L", label: "Top Package" },
  ];

  return (
    <div className="lp-root">
      {/* animated particles */}
      {particles.map((p) => (
        <span key={p.id} className="lp-particle"
          style={{ left: `${p.x}%`, top: `${p.y}%`, width: p.size, height: p.size,
            animationDuration: `${p.dur}s`, animationDelay: `${p.delay}s` }} />
      ))}

      {/* glow orbs */}
      <div className="lp-orb lp-orb1" />
      <div className="lp-orb lp-orb2" />
      <div className="lp-orb lp-orb3" />

      {/* grid lines */}
      <div className="lp-grid" />

      <div className="lp-inner">
        {/* ── LEFT PANEL ── */}
        <div className="lp-left">
          <div className="lp-logo">
            <div className="lp-logo-icon">📈</div>
            <span className="lp-logo-text">PlaceTrack</span>
          </div>

          <div className="lp-hero">
            <div className="lp-badge">✦ Analytics Platform</div>
            <h1 className="lp-title">
              Turn Data Into<br />
              <span className="lp-title-grad">Career Insights</span>
            </h1>
            <p className="lp-desc">
              Visualise placement trends, identify skill gaps, and predict
              student outcomes with real-time analytics.
            </p>
          </div>

          <div className="lp-stats">
            {stats.map((s) => (
              <div key={s.label} className="lp-stat">
                <span className="lp-stat-icon">{s.icon}</span>
                <span className="lp-stat-val">{s.value}</span>
                <span className="lp-stat-lbl">{s.label}</span>
              </div>
            ))}
          </div>

          <div className="lp-features">
            {["Real-time dashboard", "ML placement predictor", "Skill gap analysis", "Company analytics"].map((f) => (
              <div key={f} className="lp-feature-item">
                <span className="lp-feature-dot" />
                {f}
              </div>
            ))}
          </div>
        </div>

        {/* ── RIGHT PANEL ── */}
        <div className="lp-right">
          <div className="lp-card">
            <div className="lp-card-top">
              <div className="lp-avatar">👤</div>
              <h2 className="lp-card-title">Sign In</h2>
              <p className="lp-card-sub">Access your analytics dashboard</p>
            </div>

            {error && (
              <div className="lp-error">
                <span>⚠</span> {error}
              </div>
            )}

            <form onSubmit={handleSubmit} noValidate>
              <div className={`lp-field ${focused === "username" ? "lp-field--focus" : ""}`}>
                <label htmlFor="username">
                  <span className="lp-field-icon">👤</span> Username
                </label>
                <input id="username" name="username" type="text"
                  placeholder="Enter username"
                  value={form.username} onChange={handleChange}
                  onFocus={() => setFocused("username")}
                  onBlur={() => setFocused("")}
                  autoComplete="username" autoFocus />
              </div>

              <div className={`lp-field ${focused === "password" ? "lp-field--focus" : ""}`}>
                <label htmlFor="password">
                  <span className="lp-field-icon">🔒</span> Password
                </label>
                <div className="lp-pw-wrap">
                  <input id="password" name="password"
                    type={showPw ? "text" : "password"}
                    placeholder="Enter password"
                    value={form.password} onChange={handleChange}
                    onFocus={() => setFocused("password")}
                    onBlur={() => setFocused("")}
                    autoComplete="current-password" />
                  <button type="button" className="lp-pw-eye"
                    onClick={() => setShowPw((v) => !v)}
                    aria-label="Toggle password">
                    {showPw ? "🙈" : "👁️"}
                  </button>
                </div>
              </div>

              <button type="submit" className={`lp-btn ${loading ? "lp-btn--loading" : ""}`} disabled={loading}>
                {loading
                  ? <><span className="lp-spinner" /> Signing in…</>
                  : <><span>Sign In</span><span className="lp-btn-arrow">→</span></>}
              </button>
            </form>

            <div className="lp-divider"><span>Demo Account</span></div>

            <div className="lp-creds">
              <button className="lp-cred-btn" onClick={() => quickFill("admin", "admin123")}>
                <span className="lp-cred-role">🛡️ Admin</span>
                <span className="lp-cred-val">admin / admin123</span>
                <span className="lp-cred-hint">click to fill</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
