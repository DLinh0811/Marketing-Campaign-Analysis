SELECT 
*
FROM
dbo.products
---------------

SELECT
	ProductID,
	ProductName,
	Price,

	CASE
		WHEN Price < 50 THEN 'Low'
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
		ELSE 'High'
	END AS PriceCategory

FROM dbo.products;

----------------

SELECT 
c.CustomerID,
c.CustomerName,
c.Email,
c.Gender,
c.Age,
g.Country,
g.City

FROM
dbo.customers as c
LEFT JOIN
dbo.geography as g
ON
c.GeographyID = g.GeographyID
ORDER BY
g.Country ASC;

----------------

SELECT
ReviewID,
CustomerID,
ProductID,
ReviewDate,
Rating,
REPLACE(ReviewText, '  ', ' ') ReviewText
FROM
dbo.customer_reviews;

----------------
SELECT
*
FROM
dbo.engagement_data;

UPDATE dbo.engagement_data
SET ContentType = CASE 
    WHEN ContentType LIKE '%social%media%' OR ContentType LIKE '%socialmedia%' 
        THEN 'SOCIAL MEDIA'
    
    WHEN ContentType LIKE 'blog%' 
        THEN 'BLOG'
        
    WHEN ContentType LIKE 'video%' 
        THEN 'VIDEO'
        
    ELSE UPPER(ContentType) 
END;

SELECT
EngagementID,
ContentID,
ContentType,
Likes,
CampaignID,
ProductID,
LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,
RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
FORMAT(CONVERT(DATE,EngagementDate), 'dd-MM-yyy') AS EngagementDate
FROM
dbo.engagement_data
WHERE
ContentType != 'NEWSLETTER';

----------------

SELECT
*
FROM
dbo.customer_journey;

WITH JourneyCTE AS (
    SELECT
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        Stage,
        "Action",
        Duration,
        ROW_NUMBER() OVER (
        PARTITION BY CustomerID, ProductID, VisitDate, Stage, "Action" 
        ORDER BY JourneyID) AS rn
    FROM
        dbo.customer_journey
)

SELECT *
FROM JourneyCTE
WHERE rn > 1
ORDER BY JourneyID

SELECT
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
    COALESCE(Duration, avg_duration) AS Duration
FROM
    (
    SELECT
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        UPPER(Stage) AS Stage,
        Action,
        Duration,
        AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration, 
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
            ORDER BY JourneyID
        ) AS row_num
    FROM
        dbo.customer_journey -- Removed the trailing 'AS'
    ) AS sub_query
WHERE
    row_num = 1;