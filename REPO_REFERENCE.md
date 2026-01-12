# Trade Dashboards Repository - AI Reference Document

**Project Overview:** An R-based interactive dashboard system analyzing US trade data with tariff impacts. Generates 17 interactive visualizations and static reference plots from processed trade data.

**Repository Location:** `c:\Code\trade_dashboards`  
**Primary Output Directory:** `data_exploration/output/interactive/`  
**Deployment Target:** GitHub Pages via `/docs` folder

---

## 📊 Project Structure

### Data Folder (`data/`)
- `raw/` - Original trade data sources
- `processed/` - Cleaned parquet files
  - `monthly_by_hs10.parquet` - Monthly trade data by HS10 product codes
  - `monthly_by_hs6.parquet` - Monthly trade data by HS6 product codes
  - `monthly_by_country.parquet` - Monthly trade data by country
  - `monthly_by_chapter.parquet` - Monthly trade data by HS chapter
  - `top_entities_hs10.parquet` - Top 200 HS10 products
  - `top_entities_countries.parquet` - Top 100 trading countries
  - `top_entities_chapters.parquet` - Top 30 HS chapters
  - `hs_lookup.parquet` - Product descriptions and hierarchies
  - `hs10_lookup.csv/json` - HS10 product lookup tables
- `tariff_events_config.csv` - Centralized configuration of tariff implementation dates

### Scripts Folder (`data_exploration/scripts/`)

#### **00_master_regenerate_dashboards.R** (Master Orchestrator)
- **Purpose:** Entry point that runs all other scripts sequentially
- **Sequence:** Scripts 03 → 04 → 10 → 05 → 06
- **Output:** Logs execution time and generates all visualizations
- **Key Features:**
  - Times full regeneration
  - Uses `source()` with `here::here()` for path management
  - Provides progress messages with ✅ indicators

#### **01_prepare_interactive_data.R** (Data Pipeline - NOT in master script)
- **Purpose:** One-time data preparation from raw sources to processed parquets
- **Key Operations:**
  1. Parses `htsdata.json` and builds hierarchical product descriptions
  2. Generates breadcrumb descriptions (e.g., "Chapter > Section > Subsection > Product")
  3. Extracts chapter names from JSON (HS2 level, indent=0)
  4. Creates top-entity lists and lookup tables
  5. Writes all to parquet format for efficient loading
- **Key Classes:** data.table operations, arrow library for parquet I/O
- **Not Run Automatically:** Must be run separately if data sources change

#### **02_static_reference_plots.R** (Publication-Ready Static Plots)
- **Purpose:** Generate PNG + PDF static figures for paper inclusion
- **Premium Theme Features:**
  - Custom `theme_premium()` function
  - Google Font "Inter" for styling
  - Defined color palette for consistency
  - Publication-ready sizing and margins
- **Plots Generated:**
  - Monthly imports time series with event markers
  - Top 30 HS chapters by value
  - Top 30 countries by value
- **Output:** PNG/PDF files to `data_exploration/output/static/`
- **Not Currently Run:** Script exists but not called from master regenerator

#### **03_interactive_time_series.R** (Time Series Explorers - Charts 01-05)
- **Purpose:** Create 5 premium interactive plotly dashboards
- **Charts Generated:**
  1. **01_monthly_imports_interactive.html** - Monthly imports with event markers, country/chapter filter dropdown
  2. **02_tariff_evolution_interactive.html** - 4-rate decomposition (Overall, Dutiable, Section 61, Section 69)
  3. **03_trade_vs_tariff_scatter.html** - Monthly bubble chart (X: trade, Y: tariff, size: tariffs paid)
  4. **04_countries_evolution.html** - Multi-line chart of top 20 trading partners
  5. **05_chapters_stacked_area.html** - Market share composition over time by HS chapter
- **Key Features:**
  - Shared `create_description_panel()` HTML template
  - Plotly rangeslider for date selection
  - Color-coded tariff event markers (China, Mexico-Canada, Steel-Aluminum, Global, Biden)
  - Unified styling with premium colors
- **Input Data:** `monthly_by_country`, `monthly_by_chapter`, `tariff_events_config.csv`
- **Trump Events:** Loaded from centralized config for consistency

#### **04_interactive_product_explorer.R** (Product Explorers - Charts 06-09)
- **Purpose:** Deep-dive into product-level trade and tariff data
- **Charts Generated:**
  1. **06_trade_tariff_scatter.html** - Top 500 HS10 products (X: cumulative value, Y: tariff rate, color: chapter)
  2. **07_top_products_table.html** - Interactive DataTable of top products with descriptions
  3. **08_concentration_lorenz.html** - Lorenz curve showing trade concentration (top 10% of products)
  4. **09_tariff_distribution_violin.html** - Violin plot of tariff distributions by chapter
- **Key Features:**
  - Treemap explorer (14_hs10_treemap.html) - Top 200 HS10 products by value
  - Rich product descriptions from HS lookup
  - DataTable.js for interactive tables with search/sort
  - Color palette consistent with other visualizations
