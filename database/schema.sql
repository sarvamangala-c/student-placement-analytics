-- ============================================================
--  Student Placement Analytics — Create Database & Tables
--  Run: mysql -u root -p < database/schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS placement_db;

USE placement_db;

-- Students table
CREATE TABLE IF NOT EXISTS students (
    id               INT PRIMARY KEY,
    name             VARCHAR(100),
    gender           VARCHAR(10),
    department       VARCHAR(20),
    cgpa             DECIMAL(4,2),
    backlogs         INT,
    internship       VARCHAR(5),
    projects         INT,
    skills           VARCHAR(300),
    company          VARCHAR(100),
    package_lpa      DECIMAL(5,2),
    placement_month  VARCHAR(20),
    placement_year   INT,
    is_placed        VARCHAR(5)
);
