-- Q1. How many total records are present in the Orders dataset?
SELECT COUNT(*) FROM orders;

-- Q2. Are there any missing values in Sales, Discount, Profit, or Quantity?
SELECT * 
FROM orders
WHERE sales IS NULL OR discount IS NULL OR profit IS NULL OR quantity IS NULL;

-- Q3. Are there duplicate Order IDs?
SELECT orderID, COUNT(*) 
FROM orders 
GROUP BY orderID 
HAVING COUNT(*) > 1;

-- Q4. How many unique orders are there in total?
SELECT COUNT(DISTINCT orderid) AS total_orders 
FROM orders;

-- Q5. What is the earliest and latest order date in the dataset?
SELECT MIN(orderdate), MAX(orderdate) 
FROM orders;

-- Q6. How many orders resulted in a loss (negative profit)?
SELECT COUNT(*) AS loss_count 
FROM orders 
WHERE profit < 0;

-- Q7. What are the Total Sales, Total Profit, and Total Orders?
SELECT ROUND(SUM(sales),2) AS Total_sales,
       ROUND(SUM(profit),2) AS Total_profit,
       COUNT(DISTINCT orderid) AS total_orders
FROM orders;

-- Q8. What is the sales distribution across different Regions?
SELECT region, SUM(sales) AS revenue 
FROM orders 
GROUP BY region 
ORDER BY revenue DESC;

-- Q9. Which are the Top 5 Products by Sales?
SELECT productname, SUM(sales) AS revenue 
FROM orders 
GROUP BY productname 
ORDER BY revenue DESC 
LIMIT 5;

-- Q10. What is the Monthly Sales Trend?
SELECT strftime('%Y-%m', DATE(orderdate)) AS month, 
       SUM(sales) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- Q11. Who are the Top 10 Customers by Sales Revenue?
SELECT customername, SUM(sales) AS revenue 
FROM orders 
GROUP BY customername 
ORDER BY revenue DESC 
LIMIT 10;

-- Q12. How does Discount affect Profit?
SELECT discount, SUM(profit) AS total_profit 
FROM orders 
GROUP BY discount 
ORDER BY total_profit DESC;

-- Q13. What is the Average Order Value?
SELECT (SUM(sales)/COUNT(DISTINCT orderid)) AS avg_order_value 
FROM orders;

-- Q14. Which are the Top 10 Loss-Making Products?
SELECT productname, ROUND(SUM(profit),2) AS total_loss 
FROM orders 
GROUP BY productname 
HAVING SUM(profit) < 0 
ORDER BY total_loss ASC 
LIMIT 10;

-- Q15. What is the Sales Contribution of each Customer Segment?
SELECT segment, SUM(sales) AS revenue 
FROM orders 
GROUP BY segment 
ORDER BY revenue DESC;

-- Q16. Find the Top 3 Products by Sales in Each Region.
WITH productsale AS (
    SELECT region,
           SUM(sales) AS totalsale,
           productname,
           RANK() OVER(PARTITION BY region ORDER BY SUM(sales) DESC) AS salesrank
    FROM orders
    GROUP BY region, productname
)
SELECT region, productname, totalsale, salesrank
FROM productsale
WHERE salesrank <= 3
ORDER BY region, salesrank;

-- Q17. Calculate Month-on-Month Growth (%) of Sales.
WITH monthlysale AS (
    SELECT strftime('%Y-%m', DATE(orderdate)) AS month,
           SUM(sales) AS totalsale
    FROM orders
    GROUP BY month
    ORDER BY month
)
SELECT month,
       totalsale,
       LAG(totalsale) OVER(ORDER BY month) AS previousmonthsale,
       ((totalsale - LAG(totalsale) OVER(ORDER BY month)) / 
        LAG(totalsale) OVER(ORDER BY month)) * 100 AS growthpercentage
FROM monthlysale
ORDER BY month;

-- Q18. Find the Customer with the Highest Profit in Each Segment.
WITH customerprofit AS (
    SELECT customername,
           segment,
           SUM(profit) AS totalprofit,
           RANK() OVER(PARTITION BY segment ORDER BY SUM(profit) DESC) AS profitrank
    FROM orders
    GROUP BY segment, customername
)
SELECT customername, segment, totalprofit, profitrank
FROM customerprofit
WHERE profitrank = 1;

-- Q19. Calculate Cumulative Sales Over Time (Running Total).
WITH monthlysales AS (
    SELECT strftime('%Y-%m', DATE(orderdate)) AS month,
           SUM(sales) AS totalsale
    FROM orders
    GROUP BY month
)
SELECT month,
       totalsale,
       SUM(totalsale) OVER(ORDER BY month) AS cumulativesales
FROM monthlysales
ORDER BY month;

-- Q20. Find the Average Discount per Category vs Overall Average Discount.
SELECT category,
       AVG(discount) AS avgdiscount,
       (SELECT AVG(discount) FROM orders) AS overalldiscount,
       AVG(discount) - (SELECT AVG(discount) FROM orders) AS difference
FROM orders
GROUP BY category;
