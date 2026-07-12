-- ============================================================
--  Student Placement Data Analytics — Database Schema
--  Run: mysql -u root -p < database/schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS placement_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE placement_db;

-- ============================================================
--  Main Students Table
-- ============================================================
CREATE TABLE IF NOT EXISTS students (
    id               INT PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    gender           VARCHAR(10) NOT NULL,
    department       VARCHAR(20) NOT NULL,
    cgpa             DECIMAL(4,2) NOT NULL,
    backlogs         INT NOT NULL DEFAULT 0,
    internship       VARCHAR(5) NOT NULL,
    projects         INT NOT NULL DEFAULT 0,
    skills           VARCHAR(500),
    company          VARCHAR(100),
    package_lpa      DECIMAL(5,2),
    placement_month  VARCHAR(20),
    placement_year   INT,
    is_placed        VARCHAR(5) NOT NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_cgpa CHECK (cgpa BETWEEN 0 AND 10),
    CONSTRAINT chk_backlogs CHECK (backlogs >= 0),
    CONSTRAINT chk_projects CHECK (projects >= 0),
    CONSTRAINT chk_package CHECK (package_lpa IS NULL OR package_lpa > 0),
    CONSTRAINT chk_is_placed CHECK (is_placed IN ('true', 'false'))
);

-- ============================================================
--  Indexes for Performance Optimization
-- ============================================================
CREATE INDEX idx_department ON students(department);
CREATE INDEX idx_is_placed ON students(is_placed);
CREATE INDEX idx_company ON students(company);
CREATE INDEX idx_cgpa ON students(cgpa);
CREATE INDEX idx_package ON students(package_lpa);
CREATE INDEX idx_placement_year ON students(placement_year);
CREATE INDEX idx_placement_month ON students(placement_month);
CREATE INDEX idx_gender ON students(gender);

-- Composite indexes for common analytics queries
CREATE INDEX idx_dept_placed ON students(department, is_placed);
CREATE INDEX idx_company_package ON students(company, package_lpa);
CREATE INDEX idx_year_month ON students(placement_year, placement_month);

-- ============================================================
--  Analytics Views
-- ============================================================

-- Department-wise summary view
CREATE OR REPLACE VIEW vw_department_summary AS
SELECT 
    department,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN cgpa END), 2) AS avg_cgpa_placed,
    ROUND(AVG(CASE WHEN is_placed = 'false' THEN cgpa END), 2) AS avg_cgpa_unplaced,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
    MAX(CASE WHEN is_placed = 'true' THEN package_lpa END) AS max_package,
    MIN(CASE WHEN is_placed = 'true' THEN package_lpa END) AS min_package
FROM students
GROUP BY department;

-- Company-wise hiring summary view
CREATE OR REPLACE VIEW vw_company_summary AS
SELECT 
    company,
    COUNT(*) AS students_hired,
    ROUND(AVG(package_lpa), 2) AS avg_package,
    MAX(package_lpa) AS max_package,
    MIN(package_lpa) AS min_package,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    COUNT(DISTINCT department) AS departments_hired_from
FROM students
WHERE is_placed = 'true' AND company IS NOT NULL
GROUP BY company
ORDER BY students_hired DESC;

-- Monthly placement trend view
CREATE OR REPLACE VIEW vw_monthly_trend AS
SELECT 
    placement_year,
    placement_month,
    COUNT(*) AS placements,
    ROUND(AVG(package_lpa), 2) AS avg_package,
    ROUND(AVG(cgpa), 2) AS avg_cgpa
FROM students
WHERE is_placed = 'true' AND placement_year IS NOT NULL
GROUP BY placement_year, placement_month
ORDER BY placement_year, FIELD(placement_month,
    'January','February','March','April','May','June',
    'July','August','September','October','November','December');

-- Salary distribution view
CREATE OR REPLACE VIEW vw_salary_distribution AS
SELECT 
    CASE
        WHEN package_lpa <= 4  THEN '0-4 LPA'
        WHEN package_lpa <= 6  THEN '4-6 LPA'
        WHEN package_lpa <= 8  THEN '6-8 LPA'
        WHEN package_lpa <= 10 THEN '8-10 LPA'
        WHEN package_lpa <= 15 THEN '10-15 LPA'
        ELSE '15+ LPA'
    END AS salary_range,
    COUNT(*) AS student_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM students
WHERE is_placed = 'true' AND package_lpa IS NOT NULL
GROUP BY salary_range
ORDER BY MIN(package_lpa);

