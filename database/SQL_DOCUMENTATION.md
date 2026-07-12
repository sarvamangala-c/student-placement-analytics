# Student Placement Data Analytics - SQL Documentation

## Overview

This directory contains comprehensive SQL components for the Student Placement Data Analytics Platform. The database schema is designed for efficient data storage, retrieval, and advanced analytics operations.

## 📁 File Structure

```
database/
├── schema.sql           # Database schema, indexes, views, and stored procedures
├── seed.sql             # Sample data insertion (100 student records)
├── setup.sql            # Complete setup script (schema + data)
├── queries.sql          # Advanced analytics queries
├── verify.sql           # Data verification queries
└── SQL_DOCUMENTATION.md # This file
```

## 🚀 Quick Start

### Option 1: Complete Setup (Recommended)
```bash
mysql -u root -p < database/setup.sql
```

### Option 2: Step-by-Step Setup
```bash
# Step 1: Create database and schema
mysql -u root -p < database/schema.sql

# Step 2: Insert sample data
mysql -u root -p placement_db < database/seed.sql

# Step 3: Verify installation
mysql -u root -p placement_db < database/verify.sql
```

## 📊 Database Schema

### Main Table: `students`

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `id` | INT | Unique student identifier | PRIMARY KEY |
| `name` | VARCHAR(100) | Student full name | NOT NULL |
| `gender` | VARCHAR(10) | Gender (Male/Female) | NOT NULL |
| `department` | VARCHAR(20) | Engineering department | NOT NULL |
| `cgpa` | DECIMAL(4,2) | Cumulative Grade Point Average | 0.0-10.0 |
| `backlogs` | INT | Number of backlogs | >= 0 |
| `internship` | VARCHAR(5) | Internship completion (Yes/No) | NOT NULL |
| `projects` | INT | Number of projects completed | >= 0 |
| `skills` | VARCHAR(500) | Comma-separated technical skills | - |
| `company` | VARCHAR(100) | Placed company name | - |
| `package_lpa` | DECIMAL(5,2) | Annual package in Lakhs | > 0 if placed |
| `placement_month` | VARCHAR(20) | Month of placement | - |
| `placement_year` | INT | Year of placement | - |
| `is_placed` | VARCHAR(5) | Placement status (true/false) | NOT NULL |
| `created_at` | TIMESTAMP | Record creation timestamp | AUTO |
| `updated_at` | TIMESTAMP | Last update timestamp | AUTO |

### Data Constraints

- **CGPA Range**: 0.0 to 10.0
- **Backlogs**: Non-negative integers
- **Projects**: Non-negative integers
- **Package**: Positive values only (if placed)
- **Placement Status**: Only 'true' or 'false'

## 🗃️ Database Features

### 1. Performance Indexes

#### Single Column Indexes
- `idx_department`: Optimizes department-based queries
- `idx_is_placed`: Speeds up placement status filtering
- `idx_company`: Enhances company search operations
- `idx_cgpa`: Improves CGPA-based analytics
- `idx_package`: Optimizes salary range queries
- `idx_placement_year`: Speeds up yearly trend analysis
- `idx_placement_month`: Enhances monthly trend analysis
- `idx_gender`: Improves demographic analysis

#### Composite Indexes
- `idx_dept_placed`: Department + placement status combination
- `idx_company_package`: Company + package combination
- `idx_year_month`: Year + month combination for temporal analysis

### 2. Analytics Views

#### `vw_department_summary`
Comprehensive department-wise analytics including:
- Total, placed, and unplaced student counts
- Placement rates
- CGPA statistics (placed vs unplaced)
- Package statistics (average, max, min)

**Usage:**
```sql
SELECT * FROM vw_department_summary ORDER BY placement_rate DESC;
```

#### `vw_company_summary`
Company hiring analytics featuring:
- Students hired per company
- Salary statistics (average, max, min)
- Average CGPA of hired students
- Department diversity

**Usage:**
```sql
SELECT * FROM vw_company_summary WHERE students_hired > 2 ORDER BY avg_package DESC;
```

#### `vw_monthly_trend`
Temporal placement analysis:
- Monthly placement counts
- Average package per month
- Average CGPA per month
- Chronological ordering

**Usage:**
```sql
SELECT * FROM vw_monthly_trend WHERE placement_year = 2024;
```

