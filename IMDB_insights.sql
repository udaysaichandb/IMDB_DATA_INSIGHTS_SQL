USE imdb;

/* Now that we have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further, we will take a look at 'movies' and 'genre' tables.*/


-- STEP 1. Finding the total number of rows in each table of the schema

SELECT table_name,
       table_rows
FROM   information_schema.tables
WHERE  table_schema = 'imdb'; 


/* The tables : director_mapping, genre, movie, names, ratings, role_mapping are having 3867, 14662, 6407, 24036, 8230, 15165 no. of rows respectively. */





-- Columns in the movie table having null values

SELECT Sum(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS ID_nulls,
       Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS title_nulls,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS year_nulls,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS date_published_nulls,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS duration_nulls,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS country_nulls,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS worlwide_gross_income_nulls,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS languages_nulls,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS production_company_nulls
FROM   movie; 

# Number of NULL's in id, title, year, date_published, duration, country, worlwide_gross_income, languages, production_company are 0, 0, 0, 0, 0, 20, 3724, 194, 528 respectively

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Finding the total number of movies released each year and How does the trend look month wise? 


SELECT year,
       Count(title) AS number_of_movies
FROM   movie
GROUP  BY year; 


SELECT Month(date_published) AS month_num,
       Count(title)          AS number_of_movies
FROM   movie
GROUP  BY Month(date_published)
ORDER  BY Month(date_published); 

/* sorting in descending order according to number of movies per month
month_num, number_of_movies
3, 824
9, 809
1, 804
10, 801
4, 680
8, 678
2, 640
11, 625
5, 625
6, 580
7, 493
12, 438 */



/*The highest number of movies is produced in the month of March.
So, now that we have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- How many movies were produced in the USA or India in the year 2019??

SELECT Count(id) AS released_USA_INDIA_2019
FROM   movie
WHERE  ( year = 2019 )
       AND ( country LIKE '%USA%'
              OR country LIKE '%India%' ); 


/*Total movies produced in the USA or India in the year 2019 are 1059*/


/* USA and India produced 1059 movies in the year 2019.

Let’s find out the different genres in the dataset.*/

-- Finding the unique list of the genres present in the data set


SELECT DISTINCT genre
FROM   genre
ORDER  BY genre; 

/* The following are different Genre :
Action
Adventure
Comedy
Crime
Drama
Family
Fantasy
Horror
Mystery
Others
Romance
Sci-Fi
Thriller
*/




/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t we want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Which genre had the highest number of movies produced overall?


SELECT genre,
       Count(movie_id) AS no_of_movies
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY no_of_movies DESC
LIMIT  1; 

/* Highest no. of movies produced belongs to Drama Genre that equals to 4285 */

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- How many movies belong to only one genre?

WITH one_genre
     AS (SELECT movie_id,
                Count(genre) AS no_of_genres
         FROM   genre
         GROUP  BY movie_id
         HAVING no_of_genres = 1)
SELECT Count(movie_id) AS single_genre_movies
FROM   one_genre; 


/* There are 3289 movies which belongs to only single Genre 
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- What is the average duration of movies in each genre? 


SELECT genre,
       Round(Avg(duration), 2) AS avg_duration
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY avg_duration DESC; 

/* 
The following are genre and avg_duration respectively in descending order : 
Action, 112.88
Romance, 109.53
Crime, 107.0517
Drama, 106.77
Fantasy, 105.14
Comedy, 102.62
Adventure, 101.87
Mystery, 101.80
Thriller, 101.58
Family, 100.97
Others, 100.16
Sci-Fi, 97.94
Horror, 92.72
*/


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 


SELECT genre,
       Count(*) AS movie_count,
       Rank()
         OVER (
           ORDER BY Count(*) DESC) AS genre_rank
FROM   genre
GROUP  BY genre; 

/* Thriller is in rank 3 having 1484 movies produced.
Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, we analysed the movies and genres tables. 
 Next we will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Finding the minimum and maximum values in  each column of the ratings table except the movie_id column?


SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings; 

/* RESULT:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		1		|			10		|	       100		  |	   725138    		 |		1	       |	10			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Which are the top 10 movies based on average rating?


SELECT     title,
           avg_rating,
           Rank() OVER (ORDER BY avg_rating DESC) AS movie_rank
FROM       movie                                  AS m
INNER JOIN ratings                                AS r
ON         m.id = r.movie_id limit 10;

/* The following are the top 10 movies in terms of Average rating:
title							avg_rating	movie_rank
Kirket							10.0			1
Love in Kilnerry				10.0			1
Gini Helida Kathe				9.8				3
Runam							9.7				4
Fan								9.6				5
Android Kunjappan Version 5.25	9.6				5
Yeh Suhaagraat Impossible		9.5				7
Safe							9.5				7
The Brighton Miracle			9.5				7
Shibu							9.4				10
*/








-- Summarising the ratings table based on the movie counts by median ratings.


SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 

/* Movies with a median rating of 7 is highest with 2257 movies
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Which production house has produced the most number of hit movies (average rating > 8)??

SELECT     production_company,
           Count(id)                                   AS movie_count,
           Dense_rank() OVER (ORDER BY Count(id) DESC) AS prod_company_rank
FROM       movie                                       AS m
INNER JOIN ratings                                     AS r
ON         m.id = r.movie_id
WHERE      avg_rating > 8
GROUP BY   production_company limit 5;

/*Dream Warrior Pictures & National Theatre Live are the production houses that produced the most number of hit movies of 3 with average rating > 8 */


-- How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT g.genre,
       Count(g.movie_id) AS movie_count
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON g.movie_id = r.movie_id
WHERE  Year(m.date_published) = 2017
       AND Month(m.date_published) = 3
       AND r.total_votes > 1000
       AND m.country = "usa"
GROUP  BY g.genre
ORDER  BY movie_count DESC; 
/* Genre Drama has more movies released(16) during March 2017 in the USA and had more than 1,000 votes */


-- Finding movies of each genre that start with the word ‘The’ and which have an average rating > 8?


SELECT m.title,
       r.avg_rating,
       g.genre
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON g.movie_id = r.movie_id
WHERE  LEFT(m.title, 3) = "the"
       AND r.avg_rating > 8
ORDER  BY r.avg_rating DESC; 

/* The Brighton Miracle has highest Average rating
Movies of each genre that start with the word ‘The’ and which have an average rating > 8 are as follows :
title									avg_rating	genre
The Brighton Miracle					9.5			Drama
The Colour of Darkness					9.1			Drama
The Blue Elephant 2						8.8			Drama
The Blue Elephant 2						8.8			Horror
The Blue Elephant 2						8.8			Mystery
The Irishman							8.7			Crime
The Irishman							8.7			Drama
The Mystery of Godliness: The Sequel	8.5			Drama
The Gambinos							8.4			Crime
The Gambinos							8.4			Drama
Theeran Adhigaaram Ondru				8.3			Action
Theeran Adhigaaram Ondru				8.3			Crime
Theeran Adhigaaram Ondru				8.3			Thriller
The King and I							8.2			Drama
The King and I							8.2			Romance
*/

SELECT m.title,
       r.median_rating,
       g.genre
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON g.movie_id = r.movie_id
WHERE  LEFT(m.title, 3) = "the"
       AND r.median_rating > 8
ORDER  BY r.median_rating DESC; 

/* The Blue Elephant 2 has the highest Median rating */


-- we should also try our hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?


SELECT Count(m.id)
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  r.median_rating = 8
       AND m.date_published BETWEEN '2018-04-01' AND '2019-04-01'; 

/* Of the movies released between 1 April 2018 and 1 April 2019, 361 Movies were given a median rating of 8 */


-- Do German movies get more votes than Italian movies? 

SELECT Sum(total_votes) AS total_no_of_votes
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.country LIKE "%germany%"; 

/* 2026223 VOTES for movies of Germany country */

SELECT Sum(total_votes) AS total_no_of_votes
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.languages LIKE "%german%"; 

/* 4421525 VOTES for movies of German language */


SELECT Sum(total_votes) AS total_no_of_votes
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.country LIKE "%italy%"; 

/* 703024 VOTES for movies of Italy country */

SELECT Sum(total_votes) AS total_no_of_votes
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.languages LIKE "%italian%"; 

/* 2559540 VOTES for movies of Italian language 

Whether we consider country or language, the total votes is more for Germany
*/



/* Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Which columns in the names table have null values??

SELECT Sum(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls
FROM   names; 

/* Number of null values for individual columns in names table are as follows
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|		17335		|	      13431		  |	   15226	    	 |
+---------------+-------------------+---------------------+----------------------+*/





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH top_3_genres AS
(
         SELECT   genre,
                  Count(g.movie_id) AS movie_counts
         FROM     genre             AS g
         JOIN     ratings           AS r
         ON       g.movie_id = r.movie_id
         WHERE    avg_rating > 8
         GROUP BY g.genre
         ORDER BY movie_counts DESC limit 3 )
SELECT   n.NAME            AS director_name,
         Count(g.movie_id) AS movie_count
FROM     names             AS n
JOIN     director_mapping  AS d
ON       n.id = d.name_id
JOIN     genre AS g
ON       d.movie_id = g.movie_id
JOIN     ratings AS r
ON       r.movie_id = g.movie_id,
         top_3_genres
WHERE    g.genre IN (top_3_genres.genre)
AND      avg_rating > 8
GROUP BY director_name
ORDER BY movie_count DESC limit 3;

/* the top three directors in the top three genres whose movies have an average rating > 8 are:
1. James Mangold
2. Anthony Russo
3. Soubin Shahir
 */

/* James Mangold can be hired as the director for RSVP's next project.  
Now, let’s find out the top two actors.*/

-- Who are the top two actors whose movies have a median rating >= 8?

SELECT DISTINCT name              AS actor_name,
                Count(r.movie_id) AS movie_count
FROM   ratings AS r
       INNER JOIN role_mapping AS rm
               ON r.movie_id = rm.movie_id
       INNER JOIN names AS n
               ON rm.name_id = n.id
WHERE  r.median_rating >= 8
       AND rm.category = 'actor'
GROUP  BY n.name
ORDER  BY movie_count DESC
LIMIT  2; 

/* Mammootty and Mohanlal are the top two actors whose movies have a median rating >= 8*/




/* RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Which are the top three production houses based on the number of votes received by their movies?

SELECT     m.production_company,
           Sum(r.total_votes)                                   AS vote_count,
           Dense_rank() OVER (ORDER BY Sum(r.total_votes) DESC) AS prod_comp_rank
FROM       movie                                                AS m
INNER JOIN ratings                                              AS r
ON         m.id = r.movie_id
GROUP BY   m.production_company limit 3;


/* Marvel Studios, Twentieth Century Fox & Warner Bros. are the top three production houses respectively based on the number of votes received by their movies
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- (Considering actor should have acted in at least five Indian movies.)


WITH indian_actor_rank
     AS (SELECT n.NAME,
                Sum(total_votes)                                           AS
                   total_votes,
                Count(r.movie_id)                                          AS
                   movie_count,
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS
                   actor_avg_rating
         FROM   movie AS m
                JOIN ratings AS r
                  ON m.id = r.movie_id
                JOIN role_mapping AS rm
                  ON m.id = rm.movie_id
                JOIN names AS n
                  ON rm.name_id = n.id
         WHERE  country LIKE 'India'
                AND category = 'actor'
         GROUP  BY NAME)
SELECT *,
       Rank()
         OVER (
           ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM   indian_actor_rank
WHERE  movie_count >= 5; 


-- Top actor is Vijay Sethupathi

-- Finding out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Considering actresses should have acted in at least three Indian movies. 


SELECT   NAME AS actress_name,
         total_votes,
         Count(m.id)                                                         AS movie_count,
         Round(Sum(avg_rating*total_votes)/Sum(total_votes),2)               AS actress_avg_rating,
         Dense_rank() OVER (ORDER BY Avg(avg_rating) DESC, total_votes DESC) AS actress_rank
FROM     names                                                               AS n
JOIN     role_mapping                                                        AS rm
ON       n.id = rm.name_id
JOIN     ratings AS r
ON       rm.movie_id = r.movie_id
JOIN     movie AS m
ON       r.movie_id = m.id
WHERE    category = "actress"
AND      country LIKE "%India%"
AND      languages LIKE "%Hindi%"
GROUP BY NAME
HAVING   Count(m.id) >= 3 limit 5;


/* Taapsee Pannu, Divya Dutta, Shraddha Kapoor, Kriti Sanon & Kriti Kharbanda are the top five actresses respectively in Hindi movies released in India based on their average ratings
Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT title,
       avg_rating,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN avg_rating < 5 THEN 'Flop movies'
       END AS movie_rating_category
FROM   movie AS m
       JOIN ratings AS r
         ON m.id = r.movie_id
       JOIN genre AS g
         ON r.movie_id = g.movie_id
WHERE  g.genre = "thriller"
ORDER  BY avg_rating DESC; 


/* Until now, we have analysed various tables of the data set. 
Now, we will perform some tasks that will give us a broader understanding of the data in this segment.*/

-- What is the genre-wise running total and moving average of the average movie duration? 


SELECT g.genre,
       Round(Avg(m.duration), 2)                    AS avg_duration,
       SUM(Round(Avg(m.duration), 2))
         over(
           ORDER BY genre ROWS unbounded preceding) AS running_total_duration,
       Avg(Round(Avg(duration), 2))
         over(
           ORDER BY genre ROWS 10 preceding)        AS moving_avg_duration
FROM   movie AS m
       inner join genre AS g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY genre; 

-- Round is good to have and not a must have; Same thing applies to sorting
-- Let us find top 5 movies of each year with top 3 genres.

-- Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- Top 3 Genres based on most number of movies
WITH top_3_genres AS
(
         SELECT   genre,
                  Count(g.movie_id) AS movie_counts
         FROM     genre             AS g
         JOIN     ratings           AS r
         ON       g.movie_id = r.movie_id
         GROUP BY g.genre
         ORDER BY movie_counts DESC limit 3 ), top_movies AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      worlwide_gross_income,
                      Dense_rank() OVER(partition BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
           FROM       movie                                                                    AS m
           INNER JOIN genre                                                                    AS g
           ON         m.id = g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_3_genres) )
