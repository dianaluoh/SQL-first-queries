-- Curators

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    CID INT NOT NULL,
    category_name TEXT NOT NULL,
    PRIMARY KEY(CID, category_name)
);

-- All items in each category
DROP VIEW IF EXISTS CategoryItems CASCADE;
CREATE VIEW CategoryItems AS
SELECT I.category, I.IID
FROM Item I;

-- Items purchased by each customer
DROP VIEW IF EXISTS PurchasedItems CASCADE;
CREATE VIEW PurchasedItems AS
SELECT DISTINCT P.CID, LI.IID
FROM Purchase P
JOIN LineItem LI ON P.PID = LI.PID;

-- Items reviewed by each customer with a non-NULL comment
DROP VIEW IF EXISTS ReviewedWithComment CASCADE;
CREATE VIEW ReviewedWithComment AS
SELECT R.CID, R.IID
FROM Review R
WHERE R.comment IS NOT NULL;

-- Items for which a customer both purchased the item and reviewed it with comment
DROP VIEW IF EXISTS QualifiedItems CASCADE;
CREATE VIEW QualifiedItems AS
SELECT PI.CID, I.category, PI.IID
FROM PurchasedItems PI
JOIN ReviewedWithComment RWC
  ON PI.CID = RWC.CID AND PI.IID = RWC.IID
JOIN Item I
  ON PI.IID = I.IID;

-- For each customer-category pair, count how many category items they qualify for
DROP VIEW IF EXISTS CustomerCategoryQualifiedCount CASCADE;
CREATE VIEW CustomerCategoryQualifiedCount AS
SELECT QI.CID, QI.category, COUNT(DISTINCT QI.IID) AS qualified_count
FROM QualifiedItems QI
GROUP BY QI.CID, QI.category;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT CCQC.CID, CCQC.category
FROM CustomerCategoryQualifiedCount CCQC
JOIN (
    SELECT category, COUNT(*) AS total_items
    FROM Item
    GROUP BY category
) CategoryTotals
  ON CCQC.category = CategoryTotals.category
WHERE CCQC.qualified_count = CategoryTotals.total_items;