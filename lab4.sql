USE sakila;
-- Write SQL queries to perform the following tasks using the Sakila database:
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(i.inventory_id) AS number_of_copies FROM sakila.film AS f
JOIN sakila.inventory AS i
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT a.first_name, a.last_name FROM sakila.actor AS a
JOIN sakila.film_actor AS fa 
ON a.actor_id = fa.actor_id
WHERE fa.film_id = (SELECT f.film_id FROM sakila.film AS f WHERE f.title = 'Alone Trip');

-- BONUS
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title FROM sakila.film AS f
JOIN sakila.film_category AS fc 
ON f.film_id = fc.film_id
JOIN sakila.category AS c 
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 5 Retrieve the name and email of customers from Canada using both subqueries and joins.
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.

-- using joins:
SELECT cu.first_name, cu.last_name, cu.email FROM sakila.customer AS cu
JOIN sakila.address AS a 
ON cu.address_id = a.address_id
JOIN sakila.city AS ci 
ON a.city_id = ci.city_id
JOIN sakila.country AS co 
ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- using subqueries:
SELECT cu.first_name, cu.last_name, cu.email FROM sakila.customer AS cu
WHERE cu.address_id IN (SELECT a.address_id FROM sakila.address AS a
WHERE a.city_id IN (SELECT ci.city_id FROM sakila.city AS ci
WHERE ci.country_id = (SELECT co.country_id FROM sakila.country AS co
WHERE co.country = 'Canada')));

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT actor_id FROM sakila.film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1; -- this is the most prolific actor

-- and now lets find the films he starred
SELECT f.title FROM sakila.film AS f
JOIN sakila.film_actor AS fa 
ON f.film_id = fa.film_id
WHERE fa.actor_id = (SELECT actor_id FROM sakila.film_actor -- adding the most prolific actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1);

-- 7. Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT customer_id FROM sakila.payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1; -- this is the most profitable customer

-- now lets find the films he rented:
SELECT DISTINCT f.title FROM sakila.film AS f
JOIN sakila.inventory AS i 
ON f.film_id = i.film_id
JOIN sakila.rental AS r 
ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (SELECT customer_id -- adding the most profitable customer
FROM sakila.payment
GROUP BY customer_id
 ORDER BY SUM(amount) DESC
LIMIT 1);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.
SELECT customer_id, SUM(amount) AS total_amount_spent FROM sakila.payment
GROUP BY customer_id
HAVING total_amount_spent > (SELECT AVG(total_spent) FROM (SELECT SUM(amount) AS total_spent FROM sakila.payment GROUP BY customer_id) AS subquery);
