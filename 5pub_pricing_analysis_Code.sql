create table pubs
( pub_id int primary key,
  pub_name varchar(50),
  city varchar(50),
  state varchar(50),
  country varchar(50));
  
insert into pubs
values
(1, 'The Red Lion', 'London', 'England', 'United Kingdom'),
(2, 'The Dubliner', 'Dublin', 'Dublin', 'Ireland'),
(3, 'The Cheers Bar', 'Boston', 'Massachusetts', 'United States'),
(4, 'La Cerveceria', 'Barcelona', 'Catalonia', 'Spain');

create table beverages
( bev_id int primary key,
  bev_name varchar(50),
  category varchar(50),
  alchol_content float,
  price_per_unit decimal(8,2));
  
insert into beverages
values
(1, 'Guinness', 'Beer', 4.2, 5.99),
(2, 'Jameson', 'Whiskey', 40.0, 29.99),
(3, 'Mojito', 'Cocktail', 12.0, 8.99),
(4, 'Chardonnay', 'Wine', 13.5, 12.99),
(5, 'IPA', 'Beer', 6.8, 4.99),
(6, 'Tequila', 'Spirit', 38.0, 24.99);
  
create table ratings
( rating_id int primary key,
  pub_id int,
  customer_name varchar(50),
  rating float,
  review text,
  foreign key(pub_id) references pubs(pub_id));

insert into ratings
values
(1, 1, 'John Smith', 4.5, 'Great pub with a wide selection of beers.'),
(2, 1, 'Emma Johnson', 4.8, 'Excellent service and cozy atmosphere.'),
(3, 2, 'Michael Brown', 4.2, 'Authentic atmosphere and great beers.'),
(4, 3, 'Sophia Davis', 4.6, 'The cocktails were amazing! Will definitely come back.'),
(5, 4, 'Oliver Wilson', 4.9, 'The wine selection here is outstanding.'),
(6, 4, 'Isabella Moore', 4.3, 'Had a great time trying different spirits.'),
(7, 1, 'Sophia Davis', 4.7, 'Loved the pub food! Great ambiance.'),
(8, 2, 'Ethan Johnson', 4.5, 'A good place to hang out with friends.'),
(9, 2, 'Olivia Taylor', 4.1, 'The whiskey tasting experience was fantastic.'),
(10, 3, 'William Miller', 4.4, 'Friendly staff and live music on weekends.');

create table sales
( sale_id int primary key,
  pub_id int,
  beverage_id int,
  Quantity int,
  transaction_date date,
  foreign key(pub_id) references pubs(pub_id),
  foreign key(beverage_id) references beverages(bev_id));
  
  insert into sales
  values
  (1, 1, 1, 10, '2023-05-01'),
(2, 1, 2, 5, '2023-05-01'),
(3, 2, 1, 8, '2023-05-01'),
(4, 3, 3, 12, '2023-05-02'),
(5, 4, 4, 3, '2023-05-02'),
(6, 4, 6, 6, '2023-05-03'),
(7, 2, 3, 6, '2023-05-03'),
(8, 3, 1, 15, '2023-05-03'),
(9, 3, 4, 7, '2023-05-03'),
(10, 4, 1, 10, '2023-05-04'),
(11, 1, 3, 5, '2023-05-06'),
(12, 2, 2, 3, '2023-05-09'),
(13, 2, 5, 9, '2023-05-09'),
(14, 3, 6, 4, '2023-05-09'),
(15, 4, 3, 7, '2023-05-09'),
(16, 4, 4, 2, '2023-05-09'),
(17, 1, 4, 6, '2023-05-11'),
(18, 1, 6, 8, '2023-05-11'),
(19, 2, 1, 12, '2023-05-12'),
(20, 3, 5, 5, '2023-05-13');


/*1. How many pubs are located in each country??*/

select country,count(pub_id)
from pubs
group by country;

/*2. What is the total sales amount for each pub, including the beverage price and quantity sold?*/

select p.pub_id as Pub_ID,p.pub_name as Pub_Name,sum(s.Quantity*b.price_per_unit) as Total_Sales_Amount
from pubs p 
join sales s 
using(pub_id)
join beverages b
using(bev_id)
group by p.pub_id;

/*3. Which pub has the highest average rating?*/

