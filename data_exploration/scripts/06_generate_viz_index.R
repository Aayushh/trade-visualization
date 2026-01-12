# Enhanced Visualization Index Generator
# Purpose: Create a modern, premium index.html with glassmorphism design,
#          rich descriptions, dark mode, and category filtering

options(stringsAsFactors = FALSE)
message("════════════════════════════════════════════════════════════════")
message("  ENHANCED VISUALIZATION INDEX GENERATOR")
message("════════════════════════════════════════════════════════════════\n")

out_dir <- here::here("data_exploration", "output", "interactive")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

generated_date <- format(Sys.Date(), "%B %d, %Y")

# ============================================================================
# VISUALIZATION METADATA - Rich descriptions for each chart
# ============================================================================

viz_cards <- list(
    # Static Reference Plots
    list(
        id = "static-1",
        category = "static",
        num = "S1",
        icon = "📅",
        title = "Monthly US Imports",
        subtitle = "Time Series with Event Markers",
        description = "Publication-ready time series showing total US imports from January 2024 to August 2025. Vertical dashed lines mark major Trump-era tariff implementation dates. Color-coded by tariff event category (China, Mexico-Canada, Steel-Aluminum, Global).",
        insights = "Import values show seasonal patterns with notable disruptions following major tariff announcements.",
        chart_type = "Time Series",
        link = "../static/monthly_imports.png",
        link_type = "image"
    ),
    list(
        id = "static-2",
        category = "static",
        num = "S2",
        icon = "📊",
        title = "Top 30 HS Chapters",
        subtitle = "Trade Volume by Category",
        description = "Horizontal bar chart ranking the top 30 HS chapters (2-digit product categories) by total import value. Bar colors indicate average tariff rate using a plasma color scale.",
        insights = "Electronics (Chapter 85) and machinery (Chapter 84) dominate US imports by value.",
        chart_type = "Bar Chart",
        link = "../static/top_chapters.png",
        link_type = "image"
    ),
    list(
        id = "static-3",
        category = "static",
        num = "S3",
        icon = "🌍",
        title = "Top 30 Countries",
        subtitle = "Trade Partners by Value",
        description = "Horizontal bar chart of the 30 largest US import partners by total trade value. Color indicates average tariff rate applied to imports from each country.",
        insights = "China remains the largest source of US imports despite elevated tariff rates.",
        chart_type = "Bar Chart",
        link = "../static/top_countries.png",
        link_type = "image"
    ),

    # Interactive Time Series
    list(
        id = "ts-1",
        category = "timeseries",
        num = "01",
        icon = "📈",
        title = "Monthly Imports Interactive",
        subtitle = "With Event Markers & Filtering",
        description = "Interactive exploration of monthly US imports with dropdown to filter by country or HS chapter. Trump tariff events shown as vertical dashed lines. Features range slider for time period selection, hover details, and zoom capabilities.",
        insights = "Toggle between aggregate view and individual country/chapter trends to identify patterns.",
        chart_type = "Interactive Line Chart",
        link = "01_monthly_imports_interactive.html",
        link_type = "html"
    ),
    list(
        id = "ts-2",
        category = "timeseries",
        num = "02",
        icon = "📉",
        title = "Tariff Rate Evolution",
        subtitle = "4-Rate Decomposition",
        description = "Four tariff rate metrics tracked over time: Overall rate (rate_total), Dutiable rate, Section 61 (China-specific), and Section 69 (Steel & Aluminum). See how different tariff components evolved during the Trump administration.",
        insights = "Section 61 and 69 rates show step increases aligned with tariff implementation dates.",
        chart_type = "Multi-Line Chart",
        link = "02_tariff_evolution_interactive.html",
        link_type = "html"
    ),
    list(
        id = "ts-3",
        category = "timeseries",
        num = "03",
        icon = "🎯",
        title = "Trade vs Tariff Scatter",
        subtitle = "Bubble Size = Tariffs Paid",
        description = "Monthly scatter plot showing average tariff rate (Y-axis) over time (X-axis). Bubble size represents total tariffs paid that month. Color encodes tariff rate for quick visual identification of high-tariff periods.",
        insights = "Larger bubbles indicate months with higher tariff revenue collection.",
        chart_type = "Bubble Chart",
        link = "03_trade_vs_tariff_scatter.html",
        link_type = "html"
    ),
    list(
        id = "ts-4",
        category = "timeseries",
        num = "04",
        icon = "🌐",
        title = "Countries Evolution",
        subtitle = "Top 20 Partners Over Time",
        description = "Multi-line chart tracking monthly import values from the top 20 trading partners. Each country has a distinct color. Trump tariff events shown as vertical markers. Hover to see exact values.",
        insights = "Compare how different countries' import volumes responded to tariff changes.",
        chart_type = "Multi-Line Chart",
        link = "04_countries_evolution.html",
        link_type = "html"
    ),
    list(
        id = "ts-5",
        category = "timeseries",
        num = "05",
        icon = "📦",
        title = "HS Chapters Stacked Area",
        subtitle = "100% Market Share Over Time",
        description = "100% stacked area chart showing how the top 15 HS chapters contribute to total imports each month. Click legend items to isolate specific chapters. Hover for exact share percentages and absolute values.",
        insights = "Market share shifts reveal which sectors gained or lost ground during the tariff period.",
        chart_type = "Stacked Area",
        link = "05_chapters_stacked_area.html",
        link_type = "html"
    ),

    # Product Deep-Dive
    list(
        id = "prod-1",
        category = "products",
        num = "06",
        icon = "🔍",
        title = "Trade-Tariff Scatter",
        subtitle = "500 Products by Volume & Rate",
        description = "Interactive bubble chart of top 500 HS10 products. X-axis: total trade value (log scale). Y-axis: average tariff rate. Bubble size indicates trade volume. Click any bubble to see full product description. Color by HS chapter.",
        insights = "Upper-right quadrant (high trade + high tariff) products contribute most to tariff revenue.",
        chart_type = "Interactive Scatter",
        link = "06_trade_tariff_scatter.html",
        link_type = "html"
    ),
    list(
        id = "prod-2",
        category = "products",
        num = "07",
        icon = "📋",
        title = "Top 500 Products Table",
        subtitle = "Searchable & Sortable",
        description = "Comprehensive table of the 500 largest imported products by value. Columns: HTS code, product description, chapter, trade value, average tariff, and number of source countries. Search by keyword, sort by any column.",
        insights = "Use the search box to find specific products. Full descriptions are searchable even when truncated.",
        chart_type = "Data Table",
        link = "07_top_products_table.html",
        link_type = "html"
    ),
    list(
        id = "prod-3",
        category = "products",
        num = "08",
        icon = "📐",
        title = "Trade Concentration Lorenz",
        subtitle = "Gini Coefficient Analysis",
        description = "Lorenz curve showing how trade is concentrated across products. The curve shows cumulative trade value (Y) for cumulative share of products (X). Dashed line represents perfect equality. Larger gap = higher concentration.",
        insights = "A small percentage of products account for the majority of US import value.",
        chart_type = "Lorenz Curve",
        link = "08_concentration_lorenz.html",
        link_type = "html"
    ),
    list(
        id = "prod-4",
        category = "products",
        num = "09",
        icon = "🎻",
        title = "Tariff Distribution Violin",
        subtitle = "By HS Chapter",
        description = "Violin plots showing the distribution of tariff rates across products within each of the top 15 HS chapters. Width indicates density of products at each tariff level. Box shows interquartile range; line shows median.",
        insights = "Wide violins indicate high tariff variability within a chapter; narrow violins indicate uniform treatment.",
        chart_type = "Violin Plot",
        link = "09_tariff_distribution_violin.html",
        link_type = "html"
    ),
    list(
        id = "prod-5",
        category = "products",
        num = "14",
        icon = "🌳",
        title = "HS10 Product Treemap",
        subtitle = "200 Products Hierarchical View",
        description = "Interactive treemap of top 200 products organized by HS chapter. Tile size represents trade value. Color indicates average tariff rate (Viridis scale). Click any product tile to see full description popup.",
        insights = "Quickly identify which chapters and products dominate US imports by visual size.",
        chart_type = "Treemap",
        link = "14_hs10_treemap.html",
        link_type = "html"
    ),

    # Geographic & Relationships
    list(
        id = "geo-1",
        category = "geographic",
        num = "10",
        icon = "🗺️",
        title = "Country Dashboard",
        subtitle = "Distance vs Tariff vs Trade",
        description = "Scatter plot of 100 countries. X-axis: average sea distance to US. Y-axis: average tariff rate. Bubble size: total trade value. Color: tariff rate. Hover for country details.",
        insights = "Explore whether distance correlates with tariff treatment or trade volume.",
        chart_type = "Bubble Chart",
        link = "10_country_dashboard.html",
        link_type = "html"
    ),
    list(
        id = "geo-2",
        category = "geographic",
        num = "11",
        icon = "📏",
        title = "Distance Effect Analysis",
        subtitle = "Near vs Far Countries",
        description = "Dual-axis comparison of 'near' (below mean distance) vs 'far' (above mean distance) trading partners. Track trade value and tariff rates over time for each segment. See if proximity affects tariff treatment.",
        insights = "Compare whether closer trading partners receive different tariff treatment.",
        chart_type = "Dual-Axis Line",
        link = "11_distance_effect.html",
        link_type = "html"
    ),
    list(
        id = "geo-3",
        category = "geographic",
        num = "12",
        icon = "🔥",
        title = "Countries Trade Heatmap",
        subtitle = "Monthly Import Patterns",
        description = "Heatmap showing monthly trade values for top 20 countries. Rows: countries (ordered by total trade). Columns: months. Color intensity: trade value. Identify seasonal patterns and disruption events.",
        insights = "Visual patterns reveal whether trade disruptions affected multiple countries simultaneously.",
        chart_type = "Heatmap",
        link = "12_countries_heatmap.html",
        link_type = "html"
    ),
    list(
        id = "geo-4",
        category = "geographic",
        num = "13",
        icon = "📊",
        title = "Tariff by Country Origin",
        subtitle = "Distribution Histogram",
        description = "Overlapping histograms showing the distribution of monthly tariff rates for top 15 countries. Compare how tariff rates vary across different trading partners over time.",
        insights = "Some countries have consistent tariff rates while others show high variability.",
        chart_type = "Histogram",
        link = "13_tariff_distribution_by_country.html",
        link_type = "html"
    ),

    # Animations
    list(
        id = "anim-1",
        category = "animations",
        num = "15",
        icon = "🎬",
        title = "Trade-Tariff Animation",
        subtitle = "Top 100 Products Evolution",
        description = "Animated scatter plot showing how the top 100 products evolve over time. Each frame represents cumulative trade data up to that month. Bubbles grow as trade accumulates. Color indicates HS chapter. Use Play button or drag slider.",
        insights = "Watch products accumulate trade volume over time and see how tariff rates affect high-value items.",
        chart_type = "Animated Scatter",
        link = "15_trade_tariff_animation.html",
        link_type = "html"
    ),
    list(
        id = "anim-2",
        category = "animations",
        num = "16",
        icon = "🌍",
        title = "Country Evolution Animation",
        subtitle = "Top 50 Partners Over Time",
        description = "Animated bubble chart tracking the top 50 trading partners from January 2024 to present. X-axis: sea distance. Y-axis: average tariff rate. Bubble size grows with cumulative trade. Regional color coding: Asia-Pacific (red), Europe (purple), North America (green).",
        insights = "Observe how tariff rates spike for specific countries (especially China) following tariff announcements.",
        chart_type = "Animated Scatter",
        link = "16_country_evolution_animation.html",
        link_type = "html"
    ),

    # Tools
    list(
        id = "tool-1",
        category = "tools",
        num = "17",
        icon = "T",
        title = "HS Code Lookup",
        subtitle = "Interactive Code Search",
        description = "Search and explore HS 10-digit product codes with full descriptions, chapter names, and section information. Find codes by keyword or browse the hierarchical structure.",
        insights = "Use this tool to understand product classifications and find specific HS codes for analysis.",
        chart_type = "Interactive Tool",
        link = "17_hs_code_lookup.html",
        link_type = "html"
    )
)

