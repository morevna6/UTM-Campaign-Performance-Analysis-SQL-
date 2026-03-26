# UTM Campaign Performance Analysis (SQL)

## Project Overview
This project analyzes marketing campaign performance using UTM parameters extracted from URL data.

It combines Facebook Ads and Google Ads datasets, cleans and decodes URL parameters, and calculates key marketing KPIs at the campaign level.

---

## 🗂 Datasets
- `facebook_ads_basic_daily`
- `google_ads_basic_daily`

---

## Analysis Tasks

### 1. Data Unification
Combine Facebook Ads and Google Ads into a single dataset using `UNION ALL`.

### 2. Data Cleaning
- Handle missing values using `COALESCE`
- Normalize campaign data
- Remove invalid values (e.g., 'nan')

### 3. UTM Campaign Extraction
- Extract `utm_campaign` from URL parameters
- Decode URL-encoded strings using a custom SQL function

### 4. KPI Calculation
Calculate key performance metrics:

- CTR (Click-Through Rate)
- CPC (Cost Per Click)
- CPM (Cost Per 1000 Impressions)
- ROMI (Return on Marketing Investment)

---

## SQL Highlights
- Custom `url_decode` function for parsing URL parameters  
- Use of `CTE` for structured transformations  
- String parsing with `split_part`  
- Conditional KPI calculations with `CASE`  
- Multi-source data integration  

---

## Tools Used
- PostgreSQL
- DBeaver

---

## Conclusion
This project demonstrates how raw marketing data can be transformed into meaningful insights by extracting campaign information from URLs and calculating performance metrics across multiple channels.
