-- ============================================================
--  Student Placement Data Analytics — Advanced Analytics Queries
--  Run these queries in MySQL Workbench or CLI for insights
-- ============================================================

USE placement_db;

-- ============================================================
--  DESCRIPTIVE STATISTICS
-- ============================================================

-- 1. Overall placement statistics
SELECT
    COUNT(*)                                    AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed,
    SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_pct,
    ROUND(AVG(cgpa), 2)                         AS avg_cgpa,
    ROUND(STDDEV(cgpa), 2)                      AS cgpa_std_dev,
    ROUND(AVG(backlogs), 2)                     AS avg_backlogs,
    ROUND(AVG(projects), 2)                     AS avg_projects
FROM students;

-- 2. Package statistics for placed students
SELECT
    ROUND(AVG(package_lpa), 2)  AS avg_package,
    ROUND(MEDIAN(package_lpa), 2) AS median_package,
    MAX(package_lpa)            AS highest_package,
    MIN(package_lpa)            AS lowest_package,
    ROUND(STDDEV(package_lpa), 2) AS package_std_dev,
    ROUND(VARIANCE(package_lpa), 2) AS package_variance
FROM students
WHERE is_placed = 'true';

-- 3. CGPA statistics by placement status
SELECT
    is_placed,
    COUNT(*)                AS student_count,
    ROUND(AVG(cgpa), 2)     AS avg_cgpa,
    ROUND(MIN(cgpa), 2)     AS min_cgpa,
    ROUND(MAX(cgpa), 2)     AS max_cgpa,
    ROUND(STDDEV(cgpa), 2)  AS cgpa_std_dev
FROM students
GROUP BY is_placed;

-- ============================================================
--  DEPARTMENT ANALYTICS
-- ============================================================

-- 4. Department-wise comprehensive analysis
SELECT
    department,
    COUNT(*)                        AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed,
    SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(cgpa), 2)             AS avg_cgpa,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN cgpa END), 2) AS avg_cgpa_placed,
    ROUND(AVG(CASE WHEN is_placed = 'false' THEN cgpa END), 2) AS avg_cgpa_unplaced,
    ROUND(AVG(backlogs), 2)         AS avg_backlogs,
    ROUND(AVG(projects), 2)         AS avg_projects,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
    MAX(CASE WHEN is_placed = 'true' THEN package_lpa END) AS max_package,
    MIN(CASE WHEN is_placed = 'true' THEN package_lpa END) AS min_package
FROM students
GROUP BY department
ORDER BY placement_rate DESC;

-- 5. Department performance ranking
SELECT
    department,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
    RANK() OVER (ORDER BY SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC) AS placement_rank,
    RANK() OVER (ORDER BY AVG(CASE WHEN is_placed = 'true' THEN package_lpa) DESC) AS package_rank
FROM students
GROUP BY department;

-- ============================================================
--  COMPANY ANALYTICS
-- ============================================================

-- 6. Company-wise hiring analysis (top 15)
SELECT
    company,
    COUNT(*)                    AS students_hired,
    ROUND(AVG(package_lpa), 2)  AS avg_package,
    MAX(package_lpa)            AS max_package,
    MIN(package_lpa)            AS min_package,
    ROUND(AVG(cgpa), 2)         AS avg_cgpa,
    ROUND(AVG(backlogs), 2)    AS avg_backlogs,
    COUNT(DISTINCT department)  AS departments_hired_from,
    ROUND(AVG(projects), 2)    AS avg_projects
FROM students
WHERE is_placed = 'true' AND company IS NOT NULL
GROUP BY company
ORDER BY students_hired DESC
LIMIT 15;

-- 7. Company salary brackets
SELECT
    company,
    COUNT(*) AS total_hired,
    SUM(CASE WHEN package_lpa <= 5 THEN 1 ELSE 0 END) AS low_salary_3_5_lpa,
    SUM(CASE WHEN package_lpa > 5 AND package_lpa <= 8 THEN 1 ELSE 0 END) AS mid_salary_5_8_lpa,
    SUM(CASE WHEN package_lpa > 8 AND package_lpa <= 12 THEN 1 ELSE 0 END) AS high_salary_8_12_lpa,
    SUM(CASE WHEN package_lpa > 12 THEN 1 ELSE 0 END) AS very_high_salary_12_plus_lpa
