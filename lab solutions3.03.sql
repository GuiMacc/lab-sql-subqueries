USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
    
SELECT film_id, count(*) AS num_film FROM sakila.inventory
	WHERE film_id = (
	SELECT film_id FROM sakila.film
    WHERE title='Hunchback Impossible'
    ) ;

-- 2. List all films whose length is longer than the average of all the films.

SELECT title FROM sakila.film
	WHERE length > (
    SELECT avg(length) FROM sakila.film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT concat(first_name,' ',last_name) AS actor_name FROM sakila.actor
	WHERE actor_id IN (
	SELECT actor_id FROM sakila.film_actor
		WHERE film_id = (
		SELECT film_id FROM sakila.film
			WHERE title = 'Alone Trip'
		)
	);
        

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title FROM sakila.film
	WHERE film_id IN (
    SELECT film_id FROM sakila.film_category
		WHERE category_id = (
		SELECT category_id FROM sakila.category
			WHERE name = 'family'
        )
	);

/* 5. Get name and email from customers from Canada using subqueries. Do the same with joins.
Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.*/

SELECT email FROM customer
	WHERE address_id IN (
    SELECT address_id FROM address
		WHERE city_id IN (
        SELECT city_id FROM city
			WHERE country_id IN (
			SELECT country_id FROM country
				WHERE country = 'CANADA'
			)
		)
	);
  
SELECT c.email FROM sakila.customer c
	JOIN address a
	ON c.address_id = a.address_id
		JOIN city ci
        ON a.city_id = ci.city_id
			JOIN country co
            ON ci.country_id = co.country_id
            WHERE co.country='CANADA';

/* 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films.
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.*/

SELECT title FROM sakila.film
	WHERE film_id IN (
    SELECT film_id FROM (
		SELECT actor_id, count(*) AS num_films FROM sakila.film_actor
		GROUP BY actor_id
        ) AS actor_sub
	)
    LIMIT 1 ;
    
SELECT title FROM sakila.film
	WHERE film_id IN (
		SELECT film_id FROM(
		SELECT film_id, actor_id FROM sakila.film_actor
			WHERE actor_id IN (
				SELECT actor_id FROM (
				SELECT actor_id, count(*) AS num_films FROM sakila.film_actor
				GROUP BY actor_id
                ORDER BY num_films DESC
                LIMIT 1
				) as actor_sub
			)
		) as film_sub
	);

/* 7. Films rented by most profitable customer.
You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments*/

SELECT title FROM sakila.film
	WHERE film_id IN (
		SELECT film_id FROM (
		SELECT film_id, inventory_id FROM sakila.inventory
			WHERE inventory_id IN (
				SELECT inventory_id FROM (
                SELECT inventory_id, rental_id FROM sakila.rental
					WHERE rental_id IN (
						SELECT rental_id FROM (
						SELECT rental_id, customer_id FROM sakila.payment
							WHERE customer_id in (
								SELECT customer_id FROM (
								SELECT customer_id, sum(amount) AS amount_paid FROM sakila.payment
								GROUP BY customer_id
								ORDER BY amount_paid DESC
								LIMIT 1
								) as pay_sub
							)
						) as pay_sub
					)
				) as rental_sub
			)
		) as inv_sub
	);

-- 8. Customers who spent more than the average payments.

SELECT customer_id, concat(first_name, ' ', last_name) FROM sakila.customer
	WHERE customer_id IN (
    SELECT customer_id FROM (
    SELECT customer_id, avg(amount) AS amount_per_cust FROM payment
        GROUP BY customer_id
        HAVING amount_per_cust > (
        SELECT avg(amount) FROM payment)
	) as sub1);