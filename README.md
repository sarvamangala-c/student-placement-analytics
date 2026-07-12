# PlaceTrack — Student Placement Data Analytics Platform

A comprehensive data analytics platform that analyses student placement data using statistical methods, visualises key metrics through interactive charts, and predicts placement probability using machine learning algorithms.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, React Router 6, Recharts, Axios |
| Backend | Python 3.10+, Flask 3, Flask-CORS |
| Data Analysis | Pandas, NumPy, Scipy |
| Machine Learning | Scikit-learn (Random Forest, Feature Engineering) |
| Database | MySQL 8 |
| Data Visualization | Recharts, Matplotlib (backend analysis) |
| Styling | Custom CSS (no framework dependency) |

---

## Project Structure

```
student-placement-analytics/
├── backend/
│   ├── app.py                  # Flask entry point
│   ├── requirements.txt
│   ├── analysis/
│   │   ├── analyzer.py         # Core Pandas analysis functions
│   │   ├── ml_predictor.py     # RandomForest placement predictor
│   │   └── run_analysis.py     # Standalone script to test analysis
│   └── routes/
│       ├── auth.py             # POST /api/auth/login
│       ├── dashboard.py        # GET  /api/dashboard/*
│       ├── students.py         # GET  /api/students/
│       ├── companies.py        # GET  /api/companies/
│       └── analytics.py        # GET/POST /api/analytics/*
├── data/
│   └── students.csv            # 100-student sample dataset
├── database/
│   ├── schema.sql              # Tables + views DDL
│   ├── seed.sql                # All 100 students + placements
│   └── queries.sql             # 10 useful analytics queries
└── frontend/
    ├── package.json
    ├── public/index.html
    └── src/
        ├── index.js / App.jsx
        ├── index.css
        ├── context/AuthContext.jsx
        ├── services/api.js
        ├── components/
        │   ├── Sidebar.jsx
        │   ├── Layout.jsx
        │   ├── KpiCard.jsx
        │   └── Spinner.jsx
        └── pages/
            ├── Login.jsx
            ├── Dashboard.jsx
            ├── Students.jsx
            ├── Companies.jsx
            ├── SkillGap.jsx
            └── Predict.jsx
```

---

## Prerequisites

Install these before setup:

- **Python 3.10+** — https://www.python.org/downloads/
- **Node.js 18+** — https://nodejs.org/
- **MySQL 8+** — https://dev.mysql.com/downloads/mysql/
- **Git** — https://git-scm.com/

---

## Setup — Step by Step

### 1. Clone / open the project

```bash
cd student-placement-analytics
```

---

### 2. Database setup (MySQL)

Open MySQL Workbench or your terminal:

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p placement_db < database/seed.sql
```

This creates the `placement_db` database with all tables, views, and 100 student records.

To verify:

```sql
USE placement_db;
SELECT COUNT(*) FROM students;         -- should be 100
SELECT COUNT(*) FROM placements;       -- should be ~80
SELECT * FROM vw_dept_summary;         -- department breakdown
```

> The Flask backend currently reads directly from `data/students.csv` using Pandas.
> MySQL is provided for reference, reporting queries, and production use.
> To switch the backend to MySQL, replace `load_data()` in `analyzer.py` with a
> `pd.read_sql()` call against a SQLAlchemy connection.

---

### 3. Backend setup

```bash
cd backend

# Create a virtual environment
python -m venv venv

# Activate it
# Windows:
venv\Scripts\activate
# macOS / Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

Start the Flask API:

```bash
python app.py
```

The API will be available at **http://localhost:5000**

Test it:

```bash
curl http://localhost:5000/api/health
# {"status": "ok", "service": "Student Placement Analytics API"}
```

---

### 4. Frontend setup

Open a **new terminal window**:

```bash
cd frontend
npm install
npm start
```

The React app will open at **http://localhost:3000**

> The `"proxy": "http://localhost:5000"` in `package.json` forwards all `/api/*`
> calls to Flask automatically during development.

---

## Login Credentials

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `admin123` |

---

## Data Analytics Features

### Statistical Analysis
- **Descriptive Statistics**: Mean, median, mode, standard deviation for CGPA, packages, and placement metrics
- **Correlation Analysis**: Pearson correlation between CGPA, backlogs, projects, and placement outcomes
- **Distribution Analysis**: Histogram and bucket analysis for salary ranges, CGPA distribution, and department-wise placement rates
- **Time Series Analysis**: Monthly placement trends and seasonal patterns

### Data Processing Pipeline
- **Data Cleaning**: Handling missing values, outlier detection, and data normalization
- **Feature Engineering**: Creating derived features like skill count, experience level, and academic performance metrics
- **Data Transformation**: Converting raw CSV data into structured analytics-ready datasets
- **Skill Analysis**: Natural language processing to extract and categorize technical skills from student profiles

