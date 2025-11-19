--PART 1: DATABASE SETUP
CREATE TABLE departments (
    dep_id INT PRIMARY KEY,
    dep_name VARCHAR(60),
    location VARCHAR(40)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dep_id INT,
    salary NUMERIC,
    email VARCHAR(120),
    phone VARCHAR(20),
    hire_date DATE,
    FOREIGN KEY (dep_id) REFERENCES departments(dep_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_title VARCHAR(100),
    budget NUMERIC,
    dep_id INT,
    FOREIGN KEY (dep_id) REFERENCES departments(dep_id)
);

INSERT INTO departments VALUES
(10, 'IT', 'Block A'),
(20, 'HR', 'Block B'),
(30, 'Logistics', 'Block C');

INSERT INTO employees (emp_id, emp_name, dep_id, salary, email, phone, hire_date) VALUES
(1, 'Adam Ray', 10, 51000, 'adam.ray@corp.kz', NULL, '2020-01-05'),
(2, 'Emily Lee', 10, 54000, 'emily.lee@corp.kz', NULL, '2021-03-10'),
(3, 'Robert Miles', 20, 47000, 'robert.m@corp.kz', NULL, '2019-09-15'),
(4, 'Sofia Clark', 20, 52000, 'sofia.c@corp.kz', NULL, '2020-11-22'),
(5, 'Daniel Ross', 30, 61000, 'daniel.ross@corp.kz', NULL, '2018-07-12');

INSERT INTO projects VALUES
(1001, 'System Upgrade', 80000, 10),
(1002, 'Cloud Backup', 130000, 10),
(1003, 'HR Portal', 45000, 20);


--PART 2: BASIC INDEXES
CREATE INDEX idx_emp_salary ON employees(salary);

CREATE INDEX idx_emp_dep ON employees(dep_id);

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public';


--PART 3: MULTICOLUMN INDEXES
CREATE INDEX idx_emp_dep_salary ON employees(dep_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dep_id = 10 AND salary > 52000;

CREATE INDEX idx_salary_dep ON employees(salary, dep_id);

SELECT * FROM employees WHERE salary > 50000 AND dep_id = 20;


--PART 4: UNIQUE INDEXES
CREATE UNIQUE INDEX idx_emp_email ON employees(email);

ALTER TABLE employees ADD CONSTRAINT phone_unique UNIQUE(phone);


--PART 5: INDEXES & SORTING
CREATE INDEX idx_salary_desc ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

CREATE INDEX idx_proj_budget_nf ON projects(budget NULLS FIRST);

SELECT proj_title, budget
FROM projects
ORDER BY budget NULLS FIRST;


--PART 6: EXPRESSION INDEXES
CREATE INDEX idx_emp_lower_name ON employees(LOWER(emp_name));

SELECT * FROM employees
WHERE LOWER(emp_name) = 'adam ray';

CREATE INDEX idx_hire_year ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


--PART 7: MANAGING INDEXES
ALTER INDEX idx_emp_salary RENAME TO idx_salary_index;

DROP INDEX idx_salary_dep;

REINDEX INDEX idx_salary_index;


--PART 8: PRACTICAL INDEX SCENARIOS
SELECT e.emp_name, e.salary, d.dep_name
FROM employees e
JOIN departments d ON d.dep_id = e.dep_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX idx_salary_filter ON employees(salary)
WHERE salary > 50000;

CREATE INDEX idx_proj_big_budget ON projects(budget)
WHERE budget > 90000;

SELECT proj_title, budget FROM projects WHERE budget > 90000;

EXPLAIN SELECT * FROM employees WHERE salary > 52000;


--PART 9: INDEX TYPES
CREATE INDEX idx_dep_hash ON departments USING HASH(dep_name);

CREATE INDEX idx_proj_title_btree ON projects(proj_title);

CREATE INDEX idx_proj_title_hash ON projects USING HASH(proj_title);


--PART 10: CLEANUP
SELECT indexname,
       pg_size_pretty(pg_relation_size(indexname::regclass))
FROM pg_indexes
WHERE schemaname = 'public';

DROP INDEX IF EXISTS idx_proj_title_hash;

DROP INDEX IF EXISTS idx_salary_dep;

CREATE VIEW index_info AS
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE indexname LIKE '%salary%';

SELECT * FROM index_info;


--Summary Questions

--1) Most common index type in PostgreSQL:
--   B-tree.

--2) When indexes are useful:
--   1. Columns used often in WHERE filters
--   2. Foreign key columns used for JOINs
--   3. Columns frequently appearing in ORDER BY

--3) When indexes are NOT recommended:
--   1. Very small tables (Seq Scan is faster)
--   2. Columns with many writes (INSERT/UPDATE/DELETE), because indexes slow updates

--4) Do indexes update automatically?
--   Yes — PostgreSQL maintains them automatically.

--5) How to check if an index is used?
--   Run EXPLAIN before the query to view the execution plan.
