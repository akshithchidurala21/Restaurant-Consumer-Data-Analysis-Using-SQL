CREATE DATABASE PROJECTDB;
USE PROJECTDB;

CREATE TABLE CONSUMERS (
    Consumer_ID VARCHAR(20) PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Smoker VARCHAR(20),
    Drink_Level VARCHAR(50),
    Transportation_Method VARCHAR(50),
    Marital_Status VARCHAR(50),
    Children VARCHAR(50),
    Age INT CHECK (Age >= 0 AND Age <= 120),
    Occupation VARCHAR(100),
    Budget VARCHAR(50)
);


CREATE TABLE CONSUMER_PREFERENCES (
    Consumer_ID VARCHAR(20),
    Preferred_Cuisine VARCHAR(100),
    PRIMARY KEY (Consumer_ID, Preferred_Cuisine),
    FOREIGN KEY (Consumer_ID) REFERENCES CONSUMERS (Consumer_ID)
);


CREATE TABLE RESTAURANTS (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(200),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Zip_Code VARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Alcohol_Service VARCHAR(50),
    Smoking_Allowed VARCHAR(50),
    Price VARCHAR(50),
    Franchise VARCHAR(50),
    Area VARCHAR(50),
    Parking VARCHAR(50)
);


CREATE TABLE RESTAURANT_CUISINES (
    Restaurant_ID INT,
    Cuisine VARCHAR(100),
    PRIMARY KEY (Restaurant_ID, Cuisine),
    FOREIGN KEY (Restaurant_ID) REFERENCES RESTAURANTS (Restaurant_ID)
);


CREATE TABLE RATINGS (
    Consumer_ID VARCHAR(20),
    Restaurant_ID INT,
    Overall_Rating TINYINT CHECK (Overall_Rating BETWEEN 0 AND 2),
    Food_Rating TINYINT CHECK (Food_Rating BETWEEN 0 AND 2),
    Service_Rating TINYINT CHECK (Service_Rating BETWEEN 0 AND 2),
    PRIMARY KEY (Consumer_ID, Restaurant_ID),
    FOREIGN KEY (Consumer_ID) REFERENCES CONSUMERS (Consumer_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES RESTAURANTS (Restaurant_ID)
);


-- Using the WHERE clause to filter data based on specific criteria.

-- 1.	List all details of consumers who live in the city of 'Cuernavaca'.
SELECT * FROM CONSUMERS
WHERE CITY='CUERNAVACA';

-- 2.	Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
SELECT CONSUMER_ID, AGE, OCCUPATION
FROM CONSUMERS
WHERE OCCUPATION='STUDENT' AND SMOKER='YES';

-- 3.	List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
SELECT NAME, CITY, ALCOHOL_SERVICE, PRICE
FROM RESTAURANTS
WHERE ALCOHOL_SERVICE = 'WINE & BEER' AND PRICE = 'MEDIUM';

-- 4.	Find the names and cities of all restaurants that are part of a 'Franchise'.
SELECT NAME, CITY
FROM RESTAURANTS
WHERE FRANCHISE = 'YES';

-- 5.	Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary).
SELECT CONSUMER_ID, RESTAURANT_ID, OVERALL_RATING
FROM RATINGS
WHERE OVERALL_RATING = '2';



-- Questions JOINs with Subqueries

-- 1.List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
SELECT R.NAME, R.CITY 
FROM RESTAURANTS R
JOIN (
SELECT DISTINCT Restaurant_ID
FROM RATINGS
WHERE Overall_Rating = 2
) AS S
ON R.Restaurant_ID = S.Restaurant_ID;

-- 2.Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
SELECT C.Consumer_ID, C.Age
FROM CONSUMERS C
JOIN (SELECT DISTINCT R.Restaurant_ID, RA.Consumer_ID 
FROM RESTAURANTS R 
JOIN RATINGS RA 
ON R.Restaurant_ID = RA.Restaurant_ID 
WHERE R.City = 'San Luis Potosi') AS S
ON C.Consumer_ID = S.Consumer_ID;