#### `vw_salary_distribution`
Salary range analysis:
- Predefined salary buckets (0-4 LPA to 15+ LPA)
- Student count per bucket
- Percentage distribution

**Usage:**
```sql
SELECT * FROM vw_salary_distribution ORDER BY MIN(package_lpa);
```

#### `vw_cgpa_distribution`
CGPA range analysis:
- CGPA buckets (Below 6.0 to 9.0-10.0)
- Placement rates per CGPA range
- Student distribution

**Usage:**
```sql
SELECT * FROM vw_cgpa_distribution ORDER BY placement_rate DESC;
```

#### `vw_gender_summary`
Gender-based analytics:
- Total, placed, unplaced counts by gender
- Placement rates
- Average package by gender

**Usage:**
```sql
SELECT * FROM vw_gender_summary;
```

#### `vw_skills_analysis`
Advanced skills analytics:
- Individual skill extraction from comma-separated lists
- Placement rates per skill
- Average package per skill
- Skill popularity ranking

**Usage:**
```sql
SELECT * FROM vw_skills_analysis WHERE placement_rate_with_skill > 70 ORDER BY avg_package_with_skill DESC;
```

### 3. Stored Procedures

#### `sp_get_dashboard_summary()`
Comprehensive dashboard analytics procedure that returns:
- Overall placement statistics
- Department-wise summaries
- Top 10 company statistics

**Usage:**
```sql
CALL sp_get_dashboard_summary();
```

#### `sp_analyze_skill_gaps()`
Skill gap analysis procedure providing:
- Top 15 skills among placed students
- Average package per skill
- Skills among unplaced students
- Comparison for gap identification

**Usage:**
```sql
CALL sp_analyze_skill_gaps();
```

#### `sp_predict_placement(cgpa, backlogs, projects, internship)`
Rule-based placement prediction procedure:
- Input: Student academic and experience parameters
- Output: Predicted probability level and percentage
- Based on historical pattern analysis

**Usage:**
```sql
CALL sp_predict_placement(8.5, 0, 3, 'Yes');
```

## 📈 Analytics Queries Categories

### 1. Descriptive Statistics
- Overall placement statistics
- Package statistics (mean, median, std dev)
- CGPA statistics by placement status
- Distribution analysis

### 2. Department Analytics
- Department-wise comprehensive analysis
- Department performance ranking
- Cross-department comparisons

### 3. Company Analytics
- Company-wise hiring analysis
- Company salary brackets
- Company department preferences
- Top hiring companies

### 4. Temporal Analysis
- Monthly placement trends
- Quarterly analysis
- Year-over-year comparisons
- Seasonal patterns

### 5. Distribution Analysis
- Salary distribution analysis
- CGPA distribution with placement rates
- Backlogs impact analysis
- Percentile calculations

### 6. Correlation Analysis
- CGPA vs Package correlation
- Projects vs Placement correlation
- Internship impact analysis
- Multi-factor correlation

### 7. Skills Analysis
- Top demanded skills
- Skills gap analysis (placed vs unplaced)
- Skill combinations analysis
- Skill effectiveness metrics

### 8. Demographic Analysis
- Gender-wise comprehensive analysis
- Gender-department intersection analysis
- Diversity metrics

### 9. Advanced Analytics
- Student risk analysis
- High performers identification
- Placement probability estimation
- Department benchmarking

### 10. Data Quality Checks
- Data completeness assessment
- Outlier detection (CGPA, Package)
- Data validation queries
- Consistency checks

## 🔧 Query Examples

### Basic Analytics
```sql
-- Overall placement rate
SELECT 
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate
FROM students;
```

### Department Analysis
```sql
-- Department performance comparison
SELECT 
    department,
    COUNT(*) AS total,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate,
    ROUND(AVG(CASE WHEN is_placed = 'true' THEN package_lpa END), 2) AS avg_package
FROM students
GROUP BY department
ORDER BY placement_rate DESC;
```

### Company Analytics
```sql
-- Top hiring companies with salary details
SELECT 
    company,
    COUNT(*) AS students_hired,
    ROUND(AVG(package_lpa), 2) AS avg_package,
    MAX(package_lpa) AS max_package,
    MIN(package_lpa) AS min_package
FROM students
WHERE is_placed = 'true' AND company IS NOT NULL
GROUP BY company
ORDER BY students_hired DESC
LIMIT 10;
```