### Machine Learning Model
- **Algorithm**: Random Forest Classifier for placement prediction
- **Features**: CGPA, backlogs, projects count, internship status, skill diversity
- **Training**: 80-20 train-test split with cross-validation
- **Performance Metrics**: Accuracy, precision, recall, F1-score, and feature importance analysis
- **Model Interpretability**: Feature importance scores to identify key placement factors

### Analytics Capabilities
- **Department-wise Analysis**: Comparative placement rates across different engineering departments
- **Company Analytics**: Hiring patterns, salary benchmarks, and company-specific placement metrics
- **Skill Gap Analysis**: Identifying skill deficiencies in unplaced students compared to placed students
- **Predictive Analytics**: Real-time placement probability prediction for individual students
- **Trend Analysis**: Historical placement data analysis to identify patterns and insights

### Data Visualization
- **Interactive Dashboards**: Real-time data visualization with drill-down capabilities
- **Statistical Charts**: Bar charts, line charts, pie charts, scatter plots, and histograms
- **KPI Cards**: Key performance indicators with trend indicators
- **Comparative Analysis**: Side-by-side comparisons of different student segments

---

## Pages & Features

### Dashboard
- KPI cards: total students, placed, unplaced, avg/highest/median package
- Bar chart: department-wise placements
- Bar chart: salary distribution (0–4 LPA → 15+ LPA)
- Line chart: monthly placement trend
- Bar chart: CGPA distribution
- Pie chart: gender-wise placement
- Scatter chart: CGPA vs package correlation

### Students
- Full table of all 100 students
- Filter by department, placement status
- Search by name, skill, or company
- Download filtered results as CSV

### Company Analytics
- KPI summary: total companies, students hired, avg & highest package
- Horizontal bar chart: top 10 hiring companies
- Searchable company table with avg/max/min packages
- Click any company to drill down into its hired students

### Skill Gap
- Horizontal skill bars: top 15 in-demand skills
- Comparison: skills of placed vs unplaced students
- Missing skills highlight — what unplaced students lack
- Actionable recommendations panel

### Placement Predictor (ML)
- Input: CGPA, backlogs, projects, internship, skills
- Output: placed / not placed prediction + probability %
- Random Forest model trained on the 100-student dataset
- Displays model accuracy

---

## API Reference

### Auth
```
POST /api/auth/login         { "username": "admin", "password": "admin123" }
POST /api/auth/logout
GET  /api/auth/me
```

### Dashboard
```
GET /api/dashboard/summary
GET /api/dashboard/departments
GET /api/dashboard/salary-distribution
GET /api/dashboard/cgpa-distribution
GET /api/dashboard/monthly-trend
GET /api/dashboard/gender-stats
GET /api/dashboard/cgpa-vs-package
```

### Students
```
GET /api/students/                          all students
GET /api/students/?department=CSE           filter by dept
GET /api/students/?placed=true              placed only
GET /api/students/?search=python            search by skill
GET /api/students/5                         single student
```

### Companies
```
GET /api/companies/                         all companies
GET /api/companies/?limit=10                top 10
GET /api/companies/Infosys/students         students at Infosys
```

### Analytics
```
GET  /api/analytics/skills                  skill gap data
GET  /api/analytics/feature-importance      ML feature weights
POST /api/analytics/predict                 predict placement
POST /api/analytics/train                   retrain model
```

Sample predict request:

```bash
curl -X POST http://localhost:5000/api/analytics/predict \
  -H "Content-Type: application/json" \
  -d '{"cgpa": 8.5, "backlogs": 0, "projects": 3, "internship": true, "skills": ["Python","SQL","React"]}'
```

---

## Dataset

`data/students.csv` contains 100 students with comprehensive placement data:

### Data Schema
- **Student Information**: ID, name, department, CGPA, backlogs
- **Skills**: Technical skills array (Python, Java, SQL, React, etc.)
- **Experience**: Projects count, internship status
- **Placement Data**: Company name, package (LPA), placement status
- **Demographics**: Gender, graduation year

### Data Distribution
- **Departments**: CSE (42), IT (20), ECE (7), EEE (5), MECH (8) + others
- **Companies**: 50 companies including Google, Microsoft, Amazon, Infosys, TCS, Wipro
- **Packages**: ₹3.5 LPA (lowest) to ₹22 LPA (highest)
- **Placed**: ~82 students | **Unplaced**: ~18 students
- **Skills**: 80+ unique skills across all students

### Key Analytics Insights
- **Placement Rate**: ~82% overall placement rate
- **Department Performance**: CSE leads with highest placement rate and average package
- **Salary Distribution**: Right-skewed distribution with median around ₹6-8 LPA
- **Skill Correlation**: Students with diverse technical skills have higher placement probability
- **CGPA Impact**: Strong positive correlation between CGPA and placement outcomes
- **Company Concentration**: Top 10 companies hire 60% of placed students

