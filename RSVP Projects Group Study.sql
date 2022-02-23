USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
select count(*) from director_mapping;
-- 3867 rows 
select count(*) from genre;
-- 14662 rows
select count(*) from movie;
-- 7997  rows
select count(*) from names;
-- 25735
select count(*) from ratings;
-- 7997 rows
select count(*) from role_mapping;
-- 15615


-- Q2. Which columns in the movie table have null values?
-- Type your code below:

select count(*) from movie where id is null;
-- 0 in id
select count(*) from movie where title is null;
-- 0 in title
select count(*) from movie where year is null;
-- 0 in year
select count(*) from movie where date_published is null;
-- 0 in date_published
select count(*) from movie where duration is null;
-- 0 in duartion
select count(*) from movie where country is null;
-- There are all total 20 rows in movie where country of origin is null
select count(*) from movie where worlwide_gross_income is null;
-- There are all total 3724 movies whose worldwide gross income is unknown
select count(*) from movie where languages is null;
-- there are all total 194 movies whoese language is unknown
select count(*) from movie where production_company is null;
-- there all total 528 movies whose production_company is null.

/* Columns having null values:
a. country
b. worldwide_gross_income
c. languages
d. production_company
*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
select year,count(year(date_published)) as number_of_movies
from movie
group by year
order by year;
/* 2017- 3052
   2018- 2944
   2019- 2001
*/

select month(date_published) as month_num, count(date_published) as number_of_movies
from movie
group by month_num
order by number_of_movies desc;


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

with  t1 as(
select country,count(id) as num_of_movies
from movie
where country like "%USA%"
      or
      country="%India%"
      and year="2019"
group  by country
)select sum(num_of_movies) as Movies_USA_or_India
from t1;

-- There are all total 2863 movies produced in Usa or India.

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
select distinct(genre) from genre;

/*
13 Genres are:

Drama
Fantasy
Thriller
Comedy
Horror
Family
Romance
Adventure
Action
Sci-Fi
Crime
Mystery
Others
*/


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:


select g.genre, count(m.id) as num_of_movies
from movie m
inner join genre g
on g.movie_id= m.id
where year="2019"
group by genre
order by num_of_movies desc

limit 1;

-- Drama genre have highest number of movies released.

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

create view genre_with_movie as
select distinct(movie_id) as movie_id,
		group_concat(genre) as movie_genre
from genre
group by movie_id;

with movie_counts_one_genre as(
select movie_genre,count(movie_genre) as movie_counts
from genre_with_movie
where movie_genre in('Drama','Fantasy','Thriller','Comedy','Horror','Family'
,'Romance','Adventure','Action','Sci-Fi'
,'Crime','Mystery','Others')
group by movie_genre
)select sum(movie_counts) from movie_counts_one_genre;

-- There are all total 3289 movies which is associated with only one genre.


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select g.genre,avg(m.duration) as avg_duration
from genre g
inner join movie m
on m.id=g.movie_id
group by genre;


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


with genre_with_movie_counts as(
select genre,count(id) as movie_count
from genre g
inner join movie m
on m.id=g.movie_id
group by genre
order by movie_count desc
)select *, 
		rank() over (order by movie_count desc)as genre_rank
from genre_with_movie_counts;


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
select min(avg_rating) as min_avg_rating,
	   max(avg_rating) as max_avg_rating,
       min(total_votes) as min_total_votes,
       max(total_votes) as max_total_votes,
       min(median_rating) as min_median_rating,
       max(median_rating) as max_median_rating
from ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


select m.title, r.avg_rating,
       dense_rank() over(order by avg_rating desc)as movie_rank
from movie m
inner join ratings r
on m.id=r.movie_id
group by m.title
order by movie_rank
limit 10;


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

select median_rating,count(movie_id) as movie_count
from ratings
group by median_rating
order by movie_count desc;




/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

select production_company,count(id) as movie_count,
		dense_rank() over (order by count(id) desc) as prod_company_rank 
