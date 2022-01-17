USE imdb_ijs;

/* The big picture:
	- How many actors are there in the actors table?
    - How many directors are there in the directors table?
    - How many movies are there in the movies table? */

SELECT COUNT(DISTINCT id) as num_actors FROM actors;
SELECT COUNT(DISTINCT id) as num_directors FROM directors;
SELECT COUNT(DISTINCT id) as num_movies FROM movies;

/* Exploring the movies:
	- From what year are the older and the newest movies? What are the names of those movies?
    - What movies have the highest and the lowest ranks?
    - What is the most common movie title? */

#Oldest and newest movies:
SELECT b.name AS movie_name, b.year AS year
FROM (
SELECT MIN(year) AS min_year FROM movies 
) AS a, 
(SELECT name, year FROM movies) AS b
WHERE b.year = a.min_year
UNION
SELECT b.name AS movie_name, b.year AS year
FROM (
SELECT MAX(year) AS max_year FROM movies 
) AS a, 
(SELECT name, year FROM movies) AS b
WHERE b.year = a.max_year;


# Highest and lowest rank:
SELECT name, movies.rank FROM movies
WHERE movies.rank IS NOT NULL
ORDER BY movies.rank DESC;

SELECT name, movies.rank FROM movies
WHERE movies.rank IS NOT NULL
ORDER BY movies.rank ASC;

SELECT name, COUNT(id) as num_common FROM movies
GROUP BY name
ORDER BY num_common DESC
LIMIT 1;

/* Understanding the database
	- Are there movies with multiple directors */

SELECT movie_id, COUNT(DISTINCT director_id) as num_director FROM movies_directors
GROUP BY movie_id
ORDER BY num_director DESC;
    
/*  - What is the movie with the most directors? Why do you think it has so many? */

SELECT m.id, m.name, COUNT(DISTINCT md.director_id) as num_director FROM movies AS m, movies_directors AS md
WHERE m.id = md.movie_id
GROUP BY md.movie_id
ORDER BY num_director DESC
LIMIT 1;

/*  - On average, how many actors are listed by movie? */
WITH previous AS(
SELECT DISTINCT movie_id, COUNT(DISTINCT actor_id) as num_actor FROM roles
GROUP BY movie_id
)
SELECT ROUND(AVG(num_actor)) as avg_num_actor FROM previous;

/*  - Are there movies with more than one genre? */
WITH previous AS(
SELECT COUNT(movies_genres.index) AS num_genre, movie_id FROM movies_genres
GROUP BY movie_id)
SELECT COUNT(DISTINCT movie_id) FROM previous
WHERE num_genre > 1;
    
/* Looking for specific movies
	- Can you find the movie called "Pulp Fiction"?
		- Who directed it?
        - Which actors where casted on it?*/

# Find Pulp Fiction and the director
SELECT year, name, last_name, first_name FROM movies
INNER JOIN movies_directors
	ON movies_directors.movie_id = movies.id
INNER JOIN directors
	ON directors.id = movies_directors.director_id
WHERE name = 'Pulp Fiction';

# Actors casted on Pulp Fiction
SELECT name, first_name, last_name FROM actors
INNER JOIN roles
	ON roles.actor_id = actors.id
INNER JOIN movies
	ON movies.id = roles.movie_id
WHERE name = 'Pulp Fiction';


/*  - Can you find the movie called "La Dolce Vita"?
		- Who directed it?
        - Which actors where casted on it? */

# Find "La Dolce Vita" and the director
SELECT year, name, last_name, first_name FROM movies
INNER JOIN movies_directors
	ON movies_directors.movie_id = movies.id
INNER JOIN directors
	ON directors.id = movies_directors.director_id
WHERE name REGEXP '^la dolce vita|^dolce vita, la';

# Actors casted in La Dolce Vita
SELECT name, first_name, last_name FROM actors
INNER JOIN roles
	ON roles.actor_id = actors.id
INNER JOIN movies
	ON movies.id = roles.movie_id
WHERE name REGEXP '^la dolce vita|^dolce vita, la';
    
/*  - When was the movie "Titanic" by James Cameron released?
		- Hint 1: there are many movies names "Titanic". We want the one directed by James Cameron.
        - Hint 2: the name "James Cameron" is stored with a weird charater on it. */

SELECT year, name, last_name, first_name FROM movies
INNER JOIN movies_directors
	ON movies_directors.movie_id = movies.id
