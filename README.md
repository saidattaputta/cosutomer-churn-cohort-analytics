# SQL Customer Retention & Cohort Analytics

A Google BigQuery SQL case study that transforms retail transaction line items into order- and customer-level datasets, then analyzes recency, customer activity, repeat purchasing, monthly retention, and cohort engagement.

> This repository is a SQL lifecycle and cohort-analysis project. It is separate from the machine-learning churn repositories in this GitHub account.

## Business Questions

- How much revenue is associated with repeat versus one-time customers?
- Which customers have become inactive based on their last order date?
- How does customer activity change over time?
- How does retention vary by acquisition cohort?
- Which inactive customers represent larger historical revenue exposure?

## SQL Workflow

1. **Transaction cleaning** — cast customer IDs, exclude invalid IDs, and filter non-positive quantities/prices.
2. **Order-level modeling** — aggregate invoice lines into invoice/order revenue.
3. **Customer summary** — calculate first and last order dates, order counts, revenue, and active span.
4. **Activity segmentation** — calculate days since last purchase and assign Active (0–30 days), Partially Inactive (31–90 days), or Inactive (over 90 days) statuses.
5. **Repeat-purchase analysis** — compare customer counts and revenue contribution across purchase-frequency groups.
6. **Monthly retention** — compare customers active in one month with those returning in the following month.
7. **Cohort analysis** — group customers by first purchase month and measure subsequent activity.

## Technology

- Google BigQuery
- Standard SQL
- Views, CTEs, joins, date functions, aggregations, and window functions

## Repository Contents

```text
.
├── project copy.sql
├── README.md
└── results/
    └── exported query result CSV files
```

The SQL script contains view definitions and inspection queries. The `results/` directory contains exported result files from selected query executions.

## Running the SQL

1. Create or select a BigQuery project and dataset.
2. Load a compatible retail transaction table.
3. Review the source table identifier in the SQL file and replace it with your own fully qualified table name.
4. Run the SQL in logical order so that upstream views exist before downstream views are queried.
5. Inspect the exported result files or write query outputs to your own reporting layer.

## Interpretation Notes

- The 30-day and 90-day activity boundaries are project-defined segmentation rules, not universal churn definitions.
- The analysis date is derived from the latest order date in the dataset.
- Retention is descriptive and does not explain why customers return or leave.
- Results depend on correct customer identifiers, invoice definitions, and transaction cleaning.

## Known SQL Review Note

The script contains an early draft and a later validated `v2` transaction-cleaning path. The later path uses `SAFE_CAST(`Customer ID` AS INT64)` in the filter; the early draft uses a string literal in the cast/filter expression and should not be treated as the final validated query.


---

**Sai Datta Putta**

[LinkedIn](https://www.linkedin.com/in/sai-datta-putta/)
