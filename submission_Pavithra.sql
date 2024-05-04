/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
     
SELECT state, COUNT(*) AS customer_count
FROM customer_t
GROUP BY state;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

-- Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. Now average the feedback for each quarter. */

SELECT quarter_number,
AVG(
    CASE
      WHEN customer_feedback = 'Very Bad' THEN 1
      WHEN customer_feedback = 'Bad' THEN 2
      WHEN customer_feedback = 'Okay' THEN 3
      WHEN customer_feedback = 'Good' THEN 4
      WHEN customer_feedback = 'Very Good' THEN 5
      ELSE NULL
    END
  ) AS average_rating
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
SELECT
  quarter_number,
  COUNT(*) AS total_feedback,
  SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) AS very_bad_count,
  SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) AS bad_count,
  SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) AS okay_count,
  SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) AS good_count,
  SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) AS very_good_count,
  (SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_very_bad,
  (SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_bad,
  (SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_okay,
  (SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_good,
  (SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_very_good
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;
      


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT vehicle_maker,COUNT(DISTINCT customer_id) AS customer_count
FROM order_t
JOIN product_t ON order_t.product_id = product_t.product_id
GROUP BY vehicle_maker
ORDER BY customer_count DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT state, vehicle_maker, make_rank
FROM (
SELECT c.state, p.vehicle_maker,
RANK() OVER (PARTITION BY c.state ORDER BY COUNT(DISTINCT o.customer_id) DESC) AS make_rank
FROM order_t o
JOIN product_t p ON o.product_id = p.product_id
JOIN customer_t c ON o.customer_id = c.customer_id
GROUP BY c.state, p.vehicle_maker
) AS RankedVehicleMakes
WHERE make_rank = 1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT quarter_number,
COUNT(*) AS order_count
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.*/
      
SELECT quarter_number, total_revenue,
LAG(total_revenue) OVER (ORDER BY quarter_number) AS prev_quarter_revenue,
(total_revenue - LAG(total_revenue) OVER (ORDER BY quarter_number)) / LAG(total_revenue) OVER (ORDER BY quarter_number) * 100 AS qoq_percentage_change
FROM (
  SELECT
    quarter_number,
    SUM(vehicle_price * quantity) AS total_revenue
    FROM order_t
    GROUP BY quarter_number
) AS QuarterlyRevenue
ORDER BY quarter_number;      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT
  quarter_number,
  SUM(vehicle_price * quantity) AS total_revenue,
  COUNT(*) AS order_count
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT c.credit_card_type,
AVG(o.discount) AS average_discount
FROM order_t o
JOIN customer_t c ON o.customer_id = c.customer_id
GROUP BY c.credit_card_type;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.*/
    
SELECT quarter_number,
AVG(DATEDIFF(ship_date, order_date)) AS average_shipping_time
FROM order_t
GROUP BY quarter_number;


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



