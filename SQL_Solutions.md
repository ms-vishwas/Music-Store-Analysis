### Question Set 1 - Easy
1. Identify the senior-most employee based on job title.
```sql
select top 1 title, last_name, first_name 
FROM employee
ORDER BY levels DESC
```
***
2. Determine which countries have the most invoices.
```sql
select billing_country,count(*) as cnt
from invoice
group by billing_country
order by 2 desc
```
***
3. Find the top 3 values of total invoices.
```sql
select distinct top 3 total
from invoice
order by total desc
```
***
4. Identify the city with the best customers (highest sum of invoice totals) for a promotional music festival.
```sql
select top 1 billing_city,SUM(total) as total_invoice
from invoice
group by billing_city
order by 2 desc
```
***
5. Determine the "best customer" by finding the person who has spent the most money.
```sql
select top 1 c.first_name,c.last_name,SUM(i.total) as total_spent
from invoice i
join customer c on i.customer_id =c.customer_id
group by c.first_name,c.last_name
order by 3 desc
```
***
### Question Set 2 - Moderate
1. Retrieve the email, first name, last name, and genre of all Rock Music listeners, ordered alphabetically by email.
```sql
select distinct c.email,c.first_name,c.last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email
```
***
2. Identify the top 10 artists who have written the most rock music, returning their name and total track count.
```sql
select top 10 a.artist_id,a.name,count(a.artist_id) as number_of_songs 
from artist a
join album al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id 
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
group by a.artist_id,a.name
order by 3 desc
```
***
3. Find all track names with a song length longer than the average song length, returning the name and milliseconds, ordered by longest songs first.
```sql
select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc
```
***
### Question Set 3 - Advanced
1. Calculate the total amount spent by each customer on different artists, returning customer name, artist name, and total spent.
```sql
select c.customer_id,c.first_name,c.last_name,a.name,sum(i.total) as tottal_spent
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album al on t.album_id = al.album_id
join artist a on al.artist_id = a.artist_id
group by c.customer_id,c.first_name,c.last_name,a.name
order by 1,2,3,4
```
***
2. Determine the most popular music genre for each country (genre with the highest amount of purchases). For countries with shared maximum purchases, return all relevant genres.
```sql
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
```
***
3. Identify the customer who has spent the most on music for each country, returning the country, the top customer, and the amount spent. For countries with shared top spending, provide all such customers.
```sql
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
```
***