SELECT *
FROM   top_movies
WHERE  movie_rank <= 5;



-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?


SELECT   production_company,
         Count(movie_id)                                  AS movie_count,
         Dense_rank() OVER(ORDER BY Count(movie_id) DESC) AS prod_comp_rank
FROM     movie                                            AS m
JOIN     ratings                                          AS r
ON       m.id = r.movie_id
WHERE    r.median_rating >= 8
AND      m.production_company IS NOT NULL
AND      position(',' IN m.languages) > 0
GROUP BY m.production_company limit 2;


/* Star Cinema & Twentieth Century Fox are the top two production houses that have produced the highest number of hits and also considering multilingual movies*/

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

WITH top AS
(
           SELECT     n.NAME           AS actress_name,
                      Sum(total_votes) AS total_votes,
                      Count(m.id)      AS movie_count,
                      r.avg_rating
           FROM       names AS n
           INNER JOIN role_mapping ro
           ON         n.id = ro.name_id
           INNER JOIN ratings r
           ON         ro.movie_id = r.movie_id
           INNER JOIN movie m
           ON         m.id = r.movie_id
           INNER JOIN genre g
           ON         m.id = g.movie_id
           WHERE      category = 'Actress'
           AND        genre = 'Drama'
           AND        avg_rating > 8
           GROUP BY   actress_name )
