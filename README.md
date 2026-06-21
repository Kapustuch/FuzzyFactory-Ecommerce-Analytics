# 🧸 Maven Fuzzy Factory: E-Commerce Product Analytics: Conversion Funnel, A/B Testing & Unit Economics

## Table of Contents

- [Project Overview](#project-overview)
- [Tableau Dashboard](#tableau-dashboard)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Final Results & Business Recommendations](#final-results--business-recommendations)

## Project Overview

This portfolio project focuses on extracting actionable product insights from the "Maven Fuzzy Factory" database using advanced SQL and Python. The core objectives are:

1. **Product Funnel Analysis:** Build a multi-step conversion funnel (from `/home` to `/billing`) to identify user drop-off points and optimize UX.
2. **A/B/n Testing:** Conduct statistical testing to compare experimental landing pages against the default homepage, identifying the optimal user entry point to maximize the final order conversion rate.
3. **Marketing Analytics & Traffic Optimization:** Analyze UTM parameters to evaluate campaign profitability (Revenue per Session), identify device-level purchasing behaviors for bid adjustments, and compare brand vs. non-brand traffic dynamics.
4. **Core Business Metrics:** Calculate and visualize key performance indicators, including Retention, AOV, ARPU (Average Revenue Per User), LTV, Refund Rate.

## Tableau Dashboard

To make the insights accessible to non-technical stakeholders, a dynamic Dashboard was built.  

[Link to Interactive Tableau Dashboard](https://public.tableau.com/app/profile/yurii.kapusta/viz/FuzzyFactory_17820809897120/Dashboard)

<img width="1198" height="894" alt="image" src="https://github.com/user-attachments/assets/569cab7e-a672-4389-9317-7848f1a59b94" />

## Data Sources

The dataset consists of a relational database containing 6 primary tables detailing the end-to-end user journey: 

`website_sessions:` Traffic acquisition data (UTM source, campaign, device type).  
`website_pageviews:` Granular tracking of user navigation across the website.  
`orders:` Transactional data (revenue, margins, volumes).  
`order_items` & `order_item_refunds:` Item-level details and return rates.  
`products:` Product catalog and launch dates.  

You can access the dataset and its files here: 
[Toy Store E-commerce Database](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database)

## Tools 

- **SQL (MySQL):** Data extraction, CTEs, Window Functions, JOINs, data aggregation.
- **Python:** Data transformation and advanced EDA.
- **Libraries:** Pandas, NumPy, Matplotlib, Seaborn, Plotly, Scipy, Statsmodels
- **Tableau:** Interactive Executive Dashboarding (Parameters, Calculated Fields, Dual-Axis charts, Funnel visualization).

## Exploratory Data Analysis

Initial Exploratory Data Analysis (EDA) was conducted to understand the macro-trends of the business and formulate targeted hypotheses. Key questions explored during this phase included:

* **Baseline Performance:** What is the overall baseline Conversion Rate (CVR) across the entire conversion funnel?
* **Landing Page Efficiency:** How do the experimental landing pages (`/lander-1` through `/lander-5`) perform against the default `/home` page in terms of conversion?
* **Traffic Acquisition:** Which traffic sources (`gsearch`, `bsearch`, `socialbook`) and campaign types (Brand vs. Non-brand) drive the highest volume and RPS?
* **Device Dynamics:** How does user purchasing behavior and friction differ across device types (Desktop vs. Mobile)?
* **Monetization Trends:** How has the Average Order Value (AOV) trended over time, specifically following the launch of new cross-sell products?
* **Unit Economics:** What are the foundational unit metrics (Revenue Per Session, Net ARPU, and Refund Rates) that define the company's profitability?

## Data Analysis

### Example: Funnel Steps  

A key component of the project was identifying bottlenecks within the purchasing flow. By pivoting raw session data via advanced SQL and transforming it with Pandas, a comprehensive funnel model was generated to highlight where potential revenue was leaking before the final checkout step.

```python
funnel_summary_sql = '''
    WITH cte AS (
        SELECT 
            website_session_id,
            MAX(CASE WHEN pageview_url IN (
                '/home', 
                '/lander-1', 
                '/lander-2', 
                '/lander-3', 
                '/lander-4', 
                '/lander-5'
            ) THEN 1 ELSE 0 END) as entry_page,
            MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) as products_page,
            MAX(CASE WHEN pageview_url IN (
                '/the-original-mr-fuzzy', 
                '/the-forever-love-bear', 
                '/the-birthday-sugar-panda', 
                '/the-hudson-river-mini-bear' 
            ) THEN 1 ELSE 0 END) as product_detail_page,
            MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) as cart_page,
            MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) as shipping_page,
            MAX(CASE WHEN pageview_url IN (
                '/billing',
                '/billing-2'
            ) THEN 1 ELSE 0 END) as billing_page,
            MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) as order_completed_page
        FROM website_pageviews
        GROUP BY website_session_id
    )

    SELECT 
        SUM(entry_page) AS total_entries,
        SUM(products_page) AS total_catalog,
        SUM(product_detail_page) AS total_pdp,
        SUM(cart_page) AS total_cart,
        SUM(shipping_page) AS total_shipping,
        SUM(billing_page) AS total_billing,
        SUM(order_completed_page) AS total_completed
    FROM cte
'''

funnel_summary_df = pd.read_sql(funnel_summary_sql, con=engine)

funnel_melted = funnel_summary_df.melt(
    var_name='funnel_step', 
    value_name='users_count'
)

funnel_melted.to_sql('funnel_steps_long', con=engine, if_exists='replace', index=False)
funnel_melted

```
| funnel_step | users_count |
| :--- | :--- |
| `total_entries` | 472,871 |
| `total_catalog` | 261,231 |
| `total_pdp` | 210,214 |
| `total_cart` | 94,953 |
| `total_shipping` | 64,484 |
| `total_billing` | 52,058 |
| `total_completed` | 32,313 |

### Executive Insights & Funnel Optimization Strategy

Based on the interactive funnel metrics (Overall Conversion Rate: **6.83%**), we have identified three critical bottlenecks where the business is losing potential revenue:

**1. Top-of-Funnel Friction (Entry ➔ Catalog)**
* **Data:** Only **55.24%** of users proceed from their entry page to the catalog. Nearly 45% of our acquired traffic bounces immediately.
* **Hypothesis:** This high bounce rate suggests a potential mismatch between ad messaging and landing page content, slow page load times, or weak Call-to-Action (CTA) placement on the `/home` and `/lander` pages.
* **Recommendation:** Conduct A/B testing on landing page headlines and images to better align with marketing campaigns.

**2. Billing Conversion Gap (Billing ➔ Order Completed)**
* **Data:** **11.01%** of users reach the billing stage, but only **6.83%** successfully complete the order. This represents a massive ~38% relative drop-off at the very last step where users already have their credit cards out.
* **Hypothesis:** This is a critical revenue leak likely caused by technical payment gateway errors, a lack of trusted payment options (e.g., Apple Pay, PayPal), or unexpected fees appearing at the final step.
* **Recommendation:** Immediate technical audit of the `/billing` page.
---

## Final Results & Business Recommendations  

To ensure sustainable, long-term profitability, the executive team should focus on the following pillars:

### 1. Resolve Critical UX Friction & Roll Out Winning Variants
* **Action (Mobile UX Overhaul):** Conduct an immediate design and technical audit of the mobile web experience. With mobile users dropping off at a staggering rate before even reaching the Product Details Page (32.23% success vs. 49.91% on desktop), the mobile flow is actively leaking top-of-funnel acquisition budget.
* **Action (Billing Audit):** Address the 38% cart abandonment rate at the `/billing` payment stage. Investigate adding trusted express payment options (e.g., Apple Pay/PayPal) and ensuring shipping costs are transparent earlier in the funnel to prevent sticker shock.
* **Action (Top-of-Funnel CRO):** Immediately deprecate all experimental landing pages and the baseline `/home` page for paid traffic. **Roll out `/lander-5` to 100% of incoming ad traffic.** This is projected to increase the overall baseline conversion rate by ~3 percentage points.

### 2. Aggressive Bidding Strategy & Strict CAC Ceilings
* **Action (Protect & Scale Brand Traffic):** Allocate specific, protected budgets for `brand` search campaigns across both major engines. Since Bing Brand traffic generates our highest overall yield ($5.21 RPS), we should target a 100% impression share for these keywords to capture all high-intent, high-value traffic.
* **Action (Device-Level Bid Adjustments):** Apply a positive bid adjustment for Desktop traffic to maximize volume in our highest-converting segment. Conversely, significantly reduce bids for Mobile traffic to prevent budget waste until the mobile UX bottleneck is resolved.
* **Action (Acquisition Caps):** With a known Net ARPU of ~$58.47 and no recurring revenue, the marketing team must operate under a strict, unyielding ceiling. Fully-loaded Customer Acquisition Cost (CAC) must remain significantly below $58.47 (ideally under $19.50) to maintain a healthy 3:1 LTV:CAC ratio.

### 3. Product & CRM (Unlocking Retention)
The biggest untapped growth lever for Maven Fuzzy Factory is existing customers. Relying entirely on top-of-funnel acquisition is expensive and risky.
* **Action:** Launch lifecycle email marketing campaigns and introduce loyalty incentives or cross-sell discounts. Converting even 5% of one-time buyers into repeat customers would exponentially increase overall LTV.

### 4. Operations & QA (Protecting Margins)

Every refunded order is not just lost revenue, but a sunk marketing cost and negative brand equity.
* **Action:** Implement stricter Quality Assurance (QA) checkpoints with suppliers. The Q3 2014 crisis showed that operations can break under pressure—supply chain capabilities must scale synchronously with marketing volume. 

