# DataGrokr PLP - Week 5: SQL Dimensional Reporting & Advanced Analytics

## Overview
This repository contains the official Week 5 SQL Mini-Project submission for the DataGrokr Pre-Learning Program (PLP). The project demonstrates proficiency in building star schemas, executing window analytical functions, calculating Month-over-Month (MoM) growth using CTEs, and generating multi-dimensional aggregated reports.

## Database Schema & Architecture
The project utilizes a **Star Schema** data model composed of three dimension tables and one fact table:
- **`dim_customer`**: Stores customer demographical details and segments.
- **`dim_product`**: Contains product listings and category information.
- **`dim_date`**: Supports time-series analytics and calendar breakdowns.
- **`fact_sales`**: Granular transaction records referencing dimension entities.

## Key Technical Queries & Concepts Implemented
1. **Star Schema DDL & DML**: Complete database creation, table relations, foreign keys, and sample data population.
2. **Window Function Rankings**: Partitioning sales rankings across product categories using `DENSE_RANK()` and `ROW_NUMBER()`.
3. **MoM Revenue Growth Analysis**: Multi-stage CTEs using `LAG()` to calculate absolute and percentage Month-over-Month sales progression.
4. **Multi-Level Aggregations**: Hierarchical revenue rollups using `GROUP BY WITH ROLLUP` and `COALESCE` handling.
5. **Analytical Views**: Abstraction of customer performance tiers using `NTILE()` window function.

## Execution Instructions
1. Open MySQL Workbench or MySQL CLI.
2. Execute `solution.sql` sequentially.
3. The script automatically drops/re-creates `datagrokr_week5_db` and runs all reporting outputs.
