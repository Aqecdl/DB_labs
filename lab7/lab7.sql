-- PART 1: Database Setup
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10,2)
);

CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);

CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10,2)
);

INSERT INTO employees VALUES
(1,'John Smith',101,50000),
(2,'Jane Doe',102,60000),
(3,'Mike Johnson',101,55000),
(4,'Sarah Williams',103,65000),
(5,'Tom Brown',NULL,45000);

INSERT INTO departments VALUES
(101,'IT','Building A'),
(102,'HR','Building B'),
(103,'Finance','Building C'),
(104,'Marketing','Building D');

INSERT INTO projects VALUES
(1,'Website Redesign',101,100000),
(2,'Employee Training',102,50000),
(3,'Budget Analysis',103,75000),
(4,'Cloud Migration',101,150000),
(5,'AI Research',NULL,200000);


--Part 2

CREATE VIEW employee_details AS 
SELECT e.emp_name, e.salary, d.name, d.location
FROM employees e 
INNER JOIN department d ON e.dept_id = d.dept_id;

SELECT * from employee_details;
-- Returned 4 rows (Tom Brown won’t appear because his dept_id is NULL — the JOIN excludes unmatched rows).

--2.2
CREATE VEIW dept_statistics AS
SELECT d.dept_name,
        COUNT(e.emp_id) AS employee_count,
        AVG(e.salary) AS avg_salary,
        MAX(e.salary) AS max_salary,
        MIN(e.salary) AS min_salary
FROM department d 
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;

--2.2 (test)
SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

--Exercise 2.3
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(DISTINCT e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d ON d.dept_id = p.dept_id
LEFT JOIN employees e ON e.dept_id = p.dept_id
GROUP BY  p.project_name, p.budget, d.dept_name, d.location;
--Exercise 2.3 (test)
SELECT * FROM project_overview;


--Exercise 2.4
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
WHERE e.salary > 55000;
--Exercise 2.4 (test)
SELECT * FROM high_earners;
-- You’ll see Jane Doe and Sarah Williams — both above 55k.



--Part 3: Modifying and Managing Views
--Exercise 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id;
--Exercise 3.1 (test)
SELECT * FROM employee_details;


--Exercise 3.2
ALTER VIEW high_earners RENAME TO top_performers;
--Exercise 3.2 (test)
SELECT * FROM top_performers;


--Exercise 3.3
CREATE VIEW temp_view AS
SELECT emp_name, salary
FROM employees
WHERE salary < 50000;
--Exercise 3.3 (test)
SELECT * FROM temp_view;

DROP VIEW temp_view;



--Part 4: Updatable Views
--Exercise 4.1
CREATE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;
--Exercise 4.1 (test)
SELECT * FROM employee_salaries;


--Exercise 4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
--Exercise 4.2 (test)
SELECT * FROM employees WHERE emp_name = 'John Smith';
--The employees table was updated


--Exercise 4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6,'Alice Johnson', 102, 58000);
--Exercise 4.3 (test)
SELECT * FROM employees;
--Alice Johnson added successfully


--Exercise 4.4
CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);
--The CHECK OPTION ensures all inserted/updated rows satisfy the view’s condition (dept_id = 101).
--Bob Wilson’s department 103 doesn’t, so the operation is rejected.



--Part 5: Materialized Views
--Exercise 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id, d.dept_name,
    COUNT(DISTINCT e.emp_id) AS total_employees,
    COALESCE(SUM(DISTINCT e.salary), 0) AS total_salaries,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
LEFT JOIN projects p ON p.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;
--Exercise 5.1 (test)
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;


--Exercise 5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);
--Exercise 5.2 (test1)
SELECT * FROM dept_summary_mv;
REFRESH MATERIALIZED VIEW dept_summary_mv;
--Exercise 5.2 (test2)
SELECT * FROM dept_summary_mv;
--Before: Total employees for IT (dept_id 101) is 2. After: It becomes 3, reflecting the new insert


--Exercise 5.3
CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--It allows the view to be refreshed without locking out queries, so users can still query the old data during refresh


--Exercise 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS assigned_employees
FROM projects p
JOIN departments d ON d.dept_id = p.dept_id
LEFT JOIN employees e on p.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name
WITH NO DATA;



--Part 6: Database Roles
--Exercise 6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user PASSWORD 'report456';
--Exercise 6.1 (test)
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';


--Exercise 6.2
CREATE ROLE db_creator CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';


--Exercise 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;


--Exercise 6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 PASSWORD 'hr001';
CREATE USER hr_user2 PASSWORD 'hr002';
CREATE USER finance_user1 PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;


--Exercise 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES  ON employee_details FROM data_viewer;


--Exercise 6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;



--Part 7: Advanced Role Management
--Exercise 7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;


--Exercise 7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;
--Exercise 7.2 (test)
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';


--Exercise 7.3
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table( id INT );
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;


--Exercise 7.4
CREATE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;



--Part 8: Practical Scenarios
--Exercise 8.1
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    ROUND(AVG(DISTINCT COALESCE(e.salary, 0)), 2) AS avg_salary,
    COUNT(DISTINCT p.project_id) AS active_projects,
    SUM(DISTINCT p.budget) AS total_project_budget,
    CASE
        WHEN COUNT(DISTINCT e.emp_id) = 0 THEN 0
        ELSE ROUND(SUM(DISTINCT p.budget) / COUNT(DISTINCT e.emp_id), 2)
    END AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
LEFT JOIN projects p ON p.dept_id = d.dept_id
GROUP BY d.dept_name, d.location;


--Exercise 8.2
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
JOIN departments d ON d.dept_id = p.dept_id
WHERE p.budget > 75000;


--Exercise 8.3
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice LOGIN PASSWORD 'alice123';
CREATE USER bob LOGIN PASSWORD 'bob123';
CREATE USER charlie LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;