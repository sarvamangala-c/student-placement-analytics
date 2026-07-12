USE placement_db;
SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS placed_students FROM students WHERE is_placed = 'true';
SELECT COUNT(*) AS unplaced_students FROM students WHERE is_placed = 'false';
SELECT name, department, package_lpa FROM students WHERE is_placed = 'true' ORDER BY package_lpa DESC LIMIT 5;
