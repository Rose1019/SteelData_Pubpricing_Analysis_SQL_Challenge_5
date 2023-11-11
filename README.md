# SteelData_Pubpricing_Analysis_SQL_Challenge_5

### Introduction
You are a Pricing Analyst working for a pub chain called 'Pubs "R" Us'
You have been tasked with analysing the drinks prices and sales to gain a greater insight into how the pubs in your chain are performing.

Sharing the link to [SteelData-SQL Challenge 5](https://www.steeldata.org.uk/sql5.html)

-----------------------------------------------------------------------------------------------------------------------------------------

## Table Details

| Table Name | Column Name |
| ---------- | ----------- |
| Pubs | Pub_id,pub_name,city,state,country |
| Beverages | Beverage_id,beverage_name,category,alcohol_content,price_per_unit |
| Ratings | Ratings_id,pub_id,customer_name,rating,review |
| Sales | Sales_id,pub_id,beverage_id,quantity,transaction_date |


---------------------------------------------------------------------------------------------------------------------------------------------

## Code

*1. How many pubs are located in each country??*

``` js
select country,count(pub_id)
from pubs
group by country;
``` 
 
```
                                 Output
In the analytical data, there is precisely one pub per country.

                              Concepts learned
1.COUNT()
2.GROUP BY
```
-----------------------------------------------------------------------------------------------------

*2. What is the total sales amount for each pub, including the beverage price and quantity sold?*

``` js
select p.pub_id as Pub_ID,p.pub_name as Pub_Name,sum(s.Quantity*b.price_per_unit) as Total_Sales_Amount
from pubs p 
join sales s 
using(pub_id)
join beverages b
using(bev_id)
group by p.pub_id;
``` 

```
                                 Output
Retrieve analytical data detailing the total sales amounts for each pub,
highlighting The Red Lion with the highest sales amount of $532 and
La Cerveceria with the lowest sales amount of $337.

                              Concepts learned
1.JOIN
2.SUM()
3.GROUP BY

```
-----------------------------------------------------------------------------------------------------

*3. Which pub has the highest average rating?*

``` js
SELECT p.pub_id, p.pub_name, round(AVG(r.rating),2) AS avg_rating
FROM pubs p 
JOIN ratings r 
ON p.pub_id = r.pub_id
GROUP BY p.pub_id,p.pub_name
ORDER BY avg_rating DESC
LIMIT 1;
``` 

```
                                 Output
In the analytical assessment, The Red Lion pub boasts the highest average rating, quantified at $4.67.
                              Concepts learned
1.JOIN
2.GROUP BY
3.ORDER BY
4.AVG()
5.ROUND()
```
-----------------------------------------------------------------------------------------------------

*4. What are the top 5 beverages by sales quantity across all pubs?*

``` js
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
``` 
```
                                 Output
Fetches top 5 beverages by sales quantity across all pubs.

                              Concepts learned
1.CTE
2.JOIN
3.DENSE_RANK()
2.USING()
3.GROUP BY
4.SUM()

```
-----------------------------------------------------------------------------------------------------

*5. How many sales transactions occurred on each date?*

``` js
select transaction_date,count(sale_id) as number_of_sales_transaction
from sales
group by transaction_date;
``` 

```
                                 Output


In the analytical data, the 5th of May registers the highest volume of transactions,
while the period spanning from the 4th of May to the 13th of May reflects the lowest occurrence of transactions.
                              Concepts learned
1.GROUP BY
2.COUNT()
```
-----------------------------------------------------------------------------------------------------

*6. Find the name of someone that had cocktails and which pub they had it in.*

``` js
select r.customer_name,r.pub_id,p.pub_name
from ratings r 
join sales s 
using(pub_id)
join beverages b 
using(bev_id)
join pubs p
using(pub_id)
where b.category='Cocktail';
``` 
```
                                 Output
Retrieves the customer name that had cocktails and which pub they had it in.

                              Concepts learned
1.JOIN
2.USING()
3.GROUP BY
```
-----------------------------------------------------------------------------------------------------

*7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?*

``` js
select category,round(avg(price_per_unit),2) as Average_Price_Category
from beverages
where category <> 'Spirit'
group by category;
``` 

```
                                 Output

Retrieve the analytical data presenting the average price per unit for each beverage category, excluding the Spirit category.
                              Concepts learned
1.GROUP BY
2.NOT operator

```
-----------------------------------------------------------------------------------------------------

*8. Which pubs have a rating higher than the average rating of all pubs?*

``` js
select r.pub_id,p.pub_name,round(avg(r.rating),2) 
from ratings r 
join pubs p 
using(pub_id)
group by r.pub_id,p.pub_name
having max(r.rating) > ALL ( select round(avg(rating),2)
							from ratings
                            group by pub_id);
``` 
```
                                 Output

The Red Lion and La Cerveceria are having a rating higher than the average rating of all pubs

                              Concepts learned
1.JOIN
2.USING()
3.GROUP BY
4.HAVING
5.ALL
```
-----------------------------------------------------------------------------------------------------

*9. What is the running total of sales amount for each pub, ordered by the transaction date?*

``` js
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
``` 

```
                                 Output
Retreives the running total of sales amount for each pub, ordered by the transaction date

                              Concepts learned
1.JOIN
2.USING()
3.ORDER BY
4.SUM()
5.OVER()
```
-----------------------------------------------------------------------------------------------------

*10. For each country, what is the average price per unit of beverages in each category, 
and what is the overall average price per unit of beverages across all categories?*

``` js
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
``` 

```
                               Output
 There are 2 branches that has the highest number of transactions in the Transactions table

                              Concepts learned
1.JOIN
2.USING()
3.GROUP BY
4.ROLLUP
```
-----------------------------------------------------------------------------------------------------

*11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, 
and what is the pub's overall sales amount?*/

``` js

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

``` 

```
                               Output
Fetched the percentage contribution of each category of beverages to the total sales amount,
and the pub's overall sales amount

                              Concepts learned
1.CTE
2.JOIN
3.SUM()
4.GROUP BY
5.OVER()
```
-----------------------------------------------------------------------------------------------------

