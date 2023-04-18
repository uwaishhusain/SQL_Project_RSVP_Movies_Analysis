USE imdb;

 /* To begin with, it is beneficial to know the shape of the tables and whether any column has null values.*/

-- Q1. Find the total number of rows in each table of the schema?

select count(*) as count_of_rows
from movie;

select count(*) as count_of_rows
from director_mapping;

select count(*) as count_of_rows
from genre;

select count(*) as count_of_rows
from names;

select count(*) as count_of_rows
from ratings;

select count(*) as count_of_rows
from role_mapping;

-- Q2. Which columns in the movie table have null values?

Select sum(case when id is null then 1 else 0 end) as Null_id,
	   sum(case when title is null then 1 else 0 end) as Null_title,
       sum(case when year is null then 1 else 0 end) as Null_year,
       sum(case when date_published is null then 1 else 0 end) as Null_date_published,
       sum(case when duration is null then 1 else 0 end) as Null_duration,
       sum(case when country is null then 1 else 0 end) as Null_country,
       sum(case when worlwide_gross_income is null then 1 else 0 end) as Null_worlwide_gross_income,
       sum(case when languages is null then 1 else 0 end) as Null_languages,
       sum(case when production_company is null then 1 else 0 end) as Null_production_company
from movie; 

-- Now as we know some of the columns in the movie table has null values. 

-- Q3. Find the total number of movies released each year? How does the trend look month wise?

select year, count(id) as Number_of_Movies
from movie
group by year order by year;

select month(date_published), count(id) as No_of_Movies
from movie
group by month(date_published) order by month(date_published);
 
-- Q4. How many movies were produced in the USA or India in the year 2019??

select count(*)
from movie
where (country like '%USA%' or country like '%India%') and year=2019;

-- Q5. Find the unique list of the genres present in the data set?

select distinct genre
from genre;

-- Q6.Which genre had the highest number of movies produced overall?

select genre, count(*)
from genre
group by genre order by count(*) desc;

-- Q7. How many movies belong to only one genre?

SELECT COUNT(*) as Total_movies_single_genre
FROM (
  SELECT movie_id, COUNT(genre)
  FROM genre
  GROUP BY movie_id
  HAVING COUNT(genre)=1) AS total_movies;

-- Q8.What is the average duration of movies in each genre? 

  select g.genre, avg(m.duration) as Average_duration
  from genre g inner join movie m on g.movie_id=m.id
  group by genre order by Average_duration desc;


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

 select genre, count(movie_id) as Movie_count, dense_rank() over(Order by count(movie_id) desc) as Genre_rank
  from genre
  group by genre;


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

  select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating,
		 min(total_votes) as min_avg_rating, max(total_votes) as max_total_votes,
         min(median_rating) as min_median_rating, max(median_rating) as max_median_rating
  from ratings;

 
-- Q11. Which are the top 10 movies based on average rating?

select m.title, r.avg_rating,
dense_rank() over(order by r.avg_rating desc) as Movie_rank
from ratings r
inner join movie m on r.movie_id=m.id
limit 10;


-- Q12. Summarise the ratings table based on the movie counts by median ratings.

select median_rating, count(*) as movie_count
from ratings
group by median_rating order by median_rating;


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

select m.production_company, count(id) as movie_count,
dense_rank() over (order by count(id) desc) as prod_company_rank
from movie m
inner join ratings r on m.id=r.movie_id
where r.avg_rating>8
group by production_company;


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

select g.genre, count(*) as movie_count
from genre g
inner join movie m on g.movie_id=m.id
inner join ratings r on r.movie_id=m.id
where (m.year=2017) and (m.country like '%USA%') and (r.total_votes>1000)
group by g.genre;


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

select m.title, r.avg_rating, g.genre
from movie m
inner join ratings r on m.id=r.movie_id
inner join genre g on m.id=g.movie_id
where (r.avg_rating>8) and (m.title like 'The%');


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