-- 3.List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
SELECT R.NAME
FROM RESTAURANTS R
JOIN (SELECT DISTINCT RC.Restaurant_ID 
FROM RESTAURANT_CUISINES RC 
JOIN RATINGS RA
ON RC.Restaurant_ID = RA.Restaurant_ID 
WHERE RC.Cuisine = 'Mexican' AND RA.Consumer_ID = 'U1001') AS S
ON R.Restaurant_ID = S.Restaurant_ID;


-- 4.	Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget
SELECT * 
FROM CONSUMERS C
JOIN (SELECT CONSUMER_ID 
FROM consumer_preferences CP
WHERE CP.PREFERRED_CUISINE = 'AMERICAN')S
ON C.CONSUMER_ID = S.Consumer_ID
WHERE C.BUDGET = 'MEDIUM';

-- 5.List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
SELECT R.NAME, R.CITY
FROM RESTAURANTS R
JOIN( SELECT RESTAURANT_ID 
FROM RATINGS 
WHERE FOOD_RATING < (SELECT AVG(FOOD_RATING) FROM RATINGS)) AS S
ON R.RESTAURANT_ID = S.RESTAURANT_ID;

-- 6.Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
SELECT C.CONSUMER_ID, C.AGE, C.OCCUPATION
FROM CONSUMERS C
JOIN(
SELECT DISTINCT CONSUMER_ID
FROM RATINGS ) AS R
ON C.CONSUMER_ID = R .CONSUMER_ID
WHERE C.CONSUMER_ID NOT IN (
SELECT DISTINCT RA.CONSUMER_ID
FROM RATINGS RA
JOIN restaurant_cuisines RC
ON RC.RESTAURANT_ID = RA.RESTAURANT_ID
WHERE RC.CUISINE = 'ITALIAN');


-- 7.	List restaurants (Name) that have received ratings from consumers older than 30.
SELECT R.NAME 
FROM restaurants R
JOIN (
SELECT RESTAURANT_ID 
FROM RATINGS RA
JOIN CONSUMERS C
ON RA.CONSUMER_ID = C.CONSUMER_ID
WHERE C.AGE>30) AS S
ON R.RESTAURANT_ID = S.RESTAURANT_ID;

-- 8.Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
SELECT C.CONSUMER_ID, C.OCCUPATION
FROM CONSUMERS C
JOIN(
SELECT CP.CONSUMER_ID 
FROM consumer_preferences CP
JOIN RATINGS R
ON CP.CONSUMER_ID = R.CONSUMER_ID
WHERE CP.Preferred_Cuisine = 'MEXICAN' AND R.OVERALL_RATING = '0') AS S
ON S.CONSUMER_ID = C.CONSUMER_ID;

-- 9.List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
SELECT R.NAME, R.CITY
FROM RESTAURANTS R
JOIN (
SELECT DISTINCT RC.RESTAURANT_ID
FROM restaurant_cuisines RC
JOIN RESTAURANTS R2
ON RC.Restaurant_ID = R2.Restaurant_ID
WHERE RC.Cuisine='PIZZERIA' AND R2.CITY IN (SELECT DISTINCT CITY FROM CONSUMERS WHERE OCCUPATION = 'STUDENT')) AS S
ON S.RESTAURANT_ID = R.RESTAURANT_ID;

-- 10.	Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
SELECT C.CONSUMER_ID, C.AGE
FROM CONSUMERS C
JOIN(
SELECT CONSUMER_ID
FROM RATINGS RA
JOIN restaurants R
ON R.Restaurant_ID = RA.RESTAURANT_ID
WHERE R.PARKING= 'NONE') AS S
ON C.CONSUMER_ID = S.CONSUMER_ID
WHERE C.DRINK_LEVEL='SOCIAL DRINKER';



-- Questions Emphasizing WHERE Clause and Order of Execution

-- 1.List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. Show only students who have rated more than 2 restaurants.
SELECT R.CONSUMER_ID, COUNT(R.RESTAURANT_ID) AS RATEDCOUNT
FROM RATINGS R
JOIN CONSUMERS C
ON C.CONSUMER_ID = R.CONSUMER_ID
WHERE C.OCCUPATION ='STUDENT'
GROUP BY R.CONSUMER_ID
HAVING COUNT(R.RESTAURANT_ID)>2;

