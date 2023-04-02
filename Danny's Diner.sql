/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id,  Sum(m.price) as total_price
FROM Dannys_diner.dbo.sales as s
inner join Dannys_diner.dbo.menu as m
	on s.product_id = m. product_id
Group by s.customer_id
order by total_price desc

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, count(DISTINCT order_date) AS Day_visited
FROM Dannys_diner.dbo.sales
Group by Customer_id
order by Day_visited

-- 3. What was the first item from the menu purchased by each customer?
SELECT s.customer_id,  MIN(s.order_date) as First_order_date, m.product_name
FROM Dannys_diner.dbo.sales as s
inner join Dannys_diner.dbo.menu as m
	on s.product_id = m. product_id
Group by s.customer_id, m.product_name
order by First_order_date asc

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_id, m.Product_name, Count(s.product_id) as Time_purchased
FROM Dannys_diner.dbo.sales as s
inner join Dannys_diner.dbo.menu as m
	on s.product_id = m. product_id
Group by  m.product_name, m.product_id
order by Time_purchased desc

-- 5. Which item was the most popular for each customer?
SELECT s.customer_id, m.product_name, COUNT(*) as Most_popular
FROM Dannys_diner.dbo.sales s
INNER JOIN Dannys_diner.dbo.menu m 
	ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING COUNT(*) = (
  SELECT MAX(cnt)
  FROM (
    SELECT COUNT(*) as cnt
    FROM Dannys_diner.dbo.sales s2
    WHERE s2.customer_id = s.customer_id
    GROUP BY s2.product_id
  ) as counts
)

-- 6. Which item was purchased first by the customer after they became a member?
SELECT s.customer_id, m.product_name, s.order_date
FROM ((Dannys_diner.dbo.sales as s
inner join Dannys_diner.dbo.menu as m
	on s.product_id = m. product_id)
inner join Dannys_diner.dbo.members as mem
      on mem.customer_id = s.customer_id)
 where mem.join_date> s.order_date
Group by s.customer_id, m.product_name, s.order_date
order by s.order_date asc

-- 7. Which item was purchased just before the customer became a member?
SELECT s.customer_id, m.product_name, s.order_date
FROM ((Dannys_diner.dbo.sales as s
inner join Dannys_diner.dbo.menu as m
	on s.product_id = m. product_id)
inner join Dannys_diner.dbo.members as mem
      on mem.customer_id = s.customer_id)
 where mem.join_date < s.order_date
Group by s.customer_id, m.product_name, s.order_date
order by s.order_date desc

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, m.product_name, m.product_id ,Sum(m.price) as Amount_purchased
FROM ((Dannys_diner.dbo.sales as s
inner join Dannys_diner.dbo.menu as m
	on s.product_id = m. product_id)
inner join Dannys_diner.dbo.members as mem
      on mem.customer_id = s.customer_id)
 where mem.join_date < s.order_date
Group by s.customer_id, m.product_name, m.product_id
order by  Amount_purchased desc


--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, 
       SUM(CASE
           WHEN m.product_name = 'sushi' THEN m.price * 20
          ELSE m.price * 10
       END) AS points
FROM Dannys_diner.dbo.sales s
INNER JOIN Dannys_diner.dbo.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id, 
       SUM(CASE 
             WHEN s.order_date <= DATEADD(DAY, 7, mem.join_date) THEN 
               CASE 
                 WHEN m.product_name = 'sushi' THEN m.price * 20 * 2 
                 ELSE m.price * 20 * 2 
               END 
             ELSE 
               CASE 
                 WHEN m.product_name = 'sushi' THEN m.price * 20 
                 ELSE m.price * 20 
               END 
           END) AS points
FROM Dannys_diner.dbo.sales as s
JOIN Dannys_diner.dbo.menu as m
	ON s.product_id = m.product_id
LEFT JOIN Dannys_diner.dbo.members as mem 
	ON s.customer_id = mem.customer_id
GROUP BY s.customer_id;