select count(m.id) as movie_count
from movie m 
inner join ratings r on m.id =r.movie_id
where (m.date_published between '2018-04-01' and '2019-04-01') and r.median_rating=8;


-- Q17. Do German movies get more votes than Italian movies? 

select sum(r.total_votes) as votes
from movie m
inner join ratings r on m.id=r.movie_id
where country like '%Germany%';

select sum(r.total_votes) as votes
from movie m
inner join ratings r on m.id=r.movie_id
where country like '%Italy%';

-- Answer is Yes


-- Q18. Which columns in the names table have null values??

select sum(case when id is null then 1 else 0 end) as Null_id,
       sum(case when name is null then 1 else 0 end) as Null_name,
       sum(case when height is null then 1 else 0 end) as Null_height,
       sum(case when date_of_birth is null then 1 else 0 end) as Null_date_of_birth
from names;

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

 With top_rated_genre As(
  SELECT genre, COUNT(g.movie_id) AS movie_count,
  RANK() OVER (ORDER BY COUNT(g.movie_id) DESC) AS genre_rank
  FROM genre AS g
  INNER JOIN ratings AS r ON g.movie_id = r.movie_id
  WHERE avg_rating > 8
  GROUP BY genre
  )
  Select n.name as director_name, count(m.id) as movie_count
	from names n
    inner join director_mapping d on n.id = d.name_id
    inner join movie m on d.movie_id=m.id
    inner join ratings r on r.movie_id=m.id
    inner join genre g on g.movie_id=m.id
    where g.genre in (select genre from top_rated_genre where genre_rank <=3)
    AND avg_rating > 8
	group by n.name
	order by count(m.id) desc
	Limit 3;

-- Q20. Who are the top two actors whose movies have a median rating >= 8?


select n.name as actor_name, count(*) as movie_count
from names n inner join role_mapping r on n.id=r.name_id
inner join ratings r2 on r2.movie_id=r.movie_id
where r2.median_rating>=8
group by n.name order by movie_count desc 
Limit 2;


-- Q21. Which are the top three production houses based on the number of votes received by their movies?

select m.production_company,sum(r.total_votes) as vote_count, 
dense_rank() over( order by sum(r.total_votes) desc) as prod_comp_rank
from movie m inner join ratings r on m.id=r.movie_id
group by m.production_company
Limit 3;


-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 

With actor_rating as(
	Select n.name as actor_name, sum(r.total_votes) as total_votes, count(m.id) as movie_count,
    ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating
	From names n
    inner join role_mapping a on n.id = a.name_id
    inner join movie m on a.movie_id = m.id
    inner join ratings r on m.id = r.movie_id
    where category = 'actor' and country like '%India%'
    group by actor_name
)
	Select *, 
    Rank() over (order by actor_avg_rating desc, total_votes desc) as actor_rank
	from actor_rating
	where movie_count>=5;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 

  With actress_rating as(
	Select n.name as actress_name, sum(r.total_votes) as total_votes, count(m.id) as movie_count,
    Round(sum(r.avg_rating*r.total_votes)/sum(r.total_votes),2) as actress_avg_rating
    from names n inner join role_mapping a on n.id = a.name_id
    inner join movie m on a.movie_id = m.id
    inner join ratings r on m.id = r.movie_id
    where category = 'actress' and languages like '%Hindi%'
    group by actress_name
 ) 
 select *, rank() over(order by actress_avg_rating desc, total_votes desc) as actress_rank
 from actress_rating
 where movie_count >=3;

-- Taapsee Pannu tops with average rating 7.74. 

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

Select m.title as movie_name,
    Case when r.avg_rating > 8 then 'Superhit'
         when r.avg_rating between 7 and 8 then 'Hit'
         when r.avg_rating between 5 and 7 then 'One time watch'
         else 'Flop' end as movie_category
From movie m 
	left join ratings r on m.id = r.movie_id
	left join genre g on m.id = g.movie_id
Where lower(genre) = 'thriller' and total_votes > 25000;
