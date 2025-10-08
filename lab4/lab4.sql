-- Create tables
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);

CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);

CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
('Yessenatay', 'Adil', 'IT', 88000, '2019-03-10', NULL, 'yessenatay.adil@company.com'),
('Mo', 'Salah', 'IT', 79000, '2020-02-05', 1, 'mo.s@company.com'),
('Darwin', 'Nunez', 'Sales', 72000, '2021-04-18', NULL, 'darwin.n@company.com'),
('Virgil', 'VanDijk', 'HR', 65000, '2021-08-12', NULL, 'virgil.v@company.com'),
('Trent', 'Arnold', 'IT', 77000, '2020-11-01', 1, NULL),
('Alisson', 'Becker', 'Finance', 71000, '2022-06-05', NULL, 'alisson.b@company.com');

INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
('Website Upgrade', 140000, '2024-01-10', '2024-06-20', 'Active'),
('CRM Deployment', 210000, '2024-02-20', '2024-12-25', 'Active'),
('Marketing Expansion', 85000, '2024-03-01', '2024-06-01', 'Completed'),
('Database Optimization', 125000, '2024-01-15', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 120.0, '2024-01-15'),
(2, 1, 95.5, '2024-01-22'),
(1, 4, 88.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-07'),
(5, 2, 115.0, '2024-02-25'),
(6, 3, 78.0, '2024-03-12');


--PART 1: BASIC SELECT QUERIES
--Task 1.1
SELECT first_name || ' ' || last_name AS full_name, department, salary FROM employees;

--Task 1.2
SELECT DISTINCT department FROM employees;

--Task 1.3
SELECT project_name, budget,
CASE
    WHEN budget > 150000 THEN 'Large'
    WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
    ELSE 'Small'
END AS budget_category
FROM projects;

--Task 1.4
SELECT first_name || ' ' || last_name AS full_name, COALESCE(email, 'No email provided') AS email FROM employees;


--PART 2: WHERE CLAUSE AND COMPARISON OPERATORS
--Task 2.1
SELECT * FROM employees WHERE hire_date > '2020-01-01';

--Task 2.2
SELECT * FROM employees WHERE salary BETWEEN 70000 AND 80000;

--Task 2.3
SELECT * FROM employees WHERE last_name LIKE 'V%' OR last_name LIKE 'A%';

--Task 2.4
SELECT * FROM employees WHERE manager_id IS NOT NULL AND department = 'IT';


--PART 3: STRING AND MATHEMATICAL FUNCTIONS
--Task 3.1
SELECT UPPER(first_name || ' ' || last_name) AS full_name,
LENGTH(last_name) AS last_name_length,
SUBSTRING(email FROM 1 FOR 3) AS email_prefix FROM employees;

--Task 3.2
SELECT salary AS annual_salary,
ROUND(salary / 12, 2) AS monthly_salary,
ROUND(salary * 0.1, 2) AS ten_percent_of_salary FROM employees;

--Task 3.3
SELECT format('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) FROM projects;

--Task 3.4
SELECT first_name || ' ' || last_name AS full_name,
EXTRACT(YEAR FROM age(CURRENT_DATE, hire_date)) AS years_in_company FROM employees;


--PART 4: AGGREGATE FUNCTIONS AND GROUP BY
--Task 4.1
SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department;

--Task 4.2
SELECT p.project_name, SUM(a.hours_worked) AS total_hours
FROM projects p
JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_name;

--Task 4.3
SELECT department, COUNT(*) AS num_employees FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

--Task 4.4
SELECT MAX(salary) AS max_salary, MIN(salary) AS min_salary, SUM(salary) AS total_payroll FROM employees;


--PART 5: SET OPERATIONS
--Task 5.1
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary FROM employees
WHERE salary > 80000
UNION
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary FROM employees
WHERE hire_date > '2021-01-01';

--Task 5.2
SELECT employee_id, first_name || ' ' || last_name AS full_name FROM employees WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name || ' ' || last_name AS full_name FROM employees WHERE salary > 75000;

--Task 5.3
SELECT employee_id, first_name || ' ' || last_name AS full_name FROM employees
EXCEPT
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS full_name FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;


--PART 6: SUBQUERIES
--Task 6.1
SELECT * FROM employees e
WHERE EXISTS (SELECT 1 FROM assignments a WHERE a.employee_id = e.employee_id);

--Task 6.2
SELECT * FROM employees e
WHERE e.employee_id IN (
    SELECT a.employee_id FROM assignments a
    JOIN projects p ON p.project_id = a.project_id
    WHERE p.status = 'Active'
);

--Task 6.3
SELECT * FROM employees WHERE salary > ANY(
    SELECT salary FROM employees WHERE department = 'Sales');


--PART 7: COMPLEX QUERIES
--Task 7.1
SELECT e.first_name || ' ' || e.last_name AS full_name, e.department,
AVG(a.hours_worked) AS avg_hours,
RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employees e
JOIN assignments a ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary;

--Task 7.2
SELECT p.project_name,
SUM(a.hours_worked) AS total_hours,
COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

--Task 7.3
SELECT department, COUNT(*) AS total_employees,
AVG(salary) AS avg_salary,
(SELECT e2.first_name || ' ' || e2.last_name
    FROM employees e2
    WHERE e2.department = e.department
    ORDER BY e2.salary DESC
    LIMIT 1) AS highest_paid_employee
FROM employees e
GROUP BY department;
