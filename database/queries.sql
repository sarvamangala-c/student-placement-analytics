-- ============================================================
--  Useful analytics queries — run in MySQL Workbench or CLI
-- ============================================================

USE placement_db;

-- 1. Total / placed / unplaced count
SELECT
    COUNT(*)                                    AS total_students,
    SUM(is_placed = 'true')                     AS placed,
    SUM(is_placed = 'false')                    AS unplaced,
    ROUND(SUM(is_placed = 'true') * 100.0 / COUNT(*), 2) AS placement_pct
FROM students;

-- 2. Average, highest, lowest package
SELECT
    ROUND(AVG(package_lpa), 2)  AS avg_package,
    MAX(package_lpa)            AS highest_package,
    MIN(package_lpa)            AS lowest_package
FROM students
WHERE is_placed = 'true';

-- 3. Department-wise placement
SELECT
    department,
    COUNT(*)                        AS total,
    SUM(is_placed = 'true')         AS placed,
    SUM(is_placed = 'false')        AS unplaced,
    ROUND(AVG(package_lpa), 2)      AS avg_package
FROM students
GROUP BY department
ORDER BY placed DESC;

-- 4. Company-wise hiring (top 10)
SELECT
    company,
    COUNT(*)                    AS students_hired,
    ROUND(AVG(package_lpa), 2)  AS avg_package,
    MAX(package_lpa)            AS max_package
FROM students
WHERE is_placed = 'true'
GROUP BY company
ORDER BY students_hired DESC
LIMIT 10;

-- 5. Gender-wise placement
SELECT
    gender,
    COUNT(*)                    AS total,
    SUM(is_placed = 'true')     AS placed,
    ROUND(SUM(is_placed = 'true') * 100.0 / COUNT(*), 1) AS placement_pct
FROM students
GROUP BY gender;

-- 6. Monthly placements
SELECT
    placement_month,
    COUNT(*) AS placements
FROM students
WHERE is_placed = 'true'
GROUP BY placement_month
ORDER BY FIELD(placement_month,
    'January','February','March','April','May','June',
    'July','August','September','October','November','December');

-- 7. Salary distribution buckets
SELECT
    CASE
        WHEN package_lpa <= 4  THEN '0-4 LPA'
        WHEN package_lpa <= 6  THEN '4-6 LPA'
        WHEN package_lpa <= 8  THEN '6-8 LPA'
        WHEN package_lpa <= 10 THEN '8-10 LPA'
        WHEN package_lpa <= 15 THEN '10-15 LPA'
        ELSE '15+ LPA'
    END          AS salary_range,
    COUNT(*)     AS students
FROM students
WHERE is_placed = 'true'
GROUP BY salary_range
ORDER BY MIN(package_lpa);

-- 8. CGPA distribution
SELECT
    CASE
        WHEN cgpa < 6 THEN 'Below 6'
        WHEN cgpa < 7 THEN '6-7'
        WHEN cgpa < 8 THEN '7-8'
        WHEN cgpa < 9 THEN '8-9'
        ELSE '9-10'
    END       AS cgpa_range,
    COUNT(*)  AS students
FROM students
GROUP BY cgpa_range
ORDER BY MIN(cgpa);

-- 9. Unplaced students list
SELECT id, name, department, cgpa, backlogs, internship, skills
FROM students
WHERE is_placed = 'false'
ORDER BY cgpa DESC;

-- 10. CGPA vs Package (for scatter plot)
SELECT name, cgpa, package_lpa, department
FROM students
WHERE is_placed = 'true'
ORDER BY cgpa;
