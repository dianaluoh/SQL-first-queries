-- Customer appreciation week

-- You must not change the next 2 lines.
SET SEARCH_PATH TO Recommender;

DROP VIEW IF EXISTS FirstPurchaseYesterday CASCADE;
DROP VIEW IF EXISTS GiftItem CASCADE;

-- Add the free gift item.
INSERT INTO Item
SELECT
    COALESCE(MAX(IID), 0) + 1,
    'Housewares',
    'Company logo mug',
    0
FROM Item;

-- Identify the free gift item we just inserted.
CREATE VIEW GiftItem AS
SELECT IID
FROM Item
WHERE description = 'Company logo mug';

-- For each customer who purchased yesterday, find their first purchase yesterday.
CREATE VIEW FirstPurchaseYesterday AS
SELECT p1.CID, p1.PID
FROM Purchase p1
WHERE p1.checkout_time >= CURRENT_DATE - INTERVAL '1 day'
  AND p1.checkout_time < CURRENT_DATE
  AND NOT EXISTS (
      SELECT *
      FROM Purchase p2
      WHERE p2.CID = p1.CID
        AND p2.checkout_time >= CURRENT_DATE - INTERVAL '1 day'
        AND p2.checkout_time < CURRENT_DATE
        AND (
            p2.checkout_time < p1.checkout_time
            OR (p2.checkout_time = p1.checkout_time AND p2.PID < p1.PID)
        )
  );

-- Add the free mug to that first purchase.
INSERT INTO LineItem
SELECT
    f.PID,
    g.IID,
    1
FROM FirstPurchaseYesterday f, GiftItem g;
