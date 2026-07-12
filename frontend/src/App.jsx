import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import Layout   from "./components/Layout";
import Login    from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Students  from "./pages/Students";
import Companies from "./pages/Companies";
import SkillGap  from "./pages/SkillGap";
import Predict   from "./pages/Predict";

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<Layout />}>
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/students"  element={<Students />} />
            <Route path="/companies" element={<Companies />} />
            <Route path="/skills"    element={<SkillGap />} />
            <Route path="/predict"   element={<Predict />} />
          </Route>
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
