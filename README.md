# SQL Customer Retention & Cohort Analytics

A Google BigQuery SQL case study using retail transaction data to build order- and customer-level views, then analyze repeat purchasing, revenue concentration, customer recency, monthly next-month retention, and cohort activity.

This is a SQL customer lifecycle analysis, separate from the machine-learning churn repositories in this profile.

## Executive Findings

The committed v2 results report **5,878 identified customers** and **40,078 orders** in the saved order-level output. Repeat purchasers make up 72.39% of customers but contribute 96.80% of the saved customer revenue.

The activity segmentation classifies 2,989 customers (50.85%) as Inactive at the dataset's latest observed order date, 2011-12-09. These inactive customers contribute 19.55% of historical revenue.

Monthly next-month retention varies across the observed period. The saved rates range from 22.30% in November 2011 to 45.60% in October 2011. December 2011 has no following month in the dataset, so its 0 retained customers is an end-of-period artifact—not a measured churn rate.

## Business Questions

- What share of customers are repeat purchasers?
- How much revenue is contributed by repeat versus one-time purchasers?
- Which customers are active, partially inactive, or inactive?
- Which inactive customers have higher historical revenue?
- How does customer return behavior vary month to month?
- How does last observed activity vary by acquisition cohort?

## Dataset and SQL Model

The SQL references a Google BigQuery source table named online_retail_transactions and creates views in the sql-retention-analytics.ecommerce_retention dataset.

The analytical sequence is transaction cleaning, order-level aggregation, customer summary, customer activity segmentation, repeat-purchase analysis, monthly next-month retention, and cohort-age analysis.

**Cleaning-version caveat:** the SQL contains an early draft and a later v2 path. The early draft casts the string literal 'Customer ID' and tests that literal in the WHERE clause, resulting in a null customer identifier. The v2 path uses SAFE_CAST on the Customer ID column and filters null/non-positive IDs. The customer-level results documented below are from the v2 outputs.

## Results

### Customer base and repeat purchasing

| Measure | Saved result |
|---|---:|
| Identified customers in v2 | 5,878 |
| Null customer IDs in v2 customer summary | 0 |
| Orders in saved order-level output | 40,078 |
| Latest observed order date | 2011-12-09 |

| Customer type | Customers | Customer share | Revenue | Revenue share |
|---|---:|---:|---:|---:|
| Repeat | 4,255 | 72.39% | 17,175,255.35 | 96.80% |
| One-time | 1,623 | 27.61% | 568,173.83 | 3.20% |

**Finding:** repeat purchasers are the dominant revenue segment in the saved output. This is a descriptive association, not evidence that a particular retention intervention causes repeat purchases.

### Customer activity segmentation

The SQL defines Active as 0–30 days since last purchase, Partially Inactive as 31–90 days, and Inactive as more than 90 days. The analysis date is 2011-12-09, the latest observed last-order date.

| Status | Customers | Revenue | Revenue share |
|---|---:|---:|---:|
| Active | 1,667 | 11,316,144.79 | 63.78% |
| Partially Inactive | 1,222 | 2,958,525.81 | 16.67% |
| Inactive | 2,989 | 3,468,758.58 | 19.55% |
| **Total** | **5,878** | **17,743,429.18** | **100.00%** |

**Finding:** just over half of identified customers are classified as Inactive, but they contribute less than one-fifth of historical revenue. The inactive-customer export ranks those customers by their historical revenue, which can help prioritize investigation; it is not an estimate of recoverable revenue.

### Monthly next-month retention

The monthly query counts customers active in one calendar month who also appear in the immediately following month.

| Month | Customers in month | Retained next month | Retention |
|---|---:|---:|---:|
| 2009-12 | 955 | 337 | 35.29% |
| 2010-10 | 1,497 | 657 | 43.89% |
| 2010-11 | 1,607 | 524 | 32.61% |
| 2011-08 | 935 | 425 | 45.45% |
| 2011-10 | 1,364 | 622 | 45.60% |
| 2011-11 | 1,664 | 371 | 22.30% |
| 2011-12 | 615 | 0 | 0.00% |

**Interpretation:** among months with an observed following month, the saved rate ranges from 22.30% to 45.60%. December 2011 is the final month in the dataset and has no next-month observation; do not interpret its 0.00% as a churn rate.

### Cohort timing

The saved cohort output groups customers by first-order month and the month distance between first and last observed order. For example, the December 2009 cohort begins with 89 customers at month 0 and has saved counts at later offsets, including 259 at month 23 and 188 at month 24.

This output is a distribution of last-observed-activity timing by cohort age. It is not a full cohort-retention matrix tracking whether every customer was active in every intervening month.

## Saved Result Files

The results directory contains CSV exports for customer counts, order counts, customer summaries, repeat-purchase mix, revenue contribution, customer activity status, inactive-customer ranking, monthly retention, and cohort timing.

The filenames are BigQuery job-export names; the original files have been preserved.

## Technology

Google BigQuery, Standard SQL, views, CTEs, joins, SAFE_CAST, date functions, aggregations, and window functions.

## Running the SQL

1. Create or select a BigQuery project and dataset.
2. Load a compatible Online Retail transaction table.
3. Update the fully qualified source-table name in the SQL file.
4. Run the v2 cleaned-transactions view before its dependent order-level and customer-summary views.
5. Run customer activity, repeat-purchase, monthly-retention, and cohort queries after upstream views exist.
6. Export query results to CSV to recreate the saved output format.

## Repository Structure

\`\`\`text
.
├── project copy.sql
├── results/                 # Saved BigQuery query-result CSV files
├── .gitignore
└── README.md
\`\`\`

## Limitations and Data Quality Notes

- Use the v2 Customer ID cleaning path; the earlier draft produces a null customer identifier.
- The 30-day and 90-day activity thresholds are project-defined rules, not universal churn definitions.
- Activity labels are historical relative to 2011-12-09.
- December 2011 has no following month for retention measurement.
- The saved cohort output measures first-to-last order timing, not a standard monthly retention matrix.
- Currency is not identified in the saved CSVs, so amounts are shown without a currency symbol.
- These SQL summaries are descriptive and do not establish causal drivers of retention.

## Recommendations from the Saved Analysis

1. Protect the repeat-purchase segment, which contributes 96.80% of saved revenue.
2. Prioritize investigation of higher-value inactive customers.
3. Investigate the November 2011 next-month retention decline.
4. Exclude the final month from month-to-next-month retention interpretation.
5. Keep the v2 customer-ID cleaning path as the basis for customer-level results.

---

**Sai Datta Putta**

[LinkedIn](https://www.linkedin.com/in/sai-datta-putta/)
