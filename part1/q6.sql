--Year-over-year sales

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6 (
    IID INT NOT NULL,
    year1 INT NOT NULL,
    year1_avg FLOAT NOT NULL,
    year2 INT NOT NULL,
    year2_avg FLOAT NOT NULL,
    yoy_change FLOAT NOT NULL
);

DROP VIEW IF EXISTS OpYears CASCADE;
CREATE VIEW OpYears AS
SELECT generate_series(
    (SELECT EXTRACT(YEAR FROM MIN(checkout_time))::INT FROM Purchase), 
    (SELECT EXTRACT(YEAR FROM MAX(checkout_time))::INT FROM Purchase)
) AS op_year;

-- Every item with an operational year attached
DROP VIEW IF EXISTS ItemYears CASCADE;
CREATE VIEW ItemYears AS
SELECT i.IID, y.op_year
FROM Item i CROSS JOIN OpYears y;

DROP VIEW IF EXISTS YearlyAverages CASCADE;
CREATE VIEW YearlyAverages AS
SELECT 
    iy.IID, 
    iy.op_year, 
    COALESCE(SUM(l.quantity), 0) / 12.0 AS year_avg
FROM ItemYears iy
LEFT JOIN Purchase p ON EXTRACT(YEAR FROM p.checkout_time) = iy.op_year
LEFT JOIN LineItem l ON p.PID = l.PID AND l.IID = iy.IID
GROUP BY iy.IID, iy.op_year;

-- Year pairs for every item and each year's average sales
DROP VIEW IF EXISTS YearPairs CASCADE;
CREATE VIEW YearPairs AS
SELECT 
    y1.IID,
    y1.op_year AS year1,
    y1.year_avg AS year1_avg,
    y2.op_year AS year2,
    y2.year_avg AS year2_avg
FROM YearlyAverages y1
JOIN YearlyAverages y2 ON y1.IID = y2.IID AND y2.op_year = y1.op_year + 1;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
SELECT 
    IID,
    year1,
    year1_avg,
    year2,
    year2_avg,
    CASE
        WHEN year1_avg = 0 AND year2_avg = 0 THEN 0.0
        WHEN year1_avg = 0 AND year2_avg > 0 THEN 'Infinity'::FLOAT
        ELSE ((year2_avg - year1_avg) / year1_avg) * 100.0
    END AS yoy_change
FROM YearPairs;