from movie m inner join ratings r on r.movie_id=m.id
where production_company is not null and avg_rating>8
group by production_company
order by prod_company_rank;



-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with USA_movies as(
select g.genre,m.id as movie_id
from genre g inner join movie m on g.movie_id=m.id
where country like "%USA%" and year="2017" and month(date_published)="03"
) select genre,count(movie_id) as movie_count
from USA_movies inner join ratings using(movie_id)
where total_votes>1000
group by genre
order by movie_count desc;




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

select distinct(m.title),r.avg_rating,group_concat(g.genre)
from movie m inner join ratings r on m.id=r.movie_id inner join genre g on r.movie_id=g.movie_id 
where title like "The%" and r.avg_rating>8
group by title
order by avg_rating desc;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

select count(id) as movie_count
from movie m 
inner join ratings r
on m.id = r.movie_id
where year between "2018" and "2019" and month(date_published)="04" and median_rating=8;


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

select sum(total_votes) as Italy_votes
from movie m
inner join
ratings r
on m.id=r.movie_id
where country= 'Italy';

-- Italy_votes=77965

select sum(total_votes) as Germany_votes
from movie m
inner join
ratings r
on m.id=r.movie_id
where country="Germany";

-- Germany_votes=106710
-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select
    sum(case when name is null then 1 else 0 end) as name_nulls,
    sum(case when height is null then 1 else 0 end) as height_nulls,
    sum(case when date_of_birth is null then 1 else 0 end) as dateof_birth_nulls,
    sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_nulls
from names;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


create view movie_avg_more_8 as
select movie_id,name_id
from director_mapping inner join ratings using (movie_id)
where avg_rating>8;

select genre,count(movie_id) as movie_count
from genre inner join movie_avg_more_8 using(movie_id)
group by genre
order by movie_count desc
limit 3;

/* Top 3 genre avg_rating>8
Drama	88
Action	29
Comedy	20
*/

with director_movie_avg_more_8 as
(
select movie_id,name_id
from movie_avg_more_8 inner join genre using(movie_id)
where genre in ('Drama','Action','Comedy')
)select n.name as director_name,count(movie_id) as movie_count
from names n inner join director_movie_avg_more_8 d on n.id=d.name_id
group by director_name 
order by movie_count desc;



/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

create view movie_median_more_equal_8 as
select movie_id,name_id
from role_mapping inner join ratings using (movie_id)
where median_rating>=8;

select name as actor_name, count(movie_id) as movie_count
from names n inner join movie_median_more_equal_8 m on n.id=m.name_id inner join role_mapping using(movie_id)
where category="actor"
group by actor_name
order by movie_count desc
limit 10; 






 
/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


with prod_compvsvote_count as
(
select production_company, sum(total_votes) as vote_count
from movie m inner join ratings r on m.id=r.movie_id
group by production_company
) select *, dense_rank() over(order by vote_count desc) as prod_comp_rank
from prod_compvsvote_count
limit 3;

-- Top Three
/*Marvel Studios
Twentieth Century Fox
Warner Bros*/

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select name as actor_name, cast(sum(total_votes)/count(movie_id) as decimal(8,0)) as total_votes, count(movie_id) as movie_count, avg_rating as actor_avg_rating,
				dense_rank() over(order by avg_rating desc) as actor_rank
from names n inner join role_mapping r on n.id=r.name_id inner join ratings using (movie_id) inner join movie m on m.id=r.movie_id
where country="India" and category="actor" 
group by actor_name
having count(movie_id)>=5; 


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


select name as actress_name, cast(sum(total_votes)/count(movie_id) as decimal(8,0)) as total_votes, count(movie_id) as movie_count, avg_rating as actress_avg_rating,
				dense_rank() over(order by avg_rating desc) as actor_rank
from names n inner join role_mapping r on n.id=r.name_id inner join ratings using (movie_id) inner join movie m on m.id=r.movie_id
where country="India" and category="actress" 
group by actress_name
having count(movie_id)>=3; 


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:



