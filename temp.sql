USE sakila;
#Step 1: Create a View
#First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_rental_summary AS 
SELECT c.customer_id, first_name, last_name, email, COUNT(r.rental_id) as rental_count
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

SELECT *
FROM customer_rental_summary;

#Step 2: Create a Temporary Table
#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE temp_amount AS 
SELECT p.customer_id,first_name, last_name, SUM(amount) as total_paid
FROM customer_rental_summary crs
JOIN payment p
ON crs.customer_id = p.customer_id
GROUP BY p.customer_id;

#Step 3: Create a CTE and the Customer Summary Report
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
WITH cte_summary AS (
    SELECT temp_amount.first_name,temp_amount.customer_id, temp_amount.last_name, customer_rental_summary.email, customer_rental_summary.rental_count
    FROM temp_amount
    JOIN customer_rental_summary
    ON customer_rental_summary.customer_id = temp_amount.customer_id
)
SELECT * FROM cte_summary;
#Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH cte_summary AS (
    SELECT 
	t.customer_id,
    t.first_name,
    t.last_name,
    s.email,
    s.rental_count,
    t.total_paid
    FROM temp_amount t
    JOIN customer_rental_summary s
    ON s.customer_id = t.customer_id
)
SELECT customer_id,
 first_name,
 last_name,
 email,
 rental_count,
 total_paid,
 total_paid/rental_count AS average_payment_per_rental
FROM cte_summary;
