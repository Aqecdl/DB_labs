--Student Name: Yessentay Adil 
--Student ID: 24B031759
-- PART 1: CHECK Constraints

-- TASK 1.1
CREATE TABLE employees_check (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK(age BETWEEN 18 AND 65),
    salary NUMERIC CHECK(salary > 0)
);

-- TASK 1.2
CREATE TABLE product_prices (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK(regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

-- TASK 1.3
CREATE TABLE reservations (
    booking_id INTEGER,
    check_in DATE,
    check_out DATE,
    guests INTEGER CHECK(guests BETWEEN 1 AND 8),
    CHECK(check_out > check_in)
);

-- Correct data
INSERT INTO employees_check VALUES (1, 'Adil', 'Yessenatay', 22, 120000);
INSERT INTO employees_check VALUES (2, 'Mo', 'Salah', 31, 90000);

-- Incorrect data examples
-- INSERT INTO employees_check VALUES (3, 'Trent', 'Alexander', 16, 70000);
-- INSERT INTO employees_check VALUES (4, 'Virgil', 'Van Dijk', 40, -5000);

INSERT INTO product_prices VALUES (1, 'Laptop', 1000, 850);
INSERT INTO product_prices VALUES (2, 'Headphones', 200, 150);

-- Incorrect data
-- INSERT INTO product_prices VALUES (3, 'Camera', 500, 550);

INSERT INTO reservations VALUES (1, '2025-01-01', '2025-01-05', 3);
INSERT INTO reservations VALUES (2, '2025-02-10', '2025-02-12', 2);
-- INSERT INTO reservations VALUES (3, '2025-03-01', '2025-02-25', 2); -- check_out < check_in


-- PART 2: NOT NULL Constraints


CREATE TABLE clients (
    client_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE stock_items (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity >= 0),
    price NUMERIC NOT NULL CHECK(price > 0),
    updated_at TIMESTAMP NOT NULL
);

-- Correct
INSERT INTO clients VALUES (1, 'adil@example.com', '87770001122', '2025-01-01');
INSERT INTO clients VALUES (2, 'mo@lfc.com', NULL, '2025-02-01');

-- Incorrect
-- INSERT INTO clients VALUES (3, NULL, '87775556677', '2025-03-01');

INSERT INTO stock_items VALUES (1, 'Keyboard', 20, 120, '2025-10-08 10:00:00');
INSERT INTO stock_items VALUES (2, 'Mouse', 50, 60, '2025-10-08 11:00:00');

-- Incorrect
-- INSERT INTO stock_items VALUES (3, 'Monitor', 10, -50, '2025-10-09 12:00:00');


-- PART 3: UNIQUE Constraints


CREATE TABLE users_unique (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

CREATE TABLE course_registrations (
    reg_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE(student_id, course_code, semester)
);

INSERT INTO users_unique VALUES (1, 'adil', 'adil@mail.com', '2025-10-08 10:00:00');
INSERT INTO users_unique VALUES (2, 'salah', 'mo@mail.com', '2025-10-08 11:00:00');
-- INSERT INTO users_unique VALUES (3, 'adil', 'other@mail.com', '2025-10-08 12:00:00'); -- duplicate username


-- PART 4: PRIMARY KEY Constraints


CREATE TABLE departments_pk (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments_pk VALUES (1, 'IT', 'Almaty');
INSERT INTO departments_pk VALUES (2, 'HR', 'Astana');
-- INSERT INTO departments_pk VALUES (2, 'Finance', 'Shymkent'); -- duplicate PK

CREATE TABLE student_subjects (
    student_id INTEGER,
    subject_id INTEGER,
    mark NUMERIC,
    PRIMARY KEY (student_id, subject_id)
);

-- Explanation:
-- 1️⃣ PRIMARY KEY = UNIQUE + NOT NULL
-- 2️⃣ Use composite PK when two columns together form a unique pair.
-- 3️⃣ You can have one PK but many UNIQUE constraints.


-- PART 5: FOREIGN KEY Constraints


CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY,
    team_name TEXT NOT NULL
);

CREATE TABLE players (
    player_id INTEGER PRIMARY KEY,
    player_name TEXT NOT NULL,
    team_id INTEGER REFERENCES teams(team_id)
);

INSERT INTO teams VALUES (1, 'Liverpool');
INSERT INTO teams VALUES (2, 'Manchester City');

INSERT INTO players VALUES (1, 'Adil Yessenatay', 1);
INSERT INTO players VALUES (2, 'Mo Salah', 1);
INSERT INTO players VALUES (3, 'Erling Haaland', 2);
-- INSERT INTO players VALUES (4, 'Unknown', 99); -- invalid team_id

CREATE TABLE categories_fk (
    cat_id INTEGER PRIMARY KEY,
    cat_name TEXT
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    cat_id INTEGER REFERENCES categories_fk(cat_id) ON DELETE RESTRICT
);

CREATE TABLE orders_fk (
    order_id INTEGER PRIMARY KEY,
    order_date DATE
);

CREATE TABLE order_items_fk (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders_fk(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK(quantity > 0)
);

INSERT INTO categories_fk VALUES (1, 'Tech');
INSERT INTO products_fk VALUES (1, 'Headset', 1);
INSERT INTO orders_fk VALUES (1, '2025-09-15');
INSERT INTO order_items_fk VALUES (1, 1, 1, 3);

-- Test delete
-- DELETE FROM categories_fk WHERE cat_id = 1; -- FAIL (restrict)
DELETE FROM orders_fk WHERE order_id = 1; -- CASCADE deletes order_items


-- PART 6: Practical Application


CREATE TABLE customers_lab6 (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    registered DATE NOT NULL
);

CREATE TABLE products_lab6 (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC CHECK(price > 0),
    stock INTEGER CHECK(stock >= 0)
);

CREATE TABLE orders_lab6 (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers_lab6(customer_id) ON DELETE SET NULL,
    order_date DATE,
    status TEXT CHECK(status IN ('pending','processing','delivered','cancelled'))
);

CREATE TABLE order_details_lab6 (
    detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders_lab6(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_lab6(product_id),
    quantity INTEGER CHECK(quantity > 0)
);

-- Insert data
INSERT INTO customers_lab6 VALUES (1, 'Adil Yessenatay', 'adil@example.com', '2025-01-01');
INSERT INTO customers_lab6 VALUES (2, 'Mo Salah', 'mo@lfc.com', '2025-01-02');

INSERT INTO products_lab6 VALUES (1, 'Laptop', 1000, 20);
INSERT INTO products_lab6 VALUES (2, 'Keyboard', 120, 50);

INSERT INTO orders_lab6 VALUES (1, 1, '2025-10-05', 'pending');
INSERT INTO orders_lab6 VALUES (2, 2, '2025-10-06', 'processing');

INSERT INTO order_details_lab6 VALUES (1, 1, 1, 1);
INSERT INTO order_details_lab6 VALUES (2, 2, 2, 2);

-- Test delete SET NULL
DELETE FROM customers_lab6 WHERE customer_id = 1;

-- Test delete CASCADE
DELETE FROM orders_lab6 WHERE order_id = 2;
