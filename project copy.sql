create or replace view
  `sql-retention-analytics.ecommerce_retention.cleaned_transactions` as
select
  Invoice as invoice_id,
  safe_cast('Customer ID' as Int64) as customer_id,
  date(InvoiceDate) as order_date,
  Quantity,
  Price,
  Quantity * Price as line_revenue,
  Country
from `sql-retention-analytics.ecommerce_retention.online_retail_transactions`
where 
  'Customer ID' is not null
  and Quantity > 0
  and Price > 0;


create or replace view
`sql-retention-analytics.ecommerce_retention.order_level` as
select
  invoice_id as order_id,
  customer_id,
  order_date,
  sum(line_revenue) as order_revenue
from `sql-retention-analytics.ecommerce_retention.cleaned_transactions`
group by
  invoice_id,
  customer_id,
  order_date;


create or replace view
`sql-retention-analytics.ecommerce_retention.customer_summary` as
select
  customer_id,
  min(order_date) as first_order_date,
  max(order_date) as last_order_date,
  count(order_id) as total_orders,
  sum(order_revenue) as total_revenue,
  date_diff(max(order_date),min(order_date),day) as active_span_days
from `sql-retention-analytics.ecommerce_retention.order_level`
group by customer_id;


CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.cleaned_transactions_v2` AS
SELECT
  Invoice AS invoice_id,
  SAFE_CAST(`Customer ID` AS INT64) AS customer_id,
  DATE(InvoiceDate) AS order_date,
  Quantity,
  Price,
  Quantity * Price AS line_revenue,
  Country
FROM `sql-retention-analytics.ecommerce_retention.online_retail_transactions`
WHERE
  SAFE_CAST(`Customer ID` AS INT64) IS NOT NULL
  AND SAFE_CAST(`Customer ID` AS INT64) > 0
  AND Quantity > 0
  AND Price > 0;


SELECT *
FROM `sql-retention-analytics.ecommerce_retention.order_level`
LIMIT 10;

SELECT COUNT(*) AS total_orders
FROM `sql-retention-analytics.ecommerce_retention.order_level`;

select *
from `sql-retention-analytics.ecommerce_retention.customer_summary`
order by total_revenue desc;

SELECT
  COUNT(*) AS customers,
  COUNTIF(customer_id IS NULL) AS null_customers
FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`;

SELECT *
FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`
ORDER BY total_revenue DESC
LIMIT 10;


CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.order_level_v2` AS
SELECT
  invoice_id AS order_id,
  customer_id,
  order_date,
  SUM(line_revenue) AS order_revenue
FROM `sql-retention-analytics.ecommerce_retention.cleaned_transactions_v2`
GROUP BY
  invoice_id,
  customer_id,
  order_date;


CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.customer_summary_v2` AS
SELECT
  customer_id,
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  COUNT(order_id) AS total_orders,
  SUM(order_revenue) AS total_revenue,
  DATE_DIFF(MAX(order_date), MIN(order_date), DAY) AS active_span_days
FROM `sql-retention-analytics.ecommerce_retention.order_level_v2`
GROUP BY customer_id;


CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.customer_summary_v2` AS
SELECT
  customer_id,
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  COUNT(order_id) AS total_orders,
  SUM(order_revenue) AS total_revenue,
  DATE_DIFF(MAX(order_date), MIN(order_date), DAY) AS active_span_days
FROM `sql-retention-analytics.ecommerce_retention.order_level_v2`
GROUP BY customer_id;


SELECT
  MAX(last_order_date) AS analysis_date
FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`;


CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.customer_activity` AS
SELECT
  customer_id,
  first_order_date,
  last_order_date,
  total_orders,
  total_revenue,
  active_span_days,

  DATE_DIFF(
    (SELECT MAX(last_order_date)
     FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`),
    last_order_date,
    DAY
  ) AS days_since_last_order,

  CASE
    WHEN DATE_DIFF(
      (SELECT MAX(last_order_date)
       FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`),
      last_order_date,
      DAY
    ) <= 30 THEN 'Active'

    WHEN DATE_DIFF(
      (SELECT MAX(last_order_date)
       FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`),
      last_order_date,
      DAY
    ) BETWEEN 31 AND 90 THEN 'Partially Inactive'

    ELSE 'Inactive'
  END AS customer_status

FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`;


SELECT
  customer_status,
  COUNT(*) AS customers,
  ROUND(SUM(total_revenue), 2) AS revenue,
  ROUND(
    100 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (),
    2
  ) AS revenue_percentage
FROM `sql-retention-analytics.ecommerce_retention.customer_activity`
GROUP BY customer_status
ORDER BY revenue_percentage DESC;


SELECT
  customer_id,
  total_orders,
  total_revenue,
  last_order_date,
  days_since_last_order
FROM `sql-retention-analytics.ecommerce_retention.customer_activity`
WHERE customer_status = 'Inactive'
ORDER BY total_revenue DESC
LIMIT 20;


SELECT
  CASE
    WHEN total_orders = 1 THEN 'One-time'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`
GROUP BY customer_type;


SELECT
  CASE
    WHEN total_orders = 1 THEN 'One-time'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers,
  ROUND(SUM(total_revenue), 2) AS revenue,
  ROUND(
    100 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (),
    2
  ) AS revenue_percentage
FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`
GROUP BY customer_type;

CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.customer_months` AS
SELECT DISTINCT
  customer_id,
  DATE_TRUNC(order_date, MONTH) AS order_month
FROM `sql-retention-analytics.ecommerce_retention.order_level_v2`;


WITH monthly_customers AS (
  SELECT
    order_month,
    customer_id
  FROM `sql-retention-analytics.ecommerce_retention.customer_months`
),

next_month_return AS (
  SELECT
    a.order_month,
    COUNT(DISTINCT a.customer_id) AS customers_in_month,
    COUNT(DISTINCT b.customer_id) AS retained_customers
  FROM monthly_customers a
  LEFT JOIN monthly_customers b
    ON a.customer_id = b.customer_id
    AND b.order_month = DATE_ADD(a.order_month, INTERVAL 1 MONTH)
  GROUP BY a.order_month
)

SELECT
  order_month,
  customers_in_month,
  retained_customers,
  ROUND(100 * retained_customers / customers_in_month, 2) AS retention_rate
FROM next_month_return
ORDER BY order_month;


CREATE OR REPLACE VIEW
`sql-retention-analytics.ecommerce_retention.cohorts` AS
SELECT
  customer_id,
  DATE_TRUNC(first_order_date, MONTH) AS cohort_month,
  DATE_TRUNC(last_order_date, MONTH) AS last_active_month
FROM `sql-retention-analytics.ecommerce_retention.customer_summary_v2`;

SELECT
  cohort_month,
  DATE_DIFF(last_active_month, cohort_month, MONTH) AS months_since_join,
  COUNT(DISTINCT customer_id) AS customers
FROM `sql-retention-analytics.ecommerce_retention.cohorts`
GROUP BY cohort_month, months_since_join
ORDER BY cohort_month, months_since_join;

