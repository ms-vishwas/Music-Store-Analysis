--Question Set 1 - Easy
--1. Who is the senior most employee based on job title?

SELECT top 1 title, last_name, first_name 
FROM employee
ORDER BY levels DESC

--2. Which countries have the most Invoices?

select billing_country,count(*) as cnt
from invoice
group by billing_country
order by 2 desc

--3. What are top 3 values of total invoice?

select distinct top 3 total
from invoice
order by total desc

/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/

select top 1 billing_city,SUM(total) as total_invoice
from invoice
group by billing_city
order by 2 desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 c.first_name,c.last_name,SUM(i.total) as total_spent
from invoice i
join customer c on i.customer_id =c.customer_id
group by c.first_name,c.last_name
order by 3 desc

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email,c.first_name,c.last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 a.artist_id,a.name,count(a.artist_id) as number_of_songs 
from artist a
join album al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id 
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
group by a.artist_id,a.name
order by 3 desc

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

select c.customer_id,c.first_name,c.last_name,a.name,sum(i.total) as tottal_spent
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album al on t.album_id = al.album_id
join artist a on al.artist_id = a.artist_id
group by c.customer_id,c.first_name,c.last_name,a.name
order by 1,2,3,4

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with cte1 as (
	select c.country,g.name,sum(il.quantity) as qty_sold
	from customer c
	join invoice i on c.customer_id = i.customer_id
	join invoice_line il on i.invoice_id = il.invoice_id
	join track t on il.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by c.country,g.name
),cte2 as(
	select *,ROW_NUMBER() over(partition by country order by qty_sold desc) as rn
	from cte1
)
select country,name
from cte2
where rn = 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with cte1 as (
	select customer_id,sum(total) as total
	from invoice
	group by customer_id
),cte2 as(
	select c.customer_id,cu.country,c.total,dense_rank() over(partition by cu.country order by c.total desc) as rn
	from cte1 c
	join customer cu on c.customer_id = cu.customer_id
)
select cu.country,cu.first_name,cu.last_name,c2.total
from cte2 c2
join customer cu on c2.customer_id = cu.customer_id
where rn = 1
order by 4 desc