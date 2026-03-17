-- Fraud Prevention

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;

DROP VIEW IF EXISTS RecentPurchases CASCADE;
DROP VIEW IF EXISTS FraudulentPurchases CASCADE;

-- Purchases made in the last 24 hours
CREATE VIEW RecentPurchases AS
SELECT *
FROM Purchase
WHERE checkout_time >= NOW() - INTERVAL '24 hours';

-- Purchases after the 5th one for the same card in the last 24 hours
CREATE VIEW FraudulentPurchases AS
SELECT r1.PID
FROM RecentPurchases r1
WHERE (
    SELECT COUNT(*)
    FROM RecentPurchases r2
    WHERE r2.card_pan = r1.card_pan
      AND (
            r2.checkout_time < r1.checkout_time
            OR (r2.checkout_time = r1.checkout_time AND r2.PID <= r1.PID)
          )
) > 5;

-- Delete line items first
DELETE FROM LineItem
WHERE PID IN (
    SELECT PID
    FROM FraudulentPurchases
);

-- Then delete the purchases
DELETE FROM Purchase
WHERE PID IN (
    SELECT PID
    FROM FraudulentPurchases
);