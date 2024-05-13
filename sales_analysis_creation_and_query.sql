CREATE TABLE sales_data_partitioned (
    sale_id SERIAL,
    product_id INTEGER,
    region_id INTEGER,
    salesperson_id INTEGER,
    sale_amount NUMERIC,
    sale_date DATE,
    PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);

CREATE TABLE sales_data_2024_01 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE sales_data_2024_02 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

CREATE TABLE sales_data_2024_03 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');

CREATE TABLE sales_data_2024_04 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');

CREATE TABLE sales_data_2024_05 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');

CREATE TABLE sales_data_2024_06 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');

CREATE TABLE sales_data_2024_07 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');

CREATE TABLE sales_data_2024_08 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');

CREATE TABLE sales_data_2024_09 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');

CREATE TABLE sales_data_2024_10 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');

CREATE TABLE sales_data_2024_11 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');

CREATE TABLE sales_data_2024_12 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
	
	
DO $$
DECLARE
    i INT := 1;
    start_date DATE := DATE '2024-01-01';
BEGIN
    WHILE i <= 1000 LOOP
        DECLARE
            product_id INT;
            region_id INT;
            salesperson_id INT;
            sale_date DATE;
        BEGIN
            product_id := (RANDOM() * 10)::INT + 1;
            region_id := (RANDOM() * 5)::INT + 1;
            salesperson_id := (RANDOM() * 10)::INT + 1;
            sale_date := start_date + (RANDOM() * 365)::INT;

            EXECUTE format('
                INSERT INTO sales_data_%s
                (product_id, region_id, salesperson_id, sale_amount, sale_date)
                VALUES
                ($1, $2, $3, $4, $5)',
                to_char(sale_date, 'YYYY_MM')
            )
            USING product_id, region_id, salesperson_id, (RANDOM() * 900 + 100)::NUMERIC, sale_date;

            i := i + 1;
        END;
    END LOOP;
END $$;
	---1
SELECT *
FROM sales_data_2024_05;
	---2
SELECT 
    to_char(sale_date, 'YYYY_MM') AS month,
    SUM(sale_amount) AS total_sales
FROM sales_data_partitioned
GROUP BY to_char(sale_date, 'YYYY_MM')
ORDER BY month;

	---3
WITH ranked_sales AS (
    SELECT 
        salesperson_id,
        SUM(sale_amount) AS total_sales,
        RANK() OVER (ORDER BY SUM(sale_amount) DESC) AS sales_rank
    FROM 
        sales_data_partitioned
    WHERE 
        region_id = 1
    GROUP BY 
        salesperson_id
)
SELECT 
    salesperson_id,
    total_sales
FROM 
    ranked_sales
WHERE 
    sales_rank <= 3;