FROM students
WHERE is_placed = 'true' AND company IS NOT NULL
GROUP BY company
ORDER BY total_hired DESC
LIMIT 10;

-- 8. Company department preferences
SELECT
    company,
    department,
    COUNT(*) AS students_hired,
    ROUND(AVG(package_lpa), 2) AS avg_package
FROM students
WHERE is_placed = 'true' AND company IS NOT NULL
GROUP BY company, department
ORDER BY company, students_hired DESC;

-- ============================================================
--  TEMPORAL ANALYSIS
-- ============================================================

-- 9. Monthly placement trends with year-over-year comparison
SELECT
    placement_month,
    placement_year,
    COUNT(*) AS placements,
    ROUND(AVG(package_lpa), 2) AS avg_package,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    LAG(COUNT(*)) OVER (PARTITION BY placement_month ORDER BY placement_year) AS previous_year_placements,
    ROUND((COUNT(*) - LAG(COUNT(*)) OVER (PARTITION BY placement_month ORDER BY placement_year)) * 100.0 / 
          NULLIF(LAG(COUNT(*)) OVER (PARTITION BY placement_month ORDER BY placement_year), 0), 2) AS year_over_year_growth
FROM students
WHERE is_placed = 'true' AND placement_year IS NOT NULL
GROUP BY placement_year, placement_month
ORDER BY placement_year, FIELD(placement_month,
    'January','February','March','April','May','June',
    'July','August','September','October','November','December');

-- 10. Quarterly placement analysis
SELECT
    CASE 
        WHEN placement_month IN ('January','February','March') THEN 'Q1'
        WHEN placement_month IN ('April','May','June') THEN 'Q2'
        WHEN placement_month IN ('July','August','September') THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    placement_year,
    COUNT(*) AS placements,
    ROUND(AVG(package_lpa), 2) AS avg_package,
    ROUND(AVG(cgpa), 2) AS avg_cgpa
FROM students
WHERE is_placed = 'true' AND placement_year IS NOT NULL
GROUP BY placement_year, quarter
ORDER BY placement_year, quarter;

-- ============================================================
--  DISTRIBUTION ANALYSIS
-- ============================================================

-- 11. Salary distribution with percentiles
SELECT
    CASE
        WHEN package_lpa <= 4  THEN '0-4 LPA'
        WHEN package_lpa <= 6  THEN '4-6 LPA'
        WHEN package_lpa <= 8  THEN '6-8 LPA'
        WHEN package_lpa <= 10 THEN '8-10 LPA'
        WHEN package_lpa <= 15 THEN '10-15 LPA'
        ELSE '15+ LPA'
    END          AS salary_range,
    COUNT(*)     AS students,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(cgpa), 2) AS avg_cgpa_in_range
FROM students
WHERE is_placed = 'true'
GROUP BY salary_range
ORDER BY MIN(package_lpa);

-- 12. CGPA distribution with placement rates
SELECT
    CASE
        WHEN cgpa < 6 THEN 'Below 6.0'
        WHEN cgpa < 7 THEN '6.0-6.9'
        WHEN cgpa < 8 THEN '7.0-7.9'
        WHEN cgpa < 9 THEN '8.0-8.9'
        ELSE '9.0-10.0'
    END       AS cgpa_range,
    COUNT(*)  AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
GROUP BY cgpa_range
ORDER BY MIN(cgpa);

-- 13. Backlogs impact analysis
SELECT
    backlogs,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
GROUP BY backlogs
ORDER BY backlogs;

-- ============================================================
--  CORRELATION ANALYSIS
-- ============================================================

-- 14. CGPA vs Package correlation analysis
SELECT
    CASE
        WHEN cgpa < 6 THEN 'Below 6.0'
        WHEN cgpa < 7 THEN '6.0-6.9'
        WHEN cgpa < 8 THEN '7.0-7.9'
        WHEN cgpa < 9 THEN '8.0-8.9'
        ELSE '9.0-10.0'
    END AS cgpa_range,
    COUNT(*) AS students,
    ROUND(AVG(package_lpa), 2) AS avg_package,
    ROUND(MIN(package_lpa), 2) AS min_package,
    ROUND(MAX(package_lpa), 2) AS max_package,
    ROUND(STDDEV(package_lpa), 2) AS package_std_dev
