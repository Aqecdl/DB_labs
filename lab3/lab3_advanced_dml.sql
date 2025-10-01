-- Part A: Database and Table Setup
CREATE DATABASE advanced_lab;

\c advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(50) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

-- Part B: Advanced INSERT Operations

-- 2. Insert with column specification
INSERT INTO employees (first_name, last_name, department)
VALUES ('Mo', 'Salah', 'IT');

-- 3. Insert with DEFAULT values
INSERT INTO employees (first_name, last_name, department, hire_date, status)
VALUES ('Darwin', 'Nunez', 'Sales', '2025-09-25', DEFAULT);

-- 4. Insert multiple rows
INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('Marketing', 120000, 1),
       ('Finance', 200000, 2),
       ('HR', 90000, 3);

-- 5. Insert with expression
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Virgil', 'VanDijk', 'IT', 50000 * 1.1, CURRENT_DATE);

-- 6. Insert from SELECT
CREATE TEMPORARY TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

-- Part C: 

-- 7. Arithmetic update
UPDATE employees SET salary = salary * 1.1;

-- 8. Update with conditions
UPDATE employees SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9. Update using CASE
UPDATE employees SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

-- 10. Update with DEFAULT
UPDATE employees SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. Update with subquery
UPDATE departments
SET budget = (SELECT AVG(salary)
              FROM employees
              WHERE department = departments.dept_name) * 1.2;

-- 12. Update multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D: Advanced DELETE Operations

-- 13. Simple delete
DELETE FROM employees WHERE status = 'Terminated';

-- 14. Delete with complex WHERE
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. Delete with subquery
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16. Delete with RETURNING
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E: Operations with NULL Values

-- 17. Insert with NULL
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Luis', 'Diaz', NULL, NULL, '2023-07-12');

-- 18. Update NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. Delete with NULL condition
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- Part F: RETURNING Clause Operations

-- 20. Insert with RETURNING
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Cody', 'Gakpo', 'Sales', 50000, '2022-01-02', 'Inactive')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- 21. Update with RETURNING
UPDATE employees
SET salary = salary + 10000
WHERE department = 'IT'
RETURNING emp_id, (salary - 10000) AS old_salary, salary AS new_salary;

-- 22. Delete with RETURNING
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Part G: Advanced DML Patterns

-- 23. Conditional INSERT
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Trent', 'Arnold', 'Sales', 95000, '2020-06-12'
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Trent' AND last_name = 'Arnold'
);

-- 24. Update with JOIN logic via subquery
UPDATE employees
SET salary = CASE
    WHEN (SELECT budget
          FROM departments
          WHERE dept_name = employees.department) > 100000
         THEN salary * 1.1
    ELSE salary * 1.05
END;

-- 25. Bulk insert + bulk update
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Yessenatay', 'Adil', 'IT', 205000, '2018-01-01', 'Active'),
       ('Alisson', 'Becker', 'Sales', 150000, '2024-08-01', 'Terminated'),
       ('Andrew', 'Robertson', 'HR', 60000, '2023-11-11', 'Inactive'),
       ('Ibrahima', 'Konate', 'IT', 190000, '2023-11-11', 'Active'),
       ('Curtis', 'Jones', 'IT', 100000, '2024-09-12', 'Active');

UPDATE employees
SET salary = salary * 1.1
WHERE emp_id IN (
    SELECT emp_id
    FROM employees
    ORDER BY emp_id DESC
    LIMIT 5
);

-- 26. Data migration simulation
CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE 1 = 0;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

-- 27. Complex business logic
UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (SELECT COUNT(*)
       FROM employees
       WHERE department = (
            SELECT dept_name FROM departments WHERE dept_id = projects.dept_id
       )) > 3;
