create database Yelp;
use Yelp;
describe yelp_business;
ALTER TABLE yelp_business
CHANGE COLUMN `ï»¿"business_id"` business_id VARCHAR(255);

describe yelp_checkin;
ALTER TABLE yelp_checkin
CHANGE COLUMN `ï»¿"business_id"` business_id VARCHAR(255);

describe yelp_reviews;
ALTER TABLE yelp_reviews
CHANGE COLUMN `ï»¿"business_name"` business_name VARCHAR(255);

-- 1 Find the number of Yelp businesses that sell pizza.
SELECT 
    count(*) 
FROM yelp_business 
WHERE categories LIKE '%Pizza%';

-- 2 Find the top 5 cities with the most 5-star businesses. Output the city name along with the number of 5-star businesses. 
-- Include both open and closed businesses.
-- In the case of multiple cities having the same number of 5-star businesses, use the ranking function returning the 
-- lowest rank in the group and output cities with a rank smaller than or equal to 5.
WITH RankedCities AS(
SELECT city,COUNT(*)AS five_star_count,
RANK()OVER(ORDER BY COUNT(*)DESC)AS city_rank
FROM yelp_business
WHERE stars=5
GROUP BY city)
SELECT city,five_star_count
FROM RankedCities
WHERE city_rank<=5;

-- 3 Find the review_text that received the highest number of  'cool' votes.
-- Output the business name along with the review text with the highest numbef of 'cool' votes.
SELECT business_name, review_text
FROM yelp_reviews
WHERE cool = (
    SELECT MAX(cool)
    FROM yelp_reviews
);

-- 4 Find the number of reviews received by Lo-Lo's Chicken & Waffles for each star.
-- Output the number of stars along with the corresponding number of reviews.
-- Sort records by stars in ascending order.
SELECT stars, COUNT(*) AS review_count
FROM yelp_reviews
WHERE business_name = 'Lo-Lo''s Chicken & Waffles'
GROUP BY stars
ORDER BY stars ASC;

-- 5 Find the number of 5-star reviews earned by Lo-Lo's Chicken & Waffles.
SELECT 
    count(*) AS n_5star_reviews
FROM yelp_reviews
WHERE 
    business_name LIKE 'Lo-Lo_s Chicken & Waffles' AND 
    stars = 5;
    
    -- 6 Cast stars column values to integer and return with all other column values. Be aware that certain rows contain non integer values.
-- You need to remove such rows. You are allowed to examine and explore the dataset before making a solution.
SELECT business_name, review_id, user_id, CAST(stars AS UNSIGNED) AS stars, review_date, review_text, funny, useful, cool
FROM yelp_reviews
WHERE stars REGEXP '^[0-9]+$';  -- Adjust REGEXP for your SQL dialect if necessary

-- 7 Find records with the value '?' in the stars column.
SELECT DISTINCT stars
FROM yelp_reviews;

SELECT *, HEX(stars) AS hex_value
FROM yelp_reviews;

SELECT *, HEX(stars) AS hex_value
FROM yelp_reviews
WHERE stars = '?';

-- 8 Find the number of entries per star.
-- Output each number of stars along with the corresponding number of entries.
-- Order records by stars in ascending order.
SELECT stars, COUNT(*) AS entry_count
FROM yelp_reviews
GROUP BY stars
ORDER BY stars ASC;


-- 9 Find the top 5 businesses with the most check-ins.
-- Output the business id along with the number of check-ins.
SELECT business_id, SUM(checkins) AS total_checkins
FROM yelp_checkin
GROUP BY business_id
ORDER BY total_checkins DESC
LIMIT 5;
-- 10 Find the average number of stars for each state.
-- Output the state name along with the corresponding average number of stars.
SELECT state, AVG(stars) AS average_stars
FROM yelp_business
GROUP BY state
ORDER BY state ASC;


-- 11 Find the number of open businesses.
SELECT COUNT(*) AS open_business_count
FROM yelp_business
WHERE is_open = 1;

-- 12 Find the review count for one-star businesses from yelp.
-- Output the name along with the corresponding review count.
SELECT 
    name, 
    SUM(review_count) AS total_review_count 
FROM yelp_business 
WHERE stars = 1 
GROUP BY 
    name;

-- 13 Find the top business categories based on the total number of reviews.
--  Output the category along with the total number of reviews. Order by total reviews in descending order.
WITH RECURSIVE num (n) AS (
    -- Create a list from 1 to 15
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM num WHERE n < 15
)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(categories, ';', n), ';', -1) ) AS category,
    SUM(review_count) AS review_cnt
FROM 
    yelp_business
INNER JOIN 
    num ON n <= CHAR_LENGTH(categories) - CHAR_LENGTH(REPLACE(categories, ';', '')) + 1
GROUP BY 
    category
ORDER BY 
    review_cnt DESC;

-- 14 Find the top 5 businesses with most reviews. Assume that each row has a unique business_id such that the total reviews for each
--  business is listed on each row.
--  Output the business name along with the total number of reviews and order your results by the total reviews in descending order
-- columns needed: review_count, name
-- total reviews on each row, so no need for sum or group by
-- output: name, review_count, order by review_count, limit 5

SELECT name, review_count
FROM yelp_business
ORDER BY review_count DESC
LIMIT 5;

-- 15 Find the top 5 states with the most 5 star businesses. Output the state name along with the number of 5-star businesses and 
-- order records by the number of 5-star businesses in descending order. In case there are ties in the number of businesses, 
-- return all the unique states. If two states have the same result, sort them in alphabetical order.
WITH state_counts AS (
SELECT state,COUNT(business_id) AS five_star_counts,
RANK() OVER (ORDER BY COUNT(business_id) DESC) AS state_rank
FROM yelp_business
WHERE stars = 5
GROUP BY state)
SELECT state,five_star_counts
FROM state_counts
WHERE state_rank <= 5
ORDER BY five_star_counts DESC, 
state ASC;


-- 16 Find Yelp food reviews containing any of the keywords: 'food', 'pizza', 'sandwich', or 'burger'. 
-- List the business name, address, and the state which satisfies the requirement.
SELECT b.name, b.address, b.state 
FROM yelp_business AS b
JOIN yelp_reviews AS r ON b.name = r.business_name
WHERE r.review_text LIKE '%food%' 
OR r.review_text LIKE '%pizza%' 
OR r.review_text LIKE '%sandwich%' 
OR r.review_text LIKE '%burger%';














