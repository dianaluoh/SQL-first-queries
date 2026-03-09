-- SALE!SALE!SALE!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps. (But give them better names!)
DROP VIEW IF EXISTS IntermediateStep CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW IntermediateStep AS 
SELECT
    i.IID,
    i.price AS old_price,
    SUM(li.quantity) AS total_units_sold,
    CASE
        WHEN SUM(li.quantity) >= 10 AND i.price BETWEEN 10 AND 50
            THEN ROUND((i.price * 0.80)::numeric, 2)::float
        WHEN SUM(li.quantity) >= 10 AND i.price > 50 AND i.price <= 100
            THEN ROUND((i.price * 0.70)::numeric, 2)::float
        WHEN SUM(li.quantity) >= 10 AND i.price > 100
            THEN ROUND((i.price * 0.50)::numeric, 2)::float
        ELSE i.price
    END AS new_price
FROM Item i
JOIN LineItem li
  ON li.IID = i.IID
GROUP BY i.IID, i.price;

-- Update only items that sold at least 10 units and cost at least $10
UPDATE Item i
SET price = s.new_price
FROM IntermediateStep s
WHERE i.IID = s.IID
  AND s.total_units_sold >= 10
  AND s.old_price >= 10;


