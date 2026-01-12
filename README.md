# Trade Dashboards - Interactive Visualization Suite

A comprehensive R-based analytics platform analyzing US trade data and tariff impacts across multiple dimensions: products, countries, time periods, and geographic relationships.

**Live Site:** https://Aayushh.github.io/trade-visualization/

---

## 📊 Overview

This project generates 17 interactive visualizations and 3 static reference plots analyzing US imports from January 2024 to August 2025, with special attention to tariff implementation events. All visualizations are built with Plotly.js and deployed as static HTML to GitHub Pages.

### Key Features

- **17 Interactive Dashboards** - Time series, product analysis, geographic relationships, animated evolution
- **Static Publication Plots** - Premium-quality PNG/PDF figures for academic papers
- **Real-time Filtering** - Date ranges, country selection, product categories
- **Event Markers** - Visual timeline of tariff implementation announcements
- **Responsive Design** - Works on desktop and mobile browsers
- **Zero Server Requirements** - Pure client-side rendering (static HTML/JS)

---

## 📁 Project Structure

```
trade_dashboards/
├── docs/                           # GitHub Pages deployment folder
│   ├── index.html                 # Main dashboard entry point
│   ├── 01-17_*.html               # Interactive visualizations
│   ├── static/                    # Static PNG/PDF reference plots
│   └── *_files/                   # Supporting assets (JS, CSS)
│
├── data/
│   ├── raw/                       # Original data sources
│   ├── processed/                 # Cleaned parquet files
│   │   ├── monthly_by_*.parquet  # Monthly aggregations
│   │   ├── top_entities_*.parquet # Top products/countries/chapters
│   │   └── hs_lookup.parquet     # Product descriptions
│   └── tariff_events_config.csv  # Centralized tariff event dates
│
├── data_exploration/
│   ├── scripts/                   # R generation scripts
│   │   ├── 00_master_regenerate_dashboards.R
│   │   ├── 01_prepare_interactive_data.R
│   │   ├── 03_interactive_time_series.R
│   │   ├── 04_interactive_product_explorer.R
│   │   ├── 05_interactive_geo_relationships.R
│   │   ├── 06_generate_viz_index_simple.R
│   │   └── 07_animated_visualizations.R
│   └── output/
│       ├── interactive/           # Generated HTML visualizations
│       └── static/                # Generated PNG/PDF plots
│
├── REPO_REFERENCE.md              # Detailed AI reference document
├── README.md                       # This file
└── .gitignore                     # Git ignore patterns
```

---

## 🎨 Visualizations Included

### Static Reference Plots (S1-S3)
- **Monthly US Imports** - Time series with tariff event markers
- **Top 30 HS Chapters** - Trade volume by product category
- **Top 30 Countries** - Trade partners ranked by value

### Time Series Explorers (Charts 01-05)
1. **Monthly Imports Interactive** - Dropdown filter by country/chapter + event markers
2. **Tariff Rate Evolution** - 4-rate decomposition (Overall, Dutiable, Section 61, Section 69)
3. **Trade vs Tariff Scatter** - Monthly bubble chart colored by tariff rate
4. **Countries Evolution** - Multi-line chart of top 20 partners
5. **HS Chapters Stacked Area** - Market share composition over time

### Product Explorers (Charts 06-09, 14)
6. **Trade-Tariff Scatter** - Top 500 products (X: value, Y: rate, Color: chapter)
7. **Top Products Table** - Interactive DataTable with search/sort/descriptions
8. **Trade Concentration (Lorenz)** - Concentration analysis curve
9. **Tariff Distribution** - Violin plots by HS chapter
14. **HS10 Treemap** - Top 200 products by trade value

### Geographic & Relationship Explorers (Charts 10-13)
10. **Country Dashboard** - Distance vs tariff scatter with date range filter
11. **Distance Effect** - Regression analysis of geographic distance impact
12. **Countries Heatmap** - Country × HS Chapter interaction matrix
13. **Tariff Distribution by Country** - Box plots showing tariff ranges

