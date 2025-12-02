-- 3.1 Setup
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);



--3.2 Task 1 
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
COMMIT;
-- A) Alice = 900
--Bob = 600
-- B) The transfer must be treated as a single logical action so both updates are applied together.
-- C) The deduction from Alice would remain but Bob would never receive the money.

--3.3 Task 2

BEGIN;
UPDATE accounts SET balance - 500 WHERE name = 'Alece';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

-- a) Before rollback Alice temporarily had 500.
-- b) After rollback her balance returned to 1000.
-- c) ROLLBACK is useful when an incorrect operation is detected or an error occurs mid-transaction.


--3.4 Task 4

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
--Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;

-- a) Alice = 900, Bob = 500, Wally = 850
-- b) Bob was credited only temporarily; the rollback to savepoint cancelled this change.

-- c) SAVEPOINT allows rolling back only part of a transaction, unlike a full rollback.

-- 3.5 Task 4: Isolation Level Demonstration

-- Scenario A: READ COMMITTED
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait, then:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2:
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products VALUES (DEFAULT, 'Joe''s Shop', 'Fanta', 3.50);
COMMIT;

-- Scenario B: SERIALIZABLE
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2: same modifications as above

-- a) Under READ COMMITTED: first SELECT shows Coke+Pepsi, second shows Fanta.
-- b) Under SERIALIZABLE: both SELECTs return the original data.
-- c) READ COMMITTED allows non-repeatable reads; SERIALIZABLE completely prevents anomalies.



-- 3.6 Task 5

-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2:
BEGIN;
INSERT INTO products VALUES (DEFAULT, 'Joe''s Shop', 'Sprite', 4.00);
COMMIT;

-- a) Terminal 1 does not see Sprite.
-- b) Phantom read = new rows appear in the result of repeated queries inside one transaction.
-- c) SERIALIZABLE prevents phantom reads.



-- 3.7 Task 6

-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2:
BEGIN;
UPDATE products SET price = 99.99 WHERE product = 'Fanta';
-- wait, then:
ROLLBACK;

-- a) Terminal 1 sees the uncommitted 99.99 value, which is unsafe.
-- b) Dirty read = reading uncommitted transient changes.
-- c) READ UNCOMMITTED compromises data correctness and should not be used.



-- Independent Exercise 1

BEGIN;

DO $$
DECLARE
    bal DECIMAL;
BEGIN
    SELECT balance INTO bal FROM accounts WHERE name = 'Bob';

    IF bal < 200 THEN
        RAISE EXCEPTION 'Not enough money on Bob''s account';
    END IF;

    UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob';
    UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';
END $$;

COMMIT;



-- Independent Exercise 2

BEGIN;

INSERT INTO products VALUES (DEFAULT, 'Joe''s Shop', 'Juice', 2.00);
SAVEPOINT p1;

UPDATE products SET price = 3.00 WHERE product = 'Juice';
SAVEPOINT p2;

DELETE FROM products WHERE product = 'Juice';

ROLLBACK TO p1;
COMMIT;

-- Final result: Juice remains in table with price = 2.00.



-- Independent Exercise 3: concurrent withdrawals

-- READ COMMITTED allows both users to read the same initial balance.
-- REPEATABLE READ forces one transaction to fail on commit if data was modified.
-- SERIALIZABLE ensures strict ordering and only one withdrawal succeeds.



-- Independent Exercise 4: MAX < MIN anomaly

CREATE TABLE Sells (
    id SERIAL PRIMARY KEY,
    price NUMERIC
);

INSERT INTO Sells(price) VALUES (100), (200);

SELECT MAX(price) FROM Sells;
-- parallel changes happen:
DELETE FROM Sells;
INSERT INTO Sells(price) VALUES (400), (900);
SELECT MIN(price) FROM Sells;

-- anomaly occurs (MAX < MIN)

-- Fix using transaction:
BEGIN;
SELECT MAX(price) FROM Sells;
SELECT MIN(price) FROM Sells;
COMMIT;



-- Self-Assessment answers

-- 1) Atomicity = all-or-nothing. Consistency = valid DB state. 
--    Isolation = transactions do not disturb each other. 
--    Durability = changes persist after commit.

-- 2) COMMIT saves work; ROLLBACK cancels it.

-- 3) SAVEPOINT allows undoing only a portion of the transaction.

-- 4) SERIALIZABLE is strictest; REPEATABLE READ blocks non-repeatable reads; 
--    READ COMMITTED shows only committed data; READ UNCOMMITTED allows dirty reads.

-- 5) Dirty read = reading uncommitted data; allowed only in READ UNCOMMITTED.

-- 6) Non-repeatable read = data changes between two SELECTs inside one transaction.

-- 7) Phantom read = new rows appear. Prevented by SERIALIZABLE.

-- 8) READ COMMITTED is used for better performance.

-- 9) Transactions protect consistency by isolating updates.

-- 10) Uncommitted work is discarded after crash.