---

## Data Analysis Methodology

### Data Pipeline Architecture
```
Raw Data (CSV) → Data Cleaning → Feature Engineering → Statistical Analysis → ML Model → Visualization
```

### Analysis Functions (backend/analysis/analyzer.py)

1. **load_data()**: Loads and validates student placement data
   - Reads CSV data using Pandas
   - Performs data type validation
   - Handles missing values and outliers

2. **get_summary_stats()**: Computes key performance indicators
   - Total students, placed/unplaced counts
   - Salary statistics (mean, median, max, min)
   - Placement rate calculations

3. **get_department_stats()**: Department-wise analytics
   - Placement rates by department
   - Average package per department
   - Department strength distribution

4. **get_salary_distribution()**: Salary bucket analysis
   - Creates salary ranges (0-4 LPA, 4-8 LPA, 8-12 LPA, 12-15 LPA, 15+ LPA)
   - Counts students in each bucket
   - Calculates percentage distribution

5. **get_company_stats()**: Company hiring analytics
   - Top hiring companies by student count
   - Average salary per company
   - Company-wise placement patterns

6. **get_skill_gap_analysis()**: Skill demand analysis
   - Extracts and counts skills from placed vs unplaced students
   - Identifies skill gaps
   - Generates actionable recommendations

7. **get_correlation_analysis()**: Statistical correlations
   - CGPA vs Package correlation
   - Backlogs vs Placement correlation
   - Projects vs Placement correlation

### Machine Learning Pipeline (backend/analysis/ml_predictor.py)

1. **Data Preparation**:
   - Feature selection and engineering
   - Handling categorical variables (skills, departments)
   - Train-test split (80-20 ratio)

2. **Model Training**:
   - Random Forest Classifier with 100 estimators
   - Cross-validation for robustness
   - Hyperparameter tuning

3. **Model Evaluation**:
   - Accuracy score on test set
   - Feature importance analysis
   - Confusion matrix and classification report

4. **Prediction**:
   - Real-time placement probability prediction
   - Returns both class prediction and probability
   - Handles unseen skill combinations

### Data Sources

**Primary Dataset**: `data/students.csv`
- 100 student records with comprehensive placement data
- Includes academic performance, skills, projects, internships
- Placement outcomes with company and salary information

**Database Schema**: `database/schema.sql`
- Normalized database structure for production use
- Supports complex analytics queries
- Enables historical trend analysis

**Analytics Queries**: `database/queries.sql`
- Pre-built SQL queries for common analytics needs
- Department-wise summaries
- Company hiring patterns
- Salary distribution analysis

---

## Common Issues

**Backend won't start — ModuleNotFoundError**
```bash
# Make sure your virtual environment is activated
venv\Scripts\activate        # Windows
pip install -r requirements.txt
```

**Frontend shows blank page / network error**
- Confirm Flask is running on port 5000 before starting React
- Check browser console for CORS or 404 errors

**MySQL seed fails with foreign key error**
- Always run `schema.sql` before `seed.sql`
- Run seed.sql against `placement_db` specifically:
  ```bash
  mysql -u root -p placement_db < database/seed.sql
  ```

**ML prediction fails on first call**
- The model trains automatically on the first prediction request
- This takes 1–2 seconds; subsequent calls are instant

---

## Running the Analysis Script Standalone

To test all analysis functions without starting the server:

```bash
cd backend/analysis
python run_analysis.py
```

This prints dashboard summary, department stats, company stats, salary buckets, skill gap analysis, and more directly to the terminal.

---

## Future Enhancements

### Data Analytics Improvements
- **Advanced ML Models**: Implement Gradient Boosting, Neural Networks for improved prediction accuracy
- **Time Series Forecasting**: Predict future placement trends based on historical data
- **Clustering Analysis**: Student segmentation based on skills, performance, and placement likelihood
- **Anomaly Detection**: Identify unusual placement patterns or data quality issues
- **A/B Testing Framework**: Test different intervention strategies for improving placement rates
- **Real-time Analytics**: Stream processing for live placement updates
- **Advanced Statistical Tests**: Chi-square tests, ANOVA for department-wise significance testing

### Platform Enhancements
- JWT-based authentication with token expiry
- Connect Flask directly to MySQL (replace CSV with `pd.read_sql`)
- Admin panel to add / edit student records
- Export dashboard as PDF and Excel
- Email alerts when placement percentage drops below threshold
- Power BI embedded dashboard via REST API
- Deployment: Flask on Render / Railway, React on Vercel

---

## Author

Built as a BCA final-year project demonstrating comprehensive data analytics capabilities:
- Statistical analysis and data visualization
- Machine learning model development and deployment
- Database design and SQL analytics
- REST API development for data services
- Interactive dashboard development
- End-to-end data pipeline implementation
