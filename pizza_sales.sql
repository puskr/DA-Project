Create Table order_details 
(
	order_details_id int,
	order_id int,
	pizza_id varchar(50),
	quantity int
)

COPY order_details
	from 'C:\Program Files\PostgreSQL\16\data\data_copy\order_details.csv'
delimiter ',' 
csv header;


select * from order_details;

create table pizza_types
(
	pizza_type_id text,
	name text,
	category text,
	ingredients text
);

	

	select * from pizza_types;

COPY pizza_types
	from 'C:\Program Files\PostgreSQL\16\data\data_copy\pizza_types.csv' WITH ENCODING 'WIN1252'
delimiter ',' 
csv header

create table pizzas (
	pizza_id text,
	pizza_type_id text,
	size varchar(10),
	price decimal(10,2)
)

COPY pizzas
	from 'C:\Program Files\PostgreSQL\16\data\data_copy\pizzas.csv'
delimiter ',' 
csv header

select * from pizzas;


create table orders
(
	order_id int,
	order_date date not null,
	order_time time not null
);

COPY orders (order_id, order_date, order_time)
	from 'C:\Program Files\PostgreSQL\16\data\data_copy\orders.csv'
delimiter ',' 
csv header

select * from orders

--Q1 Retrive the total number of orders placed.

	select count(order_id) as Tota_orders
	from orders;


--Q2 Calculate the total revenue generated from pizza sales

SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_sales
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id

--Q3 Identify the highest-priced pizza

select * from pizzas;

select max (price) as highest_priced_pizza
from pizzas;


--Q4 Identify the most common pizza size ordered


select pizzas.size, count(order_details.order_details_id)
from pizzas
join order_Details
on pizzas.pizza_id=order_details.pizza_id
	group by pizzas.size ;

--Q5 list the top 5 most ordered pizza types along with their quantities.

select *from pizza_types
	limit 5;

select pizza_types.name, 
	sum(order_details.quantity)
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
	group by pizza_types.name
	order by sum(order_details.quantity) desc limit 5;

--Q6 Join the necessary tables to find the total quantity of each pizza category

select pizza_types.category, sum(order_details.quantity) as total_quantity
from pizzas
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
	group by pizza_types.category;

--Q7 Determine the distribution of orders by hour of the day



SELECT date_part('hour', order_time) AS hour, count(order_id) 
FROM orders
	group by hour;

-- Q8 Join relevant tables to find the category-wise distribution of pizzas

/*select pizza_types.category, sum(order_details.quantity)
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category; */

select category, count(name)
from pizza_types
group by category;


--Q9 Group the orders by date and calculate the average number of pizzas ordered per day

select
	round(avg(avg_ordered)) as average_pizzas_ordered
	from
	(select order_date, sum(order_details.quantity) as avg_ordered
from order_details
join orders
on orders.order_id=order_details.order_id
group by order_date);

--Q10 Determine the top 3 most ordered pizza types based name. 

select count(quantity) as most_ordered, pizza_types.name
from order_details
join pizzas 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id= pizzas.pizza_type_id
group by pizza_types.name
	limit 3;

--Q11 Calculate the percentage contribution of each pizza type to total revenue

select pizza_types.category, 
	(sum(order_details.quantity*pizzas.price)/(select round(sum(order_details.quantity * pizzas.price),2) as tota_sales
	from 
	order_details
join 
	pizzas
on pizzas.pizza_id = order_details.pizza_id)) *100 as revenue
from pizza_types join pizzas
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
	join order_details
	on order_details.pizza_id = pizzas.pizza_id
	group by pizza_types.category
	order by revenue desc;

--Q12 Analyze the cumulative revenue generated over time.

select  order_date, sum(revenue) over (order by order_date) as cumulative_revenue
	from 
(select orders.order_date, 
sum(order_details.quantity*pizzas.price) as Revenue
from order_details 
join
pizzas
on order_details.pizza_id=pizzas.pizza_id
join 
orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