- **Input Data:** `monthly_by_hs10`, `hs_lookup`, `top_entities` data

#### **05_interactive_geo_relationships.R** (Geographic Explorers - Charts 11-13)
- **Purpose:** Explore country-level patterns and geographic relationships
- **Charts Generated:**
  1. **10_country_dashboard.html** - Distance vs tariff scatter (bubble size = trade value)
  2. **11_distance_effect.html** - Regression analysis of distance effect on tariffs
  3. **12_countries_heatmap.html** - Heatmap of top countries × top HS chapters
  4. **13_tariff_distribution_by_country.html** - Box plot of tariff distributions by country
- **Key Features:**
  - Bubble charts with distance metrics (sea distance)
  - Geographic visualization of trade relationships
  - Country-chapter interaction analysis
  - Tariff rate distributions
- **Input Data:** `monthly_by_country`, `hs_lookup`, tariff events

#### **06_generate_viz_index_simple.R** (Index/Dashboard Generator - Index.html)
- **Purpose:** Creates the master index page that links all visualizations
- **Output:** `index.html` - Landing page with:
  - Navigation tabs (Static, Time Series, Products, Geo/Relationships, Animations, Tools)
  - Card-based visualization grid with ASCII icons
  - Description, insights, and chart type for each viz
  - Category filtering
  - Modal viewer for iframes
  - Responsive design
- **Features:**
  - ASCII icons instead of emojis (UTF-8 safe for GitHub Pages)
  - Categorization: static, timeseries, products, geo, animated
  - Quick navigation between visualizations
  - Dark mode support (CSS ready)

#### **07_animated_visualizations.R** (Animated Charts - Charts 15-16)
- **Purpose:** Create animated visualizations showing evolution over time
- **Charts Generated:**
  1. **15_trade_tariff_animation.html** - Monthly evolution of top 100 products
  2. **16_country_evolution_animation.html** - Monthly evolution of top countries
- **Key Features:**
  - Plotly animation frames for each month
  - Play/pause controls
  - Speed adjustment
  - ISO 2-digit country codes
  - Continent color mapping
  - Chapter-based colors for products
- **Input Data:** `monthly_by_country`, `monthly_by_hs10`, top entities

#### **10_country_dashboard_filtered.R** (Date-Filtered Dashboard - Chart 10)
- **Purpose:** Create interactive country dashboard with date range filters
- **Output:** `10_country_dashboard.html` - Pure HTML/JavaScript dashboard
- **Features:**
  - Date range input controls
  - Real-time plot updates via JavaScript
  - No external R plotting (rendered client-side)
  - Bubble chart visualization
  - Country name hover info
- **Input Data:** `monthly_by_country`, tariff events config

---

## 🎨 Visualization Inventory

| # | Title | Type | Input Data | Features |
|---|-------|------|-----------|----------|
| S1-S3 | Static Reference Plots | PNG/PDF | Trade data | Publication-ready, event markers |
| 01 | Monthly Imports | Interactive Line | monthly_by_country | Filter dropdown, event markers |
| 02 | Tariff Evolution | Interactive Line | monthly_by_chapter | 4-rate decomposition |
| 03 | Trade vs Tariff Scatter | Bubble Chart | monthly_by_country | Monthly aggregation |
| 04 | Countries Evolution | Multi-Line | monthly_by_country | Top 20 partners |
| 05 | Chapters Stacked Area | Stacked Area | monthly_by_chapter | Market share over time |
| 06 | Trade-Tariff Scatter | Scatter | monthly_by_hs10 | Top 500 products |
| 07 | Top Products Table | DataTable | monthly_by_hs10 | Search, sort, descriptions |
| 08 | Concentration Lorenz | Curve | monthly_by_hs10 | Trade concentration analysis |
| 09 | Tariff Distribution | Violin Plot | monthly_by_hs10 | By chapter |
| 10 | Country Dashboard | Filtered Scatter | monthly_by_country | Date range filter |
| 11 | Distance Effect | Regression | monthly_by_country | Sea distance analysis |
| 12 | Countries Heatmap | Heatmap | monthly_by_country/chapter | Country × Chapter |
| 13 | Tariff Distribution | Box Plot | monthly_by_country | By country |
| 14 | HS10 Treemap | Treemap | monthly_by_hs10 | Top 200 products |
| 15 | Trade-Tariff Animation | Animated Scatter | monthly_by_hs10 | Monthly frames, products |
| 16 | Country Evolution | Animated Scatter | monthly_by_country | Monthly frames, countries |
| 17 | HS Code Lookup | Interactive Lookup | hs_lookup | Search product descriptions |

---

## 🛠️ Supporting Files

### JavaScript & CSS
- **shared_nav.js** - Navigation logic for index page
- **shared_styles.css** - Unified styling across pages

### PowerShell Scripts
- **fix_index.ps1** - Utility for fixing index.html issues
- **inject_modal.ps1** - Injects modal viewer code into visualizations