# ============================================================================
# GENERATE HTML WITH MODERN DESIGN
# ============================================================================

html_content <- paste0('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>US Trade Data Visualization Suite</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            /* Light mode colors */
            --bg-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --bg-secondary: rgba(255, 255, 255, 0.95);
            --bg-card: rgba(255, 255, 255, 0.85);
            --bg-glass: rgba(255, 255, 255, 0.25);
            --text-primary: #1a1a2e;
            --text-secondary: #4a4a6a;
            --text-muted: #6b7280;
            --accent-primary: #667eea;
            --accent-secondary: #764ba2;
            --border-color: rgba(255, 255, 255, 0.3);
            --shadow: 0 8px 32px rgba(31, 38, 135, 0.15);
            --shadow-hover: 0 12px 40px rgba(31, 38, 135, 0.25);

            /* Category colors */
            --cat-static: #10b981;
            --cat-timeseries: #3b82f6;
            --cat-products: #f59e0b;
            --cat-geographic: #ef4444;
            --cat-animations: #8b5cf6;
            --cat-tools: #06b6d4;
        }

        [data-theme="dark"] {
            --bg-primary: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            --bg-secondary: rgba(30, 30, 50, 0.95);
            --bg-card: rgba(40, 40, 70, 0.85);
            --bg-glass: rgba(255, 255, 255, 0.08);
            --text-primary: #f0f0f5;
            --text-secondary: #b0b0c5;
            --text-muted: #8080a0;
            --border-color: rgba(255, 255, 255, 0.1);
            --shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            --shadow-hover: 0 12px 40px rgba(0, 0, 0, 0.4);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: var(--bg-primary);
            min-height: 100vh;
            color: var(--text-primary);
            line-height: 1.6;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        /* Header */
        header {
            background: var(--bg-secondary);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border-color);
        }

        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .subtitle {
            font-size: 1.1rem;
            color: var(--text-secondary);
            margin-top: 0.5rem;
        }

        /* Dark mode toggle */
        .theme-toggle {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: var(--bg-glass);
            border: 1px solid var(--border-color);
            border-radius: 50px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .theme-toggle:hover {
            background: var(--accent-primary);
            color: white;
        }

        .theme-toggle-icon {
            font-size: 1.2rem;
        }

        /* Research context box */
        .context-box {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            border-left: 4px solid #f59e0b;
            border-radius: 12px;
            padding: 1.5rem;
            margin-top: 1.5rem;
        }

        [data-theme="dark"] .context-box {
            background: linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(217, 119, 6, 0.15) 100%);
        }

        .context-box h3 {
            color: #b45309;
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        [data-theme="dark"] .context-box h3 {
            color: #fbbf24;
        }

        .context-box p {
            color: #92400e;
            font-size: 0.95rem;
        }

        [data-theme="dark"] .context-box p {
            color: #fcd34d;
        }

        /* Category Tabs */
        .tabs-container {
            display: flex;
            gap: 0.75rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }

        .tab-btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 50px;
            font-family: inherit;
            font-size: 0.9rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            background: var(--bg-card);
            color: var(--text-secondary);
            box-shadow: var(--shadow);
        }

        .tab-btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
        }

        .tab-btn.active {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: white;
        }

        .tab-btn[data-category="static"].active { background: var(--cat-static); }
        .tab-btn[data-category="timeseries"].active { background: var(--cat-timeseries); }
        .tab-btn[data-category="products"].active { background: var(--cat-products); }
        .tab-btn[data-category="geographic"].active { background: var(--cat-geographic); }
        .tab-btn[data-category="animations"].active { background: var(--cat-animations); }

        /* Search */
        .search-container {
            margin-bottom: 2rem;
        }

        .search-input {
            width: 100%;
            max-width: 400px;
            padding: 1rem 1.5rem;
            border: 2px solid var(--border-color);
            border-radius: 50px;
            font-family: inherit;
            font-size: 1rem;
            background: var(--bg-card);
            color: var(--text-primary);
            box-shadow: var(--shadow);
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--accent-primary);
            box-shadow: var(--shadow-hover), 0 0 0 4px rgba(102, 126, 234, 0.1);
        }

        .search-input::placeholder {
            color: var(--text-muted);
        }

        /* Cards Grid */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 1.5rem;
        }

        .card {
            background: var(--bg-card);
            backdrop-filter: blur(20px);
            border-radius: 16px;
            border: 1px solid var(--border-color);
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            opacity: 1;
            transform: translateY(0);
        }

        .card:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-hover);
        }

        .card.hidden {
            display: none;
        }

        .card-header {
            padding: 0.75rem 1rem;
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: white;
        }

        .card[data-category="static"] .card-header { background: var(--cat-static); }
        .card[data-category="timeseries"] .card-header { background: var(--cat-timeseries); }
        .card[data-category="products"] .card-header { background: var(--cat-products); }
        .card[data-category="geographic"] .card-header { background: var(--cat-geographic); }
        .card[data-category="animations"] .card-header { background: var(--cat-animations); }

        .card-thumbnail {
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            background: var(--bg-glass);
        }

        .card-content {
            padding: 1.25rem;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        .card-title {
            font-size: 1.15rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }

        .card-subtitle {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-bottom: 0.75rem;
        }

        .card-description {
            font-size: 0.9rem;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: 0.75rem;
            flex-grow: 1;
        }

        .card-insight {
            font-size: 0.85rem;
            color: var(--accent-primary);
            font-style: italic;
            padding: 0.75rem;
            background: var(--bg-glass);
            border-radius: 8px;
            margin-bottom: 1rem;
        }

        [data-theme="dark"] .card-insight {
            color: #a5b4fc;
        }

        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            margin-top: auto;
        }

        .card-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: var(--bg-glass);
            border-radius: 20px;
            font-size: 0.75rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        .card-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.6rem 1.25rem;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .card-link:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        /* Footer */
        footer {
            background: var(--bg-secondary);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2rem;
            margin-top: 3rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border-color);
        }

        .footer-content {
            text-align: center;
        }

        .footer-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .footer-subtitle {
            color: var(--text-secondary);
            margin-bottom: 1.5rem;
        }

        .footer-meta {
            display: flex;
            justify-content: center;
            gap: 2rem;
            flex-wrap: wrap;
            font-size: 0.85rem;
            color: var(--text-muted);
        }

        .footer-meta span {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        /* Legend Section */
        .legend-section {
            background: var(--bg-secondary);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2rem;
            margin-top: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border-color);
        }

        .legend-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .legend-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }

        .legend-item {
            padding: 1rem;
            background: var(--bg-glass);
            border-left: 4px solid var(--accent-primary);
            border-radius: 8px;
        }

        .legend-item strong {
            display: block;
            color: var(--text-primary);
            font-size: 0.9rem;
            margin-bottom: 0.25rem;
        }

        .legend-item span {
            color: var(--text-secondary);
            font-size: 0.85rem;
        }

        /* Data Coverage */
        .data-coverage {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid var(--border-color);
        }

        .data-coverage h4 {
            color: var(--text-primary);
            margin-bottom: 1rem;
        }

        .coverage-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .stat-item {
            padding: 1rem;
            background: var(--bg-glass);
            border-radius: 12px;
            text-align: center;
        }

        .stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--accent-primary);
        }

        .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-top: 0.25rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }

            h1 {
                font-size: 1.75rem;
            }

            .cards-grid {
                grid-template-columns: 1fr;
            }

            .tabs-container {
                justify-content: center;
            }

            .footer-meta {
                flex-direction: column;
                gap: 0.75rem;
            }
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .card {
            animation: fadeInUp 0.5s ease-out backwards;
        }

        .card:nth-child(1) { animation-delay: 0.05s; }
        .card:nth-child(2) { animation-delay: 0.1s; }
        .card:nth-child(3) { animation-delay: 0.15s; }
        .card:nth-child(4) { animation-delay: 0.2s; }
        .card:nth-child(5) { animation-delay: 0.25s; }
        .card:nth-child(6) { animation-delay: 0.3s; }
        .card:nth-child(7) { animation-delay: 0.35s; }
        .card:nth-child(8) { animation-delay: 0.4s; }
        .card:nth-child(9) { animation-delay: 0.45s; }
        .card:nth-child(10) { animation-delay: 0.5s; }
        .card:nth-child(11) { animation-delay: 0.55s; }
        .card:nth-child(12) { animation-delay: 0.6s; }
        .card:nth-child(13) { animation-delay: 0.65s; }
        .card:nth-child(14) { animation-delay: 0.7s; }
        .card:nth-child(15) { animation-delay: 0.75s; }
        .card:nth-child(16) { animation-delay: 0.8s; }
        .card:nth-child(17) { animation-delay: 0.85s; }

        /* Iframe Modal */
        .viz-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 10000;
            animation: fadeIn 0.2s ease;
        }
        .viz-modal.active { display: flex; }
        .viz-modal .modal-content {
            width: 95%;
            height: 95%;
            margin: auto;
            background: var(--bg-secondary);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.4);
        }
        .viz-modal .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 24px;
            background: var(--bg-card);
            border-bottom: 1px solid var(--border-color);
        }
        .viz-modal .modal-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--text-primary);
        }
        .viz-modal .close-btn {
            padding: 10px 20px;
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: background 0.2s;
        }
        .viz-modal .close-btn:hover { background: #dc2626; }
        .viz-modal iframe {
            width: 100%;
            height: calc(100% - 60px);
            border: none;
            background: white;
        }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-top">
                <div>
                    <h1>📊 US Trade Data Visualization Suite</h1>
                    <p class="subtitle">Interactive Analysis of Trump-Era Tariff Pass-Through (Jan 2024 - Aug 2025)</p>
                </div>
                <button class="theme-toggle" onclick="toggleTheme()">
                    <span class="theme-toggle-icon" id="themeIcon">🌙</span>
                    <span id="themeLabel">Dark Mode</span>
                </button>
            </div>

            <div class="context-box">
                <h3>📌 About This Analysis</h3>
                <p>
                    This visualization suite examines US import prices and tariffs during the Trump administration\'s
                    tariff campaign (2024-2025). Data includes <strong>17 major tariff implementation events</strong> affecting
                    multiple trading partners and product categories. The analysis covers monthly trends in trade volume,
                    tariff rates, and product-level granularity using <strong>6.9 million trade records</strong> from USITC.
                </p>
            </div>
        </header>

        <div class="tabs-container">
            <button class="tab-btn active" data-category="all" onclick="filterCards(\'all\')">All Visualizations</button>
            <button class="tab-btn" data-category="static" onclick="filterCards(\'static\')">📈 Static Plots</button>
            <button class="tab-btn" data-category="timeseries" onclick="filterCards(\'timeseries\')">⏱️ Time Series</button>
            <button class="tab-btn" data-category="products" onclick="filterCards(\'products\')">🔍 Products</button>
            <button class="tab-btn" data-category="geographic" onclick="filterCards(\'geographic\')">🗺️ Geographic</button>
            <button class="tab-btn" data-category="animations" onclick="filterCards(\'animations\')">🎬 Animations</button>
        </div>

        <div class="search-container">
            <input type="text" class="search-input" placeholder="🔍 Search visualizations..." oninput="searchCards(this.value)">
        </div>

        <div class="cards-grid" id="cardsGrid">
')

# Generate card HTML for each visualization
for (viz in viz_cards) {
    card_html <- sprintf(
        '
            <div class="card" data-category="%s" data-title="%s" data-description="%s">
                <div class="card-header">%s · #%s</div>
                <div class="card-thumbnail">%s</div>
                <div class="card-content">
                    <div class="card-title">%s</div>
                    <div class="card-subtitle">%s</div>
                    <div class="card-description">%s</div>
                    <div class="card-insight">💡 %s</div>
                    <div class="card-footer">
                        <span class="card-badge">%s</span>
                        <a href="#" class="card-link" onclick="openInModal('%s', '%s'); return false;">Open →</a>
                    </div>
                </div>
            </div>',
        viz$category,
        viz$title,
        viz$description,
        toupper(viz$category),
        viz$num,
        viz$icon,
        viz$title,
        viz$subtitle,
        viz$description,
        viz$insights,
        viz$chart_type,
        viz$link,
        gsub("'", "\\\\'", viz$title)  # Escape quotes for JS
    )
    html_content <- paste0(html_content, card_html)
}

# Close cards grid and add legend section
html_content <- paste0(html_content, '
        </div>

        <div class="legend-section">
            <div class="legend-title">📝 Data Dictionary & Legend</div>
            <div class="legend-grid">
                <div class="legend-item">
                    <strong>Rate_Total</strong>
                    <span>Overall weighted average tariff rate on all imports</span>
                </div>
                <div class="legend-item">
                    <strong>Rate_Dutiable</strong>
                    <span>Average tariff on products subject to duties (ad-valorem equivalents)</span>
                </div>
                <div class="legend-item">
                    <strong>Rate_61 (Section 61)</strong>
                    <span>Tariff rate under Section 61 - China-specific tariffs</span>
                </div>
                <div class="legend-item">
                    <strong>Rate_69 (Section 69)</strong>
                    <span>Tariff rate under Section 69 - Steel & Aluminum tariffs</span>
                </div>
                <div class="legend-item">
                    <strong>HS 10-Digit Codes</strong>
                    <span>Harmonized Schedule product codes at most granular level</span>
                </div>
                <div class="legend-item">
                    <strong>HS Chapters (2-digit)</strong>
                    <span>Product category groupings (97 chapters total)</span>
                </div>
                <div class="legend-item">
                    <strong>Trade Value</strong>
                    <span>Total US imports measured in dollars (FOB value)</span>
                </div>
                <div class="legend-item">
                    <strong>Tariffs Paid</strong>
                    <span>Total duties collected on imports (calculated duties)</span>
                </div>
            </div>

            <div class="data-coverage">
                <h4>📊 Data Coverage</h4>
                <div class="coverage-stats">
                    <div class="stat-item">
                        <div class="stat-value">20</div>
                        <div class="stat-label">Months Covered</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">6.9M</div>
                        <div class="stat-label">Trade Records</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">17</div>
                        <div class="stat-label">Tariff Events</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">~200</div>
                        <div class="stat-label">Countries</div>
                    </div>
                </div>
            </div>
        </div>

        <footer>
            <div class="footer-content">
                <div class="footer-title">Trade Data Visualization Suite</div>
                <div class="footer-subtitle">Analysis of US Import Pricing & Tariff Pass-Through (Trump Administration, 2024-2025)</div>
                <div class="footer-meta">
                    <span>📅 Generated: ', generated_date, '</span>
                    <span>📊 Data: USITC</span>
                    <span>📈 Visualizations: R (plotly, ggplot2)</span>
                    <span>🌐 Format: Interactive HTML5</span>
                </div>
            </div>
        </footer>
    </div>

    <!-- Iframe Modal for Visualizations -->
    <div id="vizModal" class="viz-modal">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modalTitle" class="modal-title">Visualization</span>
                <button onclick="closeModal()" class="close-btn">&times; Close</button>
            </div>
            <iframe id="modalIframe" src="" allowfullscreen></iframe>
        </div>
    </div>

    <script>
        // Iframe Modal Functions
        function openInModal(url, title) {
            var modal = document.getElementById('vizModal');
            var iframe = document.getElementById('modalIframe');
            var titleEl = document.getElementById('modalTitle');
            iframe.src = url;
            titleEl.textContent = title || 'Visualization';
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal() {
            var modal = document.getElementById('vizModal');
            var iframe = document.getElementById('modalIframe');
            modal.classList.remove('active');
            iframe.src = '';
            document.body.style.overflow = '';
        }
        
        // Close on escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeModal();
        });

        // Theme toggle
        function toggleTheme() {
            const body = document.body;
            const icon = document.getElementById("themeIcon");
            const label = document.getElementById("themeLabel");

            if (body.getAttribute("data-theme") === "dark") {
                body.removeAttribute("data-theme");
                icon.textContent = "🌙";
                label.textContent = "Dark Mode";
                localStorage.setItem("theme", "light");
            } else {
                body.setAttribute("data-theme", "dark");
                icon.textContent = "☀️";
                label.textContent = "Light Mode";
                localStorage.setItem("theme", "dark");
            }
        }

        // Load saved theme
        document.addEventListener("DOMContentLoaded", function() {
            const savedTheme = localStorage.getItem("theme");
            if (savedTheme === "dark") {
                document.body.setAttribute("data-theme", "dark");
                document.getElementById("themeIcon").textContent = "☀️";
                document.getElementById("themeLabel").textContent = "Light Mode";
            }
        });

        // Category filter
        function filterCards(category) {
            const cards = document.querySelectorAll(".card");
            const tabs = document.querySelectorAll(".tab-btn");

            tabs.forEach(tab => {
                tab.classList.remove("active");
                if (tab.getAttribute("data-category") === category) {
                    tab.classList.add("active");
                }
            });

            cards.forEach(card => {
                if (category === "all" || card.getAttribute("data-category") === category) {
                    card.classList.remove("hidden");
                } else {
                    card.classList.add("hidden");
                }
            });
        }

        // Search filter
        function searchCards(query) {
            const cards = document.querySelectorAll(".card");
            const lowerQuery = query.toLowerCase();

            cards.forEach(card => {
                const title = card.getAttribute("data-title").toLowerCase();
                const desc = card.getAttribute("data-description").toLowerCase();

                if (title.includes(lowerQuery) || desc.includes(lowerQuery)) {
                    card.classList.remove("hidden");
                } else {
                    card.classList.add("hidden");
                }
            });
        }
    </script>
</body>
</html>')

# Write the file
writeLines(html_content, file.path(out_dir, "index.html"))

message("  ✅ Saved: index.html")
message(sprintf("     └─ %d visualization cards generated\n", length(viz_cards)))

message("════════════════════════════════════════════════════════════════")
message("  ✅ ENHANCED INDEX PAGE GENERATED")
message("════════════════════════════════════════════════════════════════\n")