SELECT   *,
         Dense_rank () OVER ( ORDER BY movie_count DESC) AS actress_rank
FROM     top LIMIT 3;

/* Parvathy Thiruvothu, Susan Brown & Amanda Lawrence are the top 3 actresses respectively based on number of Super Hit movies (average rating >8) in drama genre*/



/* Getting the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations*/

WITH movie_date_info AS
(
         SELECT   d.name_id,
                  NAME,
                  d.movie_id,
                  m.date_published,
                  Lead(date_published, 1) OVER(partition BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
         FROM     director_mapping                                                                         AS d
         JOIN     names                                                                                    AS n
         ON       d.name_id = n.id
         JOIN     movie AS m
         ON       d.movie_id = m.id ), date_difference AS
(
       SELECT *,
              Datediff(next_movie_date, date_published) AS diff
       FROM   movie_date_info ), avg_inter_days AS
(
         SELECT   name_id,
                  Avg(diff) AS avg_inter_movie_days
         FROM     date_difference
         GROUP BY name_id ), final_result AS
(
         SELECT   d.name_id                                          AS director_id,
                  NAME                                               AS director_name,
                  Count(d.movie_id)                                  AS number_of_movies,
                  Round(avg_inter_movie_days)                        AS inter_movie_days,
                  Round(Avg(avg_rating),2)                           AS avg_rating,
                  Sum(total_votes)                                   AS total_votes,
                  Min(avg_rating)                                    AS min_rating,
                  Max(avg_rating)                                    AS max_rating,
                  Sum(duration)                                      AS total_duration,
                  Row_number() OVER(ORDER BY Count(d.movie_id) DESC) AS director_row_rank
         FROM     names                                              AS n
         JOIN     director_mapping                                   AS d
         ON       n.id=d.name_id
         JOIN     ratings AS r
         ON       d.movie_id=r.movie_id
         JOIN     movie AS m
         ON       m.id=r.movie_id
         JOIN     avg_inter_days AS a
         ON       a.name_id=d.name_id
         GROUP BY director_id )
SELECT *
FROM   final_result LIMIT 9;


/* Based on number of movies, Andrew Jones, A.L. Vijay and Özgür Bakar are top 3 directors */




