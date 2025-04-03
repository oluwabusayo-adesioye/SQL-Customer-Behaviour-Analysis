SELECT*
FROM [JadaStores Customer Behavior Table]

--Which membership type generates the highest average spending, and how does satisfaction level vary across types?
WITH MembershipStats AS
						(
						  SELECT Membership_Type, 
								 AVG(Total_spend) AS avg_spending, 
								 COUNT(*) AS total_customers, 
								 SUM(IIF(Satisfaction_level = 'Satisfied', 1, 0)) AS satisfied_customers
						  FROM [JadaStores Customer Behavior Table]
						  GROUP BY Membership_Type
					    )
SELECT Membership_type,
	   avg_spending,
	   (satisfied_customers * 100.0 / total_customers) AS satisfaction_rate
FROM MembershipStats
ORDER BY avg_spending DESC;

--Do customers who receive discounts spend more on average than those who don’t?
SELECT Discount_Applied, 
	   AVG(Total_spend) AS avg_spending
FROM [JadaStores Customer Behavior Table]
GROUP BY Discount_Applied;

--Which cities have the highest percentage of satisfied customers, and how does spending differ across locations?
SELECT DISTINCT City,
				SUM(IIF(Satisfaction_level = 'Satisfied', 1, 0))
				OVER (PARTITION BY City) * 100.0 / COUNT(*)
				OVER (PARTITION BY City) AS satisfaction_rate,
				AVG(Total_spend)
				OVER (PARTITION BY City) AS avg_spending
FROM [JadaStores Customer Behavior Table]
ORDER BY satisfaction_rate DESC;

--Which customers are at risk of churning based on inactivity (i.e., no purchase in 40+ days) and high past spending?
SELECT Customer_ID,
	   Total_Spend,
	   Days_Since_Last_Purchase,
	   Membership_Type,
	   CASE WHEN Days_Since_Last_Purchase > 90 THEN 'High Risk'
			WHEN Days_Since_Last_Purchase BETWEEN 50 AND 90 THEN 'Moderate Risk'
			ELSE 'Low Risk'
	   END AS Churn_risk,
	   IIF(Total_spend >
						(
						  SELECT AVG(Total_spend)
						  FROM [JadaStores Customer Behavior Table]
						), 'High Value', 'Regular') AS Customer_segment
FROM [JadaStores Customer Behavior Table]
WHERE Days_Since_Last_Purchase > 40
ORDER BY Total_Spend DESC;