### Skills Analysis
```sql
-- Most in-demand skills
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(skills, ',', n), ',', -1)) AS skill,
    COUNT(*) AS total_students,
    SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) AS placed_with_skill,
    ROUND(SUM(CASE WHEN is_placed = 'true' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate
FROM students
CROSS JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) numbers
WHERE skills IS NOT NULL AND skills != '' 
  AND n <= LENGTH(skills) - LENGTH(REPLACE(skills, ',', '')) + 1
GROUP BY skill
ORDER BY placed_with_skill DESC
LIMIT 15;
```

### Risk Analysis
```sql
-- Students at risk of not being placed
SELECT 
    name,
    department,
    cgpa,
    backlogs,
    projects,
    internship,
    CASE 
        WHEN cgpa < 6.5 OR backlogs >= 2 OR (projects <= 1 AND internship = 'No') THEN 'High Risk'
        WHEN cgpa < 7.5 OR backlogs >= 1 OR (projects <= 2 AND internship = 'No') THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM students
WHERE is_placed = 'false'
ORDER BY cgpa DESC;
```

## 🎯 Use Cases

### 1. Dashboard Analytics
Use `sp_get_dashboard_summary()` for comprehensive dashboard data:
```sql
CALL sp_get_dashboard_summary();
```

### 2. Skill Gap Analysis
Identify missing skills among unplaced students:
```sql
CALL sp_analyze_skill_gaps();
```

### 3. Placement Prediction
Predict placement probability for individual students:
```sql
CALL sp_predict_placement(7.8, 1, 2, 'Yes');
```

### 4. Department Performance
Compare department performance:
```sql
SELECT * FROM vw_department_summary ORDER BY placement_rate DESC;
```

### 5. Company Insights
Analyze company hiring patterns:
```sql
SELECT * FROM vw_company_summary WHERE students_hired >= 3 ORDER BY avg_package DESC;
```

### 6. Trend Analysis
Analyze monthly placement trends:
```sql
SELECT * FROM vw_monthly_trend WHERE placement_year = 2024;
```

## 🔍 Data Analysis Workflow

### Step 1: Data Exploration
```sql
-- Check data completeness
SELECT * FROM vw_department_summary;
SELECT * FROM vw_company_summary LIMIT 10;
SELECT * FROM vw_salary_distribution;
```

### Step 2: Descriptive Analysis
```sql
-- Overall statistics
CALL sp_get_dashboard_summary();

-- Distribution analysis
SELECT * FROM vw_cgpa_distribution;
SELECT * FROM vw_gender_summary;
```

### Step 3: Diagnostic Analysis
```sql
-- Correlation analysis
-- CGPA vs Package
SELECT 
    CASE 
        WHEN cgpa < 6 THEN 'Below 6.0'
        WHEN cgpa < 7 THEN '6.0-6.9'
        WHEN cgpa < 8 THEN '7.0-7.9'
        WHEN cgpa < 9 THEN '8.0-8.9'
        ELSE '9.0-10.0'
    END AS cgpa_range,
    ROUND(AVG(package_lpa), 2) AS avg_package
FROM students
WHERE is_placed = 'true'
GROUP BY cgpa_range
ORDER BY MIN(cgpa);
```

### Step 4: Predictive Analysis
```sql
-- Placement probability estimation
CALL sp_predict_placement(8.5, 0, 3, 'Yes');

-- Risk analysis
SELECT 
    name,
    department,
    cgpa,
    backlogs,
    CASE 
        WHEN cgpa < 6.5 OR backlogs >= 2 THEN 'High Risk'
        WHEN cgpa < 7.5 OR backlogs >= 1 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM students
WHERE is_placed = 'false';
```

### Step 5: Prescriptive Analysis
```sql
-- Skill gap analysis for recommendations
CALL sp_analyze_skill_gaps();

-- Department benchmarking
SELECT 
    department,
    placement_rate,
    avg_package,
    avg_package - (SELECT AVG(package_lpa) FROM students WHERE is_placed = 'true') AS package_vs_overall
FROM vw_department_summary;
```

## 📊 Advanced Analytics Techniques

### 1. Window Functions
- Ranking: `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`
- Aggregates: `SUM() OVER()`, `AVG() OVER()`
- Lead/Lag: `LAG()`, `LEAD()` for trend analysis

### 2. Statistical Functions
- Standard Deviation: `STDDEV()`
- Variance: `VARIANCE()`
- Median: `MEDIAN()` (MySQL 8.0+)
- Percentiles: `PERCENT_RANK()`

