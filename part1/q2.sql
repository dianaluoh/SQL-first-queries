-- Helpfulness


-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q2 CASCADE;

create table q2(
    CID INTEGER,
    name TEXT NOT NULL,
    helpfulness_category TEXT NOT NULL
);

-- Reviews that have more helpful reviews than unhelpful reviews
DROP VIEW IF EXISTS HelpfulReviews CASCADE;
CREATE VIEW HelpfulReviews AS 
	SELECT reviewer as CID, IID
  FROM Helpfulness
  GROUP BY reviewer, IID
  HAVING count(*) FILTER (WHERE helpfulness = True) > 
         count(*) FILTER (WHERE helpfulness = False);
         
-- Customers that have at least 1 "helpful" review
DROP VIEW IF EXISTS HelpfulCustomers CASCADE;
CREATE VIEW HelpfulCustomers AS 
	SELECT CID, COUNT(*) as helpful_reviews
  FROM HelpfulReviews
  GROUP BY CID;
  
-- Customers and their helpfulness score
DROP VIEW IF EXISTS HelpfulnessScores CASCADE;
CREATE VIEW HelpfulnessScores AS
	SELECT R.CID, 
  			 CAST(COALESCE(H.helpful_reviews, 0) AS FLOAT) / COUNT(R.IID) AS score
  FROM Review R
  LEFT JOIN HelpfulCustomers H ON R.CID = H.CID
  GROUP BY R.CID, H.helpful_reviews;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT Customer.CID, 
			 first_name || ' ' || last_name as name, 
       CASE 
       		WHEN COALESCE(score, 0) >= 0.8 THEN 'very helpful'
          WHEN COALESCE(score, 0) >= 0.5 AND COALESCE(score, 0) < 0.8 THEN 'somewhat helpful'
          ELSE 'not helpful'
       END AS category
FROM Customer 
LEFT JOIN HelpfulnessScores ON Customer.CID = HelpfulnessScores.CID;