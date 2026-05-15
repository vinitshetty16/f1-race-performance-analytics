# F1 Race Performance Analytics

## Project Overview
End-to-end data analytics project analysing 75 years of Formula 1 
race data (1950–2024) to uncover performance patterns across drivers, 
constructors, and championship competitiveness.

## Business Questions
1. How does starting grid position translate to race wins across eras?
2. Which constructors have the highest mechanical DNF rates?
3. Which drivers consistently overperform their grid position?
4. How has championship competitiveness changed by decade?

## Key Findings
- **79%** of all race wins come from the top 3 grid positions
- **Pole position** converts to victory 42% of the time
- **Mercedes** leads modern reliability at 90% finish rate
- **F1 reliability** improved from 42% finish rate (1980) to 89% (2024)
- **Lewis Hamilton** leads the modern era with 105 wins and 202 podiums

## Tech Stack
| Layer | Tool |
|---|---|
| Cloud Warehouse | Snowflake |
| SQL Analytics | Snowflake Worksheets |
| Visualisation | Power BI Desktop |
| Publishing | Power BI Service |
| AI Assistance | Claude API |
| Documentation | Notion |

## Data Source
Ergast Motor Racing Database via Kaggle — 14 tables, 
static snapshot covering 1950–2024.

## Dashboard
[View live Power BI dashboard →](https://app.powerbi.com/groups/me/reports/bf02f62f-591b-4ec6-8e4f-2c19e9a220a1/b98549e829095d4a8ee4?ctid=d08d19e7-7313-4d83-80f9-4708ac5d544d&experience=power-bi&bookmarkGuid=a3a6edc9-746a-422e-9f0f-e3c9701716b9)

## Presentation
[Download PDF ↓](presentation/F1_Analytics_Presentation.pdf) 

## Documentation
[View Notion Docs →](https://www.notion.so/F1-Analytics-Project-327cd3d3755e803784b9fa14aee1429a)


## Project Structure
- `/sql` — All SQL scripts for setup, table creation, and analytics views
- `/powerbi` — Power BI Desktop file (.pbix)
- `/presentation` — Final stakeholder presentation (.pptx)
- `/docs` — Data dictionary and project documentation
