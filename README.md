# SaaS Metrics Dashboard

A BI portfolio project analyzing subscription business performance — Monthly Recurring Revenue (MRR), customer growth, cohort retention, and customer lifetime value (LTV) — for a simulated B2B SaaS company over a 3-year period (July 2023 – June 2026).

Built to reflect the kind of financial and executive reporting (QBR/MBR-style) used by Data Analyst and BI Analyst teams: SQL-first analytical logic, a normalized relational schema, and an interactive Power BI dashboard.

## Tech Stack

- **PostgreSQL 18** — data storage, all analytical logic (views)
- **Power BI Desktop** — dashboard, DAX measures, data visualization
- **Python (pandas, Faker)** — synthetic dataset generation and data loading

## Dataset

The underlying data is fully synthetic, generated with realistic, non-random business logic:

- **~9,400 customers**, **~114,000 subscription events** (new, renewal, upgrade, downgrade, cancellation, reactivation)
- **3 pricing tiers**: Starter ($19), Growth ($59), Enterprise ($249)
- Signup volume follows seasonal patterns (January/September peaks, December dip) and a compounding monthly growth trend
- Churn hazard varies by plan tier, customer tenure (elevated in the first 1–3 months), acquisition channel, and auto-renew status
- A small share of churned customers reactivate within 6 months

Raw data lives in `data/raw/` as `customers.csv` and `subscription_events.csv`.

## Database Schema

| Table | Description |
|---|---|
| `plans` | Plan names and prices (Starter, Growth, Enterprise) |
| `customer_profile` | Customer firmographics: company, country, acquisition channel, company size segment |
| `payment_profile` | Payment method, auto-renew flag, current plan |
| `transaction` | Event-level subscription log: event type, plan, previous plan, date |

## Analytical Views

| View | Purpose |
|---|---|
| `total_mmr_by_month` | Monthly MRR broken down by movement type (new/expansion/contraction/churn/reactivation), cumulative MRR, and MoM growth % |
| `customer_growth_by_month` | New/cancelled customer counts, net growth, cumulative customer base |
| `customer_lifecycle` | Per-customer signup date, cancellation date, and tenure (subscribe_life) |
| `cohort_retention` | % of each signup cohort retained at 30/90/180 days |
| `retention_by_plan` | Retention rates segmented by initial plan tier |
| `retention_by_channel` | Retention rates segmented by acquisition channel |
| `plan_periods` | Per-customer plan history broken into time-weighted periods (used for LTV) |
| `ltv_overall` | Time-weighted average ARPU, average customer lifespan, and overall LTV |

## Dashboard

The Power BI dashboard (`dashboard/saas_metrics_dashboard.pbix`) is organized into four sections, navigable from an Overview page:

**MRR** — Current MRR, Cumulative Trend, Monthly Growth %, Monthly Composition (by movement type)

**Customers** — Monthly Composition (new vs. cancelled), Net Growth, Cumulative Trend

**Retention** — Cohort Trend (30/90/180-day retention over time), Retention by Plan, Retention by Acquisition Channel

**LTV** — Average ARPU, Average Lifespan, Overall Lifetime Value

Each page includes a short written takeaway summarizing the key finding.

## Key Findings

- MRR grew from ~$10K to ~$572K over 36 months with no periods of decline. Month-over-month growth rate declined from ~95% (a mathematical effect of a small early base) to a stable 4–8% by 2025–2026, consistent with a maturing SaaS business.
- New customer acquisition consistently outpaces cancellations, with a mild seasonal dip in signups each December.
- Retention is strong and stable: ~95%+ at 30 days, ~85–90% at 90 days, ~80–90% at 180 days for fully-observed cohorts. Enterprise-tier customers retain notably better than Starter (80% vs. 74% at 180 days). Acquisition channel has only a modest effect on retention (3–4 point spread) compared to plan tier (6-point spread).
- Estimated overall LTV is **$928.14** per customer (time-weighted ARPU of $75.83/month × average lifespan of 12.24 months).

## Known Limitations

- **Right-censoring in retention data**: the most recent signup cohorts have not yet had enough time to generate a full 30/90/180-day observation window. These data points are excluded/flagged rather than treated as real retention decline.
- **No CAC data**: the dataset does not include customer acquisition cost, so LTV is reported in isolation without an LTV:CAC ratio.
- **Synthetic data**: all figures are generated from modeled business rules, not real transactions — useful for demonstrating analytical methodology, not for real business conclusions.

## Repository Structure

```
saas-metrics-dashboard/
├── dashboard/
│   ├── screenshots/
│   │   └── saas_metrics_dashboard.pdf
│   └── saas_metrics_dashboard.pbix
├── data/
│   └── raw/
│       ├── customers.csv
│       └── subscription_events.csv
├── notebooks/
│   ├── 00_data_check.ipynb
│   └── 01_create_tables.ipynb
├── sql/
│   ├── ddl/
│   │   ├── 00_create_tables.sql
│   │   └── 01_check_tables.sql
│   └── views/
│       ├── customers/
│       │   └── customer_growth_by_month.sql
│       ├── mrr/
│       │   └── total_mmr_by_month.sql
│       ├── retention/
│       │   ├── customer_lifecycle.sql
│       │   ├── cohort_retention.sql
│       │   ├── retention_by_plan.sql
│       │   └── retention_by_channel.sql
│       └── ltv/
│           ├── plan_periods.sql
│           └── ltv_overall.sql
└── README.md
```