-- CGPA distribution view
CREATE OR REPLACE VIEW vw_cgpa_distribution AS
SELECT 
    CASE
        WHEN cgpa < 6 THEN 'Below 6.0'
        WHEN cgpa < 7 THEN '6.0-6.9'
        WHEN cgpa < 8 THEN '7.0-7.9'
        WHEN cgpa < 9 THEN '8.0-8.9'
        ELSE '9.0-10.0'
    END AS cgpa_range,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate
FROM students
GROUP BY cgpa_range
ORDER BY MIN(cgpa);

-- Gender-wise placement view
CREATE OR REPLACE VIEW vw_gender_summary AS
SELECT 
    gender,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
GROUP BY gender;

-- Skills analysis view
CREATE OR REPLACE VIEW vw_skills_analysis AS
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(skills, ',', n), ',', -1)) AS skill,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_with_skill,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate_with_skill,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package_with_skill
FROM students
CROSS JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) numbers
WHERE skills IS NOT NULL 
  AND skills != '' 
  AND n <= LENGTH(skills) - LENGTH(REPLACE(skills, ',', '')) + 1
GROUP BY skill
ORDER BY placed_with_skill DESC;

-- ============================================================
--  Stored Procedures for Analytics
-- ============================================================

DELIMITER //

-- Procedure to get comprehensive dashboard summary
CREATE PROCEDURE sp_get_dashboard_summary()
BEGIN
    -- Overall statistics
    SELECT 
        'overall' AS category,
        COUNT(*) AS total_students,
        SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
        SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced_count,
        ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
        ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
        MAX(CASE WHEN is_placed = 'true' THEN package_lpa END) AS max_package,
        MIN(CASE WHEN is_placed = 'true' THEN package_lpa END) AS min_package,
        ROUND(AVG(cgpa), 2) AS avg_cgpa
    FROM students;
    
    -- Department statistics
    SELECT * FROM vw_department_summary;
    
    -- Company statistics
    SELECT * FROM vw_company_summary LIMIT 10;
END //

-- Procedure to analyze skill gaps
CREATE PROCEDURE sp_analyze_skill_gaps()
BEGIN
    -- Skills of placed students
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(skills, ',', n), ',', -1)) AS skill,
        COUNT(*) AS placed_students_with_skill,
        ROUND(AVG(package_lpa), 2) AS avg_package_with_skill
    FROM students
    CROSS JOIN (
        SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
        SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    ) numbers
    WHERE is_placed = 'true' 
      AND skills IS NOT NULL 
      AND skills != '' 
      AND n <= LENGTH(skills) - LENGTH(REPLACE(skills, ',', '')) + 1
    GROUP BY skill
    ORDER BY placed_students_with_skill DESC
    LIMIT 15;
    
    -- Skills of unplaced students
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(skills, ',', n), ',', -1)) AS skill,
        COUNT(*) AS unplaced_students_with_skill
    FROM students
    CROSS JOIN (
        SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
        SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    ) numbers
    WHERE is_placed = 'false' 
      AND skills IS NOT NULL 
      AND skills != '' 
      AND n <= LENGTH(skills) - LENGTH(REPLACE(skills, ',', '')) + 1
    GROUP BY skill
    ORDER BY unplaced_students_with_skill DESC
    LIMIT 15;
END //

-- Procedure to get placement predictions
CREATE PROCEDURE sp_predict_placement(IN p_cgpa DECIMAL(4,2), IN p_backlogs INT, IN p_projects INT, IN p_internship VARCHAR(5))
BEGIN
    SELECT 
        p_cgpa AS input_cgpa,
        p_backlogs AS input_backlogs,
        p_projects AS input_projects,
        p_internship AS input_internship,
        CASE 
            WHEN p_cgpa >= 8.5 AND p_backlogs = 0 AND p_projects >= 3 AND p_internship = 'Yes' THEN 'High'
            WHEN p_cgpa >= 7.5 AND p_backlogs <= 1 AND p_projects >= 2 AND p_internship = 'Yes' THEN 'Medium'
            WHEN p_cgpa >= 6.5 AND p_backlogs <= 2 AND p_projects >= 1 THEN 'Medium-Low'
            ELSE 'Low'
        END AS predicted_probability,
        ROUND(
            (CASE 
                WHEN p_cgpa >= 8.5 AND p_backlogs = 0 AND p_projects >= 3 AND p_internship = 'Yes' THEN 0.85
                WHEN p_cgpa >= 7.5 AND p_backlogs <= 1 AND p_projects >= 2 AND p_internship = 'Yes' THEN 0.70
                WHEN p_cgpa >= 6.5 AND p_backlogs <= 2 AND p_projects >= 1 THEN 0.50
                ELSE 0.30
            END) * 100, 0
        ) AS placement_probability_percentage;
END //

DELIMITER ;
