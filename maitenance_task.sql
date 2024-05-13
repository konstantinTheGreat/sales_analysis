CREATE OR REPLACE FUNCTION manage_partitions() RETURNS VOID AS
$$
DECLARE
    current_date DATE := NOW()::DATE;
    cutoff_date DATE := current_date - INTERVAL '12 months';
    next_month_start DATE := DATE_TRUNC('month', current_date);
    next_month_end DATE := next_month_start + INTERVAL '1 month';
BEGIN

    EXECUTE format('DROP TABLE IF EXISTS sales_data_%s', TO_CHAR(cutoff_date, 'YYYY_MM'));
	
    EXECUTE format('CREATE TABLE IF NOT EXISTS sales_data_%s PARTITION OF sales_data_partitioned 
                    FOR VALUES FROM (%L) TO (%L)', 
                    TO_CHAR(next_month_start, 'YYYY_MM'), next_month_start, next_month_end);
END;
$$
LANGUAGE plpgsql;


CREATE TABLE IF NOT EXISTS sales_data_2023_05 PARTITION OF sales_data_partitioned
    FOR VALUES FROM ('2023-05-01') TO ('2023-06-01');
	
SELECT manage_partitions();