### Animated Visualizations (Charts 15-16)
15. **Trade-Tariff Animation** - Month-by-month evolution of top 100 products
16. **Country Evolution Animation** - Month-by-month evolution of top countries

### Data Tools (Chart 17)
17. **HS Code Lookup** - Interactive product description search

---

## 🚀 Quick Start

### View Live Dashboard
Visit: [https://Aayushh.github.io/trade-visualization/](https://Aayushh.github.io/trade-visualization/)

### For Local Development

#### Prerequisites
- R 4.0+
- Git
- The following R packages:
  ```R
  tidyverse, plotly, data.table, arrow, htmlwidgets, 
  htmltools, DT, here, scales, showtext, patchwork
  ```

#### Setup
```bash
# Clone repository
git clone https://github.com/Aayushh/trade-visualization.git
cd trade_dashboards

# Install R dependencies (in R console)
packages <- c("tidyverse", "plotly", "data.table", "arrow", "htmlwidgets", 
              "htmltools", "DT", "here", "scales", "showtext", "patchwork")
install.packages(packages)

# Prepare data (one-time setup, if source data changes)
Rscript data_exploration/scripts/01_prepare_interactive_data.R

# Regenerate all visualizations
Rscript data_exploration/scripts/00_master_regenerate_dashboards.R
```

#### Viewing Locally
```bash
# Simple HTTP server (requires Python)
python -m http.server 8000 --directory docs

# Then visit: http://localhost:8000
```

---

## 📊 Data Sources

**Main Dataset:** US Import data aggregated at multiple levels:
- **Monthly by Product (HS10)** - 10-digit tariff classification
- **Monthly by Country** - 194+ trading partners
- **Monthly by Chapter** - 97 HS chapters
- **Product Hierarchy** - Full HS2→HS4→HS6→HS10 structure

**Tariff Events Configuration:** Centralized in `data/tariff_events_config.csv`
- Dates of major tariff announcements
- Categorized by: China, Mexico-Canada, Steel-Aluminum, Global, Biden
- Used consistently across all visualizations

---

## 🔄 Workflow: Regenerating Dashboards

### When to Regenerate
- New trade data added to `data/raw/`
- Tariff events updated in `tariff_events_config.csv`
- Visualization code modified
- Want fresh analysis snapshot

### Complete Regeneration
```powershell
# Windows PowerShell (or use Rscript commands above)
cd c:\Code\trade_dashboards

# Step 1: Prepare data (if raw data changed)
Rscript data_exploration/scripts/01_prepare_interactive_data.R

# Step 2: Generate all visualizations
Rscript data_exploration/scripts/00_master_regenerate_dashboards.R

# Step 3: Update /docs folder
Copy-Item -Path "data_exploration/output/interactive/*" -Destination "docs" -Recurse -Force

# Step 4: Commit and push
git add docs/
git commit -m "Update visualizations with latest data"
git push origin main
```

**GitHub Pages Deployment:** Automatically updates within ~1 minute after push

---

## 🔧 Technology Stack

### Backend (Generation)
- **R** - Data manipulation and visualization generation
- **Plotly** - Interactive chart library
- **data.table** - Fast data operations
- **Arrow/Parquet** - Efficient data storage
- **htmlwidgets** - HTML output generation

### Frontend (Viewing)
- **HTML5** - Structure
- **CSS3** - Styling (responsive design)
- **JavaScript** - Interactivity
- **Plotly.js** - Charts
- **DataTables.js** - Tables
- **jQuery** - DOM manipulation

### Deployment
- **GitHub Pages** - Static hosting
- **Git** - Version control
- `/docs` folder - Deployment source

---

## 🎨 Design Decisions

### Color Palette (Consistent Across All Charts)
- **Primary:** `#667eea` (Blue)
- **Secondary:** `#764ba2` (Purple)  
- **Accent:** `#f59e0b` (Amber)
- **Success:** `#10b981` (Green)
- **Danger:** `#ef4444` (Red)

### Typography
- **Font:** Inter (Google Fonts) + system fallbacks
- **Sizes:** Hierarchical sizing for accessibility

### Interaction Patterns
- **Hover:** Detailed tooltips with context
- **Filtering:** Dropdown select for categories, date inputs for ranges
- **Navigation:** Tab-based categorization with modal viewers

### Accessibility
- UTF-8 safe ASCII icons (GitHub Pages compatible)
- Semantic HTML structure
- Color + pattern distinction (not color-only)

---

## 📋 Important Configuration

### Tariff Events (`data/tariff_events_config.csv`)
Format:
```csv
date,category,description
2024-02-01,China,"China tariff escalation"
2024-03-15,Steel-Aluminum,"Steel and aluminum tariffs"
...
```

**Usage:** All visualization scripts automatically load and mark these dates

### Output Structure (`data_exploration/output/interactive/`)
```
interactive/
├── index.html                              # Entry point
├── 01_monthly_imports_interactive.html    # Chart 01
├── ...                                     # Charts 02-17
├── 01_monthly_imports_interactive_files/  # Dependencies
├── static/                                 # PNG/PDF static plots
│   ├── monthly_imports.png
│   ├── top_chapters.png
│   └── top_countries.png
└── data/                                   # JSON lookups
    └── hs10_lookup.json
```

---

## 🚀 Deployment to GitHub Pages

### First-Time Setup

1. **Create GitHub Repository**
   - Go to https://github.com/new
   - Name: `trade-visualizations` (or similar)
   - Make it **Public**
   - Don't initialize with README

2. **Initialize Git Locally**
   ```bash
   cd c:\Code\trade_dashboards
   git init
   git remote add origin https://github.com/YOUR_USERNAME/trade-visualizations.git
   git branch -M main
   ```

3. **Make Initial Commit**
   ```bash
   git add .
   git commit -m "Initial commit: Trade visualizations dashboard"
   git push -u origin main
   ```

4. **Enable GitHub Pages**
   - Go to repo Settings → Pages
   - Source: **main** branch, **/docs** folder
   - Wait 1-2 minutes
   - Site URL appears at top

5. **Visit Your Site**
   ```
   https://YOUR_USERNAME.github.io/trade-visualizations/
   ```

### Updating After Changes
```bash
# After regenerating visualizations
git add docs/
git commit -m "Update: [description of changes]"
git push

# GitHub Pages updates automatically within ~1 minute
```

---

## 📝 Scripts Reference

See [REPO_REFERENCE.md](REPO_REFERENCE.md) for detailed documentation on each script including:
- Purpose and functionality
- Input/output data
- Key features and code patterns
- Execution sequence
- Known issues and debugging tips

---

## 🐛 Troubleshooting

### Visualizations Not Loading
- Check browser console (F12) for errors
- Verify all `*_files/` folders were copied to `/docs`
- Ensure relative paths in HTML files are correct

### GitHub Pages Not Updating
- Verify Settings → Pages shows "main" branch and "/docs" folder
- Try waiting 2-3 minutes (GitHub needs time to rebuild)
- Check repo settings are saved

### R Script Errors
- Verify parquet files exist in `data/processed/`
- Check `tariff_events_config.csv` is formatted correctly
- Run `01_prepare_interactive_data.R` if data is missing

### Relative Path Issues
- All HTML files must use relative paths (e.g., `./data/hs10_lookup.json`)
- Never use absolute paths like `C:\...`

---

## 📚 Additional Resources

- [Plotly.js Documentation](https://plotly.com/javascript/)
- [DataTables Documentation](https://datatables.net/)
- [GitHub Pages Docs](https://pages.github.com/)
- [R Plotly Package](https://plotly.com/r/)

---

## 📄 License

[Specify your license here, e.g., MIT, Creative Commons]

---

## 👤 Contact & Contributing

**Author:** [Your Name/Organization]  
**Questions/Issues:** [GitHub Issues link or email]

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 🔄 Version History

- **v1.0.0** (Jan 2026) - Initial release with 17 interactive visualizations
- Generated: `2024-01-12`
- Data Coverage: January 2024 - August 2025