INNER JOIN directors
	ON directors.id = movies_directors.director_id
WHERE last_name = 'Cameron'
AND first_name LIKE '%James%'
AND name = 'Titanic';

/* Actors and directors:
	- Who is the actor that acted more times as "Himself"*/
SELECT a.first_name, a.last_name, COUNT(r.index) AS num_role, r.role FROM roles AS r, actors AS a
WHERE a.id = r.actor_id
AND
r.role = 'Himself'
GROUP BY r.actor_id
ORDER BY num_role DESC
LIMIT 1;

/*  - What is the most common name for actors? And for directors?*/
SELECT last_name, COUNT(id) AS num_name FROM actors
GROUP BY last_name
ORDER BY num_name DESC
LIMIT 1;

SELECT last_name, COUNT(id) AS num_name FROM directors
GROUP BY last_name
ORDER BY num_name DESC
LIMIT 1;

/* Analysing genders:
	- How many actors are male and how many are female?*/
/*  - Answer the question above both in absolute and relative terms*/

# In absolute terms:
SELECT COUNT(id) AS num_actor, gender FROM actors
GROUP BY gender;

# In relative terms:
SELECT (a.num_actors/b.tot_actors)*100 AS perc_actors, a.gender AS gender 
FROM 
(SELECT COUNT(id) AS num_actors, gender FROM actors
GROUP BY gender) AS a,
(SELECT COUNT(id) AS tot_actors FROM actors) AS b;

/* Movies across time:
	- How many of the movies were released after the year 2000? */
SELECT COUNT(DISTINCT id) AS num_movies_2000 FROM movies
WHERE year > 2000;

/*  - How many of the movies where released between the years 1990 and 2000? */
SELECT COUNT(DISTINCT id) AS num_movies_1990_2000 FROM movies
WHERE year >= 1990 AND year < 2000;

/*  - Which are the 3 years with the most movies? How many movies were produced on those years? */
SELECT year, COUNT(DISTINCT id) AS num_movies FROM movies
GROUP BY year
ORDER BY num_movies DESC
LIMIT 3;

/*  - What are the top 5 movie genres? */
/*		- What are the top 5 movie genres before 1920? */
/*		- What is the evolution of the top movie genres across all the decades of the 20th century? */

# Top 5 movie genres
SELECT genre, COUNT(DISTINCT movies_genres.index) AS num_genres FROM movies_genres
GROUP BY genre
ORDER BY num_genres DESC
LIMIT 5;

# Top 5 movie genres before 1920
SELECT genre, COUNT(DISTINCT movies_genres.index) AS num_genres 
FROM movies_genres
INNER JOIN movies
	ON movies_genres.movie_id = movies.id
WHERE year < 1920
GROUP BY genre
ORDER BY num_genres DESC
LIMIT 5;

# Evolution of the top movie genres across all the decades of the 20th century
SELECT genre, COUNT(DISTINCT movies_genres.index) AS num_genres 
FROM movies_genres
INNER JOIN movies
	ON movies_genres.movie_id = movies.id
GROUP BY genre
ORDER BY num_genres DESC
LIMIT 5;

/* Putting it all together: names, genders and time: */
/*	- Has the most common name for actors changed over time? */
/*	- Get the most common actor name for each decade in the XX century. */
/*	- Redo the analysis on the most common names, splitted for males and females */

# This can be done only for actors as the gender is not available for directors
SELECT f.last_name AS female_name, m.last_name AS male_name
FROM
(SELECT last_name, gender, COUNT(DISTINCT id) AS num_actors FROM actors
WHERE gender = 'M'
GROUP BY last_name
ORDER BY num_actors DESC
LIMIT 1) AS m,
(SELECT last_name, gender, COUNT(DISTINCT id) AS num_actors FROM actors
WHERE gender = 'F'
GROUP BY last_name
ORDER BY num_actors DESC
LIMIT 1) AS f;

/*	- Is the proportion of female actors greated after 1968, compared to before 1968? */
SELECT COUNT(DISTINCT actors.id) AS num_actor, gender FROM actors
INNER JOIN roles
	ON actors.id = roles.actor_id
INNER JOIN movies
	ON roles.movie_id = movies.id
GROUP BY gender;

SELECT COUNT(id) FROM actors;


/*	- What is the movie genre where there are the most female actors? Answer the question both in absolute and relative terms */

/*	- How many movies had a majority of female among their cast? Answer the question both in absolute and relative terms */
        