SELECT count(movie_id) as movie_count,
       CASE 
          when avg_rating>8  then 'Super-Hit'
	      when avg_rating between 7 and 8  then 'Hit'
          when avg_rating between 5 and 7  then 'One-time-watch' 
          else 'Flop'  
       END AS movie_category  
FROM ratings inner join genre_with_movie using(movie_id)
where movie_genre like ('%Thriller%')
group by movie_category
order by movie_count ;
       
/*
Count of Thriller Movies:
Superhit: 39
hit:166
One-time-watch:786
Flop:493
*/



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+------a---------+-------------------+---------------------+----------------------+
|	comedy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


select genre,avg(duration) as avg_duration,
		sum(duration) over w1 as running_total_duration,
        avg(duration) over w2 as moving_avg_duraion
from genre g inner join movie m on g.movie_id=m.id
group by genre 
window w1 as(order by duration rows unbounded preceding),
	   w2 as(order by duration rows 6 preceding);


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
select genre,count(movie_id) as movie_count
from genre
group by genre
order by movie_count desc
limit 3;
/*Drama
Comedy
Thriller*/

SELECT movie_genre,year,title as movie_name  
from genre_with_movie g inner join movie m on m.id=g.movie_id
WHERE  movie_genre LIKE'%Drama%' 
    OR movie_genre LIKE'%Comedy%' 
    OR movie_genre LIKE'%Thriller%';


DELIMITER $$
create function INR_to_$(worlwide_gross_income varchar(30))
returns varchar(30) deterministic

begin

declare currency_converted varchar(30);
declare inr varchar(30);
set inr= replace(worlwide_gross_income,"INR","");
set currency_converted=concat('$',' ',round(inr*0.013));
return currency_converted;
end;
$$
DELIMITER ;

drop function INR_to_$;
select INR_to_$('INR 74692496') as output;



update movie
set worlwide_gross_income= INR_to_$(worlwide_gross_income)
where worlwide_gross_income like "INR%";

DELIMITER $$
create function currency_$(worlwide_gross_income varchar(30))
returns varchar(30) deterministic

begin

declare currency varchar(30);
set currency= replace(worlwide_gross_income,"$","");
return currency;
end;
$$
DELIMITER ;

drop function currency_$;
SELECT movie_genre,year,title as movie_name, worlwide_gross_income as  worldwide_gross_income,
		dense_rank() over(order by cast(currency_$(worlwide_gross_income) as signed) desc) as movie_rank
from genre_with_movie g inner join movie m on m.id=g.movie_id
WHERE  movie_genre LIKE'%Drama%' 
    OR movie_genre LIKE'%Comedy%' 
    OR movie_genre LIKE'%Thriller%'
limit 5;

/*
Top 5 high grossers of all time
1.Avengers: Endgame
2.The Lion King
3.The Fate of the Furious
4.Toy Story 4
5.Despicable Me 3
*/
    
    
/*
-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


select production_company,count(r.movie_id) as movie_count,median_rating,
		dense_rank() over(order by count(r.movie_id) desc) as prod_comp_rank
from movie m inner join ratings r on m.id=r.movie_id
where median_rating>=8
      and position("," in languages)>0
      and production_company is not null
group by production_company;



/*
Top 2 production house which released maximum number of hits among multiligual movies
1.Star Cinema
2.Twentieth Century Fox
*/



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28.Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

select name as actress_name,total_votes, count(movie_id) as movie_count, avg_rating as actress_avg_rating,
				dense_rank() over(order by count(movie_id) desc) as actress_rank
from names n inner join role_mapping r on n.id=r.name_id inner join ratings using (movie_id) inner join movie m on m.id=r.movie_id inner join genre using(movie_id)
where category="actress" and avg_rating>8 and genre = "Drama"
group by actress_name;

/*
Top 3 actress based on number of super hit films (avg rating>8) and in Drama genre
Parvathy Thiruvothu
Susan Brown
Amanda Lawrence
*/

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

