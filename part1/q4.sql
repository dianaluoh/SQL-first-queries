-- Best and Worst Categories


-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
    month TEXT NOT NULL,
    highest_category TEXT NOT NULL,
    highest_sales_val FLOAT NOT NULL,
    lowest_category TEXT NOT NULL,
    lowest_sales_val FLOAT NOT NULL
);

-- All categories.
DROP VIEW IF EXISTS Categories CASCADE;
CREATE VIEW Categories AS
SELECT DISTINCT category
FROM Item;

-- All months.
DROP VIEW IF EXISTS Months CASCADE;
CREATE VIEW Months AS
SELECT '01' AS month
UNION SELECT '02'
UNION SELECT '03'
UNION SELECT '04'
UNION SELECT '05'
UNION SELECT '06'
UNION SELECT '07'
UNION SELECT '08'
UNION SELECT '09'
UNION SELECT '10'
UNION SELECT '11'
UNION SELECT '12';

-- Every month/category pair.
DROP VIEW IF EXISTS MonthCategory CASCADE;
CREATE VIEW MonthCategory AS
SELECT m.month, c.category
FROM Months m CROSS JOIN Categories c;

-- Real sales by month/category in 2024.
DROP VIEW IF EXISTS Sales2024 CASCADE;
CREATE VIEW Sales2024 AS
SELECT
    TO_CHAR(p.checkout_time, 'MM') AS month,
    i.category,
    SUM(li.quantity * i.price) AS sales_val
FROM Purchase p
JOIN LineItem li ON p.PID = li.PID
JOIN Item i ON li.IID = i.IID
WHERE p.checkout_time >= TIMESTAMP '2024-01-01'
  AND p.checkout_time < TIMESTAMP '2025-01-01'
GROUP BY TO_CHAR(p.checkout_time, 'MM'), i.category;

-- Include 0-sales categories/months.
DROP VIEW IF EXISTS AllSales CASCADE;
CREATE VIEW AllSales AS
SELECT
    mc.month,
    mc.category,
    COALESCE(s.sales_val, 0) AS sales_val
FROM MonthCategory mc
LEFT JOIN Sales2024 s
    ON mc.month = s.month
   AND mc.category = s.category;

-- Highest sales value per month.
DROP VIEW IF EXISTS HighestVals CASCADE;
CREATE VIEW HighestVals AS
SELECT
    month,
    MAX(sales_val) AS highest_sales_val
FROM AllSales
GROUP BY month;

-- Lowest sales value per month.
DROP VIEW IF EXISTS LowestVals CASCADE;
CREATE VIEW LowestVals AS
SELECT
    month,
    MIN(sales_val) AS lowest_sales_val
FROM AllSales
GROUP BY month;

-- Categories tied for highest.
DROP VIEW IF EXISTS HighestCategories CASCADE;
CREATE VIEW HighestCategories AS
SELECT
    a.month,
    a.category AS highest_category,
    a.sales_val AS highest_sales_val
FROM AllSales a
JOIN HighestVals h
    ON a.month = h.month
   AND a.sales_val = h.highest_sales_val;

-- Categories tied for lowest.
DROP VIEW IF EXISTS LowestCategories CASCADE;
CREATE VIEW LowestCategories AS
SELECT
    a.month,
    a.category AS lowest_category,
    a.sales_val AS lowest_sales_val
FROM AllSales a
JOIN LowestVals l
    ON a.month = l.month
   AND a.sales_val = l.lowest_sales_val;


-- Keep the required placeholder view name too.
DROP VIEW IF EXISTS IntermediateStep CASCADE;
CREATE VIEW IntermediateStep AS
SELECT *
FROM AllSales;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT
    h.month,
    h.highest_category,
    h.highest_sales_val,
    l.lowest_category,
    l.lowest_sales_val
FROM HighestCategories h
JOIN LowestCategories l
    ON h.month = l.month
ORDER BY h.month, h.highest_category, l.lowest_category;