### Logging & Debugging
- **animation_log.txt** - Animation generation logs
- **debug_output.txt** - Debug messages from recent runs
- **regeneration_log.txt** - Master script execution logs
- **run_animation_with_log.R** - Animation runner with logging
- **debug_*.R** - Various debug scripts for data validation

---

## 🔧 Key Technologies

- **R Libraries:**
  - `tidyverse` - Data manipulation (dplyr, ggplot2, etc.)
  - `plotly` - Interactive visualizations
  - `data.table` - Fast data operations
  - `arrow` - Parquet I/O for efficiency
  - `htmltools` / `htmlwidgets` - HTML generation
  - `here` - Cross-platform path management
  - `DT` - Interactive data tables
  - `showtext` / `ggplot2` - Static plot styling

- **Frontend:**
  - Plotly.js for interactivity
  - DataTables.js for table functionality
  - Bootstrap/custom CSS for layout
  - UTF-8 safe ASCII icons for GitHub Pages

---

## 📋 Workflow for Regenerating Dashboards

1. **Ensure data is prepared** (one-time setup):
   ```R
   source("data_exploration/scripts/01_prepare_interactive_data.R")
   ```

2. **Run master regenerator** (generates all 17 visualizations):
   ```R
   source("data_exploration/scripts/00_master_regenerate_dashboards.R")
   ```

3. **All outputs appear in:**
   ```
   data_exploration/output/interactive/
   ├── index.html (main entry point)
   ├── 01_monthly_imports_interactive.html
   ├── 02_tariff_evolution_interactive.html
   ├── ... (and 14 more visualizations)
   ├── static/
   │   ├── monthly_imports.png
   │   ├── top_chapters.png
   │   └── top_countries.png
   └── *_files/ (supporting assets)
   ```

4. **Copy to deployment folder** (next step is GitHub Pages setup):
   ```powershell
   Copy-Item -Path "data_exploration/output/interactive/*" -Destination "docs" -Recurse -Force
   ```

---

## 🚀 Deployment Target: GitHub Pages

**Current Status:** NOT YET DEPLOYED
- No `/docs` folder exists in repository root
- No GitHub remote configured
- DEPLOY.md suggests `/docs` folder deployment strategy

**Requirements for Deployment:**
- Create `/docs` folder in repository root
- Copy all files from `data_exploration/output/interactive/` to `/docs/`
- Configure GitHub repo settings: Pages → Main branch → `/docs` folder
- Push to GitHub

**Key Points:**
- Must use `/docs` folder (not other GitHub Pages options)
- All HTML/CSS/JS files must be relative path compatible
- ASCII icons work better than emojis for GitHub Pages
- No server-side processing needed (all client-side)

---

## 📝 Data Flow Summary

```
Raw Data (htsdata.json, CSV files)
    ↓
[01_prepare_interactive_data.R]
    ↓
Processed Parquets
    ├── monthly_by_hs10.parquet
    ├── monthly_by_country.parquet
    ├── monthly_by_chapter.parquet
    ├── top_entities_*.parquet
    └── hs_lookup.parquet
    ↓
[00_master_regenerate_dashboards.R]
    ├→ [03_interactive_time_series.R] → Charts 01-05
    ├→ [04_interactive_product_explorer.R] → Charts 06-09, 14
    ├→ [10_country_dashboard_filtered.R] → Chart 10
    ├→ [05_interactive_geo_relationships.R] → Charts 11-13
    └→ [06_generate_viz_index_simple.R] → index.html
    ↓
HTML Outputs to data_exploration/output/interactive/
    ↓
[Copy to /docs folder]
    ↓
GitHub Pages Live Site
```

---

## ⚠️ Known Issues & Notes

1. **Script 02 (Static plots)** - Not executed by master script (manual run needed)
2. **Script 07 (Animations)** - Not in master sequence (run separately if needed)
3. **UTF-8 Encoding** - ASCII icons used instead of emojis for GitHub compatibility
4. **Relative Paths** - All links use relative paths (`.html`, `../static/`)
5. **Date Filters** - Some visualizations have date range filters in JavaScript

---

## 🔐 Important Config

**Centralized Tariff Events Configuration:**
- File: `data/tariff_events_config.csv`
- Used by ALL visualization scripts
- Contains dates and categories for tariff implementation events
- Changes here affect ALL visualizations automatically

**Color Palette (Standardized):**
- Primary: `#667eea` (Blue)
- Secondary: `#764ba2` (Purple)
- Accent: `#f59e0b` (Amber)
- Success: `#10b981` (Green)
- Danger: `#ef4444` (Red)

---

## 🔄 Next Steps for AI

When regenerating or debugging:
1. Check `tariff_events_config.csv` if dates seem wrong
2. Verify parquet files exist in `data/processed/`
3. Look for error messages in `regeneration_log.txt`
4. Check chart-specific `_files/` folders for supporting assets
5. Ensure `/docs` folder structure matches `output/interactive/`
