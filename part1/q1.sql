-- Unrated products


-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF exists q1 CASCADE;

CREATE TABLE q1(
    CID INTEGER,
    first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
    email TEXT	
);

-- IID of products that dont have any ratings
DROP VIEW IF exists UnratedProducts CASCADE;
CREATE VIEW UnratedProducts AS
    SELECT IID FROM Item 
    EXCEPT
    SELECT IID FROM Review;

-- Customers who have bought atleast 3 unrated products
DROP VIEW IF exists NaiveCustomers CASCADE;
CREATE VIEW NaiveCustomers AS
    SELECT CID
    FROM (Purchase NATURAL JOIN LineItem) NATURAL JOIN UnratedProducts
    GROUP BY CID
    HAVING COUNT(DISTINCT IID) >= 3;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT DISTINCT CID, first_name, last_name, email
FROM Customer NATURAL JOIN NaiveCustomers;