-- e-commerce project
-- e commerce database management system

create database project_ecommerce;

use project_ecommerce;

select * from customers;
select * from orders;
select * from payments;
select * from products;
select * from shipping;

/*Project Task1 :
Update loyalty points for customers based on age.
•	Hint : age <25 then add 10 loyalty points
age between 25 and 40 then add 20  loyalty points
otherwise add 5 loyalty points*/

update customers 
set loyalty_points = loyalty_points +
case 
when age <25 then 10
when age between 25 and 40 then 20
else 5
end;

select * from customers;

/*In this task, I updated customer loyalty points based on their age using the CASE statement.
 Customers below 25 receive 10 points, customers between 25 and 40 receive 20 points, 
 and the remaining customers receive 5 points.*/
 
/* Project Task2:
Get total order value per country and classify sales category.
•	Hint: (Sales category Criteria)
sum(order_value) >10000 then "High"
sum(order_Value) between 5000 and 10000 then "medium"
other wise Low */

select c.country, sum(o.order_value) as total_value,
case 
when sum(o.order_value) >10000 then 'high'
when sum(o.order_value) between 5000 and 10000 then 'medium'
else 'low'
end as cus_status
from customers c join orders o on c.customer_id=o.customer_id
group by c.country;

select * from orders; -- o
select * from customers; -- c


/*In this task, I calculated the total order value for each country by joining 
the customers and orders tables. I used GROUP BY to calculate 
country-wise sales and CASE to classify sales into High, Medium, and Low categories."*/

/*Project Task3:
Pivot total order quantity per payment method.
•	Hint:Payment_method = 'credit card" then add qty(Group) as Credit_card_qty
payment_method = 'paypal' then  add qty(Group) as pay_pal_qty
payment_method = 'Bank Transfer' then add qty (group) as cash_qty*/
 
select 
sum(case when payment_method ='credit card' then quantity end) as credit_qty,
sum(case when payment_method ='paypal' then quantity end) as paypal_qty,
sum(case when payment_method ='bank transfer' then quantity end) as bank_qty
from orders;


select * from orders;

/*In this task, I calculated the total order quantity for each payment method using conditional aggregation. 
I used SUM with CASE to display Credit Card, PayPal, and Bank Transfer quantities as separate columns.*/

/*Project Task4:
(Joins with Subquery) Find top 3 customers by total order value and Customer_id (using Rank).
•	Hint: Write an SQL query to retrieve the top 3 customers who have spent the highest 
total amount across all their orders.*/

select * from orders;

select customer_id, total_value 
from (select customer_id, sum(order_value) as total_value,
rank() over(order by sum(order_value) desc) r
from orders group by customer_id) x
where r<=3;

/*In this task, I identified the top three customers based on their total order value. 
I used SUM to calculate each customer's total spending, RANK to assign rankings, 
and a subquery to filter the top three ranks.*/

/* Project Task5:
Task: Find products that have been ordered more than the average quantity.
•	Hint : Write an SQL query to identify products that are ordered in 
quantities higher than the average order quantity across all products.*/

select * from orders;

select product_id, sum(quantity) as avg_qty
from orders group by product_id having sum(quantity) > (select avg(quantity)from orders);


/*I used GROUP BY and HAVING to find products whose
 total quantity is greater than the average order quantity.*/

/*Project Task6:
Get all orders for a specific customer using customer_id
•	Hint : stored in procedures using In parameter*/

delimiter //
create procedure cus_status (in cid int)
begin
select * from orders 
where customer_id = cid;
end //
delimiter ;

call cus_status(220);

drop procedure cus_status;

/*In this task, I created a stored procedure that accepts a customer ID 
as an input parameter and retrieves all orders belonging to that customer.*/

/*Project Task7:
Return the total spending of a customer.
•	Hint : stored in procedure using in out parameter and then return the spending customers*/

select * from orders;

delimiter //
create procedure cus_spending (in cid int, inout total_spent decimal(10,2))
begin
select sum(order_value) into total_spent
from orders
where customer_id = cid;
end //
delimiter ;

call cus_spending (200,@total_spent);
select  @total_spent;

select * from orders where customer_id =200;
drop procedure cus_spending;

/*In this task, I created a stored procedure to calculate the total spending of a customer. 
I used an IN parameter to receive the customer ID and an INOUT parameter to return the calculated spending amount.*/

 /*Project Task8:
Automatically set loyalty points to 0 if NULL on insert.
•	Hint: apply triggers using before insert*/

delimiter //
create trigger before_customer_insert
before insert on customers
for each row 
begin
if new.loyalty_points is null then 
set new.loyalty_points = 0 ;
end if ;
end //
delimiter //

drop trigger before_customer_insert ;

select * from customers ;

insert into customers
values(12345,'lingesh','manmathan@gmail.com','male',41,'africa','pochinak','16-05-2021','13-06-2024',null);

select *  from customers where customer_id=12345;

delete from customers where customer_id =12345;

/*I created a BEFORE INSERT trigger to check whether loyalty points are NULL 
when a new customer is inserted. If they are NULL, the trigger automatically sets them to zero.*/

/*Project Task9:
After a new order is inserted, deduct quantity from product stock.
•	Hint1 : apply triggers using after insert(Insert event)
•	Hint2: In the concept of triggers, when an event is inserted
 using an AFTER INSERT trigger, the corresponding data should be updated in the secondary table.*/
 
delimiter //
create trigger after_order_insert
after insert on orders
for each row 
begin
update products
set stock_quantity = stock_quantity + new.quantity
where product_id = new.product_id;
end //
delimiter ;

drop trigger after_order_insert;


select * from products;
select * from orders;

select * from orders where order_id =1003;

delete from orders where order_id =1003;

insert into orders
values (1003,4555,1,'2024-05-02','delivered',5,0.02,18.69,'credit card',143.34);

/* I created an AFTER INSERT trigger on the orders table Whenever a new order is inserted, 
the trigger automatically reduces the corresponding product's stock quantity based on the quantity ordered.*/