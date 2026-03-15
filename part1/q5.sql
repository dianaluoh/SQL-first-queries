-- Hyperconsumers

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
    year VARCHAR(4) NOT NULL,
    name VARCHAR(65) NOT NULL,
    email VARCHAR(300) NOT NULL,
    items INTEGER NOT NULL
);

-- Total number of items bought by each customer in each year.
DROP VIEW IF EXISTS CustomerYearTotals CASCADE;
CREATE VIEW CustomerYearTotals AS
SELECT
    TO_CHAR(p.checkout_time, 'YYYY') AS year,
    p.CID,
    SUM(li.quantity) AS items
FROM Purchase p
JOIN LineItem li
    ON p.PID = li.PID
GROUP BY TO_CHAR(p.checkout_time, 'YYYY'), p.CID;

-- Hyperconsumers: customers whose total is among the top 5 distinct totals for that year.
DROP VIEW IF EXISTS HyperConsumers CASCADE;
CREATE VIEW HyperConsumers AS
SELECT
    t1.year,
    t1.CID,
    t1.items
FROM CustomerYearTotals t1
WHERE (
    SELECT COUNT(DISTINCT t2.items)
    FROM CustomerYearTotals t2
    WHERE t2.year = t1.year
      AND t2.items > t1.items
) < 5;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
SELECT
    h.year,
    c.first_name || ' ' || c.last_name AS name,
    c.email,
    h.items
FROM HyperConsumers h
JOIN Customer c
    ON h.CID = c.CID
ORDER BY h.year, h.items DESC, c.CID;