SELECT p.pub_id, p.pub_name, round(AVG(r.rating),2) AS avg_rating
FROM pubs p 
JOIN ratings r 
ON p.pub_id = r.pub_id
GROUP BY p.pub_id,p.pub_name
ORDER BY avg_rating DESC
LIMIT 1;       


/*4. What are the top 5 beverages by sales quantity across all pubs?*/

select (b.bev_id) as Beverage_ID,sum(s.Quantity) as Sales_Quantity
from sales s 
join beverages b 
using(bev_id)
join pubs p 
using(pub_id)
group by b.bev_id;

WITH cte1 AS (
    SELECT b.bev_id AS Beverage_ID, SUM(s.Quantity) AS Sales_Quantity
    FROM sales s 
    JOIN beverages b USING(bev_id)
    JOIN pubs p USING(pub_id)
    GROUP BY b.bev_id
)

SELECT *
from (	select *,
       DENSE_RANK() OVER (ORDER BY Sales_Quantity DESC) AS drnk
       from cte1
      ) ranked
where drnk<5;      

/*5. How many sales transactions occurred on each date?*/

select transaction_date,count(sale_id) as number_of_sales_transaction
from sales
group by transaction_date;

/*6. Find the name of someone that had cocktails and which pub they had it in.*/

select r.customer_name,r.pub_id,p.pub_name
from ratings r 
join sales s 
using(pub_id)
join beverages b 
using(bev_id)
join pubs p
using(pub_id)
where b.category='Cocktail';

/*7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?*/

select category,round(avg(price_per_unit),2) as Average_Price_Category
from beverages
where category <> 'Spirit'
group by category
;

/*8. Which pubs have a rating higher than the average rating of all pubs?*/

select r.pub_id,p.pub_name,round(avg(r.rating),2) 
from ratings r 
join pubs p 
using(pub_id)
group by r.pub_id,p.pub_name
having max(r.rating) > ALL ( select round(avg(rating),2)
							from ratings
                            group by pub_id);

/*9. What is the running total of sales amount for each pub, ordered by the transaction date?*/

SELECT 
    s.pub_id,
    p.pub_name,
    s.transaction_date,
    s.sale_id,
    s.quantity,
    b.price_per_unit,
    s.quantity * b.price_per_unit AS sales_amount,
    SUM(s.quantity * b.price_per_unit) OVER (PARTITION BY s.pub_id ORDER BY s.transaction_date) AS running_total
FROM 
    sales s
JOIN 
    pubs p ON s.pub_id = p.pub_id
JOIN 
    beverages b ON s.bev_id = b.bev_id
ORDER BY 
    s.pub_id, s.transaction_date;

/*10. For each country, what is the average price per unit of beverages in each category, 
and what is the overall average price per unit of beverages across all categories?*/

SELECT
    country,
    category,
    AVG(price_per_unit) AS avg_price_per_unit_category
FROM
    pubs
JOIN
    sales ON pubs.pub_id = sales.pub_id
JOIN
    beverages ON sales.bev_id = beverages.bev_id
GROUP BY
    country, category
WITH ROLLUP;

-- The overall average price per unit across all categories and countries
SELECT
    NULL AS country,
    NULL AS category,
    AVG(price_per_unit) AS avg_price_per_unit_overall
FROM
    pubs
JOIN
    sales ON pubs.pub_id = sales.pub_id
JOIN
    beverages ON sales.bev_id = beverages.bev_id;

/*In this query, the WITH ROLLUP clause is used to include extra rows that represent the grand totals. 
The first part of the query calculates the average price per unit for each category in each country, 
and the second part calculates the overall average price per unit across all categories and countries.*/

/*11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, 
and what is the pub's overall sales amount?*/

WITH PubSales AS (
    SELECT
        p.pub_id,
        p.pub_name,
        b.category,
        SUM(s.quantity * b.price_per_unit) AS category_sales
    FROM
        pubs p
    JOIN
        sales s ON p.pub_id = s.pub_id
    JOIN
        beverages b ON s.bev_id = b.bev_id
    GROUP BY
        p.pub_id, p.pub_name, b.category
)

SELECT
    ps.pub_id,
    ps.pub_name,
    ps.category,
    ps.category_sales,
    ps.category_sales / SUM(ps.category_sales) OVER (PARTITION BY ps.pub_id) * 100 AS category_percentage,
    SUM(ps.category_sales) OVER (PARTITION BY ps.pub_id) AS overall_sales_amount
FROM
    PubSales ps;







