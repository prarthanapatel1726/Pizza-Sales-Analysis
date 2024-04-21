-- Retrieve the total number of orders placed.
select count(*) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum(orders_details.quantity * pizzas.price), 2) as Total_revenue 
from orders_details join pizzas
on pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest-priced pizza.

select pizza_types.name,  pizzas.price 
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by price desc
limit 1;

-- Identify the most common pizza size ordered.

select pizzas.size, count(orders_details.order_details_id) as total_orders
from orders_details
join pizzas
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size
order by total_orders desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,  sum(orders_details.quantity) as total_pizza_by_type
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by total_pizza_by_type desc
limit 5
;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select count(orders_details.quantity) as quantity, pizza_types.category
from orders_details
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.category
order by quantity desc ;

select * from orders;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as newtime, count(order_id) from orders
group by newtime 
order by count(order_id) desc
;

-- Join relevant tables to find the category-wise distribution of pizzas.

select count(name) as pizza_name, category
from pizza_types 
group by category
order by pizza_name desc
;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select * from orders;

select 
round(avg(total_quantity), 0) as Avg_pizza_perday
from
(select sum(orders_details.quantity) as total_quantity, orders.order_date
from orders
join orders_details
on orders.order_id = orders_details.order_id
group by orders.order_date ) as Quantity_order;

-- Determine the top 3 most ordered pizza types based on revenue.

select round(sum(orders_details.quantity * pizzas.price),1) as revenue, pizza_types.name
from orders_details
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
group by pizza_types.name
order by revenue desc
limit 3
;

-- Calculate the percentage contribution of each pizza type to total revenue.

select * from orders_details;
select * from pizza_types;

WITH TotalRevenue AS (
    SELECT SUM(orders_details.quantity * pizzas.price) AS total_revenue
    FROM orders_details
    JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
)
SELECT 
    pizza_types.category, 
    SUM(orders_details.quantity * pizzas.price) AS revenue,
   concat( round((SUM(orders_details.quantity * pizzas.price) / TotalRevenue.total_revenue) * 100, 2), "%") AS percentage_contribution
FROM orders_details
JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
CROSS JOIN TotalRevenue
GROUP BY pizza_types.category, TotalRevenue.total_revenue
order by percentage_contribution desc;

-- Analyze the cumulative revenue generated over time. 


select order_date,
round(sum(revenue) over(order by order_date), 2) as cum_revenue
from
(select  orders.order_date , count(orders.order_id) as order_per_Day, round(sum(orders_details.quantity * pizzas.price),2) as revenue 
from orders
join orders_details
on orders.order_id = orders_details.order_id
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select
category, name, revenue, rankofpizza
from
(select
category, name, revenue,
rank() over(partition by category order by revenue desc) as rankofpizza 
from 
(select p.name, p.category, sum(d.quantity * piz.price) as revenue
from pizza_types p
join pizzas piz
on piz.pizza_type_id = p.pizza_type_id
join orders_details d
on piz.pizza_id = d.pizza_id
group by p.category, p.name
order by revenue desc) as a)
as b
where rankofpizza <=3
;