-- Final Required Table query:
select name_id as director_name,t.name as director_name, count(m.id) as number_of_movies, t.avg_inter_movie_days ,avg_rating,sum(total_votes) as total_votes,min(avg_rating) as min_rating,max(avg_rating) as max_rating,sum(duration) as total_duration
from director_mapping d inner join names n on n.id=d.name_id inner join Top_9_Directors_avg_inter_movie_days T using(name) inner join movie m on m.id=d.movie_id inner join ratings r on r.movie_id=m.id
group by t.name
order by number_of_movies desc; 

-- Query for finding top 9 directors based on number of movies:
select name as director_name,count(d.movie_id) 
from names n inner join director_mapping d on d.name_id=n.id
group by director_name
order by count(d.movie_id) desc
limit 9;
/*
A.L. Vijay
Andrew Jones
Chris Stokes
Justin Price
Jesse V. Johnson
Steven Soderbergh
Sion Sono
Özgür Bakar
Sam Liu*/


-- For detailed part by part queries to evaluate th avg_inter_movie_days for each of the 9 directors refer below:
with T1 as(
with t1 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Andrew Jones"
order by date_published
) select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t1
window w as ( order by date_published))
select round(avg(dated_diff)) from T1 where dated_diff is not null;


with T2 as(
with t2 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="A.L. Vijay"
order by date_published)
select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t2
window w as ( order by date_published))
select round(avg(dated_diff)) from T2 where dated_diff is not null;

with T3 as(
with t3 as (
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Özgür Bakar"
order by date_published
)select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t3
window w as ( order by date_published))
select round(avg(dated_diff)) from T3 where dated_diff is not null;

with T4 as(
with t4 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Jesse V. Johnson"
order by date_published
)select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t4
window w as ( order by date_published))
select round(avg(dated_diff)) from T4 where dated_diff is not null;

with T5 as(
with t5 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Chris Stokes"
order by date_published
)select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t5
window w as ( order by date_published))
select round(avg(dated_diff)) from T5 where dated_diff is not null;

with T6 as(
with t6 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Justin Price"
order by date_published)
select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t6
window w as ( order by date_published))
select round(avg(dated_diff)) from T6 where dated_diff is not null;


with T7 as(
with t7 as
(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Steven Soderbergh"
order by date_published)
select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t7
window w as ( order by date_published))
select round(avg(dated_diff)) from T7 where dated_diff is not null;

with T8 as(
with t8 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Sion Sono"
order by date_published)
select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t8
window w as ( order by date_published)
)select round(avg(dated_diff)) from T8 where dated_diff is not null;

with T9 as(
with t9 as(
select d.name_id as director_id,n.name as director_name,m.id,date_published
from director_mapping d inner join movie m on d.movie_id=m.id inner join names n on n.id=d.name_id
where n.name="Sam Liu"
order by date_published)
select abs(datediff(date_published,lead(date_published) over w)) as dated_diff
from t9
window w as ( order by date_published))
select round(avg(dated_diff)) from T9 where dated_diff is not null;


/*
Th average inter movie duration in days which has been calculated in each querie from T1-T9 are as follows-
('Andrew Jones',191)
('A.L. Vijay',177)
('Özgür Bakar',112)
('Jesse V. Johnson',299)
('Chris Stokes',198)
('Justin Price',315)
('Steven Soderbergh',254)
('Sion Sono',331)
('Sam Liu',260)
*/

create table Top_9_Directors_avg_inter_movie_days (
name varchar(30),
avg_inter_movie_days int
);
insert into  Top_9_Directors_avg_inter_movie_days(name,avg_inter_movie_days)
values
('A.L. Vijay',177),
('Andrew Jones',191),
('Chris Stokes',198),
('Justin Price',315),
('Jesse V. Johnson',299),
('Steven Soderbergh',254),
('Sion Sono',331),
('Özgür Bakar',112),
('Sam Liu',260);


		