-- 2.We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). 
--   List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be 
--   exactly 2 and who use 'Public' transportation.
SELECT C.CONSUMER_ID, C.AGE, AGE/10 AS ENGAGEMENT_SCORE
FROM CONSUMERS C
WHERE AGE/10 = '2' AND C.TRANSPORTATION_METHOD = 'PUBLIC';

-- 3.For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, 
--   and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated 
--   average Overall_Rating is greater than 1.0.
SELECT R.NAME, R.CITY, AVG(RA.OVERALL_RATING) AS AVGRATING
FROM restaurants R
JOIN RATINGS RA
ON RA.Restaurant_ID = R.Restaurant_ID
WHERE R.CITY = 'CUERNAVACA'
GROUP BY R.Restaurant_ID, R.NAME, R.CITY
HAVING AVG(RA.OVERALL_RATING > 1.0);

-- 4.Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their 
--    Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.
SELECT C.CONSUMER_ID, C.AGE
FROM CONSUMERS C
JOIN RATINGS R 
ON C.CONSUMER_ID = R.CONSUMER_ID
WHERE C.MARITAL_STATUS='MARRIED' AND R.FOOD_RATING = R.SERVICE_RATING
AND R.OVERALL_RATING =2;

-- 5.List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' and
--   have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.
SELECT C.CONSUMER_ID, C.AGE, R.NAME
FROM CONSUMERS C
JOIN RATINGS RA
ON C.CONSUMER_ID = RA.CONSUMER_ID
JOIN RESTAURANTS R
ON R.RESTAURANT_ID = RA.RESTAURANT_ID
WHERE C.OCCUPATION = 'EMPLOYED' AND RA.FOOD_RATING =0 AND R.CITY='CIUDAD VICTORIA';

SELECT C.CONSUMER_ID, C.AGE, R.NAME
FROM CONSUMERS C
JOIN RATINGS RA
ON C.CONSUMER_ID = RA.CONSUMER_ID
JOIN RESTAURANTS R
ON R.RESTAURANT_ID = RA.RESTAURANT_ID
WHERE C.OCCUPATION = 'EMPLOYED'
AND C.Consumer_ID IN (
    SELECT DISTINCT RAT.Consumer_ID 
    FROM RATINGS RAT 
    JOIN RESTAURANTS RES ON RAT.Restaurant_ID = RES.Restaurant_ID 
    WHERE RAT.Food_Rating = 0 
    AND RES.City = 'Ciudad Victoria'
);




-- Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures
-- 1.Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant 
--    they have rated with an Overall_Rating of 2.
WITH CTE_CONSUMERS AS (
    SELECT Consumer_ID, Age
    FROM CONSUMERS
    WHERE City = 'San Luis Potosi'
)
SELECT DISTINCT C.Consumer_ID, C.Age, R.Name
FROM CTE_CONSUMERS C
JOIN RATINGS RA
    ON C.Consumer_ID = RA.Consumer_ID
JOIN RESTAURANTS R
    ON RA.Restaurant_ID = R.Restaurant_ID
JOIN RESTAURANT_CUISINES RC
    ON R.Restaurant_ID = RC.Restaurant_ID
WHERE RC.Cuisine = 'Mexican'
AND RA.Overall_Rating = 2;

-- 2.For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating.
--    (Use a derived table to get consumers who have rated).
SELECT CT.OCCUPATION, CT.AVGAGE
FROM (
SELECT OCCUPATION, AVG(AGE) AS AVGAGE
FROM CONSUMERS C
JOIN RATINGS R
ON C.CONSUMER_ID = R.CONSUMER_ID
GROUP BY OCCUPATION
) AS CT;

