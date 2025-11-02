-- PART 1: Database Setup

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(60),
    dept_id INT,
    salary DECIMAL(10,2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(60),
    location VARCHAR(60)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(60),
    dept_id INT,
    budget DECIMAL(10,2)
);

-- Insert data
INSERT INTO employees VALUES
(1, 'Kevin Hart', 11, 70000),
(2, 'Emma Stone', 12, 65000),
(3, 'Chris Evans', 11, 72000),
(4, 'Natalie Portman', 14, 80000),
(5, 'Jack Black', NULL, 50000);

INSERT INTO departments VALUES
(11, 'Engineering', 'A1'),
(12, 'Human Resources', 'B2'),
(13, 'Design', 'C3'),
(14, 'Finance', 'D4');

INSERT INTO projects VALUES
(1, 'Website Upgrade', 11, 130000),
(2, 'Recruiting Campaign', 12, 60000),
(3, 'Cost Analysis', 14, 90000),
(4, 'New UI Concept', 13, 45000),
(5, 'AI Team', NULL, 500000);



-- PART 2: CROSS JOIN

SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;

SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;


-- PART 3: INNER JOIN

-- 3.1 Basic INNER JOIN
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- 3.2 USING (removes duplicate column)
SELECT emp_name, dept_id, dept_name
FROM employees
INNER JOIN departments USING (dept_id);

-- 3.3 NATURAL join
SELECT emp_name, dept_name, location
FROM employees
NATURAL JOIN departments;

-- 3.4 Joining 3 tables
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;



-- PART 4: LEFT JOIN

-- get all employees even if they don't have a department
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- employees without department
SELECT e.emp_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;



-- PART 5: RIGHT JOIN

-- get all departments even if they don't have employees
SELECT d.dept_name, e.emp_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;



-- PART 6: FULL JOIN

SELECT e.emp_name, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;



-- PART 7: ON vs WHERE

-- filter in ON
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'A1';

-- filter in WHERE
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'A1';


-- PART 8: SELF JOIN

ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id IN (1,2,5);
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