FROM students
WHERE is_placed = 'true'
GROUP BY cgpa_range
ORDER BY MIN(cgpa);

-- 15. Projects vs Placement correlation
SELECT
    projects,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
GROUP BY projects
ORDER BY projects;

-- 16. Internship impact analysis
SELECT
    internship,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
    ROUND(AVG(projects), 2) AS avg_projects
FROM students
GROUP BY internship;

-- ============================================================
--  SKILLS ANALYSIS
-- ============================================================

-- 17. Top 20 most demanded skills
SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(skills, ',', n), ',', -1)) AS skill,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_with_skill,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate_with_skill,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package_with_skill,
    ROUND(AVG(cgpa), 2) AS avg_cgpa_with_skill
FROM students
CROSS JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) numbers
WHERE skills IS NOT NULL 
  AND skills != '' 
  AND n <= LENGTH(skills) - LENGTH(REPLACE(skills, ',', '')) + 1
GROUP BY skill
ORDER BY placed_with_skill DESC
LIMIT 20;

-- 18. Skills gap analysis: Placed vs Unplaced
SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(skills, ',', n), ',', -1)) AS skill,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_students,
    SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced_students,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package_placed,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) + SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END), 0), 2) AS skill_placement_rate
FROM students
CROSS JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) numbers
WHERE skills IS NOT NULL 
  AND skills != '' 
  AND n <= LENGTH(skills) - LENGTH(REPLACE(skills, ',', '')) + 1
GROUP BY skill
HAVING SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) > 0
   OR SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) > 0
ORDER BY placed_students DESC;

-- 19. Skill combinations analysis
SELECT
    skills,
    COUNT(*) AS students_with_combination,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
WHERE skills IS NOT NULL AND skills != ''
GROUP BY skills
HAVING COUNT(*) >= 2
ORDER BY placement_rate DESC, students_with_combination DESC
LIMIT 15;

-- ============================================================
--  DEMOGRAPHIC ANALYSIS
-- ============================================================

-- 20. Gender-wise comprehensive analysis
SELECT
    gender,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    SUM(CASE WHEN is_placed = 'false' THEN 1 ELSE 0 END) AS unplaced_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
    ROUND(AVG(backlogs), 2) AS avg_backlogs,
    ROUND(AVG(projects), 2) AS avg_projects
FROM students
GROUP BY gender;

-- 21. Gender-wise department analysis
SELECT
    gender,
    department,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
GROUP BY gender, department
ORDER BY department, gender;

-- ============================================================
--  ADVANCED ANALYTICS
-- ============================================================

-- 22. Student risk analysis (students at risk of not being placed)
SELECT
    id,
    name,
    department,
    cgpa,
    backlogs,
    projects,
    internship,
    skills,
    CASE 
        WHEN cgpa < 6.5 OR backlogs >= 2 OR (projects <= 1 AND internship = 'No') THEN 'High Risk'
        WHEN cgpa < 7.5 OR backlogs >= 1 OR (projects <= 2 AND internship = 'No') THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level,
    CASE 
        WHEN cgpa < 6.5 THEN 'Low CGPA'
        WHEN backlogs >= 2 THEN 'High Backlogs'
        WHEN projects <= 1 AND internship = 'No' THEN 'No Experience'
        ELSE 'Multiple Factors'
    END AS primary_risk_factor
FROM students
WHERE is_placed = 'false'
ORDER BY 
    CASE 
        WHEN cgpa < 6.5 OR backlogs >= 2 OR (projects <= 1 AND internship = 'No') THEN 1
        WHEN cgpa < 7.5 OR backlogs >= 1 OR (projects <= 2 AND internship = 'No') THEN 2
        ELSE 3
    END,
    cgpa DESC;

