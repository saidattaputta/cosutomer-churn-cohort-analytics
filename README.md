# SQL Customer Retention & Cohort Analytics (BigQuery)

## Executive Summary

This project builds a production-style customer retention analytics pipeline using Google BigQuery SQL on a transactional retail dataset.

The objective was to transform raw transaction data into structured lifecycle intelligence by:

- Cleaning and validating revenue data
- Constructing order-level and customer-level models
- Segmenting customers by activity status
- Measuring repeat vs one-time revenue dependency
- Calculating month-over-month retention
- Performing cohort-based engagement decay analysis

This project mirrors real-world BI and growth analytics workflows used in e-commerce and retail organizations.

---

## Business Problem

Customer retention is a primary driver of sustainable revenue growth.

Key questions addressed:

- How dependent is revenue on repeat customers?
- What percentage of customers are inactive?
- What is the revenue exposure due to churn?
- How strong is month-over-month retention?
- How does engagement decay across cohorts?

---

## Data Modeling Architecture

The project follows a layered SQL modeling structure.

---

### 1️⃣ Cleaned Transactions Layer

**View Created:** `cleaned_transactions_v2`

Validation Rules Applied:
- Valid non-null Customer IDs
- Customer ID > 0
- Quantity > 0
- Price > 0

Purpose:
Ensure accurate revenue computation and eliminate noisy records.

---

### 2️⃣ Order-Level Aggregation

**View Created:** `order_level_v2`

- Aggregated invoice line items into order-level revenue
- Converted raw transactional granularity into meaningful purchase units

Purpose:
Enable customer-level revenue and frequency analysis.

---

### 3️⃣ Customer Summary Layer

**View Created:** `customer_summary_v2`

Metrics Engineered:
- First order date
- Last order date
- Total orders
- Total revenue
- Active span (days)

Purpose:
Shift from transactional analysis to lifecycle modeling.

---

### 4️⃣ Customer Activity Segmentation

**View Created:** `customer_activity`

Calculated:
- Days since last order (recency)
- Customer status:
  - Active (≤30 days)
  - Partially Inactive (31–90 days)
  - Inactive (>90 days)

Purpose:
Quantify churn exposure and identify high-risk revenue segments.

---

### 5️⃣ Repeat vs One-Time Analysis

Computed:
- Customer distribution
- Revenue contribution percentage
- Repeat dependency ratio

Business Insight:
Repeat customers typically drive disproportionate revenue contribution compared to one-time buyers.

---

### 6️⃣ Month-over-Month Retention

Method:
- DATE_TRUNC(order_date, MONTH)
- Self-join to next month activity
- Retention rate = retained_customers / customers_in_month

Purpose:
Measure customer stickiness and engagement continuity.

---

### 7️⃣ Cohort Analysis

**View Created:** `cohorts`

Measured:
- Cohort month (first purchase month)
- Months since join
- Customer count decay pattern

Purpose:
Visualize lifecycle engagement and long-term retention decay.

---

## Key Insights

- Revenue concentration exists within repeat customers.
- Inactive high-revenue customers represent churn exposure risk.
- Retention rate declines as months since join increases.
- Lifecycle segmentation enables targeted reactivation strategies.

---

## Technical Highlights

- Production-style SQL view layering
- Window functions and aggregations
- Self-join retention modeling
- Date functions (DATE_TRUNC, DATE_DIFF)
- Lifecycle segmentation logic
- Cohort decay computation

---

## Tools & Technologies

- Google BigQuery
- Standard SQL
- View-based data modeling
- Temporal analytics
- Aggregation & window functions

---

## Strategic Value

This project demonstrates:

- Strong SQL proficiency
- Structured data modeling
- Retention intelligence analytics
- Lifecycle segmentation
- Revenue risk assessment
- Cohort-based growth analysis

It reflects real-world BI and growth analytics implementation practices.

---

## Repository Structure

```
sql-customer-retention-analytics/
│
├── project.sql
├── README.md
└── results/
```

---

## Future Enhancements

- RFM Scoring (Recency-Frequency-Monetary)
- Churn probability modeling in Python
- Dashboard implementation (Looker Studio / Power BI)
- CLV estimation

---

## Author

Sai Datta Putta
