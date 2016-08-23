# Assingment 5
# tiffany chen
# 11/28/15

library(RSQLite)

## old database
# import the file
db = dbConnect(drv = SQLite(), dbname = '/Users/tiffanychen/Desktop/STA 141/imdb_data')
dbListTables(db) 

## Q1 
# look specifically at actors
dbListFields(db, "actors")

# count how many actors 3500167
dbGetQuery(db, "SELECT count(idactors) FROM actors")
dbGetQuery(db, "SELECT count(fname) FROM actors") # 3500166
dbGetQuery(db, "SELECT idactors FROM actors") 

# number of movies 1298737
dbListFields(db, "movies")
dbGetQuery(db, "SELECT count(title) FROM movies")
dbGetQuery(db, "SELECT count(idmovies) FROM movies") # 1,298,737

## Q2
dbListFields(db, "movies")
dbGetQuery(db, "SELECT year FROM movies")
dbGetQuery(db, "SELECT MIN(year) FROM movies") # 1
dbGetQuery(db, "SELECT MAX(year) FROM movies") # 2025

dbGetQuery(db, "SELECT DISTINCT(year) FROM movies") # lists all the distinct

year_period = unique(dbGetQuery(db, "SELECT year FROM movies"))
sort(year_period$year)

dbGetQuery(db, "SELECT year, title FROM movies LIMIT 100") 

dbGetQuery(db, "SELECT * FROM movies WHERE year = '2025'") # makes sense
dbGetQuery(db, "SELECT * FROM movies WHERE year = '1'")
dbGetQuery(db, "SELECT * FROM movies WHERE year = '3'")

## Q3 
dbGetQuery(db, "SELECT DISTINCT gender FROM actors")

# ===========================================================
## new data
db = dbConnect(drv = SQLite(), dbname = '/Users/tiffanychen/Desktop/STA 141/lean_imdbpy.db')
dbListTables(db) 

## data that is even smaller (used for q9-12 for using R only)
db = dbConnect(drv = SQLite(), dbname = '/Users/tiffanychen/Desktop/STA 141/lean_imdbpy_2010_idx.db')

