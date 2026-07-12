import axios from "axios";

const api = axios.create({
  baseURL: "/api",
  timeout: 15000,
  headers: { "Content-Type": "application/json" },
});

// Attach auth token to every request
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("spa_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// ── Dashboard endpoints ───────────────────────────────────────
export const getDashboardSummary     = () => api.get("/dashboard/summary");
export const getDepartmentStats      = () => api.get("/dashboard/departments");
export const getSalaryDistribution   = () => api.get("/dashboard/salary-distribution");
export const getCgpaDistribution     = () => api.get("/dashboard/cgpa-distribution");
export const getMonthlyTrend         = () => api.get("/dashboard/monthly-trend");
export const getGenderStats          = () => api.get("/dashboard/gender-stats");
export const getCgpaVsPackage        = () => api.get("/dashboard/cgpa-vs-package");

// ── Students endpoints ────────────────────────────────────────
export const getStudents     = (params) => api.get("/students/", { params });
export const getStudent      = (id)     => api.get(`/students/${id}`);

// ── Companies endpoints ───────────────────────────────────────
export const getCompanies    = (params) => api.get("/companies/", { params });
export const getCompanyStudents = (name) => api.get(`/companies/${encodeURIComponent(name)}/students`);

// ── Analytics endpoints ───────────────────────────────────────
export const getSkillStats        = ()     => api.get("/analytics/skills");
export const predictPlacement     = (body) => api.post("/analytics/predict", body);
export const getFeatureImportance = ()     => api.get("/analytics/feature-importance");

export default api;