-- 23. High performers analysis (placed with high packages)
SELECT
    id,
    name,
    department,
    cgpa,
    company,
    package_lpa,
    projects,
    internship,
    skills,
    RANK() OVER (ORDER BY package_lpa DESC) AS salary_rank
FROM students
WHERE is_placed = 'true' AND package_lpa >= 10
ORDER BY package_lpa DESC;

-- 24. Placement probability estimation (statistical model)
SELECT
    id,
    name,
    department,
    cgpa,
    backlogs,
    projects,
    internship,
    is_placed,
    -- Simple probability model based on historical patterns
    ROUND(
        (CASE 
            WHEN cgpa >= 8.5 AND backlogs = 0 AND projects >= 3 AND internship = 'Yes' THEN 0.85
            WHEN cgpa >= 8.0 AND backlogs = 0 AND projects >= 2 AND internship = 'Yes' THEN 0.80
            WHEN cgpa >= 7.5 AND backlogs <= 1 AND projects >= 2 AND internship = 'Yes' THEN 0.70
            WHEN cgpa >= 7.0 AND backlogs <= 1 AND projects >= 1 THEN 0.60
            WHEN cgpa >= 6.5 AND backlogs <= 2 AND projects >= 1 THEN 0.45
            WHEN cgpa >= 6.0 AND backlogs <= 2 THEN 0.35
            ELSE 0.25
        END) * 100, 0
    ) AS estimated_placement_probability,
    CASE 
        WHEN is_placed = 'true' THEN 'Actually Placed'
        ELSE 'Not Placed'
    END AS actual_status
FROM students
ORDER BY estimated_placement_probability DESC;

-- 25. Department benchmarking
SELECT
    department,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_count,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package,
    -- Compare with overall average
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) - 
    (SELECT ROUND(AVG(package_lpa), 2) FROM students WHERE is_placed = 'true') AS package_vs_overall,
    ROUND(AVG(cgpa), 2) AS avg_cgpa,
    -- Compare with overall average
    ROUND(AVG(cgpa), 2) - 
    (SELECT ROUND(AVG(cgpa), 2) FROM students) AS cgpa_vs_overall
FROM students
GROUP BY department
ORDER BY placement_rate DESC;

-- ============================================================
--  DATA QUALITY CHECKS
-- ============================================================

-- 26. Data completeness check
SELECT
    'id' AS field_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN id IS NOT NULL THEN 1 ELSE 0 END) AS non_null_count,
    ROUND(SUM(CASE WHEN id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completeness_percentage
FROM students
UNION ALL
SELECT
    'name', COUNT(*), SUM(CASE WHEN name IS NOT NULL AND name != '' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN name IS NOT NULL AND name != '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM students
UNION ALL
SELECT
    'cgpa', COUNT(*), SUM(CASE WHEN cgpa IS NOT NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN cgpa IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM students
UNION ALL
SELECT
    'skills', COUNT(*), SUM(CASE WHEN skills IS NOT NULL AND skills != '' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN skills IS NOT NULL AND skills != '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM students;

-- 27. Outlier detection in CGPA
SELECT
    id,
    name,
    department,
    cgpa,
    is_placed,
    CASE 
        WHEN cgpa < (SELECT AVG(cgpa) - 2 * STDDEV(cgpa) FROM students) THEN 'Low Outlier'
        WHEN cgpa > (SELECT AVG(cgpa) + 2 * STDDEV(cgpa) FROM students) THEN 'High Outlier'
        ELSE 'Normal'
    END AS cgpa_status
FROM students
ORDER BY cgpa;

-- 28. Outlier detection in Package
SELECT
    id,
    name,
    company,
    package_lpa,
    CASE 
        WHEN package_lpa < (SELECT AVG(package_lpa) - 2 * STDDEV(package_lpa) FROM students WHERE is_placed = 'true') THEN 'Low Outlier'
        WHEN package_lpa > (SELECT AVG(package_lpa) + 2 * STDDEV(package_lpa) FROM students WHERE is_placed = 'true') THEN 'High Outlier'
        ELSE 'Normal'
    END AS package_status
FROM students
WHERE is_placed = 'true'
ORDER BY package_lpa;