## Q1
# How many actors are there in the database? How many movies?
dbGetQuery(db, "SELECT COUNT(DISTINCT person_id) 
           FROM aka_name;") # 719127 distinct names of actors

dbGetQuery(db, "SELECT COUNT(name) 
           FROM name LIMIT 10;") # 5375509 actors

dbGetQuery(db, "SELECT COUNT(*) 
           FROM title LIMIT 10;") # 3527732 movies/titles

dbGetQuery(db, "SELECT COUNT(DISTINCT(title)) 
           FROM title 
           WHERE kind_id = 1;") # 722933 movies

dbGetQuery(db, "SELECT COUNT( DISTINCT(name)) 
          FROM cast_info, name
          WHERE role_id = 1 
           AND name.id = cast_info.person_id;") # 1936807 actors

## Q2
# What time period does the database cover?
# not just movies
dbGetQuery(db, "SELECT MIN(production_year) 
           FROM title;") # 1874 min yr
dbGetQuery(db, "SELECT MAX(production_year) 
           FROM title;") # 2025 max yr

dbGetQuery(db, "SELECT * FROM title 
           WHERE production_year = 1874") # looking at it to check realness
dbGetQuery(db, "SELECT title FROM title 
           WHERE production_year = 2018")

## Q3
# What proportion of the actors are female? male?
dbGetQuery(db,"SELECT * FROM name LIMIT 10;")

# returns the numbers of males/females/NAs
dbGetQuery(db, "SELECT gender, 
            COUNT(*) * 100.0 / (SELECT COUNT(*) FROM name)
           FROM name GROUP BY gender;") # actual proportions

## Q4
# What proportion of the entries in the movies table 
# are actual movies and what proportion are television series, etc.?
dbGetQuery(db, "SELECT * FROM title LIMIT 10;")
dbGetQuery(db, "SELECT * FROM kind_type;")


# merge kind of movies with the title table
dbGetQuery(db, "CREATE TABLE movie AS SELECT * 
        FROM title AS t, kind_type AS k
           WHERE t.kind_id = k.id;")
dbGetQuery(db, "SELECT * FROM movie LIMIT 10")

# return proportions of entries
dbGetQuery(db, "SELECT kind, COUNT(*) * 100.0 / 
            (SELECT COUNT(*) FROM movie)
           FROM movie GROUP BY kind;")

## Q5
# How many genres are there? 
# What are their names/descriptions?

dbGetQuery(db, "SELECT * FROM info_type LIMIT 10;") # genres = 3
dbGetQuery(db, "SELECT * FROM movie_info LIMIT 10;")

# only look at genres which is info_type 3
dbGetQuery(db, "SELECT DISTINCT info 
           FROM movie_info 
           WHERE info_type_id = 3;")

## Q6
# http://stackoverflow.com/questions/12235595/find-most-frequent-value-in-sql-column
dbGetQuery(db, "SELECT info, COUNT(info) 
            FROM movie_info 
            WHERE info_type_id = 3
           GROUP BY info 
           ORDER BY COUNT(*) DESC LIMIT 10;")

## Q7
# Find all movies with the keyword 'space'. How many are there? 
# What are the years these were released? 
# and who were the top 5 actors in each of these movies?

# You want to look for the movies that have an entry in the movie_keyword that corresponds to an entry in the keyword table that has 'space' in the keyword.
# So NOT space in the title or in the info, but in the keyword associated with the movie.

####

dbGetQuery(db, "CREATE TABLE keywordtitle AS 
          SELECT * FROM title, movie_keyword, keyword
          WHERE title.id = movie_keyword.movie_id
          AND movie_keyword.keyword_id = keyword.id")

dbGetQuery(db, "SELECT * FROM keywordtitle LIMIT 5;")

dbGetQuery(db, "CREATE TABLE spacemovies AS 
            SELECT * FROM keywordtitle 
            WHERE keyword = 'space' AND kind_id = 1;")

dbGetQuery(db, "SELECT COUNT(DISTINCT title) 
           FROM spacemovies;") # 400 space movies
dbGetQuery(db, "SELECT * FROM spacemovies LIMIT 5")
# ======================================================================
# just looking at these tables
dbGetQuery(db, "SELECT * FROM keyword LIMIT 5;")
dbGetQuery(db, "SELECT * FROM movie_keyword LIMIT 5;")
dbGetQuery(db, "SELECT * FROM title LIMIT 5;")
dbGetQuery(db, "SELECT * FROM movie_info LIMIT 3")
dbGetQuery(db, "SELECT * FROM kind_type LIMIT 5;")
dbGetQuery(db, "SELECT * FROM cast_info LIMIT 5;")

# use production_year from title table
dbGetQuery(db, "SELECT production_year FROM spacemovies;")
dbGetQuery(db, "SELECT MIN(production_year), MAX(production_year)
           FROM spacemovies;") # 1911 to 2018

# top 5 actors in each of these movies
# refers to actor's billing position 
# nr_order in the cast_info table
# piazza post 1213
dbGetQuery(db, "SELECT * FROM spacemovies LIMIT 5")
dbGetQuery(db, "SELECT nr_order FROM cast_info LIMIT 5;")
dbGetQuery(db, "SELECT * FROM name LIMIT 5;")
dbGetQuery(db, "SELECT * FROM role_type LIMIT 10;")
# =================================================

dbGetQuery(db, "CREATE TEMPORARY TABLE spacecast AS 
           SELECT * FROM cast_info, spacemovies
           WHERE cast_info.movie_id = spacemovies.id")
dbGetQuery(db, "SELECT * FROM spacecast LIMIT 5;")

dbGetQuery(db, "CREATE TABLE spacenames AS
           SELECT * FROM spacecast, name
           WHERE spacecast.person_id = name.id")
dbGetQuery(db, "SELECT * FROM spacenames LIMIT 5;")

dbGetQuery(db, "SELECT nr_order, name, title 
            FROM spacenames 
           WHERE nr_order BETWEEN 1 AND 5 
           GROUP BY title, nr_order LIMIT 30")


# =================================================
## Q8
# Has the number of movies in each genre changed over time? 
# Plot the overall number of movies in each year over time, and for each genre.
dbGetQuery(db, "SELECT * FROM genres LIMIT 40;")

movieyr = dbGetQuery(db, "SELECT production_year, COUNT(info)
          FROM genres, title 
          WHERE genres.movie_id = title.id
          AND title.kind_id = 1
          GROUP BY production_year;")

# Plot the overall number of movies in each year over time,
head(movieyr)
colnames(movieyr) = c("Year", "Number")

movieyro = na.omit(movieyr) # remove NA for graphing
plot(movieyro,  main = "Overall Number of Movies Per Year Over Time", xlab = "Year", ylab = "Number of Movies per Year", xlim = c(1875, 2025), type = "l" )

# same but using ggplot, connect lines instead of dots
library(ggplot2)
ggplot(movieyro, aes(Year, Number)) + geom_line()  + xlab("Year") + ylab("Number of Movies per Year") + ggtitle("Overall Number of Movies Per Year Over Time")
                                                                      
# http://stackoverflow.com/questions/2421388/using-group-by-on-multiple-columns
# returns year and count of movies by genre
genre = dbGetQuery(db, "SELECT info, COUNT(*) 
           FROM genres, title 
          WHERE genres.movie_id = title.id
          AND title.kind_id = 1
          GROUP BY info ;")
colnames(genre) = c("type", "count")
dotchart(genre$count, labels = as.factor(genre$type), cex = .7, main = "Overall Number of Movies for Each Genre", xlab = "Counts")

# plot over time, per genre
genreyr = dbGetQuery(db, "SELECT production_year, info, COUNT(*) 
           FROM genres, title 
          WHERE genres.movie_id = title.id
          AND title.kind_id = 1
          GROUP BY production_year, info ;")

head(genreyr, 40)
genreyr = na.omit(genreyr)
colnames(genreyr) = c("year", "genre", "count")

plot(genreyr$year, genreyr$count, main = "Number of Movies per Yr for each Genre", xlab = "Year", ylab = "Number of Movies", type = "l")

library(ggplot2)
ggplot(genreyr, aes(x = year, y = count, fill = genre)) + geom_area(colour = NA, alpha = .4) + geom_line(position = "stack", size = .2) + ggtitle("Overall Number of Movies Per Year Over Time by Genre")

## I WANT TO DO 4 GRAPHS, each graph has 7 genres
library(gridExtra)
one = subset(genreyr, genre %in% c("Action", "Adult","Adventure", "Animation", "Biography", "Comedy", "Crime"))
plot1 = ggplot(one, aes(x = year, y = count, fill = genre)) + geom_area(colour = NA, alpha = .4) + geom_line(position = "stack", size = .2) + ggtitle("Overall Number of Movies Per Year Over Time by Genre")

two = subset(genreyr, genre %in% c("Documentary", "Drama", "Family","Fantasy", "Film-Noir", "Game-Show", "History"))
plot2 = ggplot(two, aes(x = year, y = count, fill = genre)) + geom_area(colour = NA, alpha = .4) + geom_line(position = "stack", size = .2) + ggtitle("Overall Number of Movies Per Year Over Time by Genre")

three = subset(genreyr, genre %in% c("Horror", "Music","Musical", "Mystery", "News", "Reality-TV", "Romance"))
plot3 = ggplot(three, aes(x = year, y = count, fill = genre)) + geom_area(colour = NA, alpha = .4) + geom_line(position = "stack", size = .2) + ggtitle("Overall Number of Movies Per Year Over Time by Genre")

four = subset(genreyr, genre %in% c("Sci-Fi", "Short","Sport", "Talk-Show", "Thriller", "War", "Western"))
plot4 = ggplot(four, aes(x = year, y = count, fill = genre)) + geom_area(colour = NA, alpha = .4) + geom_line(position = "stack", size = .2) + ggtitle("Overall Number of Movies Per Year Over Time by Genre")

grid.arrange(plot1, plot2, plot3, plot4, ncol = 2, nrow = 2)
# https://www.safaribooksonline.com/library/view/r-graphics-cookbook/9781449363086/ch04.html

## Q9 
# Who are the actors that have been in the most movies? List the top 20.

dbGetQuery(db, "SELECT * FROM role_type;")
dbGetQuery(db, "SELECT * FROM cast_info LIMIT 5;")
dbGetQuery(db, "SELECT * FROM name LIMIT 5;")
dbGetQuery(db, "SELECT * FROM title LIMIT 5;")


# actors and names
dbGetQuery(db, "SELECT name, person_id, count(name) 
          FROM cast_info, name, title
          WHERE cast_info.role_id = 1 
           AND name.id = cast_info.person_id
           AND title.kind_id = 1
           AND cast_info.movie_id = title.id
           GROUP BY name
           ORDER BY COUNT(name) DESC LIMIT 20;")

## USING R
## data that is even smaller
db = dbConnect(drv = SQLite(), dbname = '/Users/tiffanychen/Desktop/STA 141/lean_imdbpy_2010_idx.db')
# http://stackoverflow.com/questions/18799901/data-frame-group-by-column
dbListTables(db)
name = dbReadTable(db, "name2")
head(name)
cast = dbReadTable(db, "cast_info2")
title = dbReadTable(db, "title2")
head(cast)
head(title)

actors = subset(cast, role_id == "1") # actors only
movies = subset(title, kind_id == "1")

colnames(name)[1] = "person_id"
actorname = merge(actors, name, by = c("person_id"))

colnames(movies)[1] = "movie_id"
actornametitle = merge(actorname, movies, by = c("movie_id"))

sums = aggregate(person_id ~ movie_id, actornametitle, sum) # similar to GROUP BY
attach(sum)
newdata = sum[order(-movie_id), ]
head(newdata, 20)
  
library(data.table) # results confirmed 
dt = data.table(actornametitle)
dt[, sum(person_id), by = movie_id]


## Q10
# Who are the actors that have had the most number of movies with "top billing",
# i.e., billed as 1, 2 or 3? 
# For each actor, also show the years these movies spanned?
dbGetQuery(db, "SELECT name, COUNT(name), MAX(production_year), MIN(production_year)
           FROM cast_info, name, title WHERE nr_order 
           BETWEEN 1 AND 3 AND cast_info.role_id = 1
           AND name.id = cast_info.person_id
           AND title.id = cast_info.movie_id
          AND title.kind_id = 1
           GROUP BY name
           ORDER BY COUNT(name) DESC LIMIT 5")

dbGetQuery(db, "SELECT * FROM title LIMIT 5")
dbGetQuery(db, "SELECT * FROM cast_info LIMIT 5")
dbGetQuery(db, "SELECT * FROM name LIMIT 5")

## Q11
# Who are the 10 actors that performed in the most movies within any given year? 
# What are their names, the year they starred in these movies and the names of the movies?

# You want to find the number of movies each actor appeared in for each year, and then find the 10 largest counts.
# So we might have one actor who appeared in 20 movies in 1993 and another who appeared in 25 movies in 2010 and so on.
# And we want the the 10 largest of these counts.

# for each year
dbGetQuery(db, "CREATE TABLE yearactor AS
           SELECT production_year, name, COUNT(*) AS number_of_movies 
           FROM title, name, cast_info 
           WHERE cast_info.role_id = 1 
           AND name.id = cast_info.person_id
           AND title.kind_id = 1
           AND cast_info.movie_id = title.id 
           GROUP BY name, production_year")

dbGetQuery(db, "CREATE TABLE yearactor2 AS
           SELECT production_year, name, number_of_movies, 
           (SELECT COUNT(*) 
           FROM yearactor 
           WHERE production_year = t1.production_year 
           AND number_of_movies >= t1.number_of_movies) AS rank 
           FROM yearactor AS t1")

dbGetQuery(db, "SELECT production_year, name, number_of_movies
           FROM yearactor2 
           WHERE rank <= 10")

# for all time
dbGetQuery(db, "CREATE TABLE yearactor AS
           SELECT production_year, name, COUNT(*) AS number_of_movies 
           FROM title, name, cast_info 
           WHERE cast_info.role_id = 1 
           AND name.id = cast_info.person_id
           AND title.kind_id = 1
           AND cast_info.movie_id = title.id 
           GROUP BY name, production_year")

dbGetQuery(db, "SELECT production_year, name 
           FROM yearactor
           ORDER BY number_of_movies DESC LIMIT 10")

# specific movies
dbGetQuery(db, "CREATE TEMPORARY TABLE toptens 
           AS SELECT production_year AS year, name AS actorname
           FROM yearactor
           ORDER BY number_of_movies DESC LIMIT 10")

# get the names
dbGetQuery(db, "SELECT title, year, actorname
           FROM toptens, nametitlecast
           WHERE toptens.year = nametitlecast.production_year 
           AND toptens.actorname = nametitlecast.name LIMIT 10")

# i just realized Q9-11 uses the same 3 tables
# title, name, and cast_info....
# i'll just create a table
dbGetQuery(db, "CREATE TABLE nametitlecast AS SELECT *
           FROM title, name, cast_info 
           WHERE cast_info.role_id = 1 
           AND name.id = cast_info.person_id
           AND title.kind_id = 1
           AND cast_info.movie_id = title.id ")

dbGetQuery(db, "SELECT production_year, title, name, COUNT(DISTINCT title) 
           FROM nametitlecast
           GROUP BY production_year, name 
           ORDER BY COUNT(DISTINCT title) DESC LIMIT 10")

dbGetQuery(db, "SELECT production_year, title, name, COUNT(production_year) 
           FROM nametitlecast
           GROUP BY production_year, name 
           ORDER BY COUNT(production_year) DESC LIMIT 10")


dbGetQuery(db, "SELECT * FROM nametitlecast LIMIT 5")
dbGetQuery(db, "SELECT * FROM name LIMIT 5")
dbGetQuery(db, "SELECT * FROM cast_info LIMIT 5")

# USING R
actornametitle = merge(actorname, movies, by = c("movie_id"))
# http://stackoverflow.com/questions/27193373/what-is-the-r-equivalent-of-sql-select-from-table-group-by-c1-c2 
sums = aggregate(. ~ production_year + name, actornametitle, FUN = head, 1)
attach(sum)
newdata = sum[order(-movie_id), ]
head(newdata, 20)

## Q12
# Who are the 10 actors that have the most aliases (i.e., see the aka_name table).
dbGetQuery(db, "SELECT * FROM aka_name LIMIT 10;")

dbGetQuery(db, "SELECT name, person_id, COUNT(person_id) 
           FROM aka_name GROUP BY person_id 
           ORDER BY COUNT(person_id) DESC LIMIT 10")

dbGetQuery(db, "SELECT name, person_id, COUNT(person_id) 
           FROM aka_name GROUP BY person_id 
           ORDER BY COUNT(*) DESC LIMIT 10")

## Q13
# Networks: Pick a (lead) actor who has been in at least 20 movies. 
# Find all of the other actors that have appeared in a movie with that person.
# For each of these, find all the people they have appeared in a movie with it. 
# Use this to create a network/graph of who has appeared with who. 
# Use the igraph or statnet packages to display this network. 

# If you want, you can do this with individual SQL commands and the process the results in R to generate new SQL queries. In other words, don't spend too much time trying to create clever SQL queries if there is a more direct way to do this in R.

dbListTables(db)
# top lead actor been in 20 movies.
dbGetQuery(db, "SELECT name, COUNT(name)
           FROM cast_info, name, title 
            WHERE nr_order = 1 
            AND cast_info.role_id = 1
           AND name.id = cast_info.person_id
           AND title.id = cast_info.movie_id
          AND title.kind_id = 1
           GROUP BY name
           HAVING COUNT(*) = 20 LIMIT 10")

# Ainley, Henry first person
# these steps are from nick's OH
# 1. pull person_id for specific actor 
ids = dbGetQuery(db, "SELECT id FROM name 
                 WHERE name = 'Ainley, Henry'")
ids

# 2. pull all movies for that actor
henrymovies = dbGetQuery(db, "SELECT movie_id 
                         FROM cast_info 
                         WHERE person_id = 21906")
# function
find_movies = function(actor_id, db) {
  # get movies for a specific person ID
  qr = sprintf('SELECT movie_id FROM cast_info 
               WHERE person_id = %i', actor_id)
  dbGetQuery(db, qr)
}

henrymovies = find_movies(ids$id, db)


# 3. pull cast for all that actor's movies
qr = sprintf('SELECT name FROM cast_info, name
               WHERE cast_info.movie_id = %i 
               AND name.id = cast_info.person_id', henrymovies$movie_id)
dbGetQuery(db, qr)

# function
find_actors = function(x, db) {
  # find all actors for a given movie
  qr = sprintf('SELECT name FROM cast_info, name 
               WHERE cast_info.movie_id = %i 
               AND name.id = cast_info.person_id', x)
  dbGetQuery(db, qr)
}

find_actorsid = function(x, db) {
  # find all actors for a given movie
  qr = sprintf('SELECT person_id FROM cast_info, name 
               WHERE cast_info.movie_id = %i 
               AND name.id = cast_info.person_id', x)
  dbGetQuery(db, qr)
}

actors = find_actors(henrymovies$movie_id, db)
actors = find_actorsid(henrymovies$movie_id, db)

movies = unique(henrymovies$movie_id)
cast = lapply(movies, find_actors, db)
cast = lapply(movies, find_actorsid, db)


# 4. repeat (so write a function for 1-3)
# names
cast1 = unlist(cast, use.names = FALSE)
ids2 = lapply(cast1, find_movies, db)

# ids
cast1 = unlist(cast, use.names = FALSE)
ids = lapply(cast1, find_movies, db)

# 2nd gen
ids2 = unlist(ids, use.names = FALSE)
cast2 = lapply(ids2, find_actors, db) # actors of actors of henry
cast3 = unlist(cast2, use.names = FALSE)
# graphing
library(igraph)

henry = "Ainley, Henry"
cast = cast1[1:10]
e = data.frame(henry = rep(henry, 10), cast)
g = graph_from_data_frame(e, directed = TRUE)
plot(g)

cast3 = cast3[1:30]
gen1 = rep(cast, each = 30)
gen2 = rep(cast3, 30)
e = data.frame(gen1, gen2)
gr = graph_from_data_frame(e, directed = TRUE)
plot(gr)


## Q14
# What are the 10 television series that have the most number of movie stars appearing in the shows?
dbGetQuery(db, "SELECT title, COUNT(*)
           FROM cast_info, name, title 
            WHERE nr_order = 1 
           AND cast_info.role_id = 1
           AND name.id = cast_info.person_id
           AND title.id = cast_info.movie_id
           AND title.kind_id = 2
           GROUP BY name 
           ORDER BY COUNT(*) DESC LIMIT 10")