-- 3.Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating 
--    (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.
WITH CTE_RATINGS AS (
SELECT RA.Restaurant_ID, RA.Consumer_ID, RA.Overall_Rating
FROM RATINGS RA
JOIN RESTAURANTS R
ON RA.Restaurant_ID = R.Restaurant_ID
WHERE R.City = 'Cuernavaca'
)
SELECT Restaurant_ID, Consumer_ID, Overall_Rating,
       RANK() OVER (PARTITION BY Restaurant_ID ORDER BY Overall_Rating DESC) AS RatingRank
FROM CTE_RATINGS;

-- 4.For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the 
--    average Overall_Rating given by that specific consumer across all their ratings.
SELECT DT.CONSUMER_ID, DT.RESTAURANT_ID, DT.OVERALL_RATING, DT.AVG_RATING
FROM (
SELECT R.CONSUMER_ID, RESTAURANT_ID, OVERALL_RATING, AVG(OVERALL_RATING) OVER (PARTITION BY R.Consumer_ID) AS AVG_RATING
FROM RATINGS R
JOIN CONSUMERS C
ON R.CONSUMER_ID = C.CONSUMER_ID
) AS DT;

-- 5.Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, 
--   list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table 
--   (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).
WITH CTE_STUDENTS AS (
    SELECT Consumer_ID
    FROM CONSUMERS
    WHERE Occupation = 'Student'
    AND Budget = 'Low'
),
CTE_PREF AS (
SELECT CP.Consumer_ID, CP.Preferred_Cuisine, ROW_NUMBER() OVER (
PARTITION BY CP.Consumer_ID
ORDER BY CP.Consumer_ID, CP.Preferred_Cuisine
) AS RN
FROM CONSUMER_PREFERENCES CP
JOIN CTE_STUDENTS S
ON CP.Consumer_ID = S.Consumer_ID
)
SELECT Consumer_ID, Preferred_Cuisine, RN AS Preference_Rank
FROM CTE_PREF
WHERE RN <= 3;


-- 6.Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating,
--   and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if 
--   rating time isn't available). Use a derived table to filter for the consumer's ratings first.
SELECT T.RESTAURANT_ID, T.OVERALL_RATING, 
LEAD(T.OVERALL_RATING) 
OVER (ORDER BY T.RESTAURANT_ID) AS NEXT_OVERALL_RATING
 FROM (SELECT RESTAURANT_ID, OVERALL_RATING 
 FROM RATINGS 
 WHERE CONSUMER_ID = 'U1008') AS T;



-- 7.Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City 
--    of all Mexican restaurants that have an average Overall_Rating greater than 1.5.
CREATE VIEW HIGHLYRATEDMEXICANRESTAURANTS AS
SELECT 
    R.RESTAURANT_ID,
    R.NAME,
    R.CITY,
    (SELECT AVG(OVERALL_RATING) 
     FROM RATINGS 
     WHERE RESTAURANT_ID = R.RESTAURANT_ID) AS AVG_RATING
FROM RESTAURANTS R
JOIN RESTAURANT_CUISINES RC
ON R.RESTAURANT_ID = RC.RESTAURANT_ID
WHERE RC.CUISINE = 'Mexican'
HAVING AVG_RATING > 1.5;
SELECT * FROM HIGHLYRATEDMEXICANRESTAURANTS;


-- 8.First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' 
-- cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view
WITH MEXCONSUMERS AS 
(SELECT CONSUMER_ID 
FROM CONSUMER_PREFERENCES 
WHERE PREFERRED_CUISINE = 'Mexican') 
SELECT MC.CONSUMER_ID 
FROM MEXCONSUMERS MC 
WHERE MC.CONSUMER_ID NOT IN (SELECT DISTINCT RAT.CONSUMER_ID 
							FROM RATINGS RAT 
                            JOIN HIGHLYRATEDMEXICANRESTAURANTS HR 
                            ON RAT.RESTAURANT_ID = HR.RESTAURANT_ID);

-- 9.Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating 
--  as input. It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the 
--   Overall_Rating meets or exceeds the threshold.
DELIMITER //
 CREATE PROCEDURE GETRESTAURANTRATINGSABOVETHRESHOLD(IN REST_ID INT, IN MIN_RATING INT) 
 BEGIN 
 SELECT CONSUMER_ID, OVERALL_RATING, FOOD_RATING, SERVICE_RATING 
 FROM RATINGS 
 WHERE RESTAURANT_ID = REST_ID AND OVERALL_RATING >= MIN_RATING; 
 END//
 DELIMITER ;
CALL GETRESTAURANTRATINGSABOVETHRESHOLD(132584, 1);



-- 10.Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating,
--    include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.
WITH RANKED AS (
SELECT RC.CUISINE, R.NAME, R.CITY, RAT.OVERALL_RATING,
RANK() OVER (PARTITION BY RC.CUISINE ORDER BY RAT.OVERALL_RATING DESC) AS RN
FROM RESTAURANT_CUISINES RC
JOIN RATINGS RAT ON RC.RESTAURANT_ID = RAT.RESTAURANT_ID
JOIN RESTAURANTS R ON R.RESTAURANT_ID = RAT.RESTAURANT_ID
)
SELECT CUISINE, NAME, CITY, OVERALL_RATING
FROM RANKED
WHERE RN <= 2;


-- 11.First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. 
--    Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers,
--    list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.
CREATE VIEW CONSUMERAVERAGERATINGS AS 
SELECT CONSUMER_ID, AVG(OVERALL_RATING) AS AVG_RATING 
FROM RATINGS 
GROUP BY CONSUMER_ID;
WITH TOP5 AS (
SELECT CONSUMER_ID, AVG_RATING
FROM CONSUMERAVERAGERATINGS
ORDER BY AVG_RATING DESC
LIMIT 5
)
SELECT T.CONSUMER_ID, T.AVG_RATING,
(SELECT COUNT(*) 
 FROM RATINGS RA
 JOIN RESTAURANT_CUISINES RC 
 ON RA.RESTAURANT_ID = RC.RESTAURANT_ID
 WHERE RC.CUISINE = 'Mexican'
 AND RA.CONSUMER_ID = T.CONSUMER_ID
) AS MEXICAN_RESTAURANTS_RATED
FROM TOP5 T;


-- 12.	Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.

-- The procedure should:
-- 1.Determine the consumer's "Spending Segment" based on their Budget:
-- 	'Low' -> 'Budget Conscious'
-- 	'Medium' -> 'Moderate Spender'
--  'High' -> 'Premium Spender'
-- NULL or other -> 'Unknown Budget'

-- 2.For all restaurants rated by this consumer:
-- 	List the Restaurant_Name.
-- 	The Overall_Rating given by this consumer.
-- 	The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
-- 	A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average',
--    'At Average', or 'Below Average' compared to the restaurant's overall average rating.
-- 	Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1).
DELIMITER $$
CREATE PROCEDURE GETCONSUMERSEGMENTANDRESTAURANTPERFORMANCE(IN CID VARCHAR(20))
BEGIN
WITH SEG AS (
SELECT CONSUMER_ID,
CASE 
WHEN BUDGET='Low' THEN 'Budget Conscious'
WHEN BUDGET='Medium' THEN 'Moderate Spender'
WHEN BUDGET='High' THEN 'Premium Spender'
ELSE 'Unknown Budget'
END AS SPENDING_SEGMENT
FROM CONSUMERS
WHERE CONSUMER_ID = CID
),
RESTS AS (
SELECT R.NAME,
RA.OVERALL_RATING,
(SELECT AVG(OVERALL_RATING) FROM RATINGS WHERE RESTAURANT_ID = RA.RESTAURANT_ID) AS AVG_REST_RATING,
CASE
WHEN RA.OVERALL_RATING > (SELECT AVG(OVERALL_RATING) FROM RATINGS WHERE RESTAURANT_ID = RA.RESTAURANT_ID) THEN 'Above Average'
WHEN RA.OVERALL_RATING = (SELECT AVG(OVERALL_RATING) FROM RATINGS WHERE RESTAURANT_ID = RA.RESTAURANT_ID) THEN 'At Average'
ELSE 'Below Average'
END AS PERFORMANCE_FLAG,
RANK() OVER (ORDER BY RA.OVERALL_RATING DESC) AS RATING_RANK
FROM RATINGS RA
JOIN RESTAURANTS R ON RA.RESTAURANT_ID = R.RESTAURANT_ID
WHERE RA.CONSUMER_ID = CID
)
SELECT SEG.SPENDING_SEGMENT AS SEGMENT,
RESTS.NAME AS RESTAURANT_NAME,
RESTS.OVERALL_RATING,
RESTS.AVG_REST_RATING,
RESTS.PERFORMANCE_FLAG,
RESTS.RATING_RANK
FROM SEG, RESTS;

END $$
DELIMITER ;
CALL GETCONSUMERSEGMENTANDRESTAURANTPERFORMANCE('U1008');