### 3. String Manipulation
- Skill extraction: `SUBSTRING_INDEX()`, `TRIM()`
- Pattern matching: `LIKE`, `REGEXP`
- String length: `LENGTH()`, `CHAR_LENGTH()`

### 4. Conditional Logic
- Case statements: `CASE WHEN...THEN...END`
- Null handling: `COALESCE()`, `IFNULL()`, `NULLIF()`
- Conditional aggregation: `SUM(CASE WHEN...)`

### 5. Join Operations
- Self joins for comparisons
- Cross joins for skill extraction
- Complex multi-table joins

## 🛠️ Performance Optimization

### Query Optimization Tips
1. **Use indexes**: Ensure indexed columns are used in WHERE clauses
2. **Avoid SELECT ***: Select only required columns
3. **Use views**: Pre-computed aggregations for complex queries
4. **Limit results**: Use LIMIT for large result sets
5. **Optimize joins**: Use appropriate join types

### Index Usage
```sql
-- Check index usage
EXPLAIN SELECT * FROM students WHERE department = 'CSE' AND is_placed = 'true';

-- Force index usage (if needed)
SELECT * FROM students USE INDEX (idx_dept_placed) 
WHERE department = 'CSE' AND is_placed = 'true';
```

### Query Performance Analysis
```sql
-- Analyze query execution plan
EXPLAIN ANALYZE SELECT * FROM vw_department_summary;

-- Check table statistics
SHOW TABLE STATUS LIKE 'students';
```

## 🔐 Security Considerations

### User Permissions
```sql
-- Create read-only user for analytics
CREATE USER 'analytics_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT SELECT ON placement_db.* TO 'analytics_user'@'localhost';

-- Create admin user with full access
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON placement_db.* TO 'admin_user'@'localhost';
```

### Data Privacy
- Remove sensitive personal information when sharing
- Anonymize student names in public datasets
- Implement row-level security for department-specific access

## 📝 Maintenance Tasks

### Regular Maintenance
```sql
-- Analyze table for optimization
ANALYZE TABLE students;

-- Optimize table
OPTIMIZE TABLE students;

-- Check table integrity
CHECK TABLE students;
```

### Backup Procedures
```bash
# Backup database
mysqldump -u root -p placement_db > backup_$(date +%Y%m%d).sql

# Restore database
mysql -u root -p placement_db < backup_20240101.sql
```

### Data Updates
```sql
-- Update placement status
UPDATE students SET is_placed = 'true', company = 'New Company', package_lpa = 8.5 WHERE id = 101;

-- Add new student
INSERT INTO students (id, name, gender, department, cgpa, backlogs, internship, projects, skills, is_placed)
VALUES (101, 'New Student', 'Male', 'CSE', 8.5, 0, 'Yes', 3, 'Python,Java,SQL', 'false');
```

## 🚨 Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check MySQL service is running
   - Verify credentials
   - Check firewall settings

2. **Query Performance**
   - Run EXPLAIN on slow queries
   - Check index usage
   - Consider query optimization

3. **Data Inconsistency**
   - Run data validation queries
   - Check constraint violations
   - Verify data types

4. **Permission Errors**
   - Check user privileges
   - Verify database access
   - Review security settings

## 📚 Additional Resources

### MySQL Documentation
- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL Performance Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)

### Analytics Resources
- [SQL for Data Analysis](https://www.mode.com/sql-tutorial/)
- [Advanced SQL Analytics](https://www.sqltutorial.org/advanced-sql/)

### Data Science Integration
- Connect with Python pandas: `pd.read_sql()`
- Connect with R: `dbGetQuery()`
- Connect with Tableau/Power BI via ODBC

## 🔄 Version History

- **v1.0** (2024): Initial schema with basic table
- **v2.0** (2024): Added indexes, views, and stored procedures
- **v3.0** (2024): Enhanced analytics queries and documentation

## 👥 Contributing

When adding new analytics queries:
1. Follow existing naming conventions
2. Add comments explaining the logic
3. Include usage examples
4. Update this documentation
5. Test on sample data before deployment

## 📞 Support

For issues or questions:
1. Check this documentation
2. Review MySQL error logs
3. Test queries in isolation
4. Consult MySQL documentation

---

**Last Updated**: 2024-07-12  
**Database Version**: MySQL 8.0+  
**Schema Version**: 3.0
