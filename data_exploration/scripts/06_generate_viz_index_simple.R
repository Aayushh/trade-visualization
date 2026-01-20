# Simplified Index Generator - No Emojis, Proper UTF-8
# Generates index.html with iframe modal, Tools tab, and ASCII icons

options(stringsAsFactors = FALSE)
library(here)

out_dir <- here("data_exploration", "output", "interactive")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

generated_date <- format(Sys.Date(), "%B %d, %Y")

# Visualization cards with ASCII icons instead of emojis
viz_cards <- list(
    # Static Reference Plots
    list(
        id = "static-1", category = "static", num = "S1", icon = "📊", title = "Monthly US Imports",
        subtitle = "Time Series with Event Markers",
        description = "This time series displays total US import values from January 2024 to September 2025, tracking the aggregate flow of goods into the United States. Vertical dashed lines mark 14 major Trump administration tariff implementation events, providing temporal context for trade fluctuations. The chart reveals seasonal import patterns overlaid with policy-driven disruptions, showing how trade volumes respond to tariff announcements and implementations.",
        insights = "Import values exhibit clear seasonal patterns with notable disruptions following major tariff announcements. Watch for pre-tariff import surges as businesses anticipate higher costs, followed by post-implementation corrections.",
        chart_type = "Time Series", link = "./static/monthly_imports.png", link_type = "image"
    ),
    list(
        id = "static-2", category = "static", num = "S2", icon = "📊", title = "Top 30 HS Chapters",
        subtitle = "Trade Volume by Category",
        description = "This horizontal bar chart ranks the top 30 Harmonized System (HS) chapters by total import value across the entire analysis period. Each bar is color-coded by average tariff rate, revealing which product categories face the highest duties. HS chapters represent broad product categories (e.g., Chapter 85 = Electrical Machinery, Chapter 84 = Mechanical Machinery), providing a sector-level view of US trade composition.",
        insights = "Electronics (Chapter 85) and machinery (Chapter 84) dominate US imports by value, together accounting for over 30% of total trade. Notice how capital goods and intermediate inputs make up the majority of high-value imports, reflecting US manufacturing's reliance on global supply chains.",
        chart_type = "Bar Chart", link = "./static/top_chapters.png", link_type = "image"
    ),
    list(
        id = "static-3", category = "static", num = "S3", icon = "📊", title = "Top 30 Countries",
        subtitle = "Trade Partners by Value",
        description = "This horizontal bar chart identifies the 30 largest US import partners ranked by total trade value from January 2024 to September 2025. The visualization shows both traditional allies (Canada, Mexico) and strategic competitors (China), highlighting the geographic distribution of US supply chains. Bar lengths represent cumulative import values, while colors can indicate regional groupings or tariff treatment categories.",
        insights = "China remains the largest source of US imports despite elevated tariff rates, demonstrating the difficulty of rapidly reshoring complex supply chains. Mexico and Canada follow closely, benefiting from USMCA preferential treatment and geographic proximity.",
        chart_type = "Bar Chart", link = "./static/top_countries.png", link_type = "image"
    ),

    # Time Series
    list(
        id = "ts-1", category = "timeseries", num = "01", icon = "📈", title = "Monthly Imports Interactive",
        subtitle = "With Event Markers and Filtering",
        description = "This fully interactive time series explorer allows users to filter monthly import data by individual countries or HS chapters, revealing granular trends hidden in aggregate statistics. The dropdown menu provides access to detailed trajectories for each trading partner and product category. Tariff event markers remain visible across all views, enabling direct comparison of policy timing against trade responses. The chart updates dynamically, showing how specific sectors or countries reacted to tariff implementations.",
        insights = "Toggle between aggregate view and individual country/chapter trends to identify divergent patterns. For example, compare China's sharp post-tariff decline against Vietnam's simultaneous growth to observe trade diversion effects in real-time.",
        chart_type = "Interactive Line Chart", link = "01_monthly_imports_interactive.html", link_type = "html"
    ),
    list(
        id = "ts-2", category = "timeseries", num = "02", icon = "📈", title = "Tariff Rate Evolution",
        subtitle = "4-Rate Decomposition",
        description = "This multi-line chart tracks four distinct tariff metrics over time, providing a comprehensive view of US tariff policy evolution: (1) Overall Calculated Rate = total duties paid divided by total customs value, (2) Dutiable Rate = duties paid divided only by dutiable imports (excluding free goods), (3) Section 61 Rate = China-specific duties under Section 301, and (4) Section 69 Rate = Steel/Aluminum duties under Section 232. Each metric reveals different aspects of tariff policy, from economy-wide effects to targeted actions.",
        insights = "Section 61 (China) and Section 69 (Steel/Aluminum) rates show dramatic step increases aligned with tariff implementation dates, often reaching 25% or higher. The overall rate rises more gradually, reflecting the mix of targeted and general duties across the full import base.",
        chart_type = "Line Chart", link = "02_tariff_evolution_interactive.html", link_type = "html"
    ),
    list(
        id = "ts-3", category = "timeseries", num = "03", icon = "📈", title = "Trade vs Tariff Scatter",
        subtitle = "Bubble Size = Tariffs Paid",
        description = "This bubble chart plots monthly observations with total trade value on the X-axis and average tariff rate on the Y-axis. Bubble size represents total tariff revenue collected each month, creating a three-dimensional view of trade policy impact. The visualization reveals the relationship between trade volumes, tariff rates, and government revenue - critical for understanding the fiscal and economic implications of tariff policy. Hover over each bubble to see exact values and dates.",
        insights = "Larger bubbles indicate months with higher tariff revenue collection, often appearing after major tariff rate increases. Watch for the trade-off between tariff rates and trade volumes: higher rates may reduce import quantities, potentially offsetting revenue gains.",
        chart_type = "Bubble Chart", link = "03_trade_vs_tariff_scatter.html", link_type = "html"
    ),
    list(
        id = "ts-4", category = "timeseries", num = "04", icon = "📈", title = "Countries Evolution",
        subtitle = "Top 20 Partners Over Time",
        description = "This multi-line chart displays monthly import values for the 20 largest US trading partners, each represented by a distinct color. The visualization makes it easy to compare trade trajectories across countries, identifying winners and losers from tariff policy changes. Lines are drawn with transparency to reduce overplotting while maintaining visibility of all trends. Hover over any line to highlight that country and see detailed monthly values.",
        insights = "Watch how China's import share changes relative to other major partners like Mexico, Canada, Vietnam, and India. Trade diversion effects become visible as some countries gain market share while others lose ground following tariff implementations.",
        chart_type = "Multi-Line Chart", link = "04_countries_evolution.html", link_type = "html"
    ),
    list(
        id = "ts-5", category = "timeseries", num = "05", icon = "📈", title = "HS Chapters Stacked Area",
        subtitle = "Market Share Over Time",
        description = "This stacked area chart shows the composition of US imports by HS chapter over the full analysis period, with each colored band representing a different product category. The chart reveals how market share shifts between sectors over time, highlighting structural changes in US import composition. Total area height represents aggregate import value, while individual band thickness shows each chapter's contribution. Use the chapter dropdown to filter and focus on specific sectors of interest.",
        insights = "Market share shifts reveal which sectors gained or lost ground during the tariff period. For example, electronics and machinery may maintain dominance while traditional manufacturing inputs fluctuate with tariff-driven supply chain adjustments.",
        chart_type = "Stacked Area", link = "05_chapters_stacked_area.html", link_type = "html"
    ),
    list(
        id = "ts-6", category = "timeseries", num = "18", icon = "📈", title = "Tariff Events Timeline",
        subtitle = "Interactive Policy Timeline",
        description = "This interactive card-based timeline presents all 14 major Trump administration tariff events from January to September 2025 in chronological order. Each event is displayed as a styled card with emoji icons categorizing the policy type (China, retaliatory, sectoral, etc.), full event descriptions, implementation dates, and affected products. The timeline provides essential context for interpreting trade data fluctuations and helps users understand the rapid-fire sequence of tariff announcements during this period.",
        insights = "Explore the chronological progression of tariff policy changes with detailed event information. Notice how events cluster in early 2025, creating overlapping policy shocks that make it difficult to isolate individual effects on trade flows.",
        chart_type = "Interactive Timeline", link = "18_tariff_timeline.html", link_type = "html"
    ),

    # Products
    list(
        id = "prod-1", category = "products", num = "06", icon = "📦", title = "Trade-Tariff Scatter",
        subtitle = "500 Products by Volume and Rate",
        description = "This interactive scatter plot visualizes the top 500 HS10 products (10-digit codes representing highly specific product categories) positioned by cumulative trade value (X-axis) and average tariff rate (Y-axis). Each point is color-coded by HS chapter, allowing users to see which product categories cluster together in tariff-trade space. The visualization reveals outliers: high-value products with unusual tariff rates that merit closer investigation. Hover over any point to see the full product description, tariff rate, and total trade value.",
        insights = "Identify high-value products with unusual tariff rates by exploring outliers in the upper-right and upper-left quadrants. Products in the upper-right face both high tariffs and high trade volumes, representing significant revenue sources and potential supply chain vulnerabilities.",
        chart_type = "Scatter Plot", link = "06_trade_tariff_scatter.html", link_type = "html"
    ),
    list(
        id = "prod-2", category = "products", num = "07", icon = "📦", title = "Top Products Table",
        subtitle = "Searchable HS10 Details",
        description = "This fully interactive data table presents the top 500 HS10 products with complete details including 10-digit HS codes, full product descriptions, total trade values, average tariff rates, and associated HS chapters. The table supports sorting by any column, pagination for easy browsing, and a powerful search function that filters across all fields. Export options allow users to download filtered data for further analysis. This tool serves as both a reference for specific product lookups and an exploratory interface for discovering high-value or high-tariff products.",
        insights = "Use the search box to find specific products by keyword, HS code, or chapter name. For example, search 'semiconductor' to find all chip-related products and their tariff treatment, or sort by tariff rate to identify the most heavily taxed imports.",
        chart_type = "Data Table", link = "07_top_products_table.html", link_type = "html"
    ),
    list(
        id = "prod-3", category = "products", num = "08", icon = "📦", title = "Trade Concentration Lorenz",
        subtitle = "Gini Coefficient Analysis",
        description = "This Lorenz curve plots the cumulative share of trade value against the cumulative share of products, providing a classic inequality measure adapted to trade analysis. The diagonal line represents perfect equality (every product has identical trade value), while the curved line shows actual concentration. The area between the curves yields the Gini coefficient (displayed on the chart), quantifying trade concentration: values near 0 indicate even distribution across products, while values near 1 indicate extreme concentration in a few products.",
        insights = "A steep Lorenz curve indicates high trade concentration, meaning a small number of products account for most US imports. This reveals supply chain vulnerabilities: disruptions to a handful of products could have outsized economic impacts.",
        chart_type = "Lorenz Curve", link = "08_concentration_lorenz.html", link_type = "html"
    ),
    list(
        id = "prod-4", category = "products", num = "09", icon = "📦", title = "Tariff Distribution Violin",
        subtitle = "By HS Chapter",
        description = "This violin plot displays the full distribution of tariff rates within each major HS chapter, going beyond simple averages to show the spread and density of rates. Each violin's width represents the density of products at that tariff rate (estimated using Kernel Density Estimation), revealing multimodal distributions where chapters contain distinct tariff clusters. Wide violins indicate high variability within a chapter, while narrow violins suggest uniform tariff treatment. Box plot elements inside each violin show median, quartiles, and outliers.",
        insights = "Wide violins indicate high tariff variability within a chapter, suggesting that policymakers apply different rates to subcategories within the same sector. Narrow violins suggest uniform treatment, while bimodal violins reveal distinct product groups with very different tariff rates.",
        chart_type = "Violin Plot", link = "09_tariff_distribution_violin.html", link_type = "html"
    ),
    list(
        id = "prod-5", category = "products", num = "14", icon = "📦", title = "HS10 Product Treemap",
        subtitle = "200 Products Hierarchical View",
        description = "This interactive treemap visualizes the top 200 HS10 products organized hierarchically by HS chapter. Each rectangle's size represents total trade value, while colors distinguish HS chapters. The hierarchical layout reveals the nested structure of trade: chapters contain multiple products, with rectangle sizes showing each product's contribution to chapter totals. Click on any chapter to zoom in and see its constituent products in detail, then click the chapter label again to zoom back out to the full view.",
        insights = "Explore the hierarchical structure of trade by clicking into chapters to see which specific products dominate each category. Large rectangles within a chapter represent key products that drive that sector's total import value.",
        chart_type = "Treemap", link = "14_hs10_treemap.html", link_type = "html"
    ),

    # Geographic
    list(
        id = "geo-1", category = "geographic", num = "10", icon = "🌍", title = "Country Dashboard",
        subtitle = "Trade Partner Overview",
        description = "This bubble chart visualizes the top 30 US trading partners positioned by sea distance from major US ports (X-axis) and average tariff rate (Y-axis), with bubble size representing total trade value over the analysis period. The visualization tests whether geographic proximity influences tariff treatment or trade volumes, revealing potential patterns in trade policy. Hover over each bubble to see country names, exact distances, tariff rates, and trade values. The chart combines three dimensions of trade relationships in a single interactive view.",
        insights = "Explore whether distance correlates with tariff treatment or trade volume. For example, do nearby countries like Mexico and Canada face lower tariffs? Do distant suppliers like China face higher rates despite large trade volumes? The chart reveals these geographic patterns at a glance.",
        chart_type = "Bubble Chart", link = "10_country_dashboard.html", link_type = "html"
    ),
    list(
        id = "geo-2", category = "geographic", num = "11", icon = "🌍", title = "Distance Effect Analysis",
        subtitle = "Near vs Far Countries",
        description = "This box plot comparison tests the hypothesis that geographic proximity affects tariff treatment by dividing trading partners into 'near' and 'far' categories (using median distance as the cutoff) and comparing their tariff rate distributions. Each box shows the median, quartiles, and outliers for its group. The visualization provides statistical evidence for or against distance-based tariff discrimination, a key question in international trade policy analysis.",
        insights = "Test whether geographic proximity affects tariff treatment. If near countries show significantly lower median tariff rates, it suggests preferential treatment for regional partners (possibly due to trade agreements like USMCA). Similar distributions would indicate distance-neutral tariff policy.",
        chart_type = "Box Plot", link = "11_distance_effect.html", link_type = "html"
    ),
    list(
        id = "geo-3", category = "geographic", num = "12", icon = "🌍", title = "Countries Heatmap",
        subtitle = "Monthly Trade Patterns",
        description = "This heatmap displays monthly import values for the top 20 countries in a grid format, with countries on the Y-axis, months on the X-axis, and cell colors representing trade value intensity (darker = higher imports). The visualization makes it easy to spot temporal patterns: which months saw elevated imports, whether trade disruptions affected multiple countries simultaneously, and how individual country trajectories compare. Hover over any cell to see exact monthly values and country names.",
        insights = "Visual patterns reveal whether trade disruptions affected multiple countries simultaneously (vertical bands of lighter colors) or just specific partners. Horizontal patterns show seasonal import cycles for individual countries, while diagonal patterns might indicate rolling supply chain adjustments.",
        chart_type = "Heatmap", link = "12_countries_heatmap.html", link_type = "html"
    ),
    list(
        id = "geo-4", category = "geographic", num = "13", icon = "🌍", title = "Tariff by Country Origin",
        subtitle = "Distribution Histogram",
        description = "This overlapping histogram shows the distribution of monthly tariff rates for the top 15 trading partners, with each country represented by a semi-transparent colored layer. The visualization reveals whether countries face consistent tariff rates over time (narrow, tall peaks) or highly variable rates (wide, flat distributions). Overlapping allows direct visual comparison of distributions across countries, making it easy to identify which partners face higher average rates or greater volatility.",
        insights = "Some countries have consistent tariff rates (narrow peaks) while others show high variability (wide spreads). Bimodal distributions indicate countries whose tariff treatment changed dramatically during the analysis period, likely due to policy interventions.",
        chart_type = "Histogram", link = "13_tariff_distribution_by_country.html", link_type = "html"
    ),

    # Animations
    list(
        id = "anim-1", category = "animations", num = "15", icon = "🎬", title = "Trade-Tariff Animation",
        subtitle = "Top 100 Products Evolution",
        description = "This animated scatter plot brings the top 100 HS10 products to life, showing how they accumulate trade value and experience tariff changes over time from January 2024 to September 2025. Each frame represents one month, with products positioned by cumulative trade value (X-axis) and tariff rate (Y-axis). The animation reveals temporal patterns invisible in static charts: which products see tariff spikes, when trade accelerates or decelerates, and how product rankings shift over time. Use the Play button to watch the full sequence, or drag the slider to examine specific months.",
        insights = "Watch products accumulate trade volume over time, creating upward-sloping trajectories as imports grow. Sudden vertical jumps indicate tariff rate increases for specific products, often aligned with policy announcements. Compare fast-growing products (steep slopes) against slow-growing ones.",
        chart_type = "Animated Scatter", link = "15_trade_tariff_animation.html", link_type = "html"
    ),
    list(
        id = "anim-2", category = "animations", num = "16", icon = "🎬", title = "Country Evolution Animation",
        subtitle = "Top 50 Partners Over Time",
        description = "This animated bubble chart tracks the top 50 US trading partners month-by-month from January 2024 through September 2025. Each bubble represents a country, sized by monthly import value and colored by continent. The animation displays 3-letter ISO country codes for identification, with bubbles repositioning as trade values and tariff rates fluctuate. Audio effects mark tariff event dates, providing audio-visual cues for policy timing. The visualization makes temporal patterns vivid: watch China's trajectory diverge from Vietnam's, or see how European partners respond differently than Asian ones.",
        insights = "Observe how tariff rates spike for specific countries following tariff announcements - watch for sudden upward movements of country bubbles on the Y-axis. China often shows the most dramatic movements, while USMCA partners (Mexico, Canada) remain more stable. Trade diversion becomes visible as some bubbles grow while others shrink simultaneously.",
        chart_type = "Animated Scatter", link = "16_country_evolution_animation.html", link_type = "html"
    ),

    # Tools
    list(
        id = "tool-1", category = "tools", num = "17", icon = "🔍", title = "HS Code Lookup",
        subtitle = "Interactive Code Search",
        description = "This interactive search tool provides instant access to the complete HS 10-digit product classification system used in US trade statistics. Enter any keyword, partial HS code, or product description to search across thousands of product categories. Results display the full 10-digit HS code, complete product description, associated 2-digit HS chapter, chapter name, and broader HS section. The tool serves as both a reference for understanding existing codes and a discovery mechanism for finding relevant products. Essential for interpreting trade data and understanding product categorization.",
        insights = "Use this tool to understand product classifications and find specific HS codes for analysis. For example, search 'smartphone' to see all related codes and their chapter assignments, or enter '8517' to see all products in the telecommunications chapter. The hierarchical structure (section → chapter → code) becomes clear through exploration.",
        chart_type = "Interactive Tool", link = "17_hs_code_lookup.html", link_type = "html"
    )
)

# Generate HTML content
html_content <- '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>US Trade Data Visualization Suite</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
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
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Inter", sans-serif; background: var(--bg-primary); min-height: 100vh; color: var(--text-primary); }
        .container { max-width: 1400px; margin: 0 auto; padding: 2rem; }

        header { background: var(--bg-secondary); backdrop-filter: blur(20px); border-radius: 24px; padding: 2rem; margin-bottom: 2rem; box-shadow: var(--shadow); }
        .header-top { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem; margin-bottom: 1.5rem; }
        h1 { font-size: 2rem; background: linear-gradient(135deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .subtitle { color: var(--text-secondary); font-size: 1rem; }
        .theme-toggle { padding: 0.75rem 1.25rem; background: var(--bg-glass); border: 1px solid var(--border-color); border-radius: 12px; cursor: pointer; font-size: 0.9rem; color: var(--text-primary); transition: all 0.3s; }
        .theme-toggle:hover { background: var(--accent-primary); color: white; }

        .context-box { background: var(--bg-glass); padding: 1.5rem; border-radius: 16px; border-left: 4px solid var(--accent-primary); }
        .context-box h3 { color: var(--accent-primary); margin-bottom: 0.5rem; }
        .context-box p { color: var(--text-secondary); font-size: 0.95rem; line-height: 1.6; }

        .tabs-container { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-bottom: 1.5rem; }
        .tab-btn { padding: 0.75rem 1.25rem; background: var(--bg-secondary); border: none; border-radius: 12px; cursor: pointer; font-size: 0.9rem; color: var(--text-secondary); transition: all 0.3s; }
        .tab-btn:hover, .tab-btn.active { background: var(--accent-primary); color: white; }

        .search-container { margin-bottom: 2rem; }
        .search-input { width: 100%; max-width: 400px; padding: 1rem 1.5rem; background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 16px; font-size: 1rem; color: var(--text-primary); }
        .search-input:focus { outline: none; border-color: var(--accent-primary); }

        .cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 1.5rem; }
        .card { background: var(--bg-card); backdrop-filter: blur(20px); border-radius: 20px; overflow: hidden; box-shadow: var(--shadow); transition: all 0.3s; border: 1px solid var(--border-color); }
        .card:hover { transform: translateY(-4px); box-shadow: var(--shadow-hover); }
        .card.hidden { display: none; }
        .card-header { padding: 0.75rem 1.25rem; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .card[data-category="static"] .card-header { background: linear-gradient(135deg, var(--cat-static), #059669); color: white; }
        .card[data-category="timeseries"] .card-header { background: linear-gradient(135deg, var(--cat-timeseries), #1d4ed8); color: white; }
        .card[data-category="products"] .card-header { background: linear-gradient(135deg, var(--cat-products), #d97706); color: white; }
        .card[data-category="geographic"] .card-header { background: linear-gradient(135deg, var(--cat-geographic), #b91c1c); color: white; }
        .card[data-category="animations"] .card-header { background: linear-gradient(135deg, var(--cat-animations), #7c3aed); color: white; }
        .card[data-category="tools"] .card-header { background: linear-gradient(135deg, var(--cat-tools), #0891b2); color: white; }
        .card-thumbnail { height: 80px; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; background: var(--bg-glass); }
        .card-content { padding: 1.25rem; }
        .card-title { font-size: 1.1rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.25rem; }
        .card-subtitle { font-size: 0.85rem; color: var(--accent-primary); margin-bottom: 0.75rem; }
        .card-description { font-size: 0.9rem; color: var(--text-secondary); line-height: 1.5; margin-bottom: 0.75rem; }
        .card-insight { display: none; font-size: 0.85rem; color: var(--text-muted); font-style: italic; margin-bottom: 1rem; padding: 0.75rem; background: var(--bg-glass); border-radius: 8px; }
        .card-footer { display: flex; justify-content: space-between; align-items: center; gap: 0.5rem; }
        .card-actions { display: flex; gap: 0.5rem; }
        .card-badge { padding: 0.25rem 0.75rem; background: var(--bg-glass); border-radius: 20px; font-size: 0.75rem; color: var(--text-muted); }
        .card-link { padding: 0.5rem 1rem; background: var(--accent-primary); color: white; text-decoration: none; border-radius: 8px; font-size: 0.85rem; font-weight: 500; transition: all 0.3s; border: none; cursor: pointer; }
        .card-link:hover { background: var(--accent-secondary); }
        .copy-link-btn { padding: 0.5rem 1rem; background: var(--bg-glass); color: var(--text-primary); border: 1px solid var(--border-color); border-radius: 8px; font-size: 0.85rem; font-weight: 500; cursor: pointer; transition: all 0.3s; }
        .copy-link-btn:hover { background: var(--accent-primary); color: white; border-color: var(--accent-primary); }
        .copy-link-btn.copied { background: #10b981; color: white; border-color: #10b981; }

        footer { background: var(--bg-secondary); backdrop-filter: blur(20px); border-radius: 24px; padding: 2rem; margin-top: 2rem; text-align: center; }
        .footer-title { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.5rem; }
        .footer-subtitle { color: var(--text-secondary); margin-bottom: 1rem; }
        .footer-meta { display: flex; justify-content: center; gap: 2rem; flex-wrap: wrap; font-size: 0.85rem; color: var(--text-muted); }

        /* Modal */
        .viz-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 10000; }
        .viz-modal.active { display: flex; }
        .viz-modal .modal-content { width: 95%; height: 95%; margin: auto; background: #1e1e2e; border-radius: 16px; overflow: hidden; display: flex; flex-direction: column; }
        .viz-modal .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 24px; background: #2d2d4a; flex-shrink: 0; }
        .viz-modal .modal-title { font-size: 18px; font-weight: 600; color: white; }
        .viz-modal .close-btn { padding: 10px 20px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; }
        .viz-modal .close-btn:hover { background: #dc2626; }
        .viz-modal .modal-body { width: 100%; flex: 1; background: white; display: flex; align-items: center; justify-content: center; overflow: auto; min-height: 0; }
        .viz-modal iframe { width: 100%; height: 100%; border: none; }
        .viz-modal img { max-width: 100%; max-height: 100%; object-fit: contain; }
        .viz-modal .modal-description { background: #f8f9fa; border-top: 2px solid #667eea; padding: 1.5rem 2rem; max-height: 200px; overflow-y: auto; flex-shrink: 0; }
        .viz-modal .modal-description h4 { margin: 0 0 0.75rem 0; color: #1a1a2e; font-size: 1rem; font-weight: 600; }
        .viz-modal .modal-description p { margin: 0 0 0.75rem 0; color: #4a4a6a; font-size: 0.9rem; line-height: 1.6; }
        .viz-modal .modal-description p:last-child { margin-bottom: 0; }
        .viz-modal .modal-description strong { color: #667eea; }
        .viz-modal .modal-description .insight { background: #ffffff; border-left: 3px solid #10b981; padding: 0.75rem 1rem; margin-top: 0.75rem; border-radius: 4px; }
        .viz-modal .modal-description .insight strong { color: #10b981; }


        @media (max-width: 768px) {
            .cards-grid { grid-template-columns: 1fr; }
            h1 { font-size: 1.5rem; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-top">
                <div>
                    <h1>US Trade Data Visualization Suite</h1>
                    <p class="subtitle">Interactive Analysis of Trump-Era Tariff Pass-Through (Jan 2024 - Sept 2025)</p>
                </div>
                <div style="display: flex; gap: 0.75rem; align-items: center;">
                    <a href="https://www.linkedin.com/in/aayush-agarwal-bba41677/" target="_blank" class="theme-toggle" style="text-decoration: none;">LinkedIn</a>
                    <button class="theme-toggle" onclick="toggleTheme()">
                        <span id="themeIcon">Dark</span> Mode
                    </button>
                </div>
            </div>
            <div class="context-box">
                <h3>About This Analysis</h3>
                <p>This visualization suite examines US import prices and tariffs during the Trump administration tariff campaign (2024-2025). Data includes <strong>17 major tariff implementation events</strong> affecting multiple trading partners. The analysis covers monthly trends using <strong>6.9 million trade records</strong> from USITC.</p>
            </div>
        </header>

        <div class="tabs-container">
            <button class="tab-btn active" data-category="all" onclick="filterCards(\'all\')">All</button>
            <button class="tab-btn" data-category="static" onclick="filterCards(\'static\')">Static</button>
            <button class="tab-btn" data-category="timeseries" onclick="filterCards(\'timeseries\')">Time Series</button>
            <button class="tab-btn" data-category="products" onclick="filterCards(\'products\')">Products</button>
            <button class="tab-btn" data-category="geographic" onclick="filterCards(\'geographic\')">Geographic</button>
            <button class="tab-btn" data-category="animations" onclick="filterCards(\'animations\')">Animations</button>
            <button class="tab-btn" data-category="tools" onclick="filterCards(\'tools\')">Tools</button>
        </div>

        <div class="search-container">
            <input type="text" class="search-input" placeholder="Search visualizations..." oninput="searchCards(this.value)">
        </div>

        <div class="cards-grid" id="cardsGrid">
'

# Generate card HTML for each visualization
for (viz in viz_cards) {
    is_image <- viz$link_type == "image"
    # Escape quotes for data attributes and JavaScript
    desc_escaped <- gsub("'", "&apos;", gsub('"', "&quot;", viz$description))
    insights_escaped <- gsub("'", "&apos;", gsub('"', "&quot;", viz$insights))
    title_js <- gsub("'", "\\\\'", viz$title)
    
    card_html <- sprintf(
        '
            <div class="card" data-category="%s" data-title="%s" data-description="%s" data-insights="%s">
                <div class="card-header">%s - #%s</div>
                <div class="card-thumbnail">%s</div>
                <div class="card-content">
                    <div class="card-title">%s</div>
                    <div class="card-subtitle">%s</div>
                    <div class="card-description">%s</div>
                    <div class="card-insight">TIP: %s</div>
                    <div class="card-footer">
                        <span class="card-badge">%s</span>
                        <div class="card-actions">
                            <button class="copy-link-btn" onclick="copyLink(\'%s\', this); return false;" title="Copy shareable link">📋 Copy Link</button>
                            <a href="#" class="card-link" onclick="openInModal(\'%s\', \'%s\', %s, this); return false;">Open</a>
                        </div>
                    </div>
                </div>
            </div>',
        viz$category,
        viz$title,
        desc_escaped,
        insights_escaped,
        toupper(viz$category),
        viz$num,
        viz$icon,
        viz$title,
        viz$subtitle,
        viz$description,
        viz$insights,
        viz$chart_type,
        viz$link,
        viz$link,
        title_js,
        tolower(as.character(is_image))
    )
    html_content <- paste0(html_content, card_html)
}

# Close cards grid and add footer
html_content <- paste0(html_content, sprintf('
        </div>

        <footer>
            <div class="footer-title">US Trade Data Analysis</div>
            <div class="footer-subtitle">Interactive Visualization Suite</div>
            <div class="footer-meta">
                <span>Generated: %s</span>
                <span>Data: USITC</span>
                <span>Visualizations: R (plotly, ggplot2)</span>
            </div>
        </footer>
    </div>

    <!-- Modal -->
    <div id="vizModal" class="viz-modal" onclick="if(event.target===this)closeModal()">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modalTitle" class="modal-title">Visualization</span>
                <button onclick="closeModal()" class="close-btn">X Close</button>
            </div>
            <div id="modalBody" class="modal-body"></div>
            <div id="modalDescription" class="modal-description"></div>
        </div>
    </div>

    <script>
        function copyLink(relativeUrl, button) {
            var baseUrl = window.location.origin + window.location.pathname.replace("index.html", "");
            var fullUrl = baseUrl + relativeUrl;
            navigator.clipboard.writeText(fullUrl).then(function() {
                var originalText = button.innerHTML;
                button.innerHTML = "✓ Copied!";
                button.classList.add("copied");
                setTimeout(function() {
                    button.innerHTML = originalText;
                    button.classList.remove("copied");
                }, 2000);
            }).catch(function(err) {
                alert("Failed to copy link. URL: " + fullUrl);
            });
        }

        function openInModal(url, title, isImage, linkElement) {
            var modal = document.getElementById("vizModal");
            var body = document.getElementById("modalBody");
            var titleEl = document.getElementById("modalTitle");
            var descEl = document.getElementById("modalDescription");
            
            titleEl.textContent = title || "Visualization";
            
            if (isImage) {
                body.innerHTML = "<img src=\\"" + url + "\\" alt=\\"" + title + "\\">";
            } else {
                body.innerHTML = "<iframe src=\\"" + url + "\\" allowfullscreen></iframe>";
            }
            
            // Get description and insights from card data attributes
            var cardElement = linkElement.closest(".card");
            var description = cardElement ? cardElement.getAttribute("data-description") : "";
            var insights = cardElement ? cardElement.getAttribute("data-insights") : "";
            
            // Build description HTML
            var descHTML = "";
            if (description) {
                // Unescape HTML entities
                description = description.replace(/&quot;/g, \'"\'). replace(/&apos;/g, "\'");
                descHTML += "<h4>About This Visualization</h4>";
                descHTML += "<p>" + description + "</p>";
            }
            if (insights) {
                insights = insights.replace(/&quot;/g, \'"\'). replace(/&apos;/g, "\'");
                descHTML += "<div class=\'insight\'><p><strong>Key Insight:</strong> " + insights + "</p></div>";
            }
            descEl.innerHTML = descHTML;
            
            modal.classList.add("active");
            document.body.style.overflow = "hidden";
        }

        function closeModal() {
            var modal = document.getElementById("vizModal");
            document.getElementById("modalBody").innerHTML = "";
            document.getElementById("modalDescription").innerHTML = "";
            modal.classList.remove("active");
            document.body.style.overflow = "";
        }

        document.addEventListener("keydown", function(e) { if (e.key === "Escape") closeModal(); });

        function toggleTheme() {
            var body = document.body;
            var icon = document.getElementById("themeIcon");
            if (body.getAttribute("data-theme") === "dark") {
                body.removeAttribute("data-theme");
                icon.textContent = "Dark";
                localStorage.setItem("theme", "light");
            } else {
                body.setAttribute("data-theme", "dark");
                icon.textContent = "Light";
                localStorage.setItem("theme", "dark");
            }
        }

        document.addEventListener("DOMContentLoaded", function() {
            var savedTheme = localStorage.getItem("theme");
            if (savedTheme === "dark") {
                document.body.setAttribute("data-theme", "dark");
                document.getElementById("themeIcon").textContent = "Light";
            }
        });

        function filterCards(category) {
            var cards = document.querySelectorAll(".card");
            var tabs = document.querySelectorAll(".tab-btn");
            tabs.forEach(function(tab) {
                tab.classList.remove("active");
                if (tab.getAttribute("data-category") === category) tab.classList.add("active");
            });
            cards.forEach(function(card) {
                if (category === "all" || card.getAttribute("data-category") === category) {
                    card.classList.remove("hidden");
                } else {
                    card.classList.add("hidden");
                }
            });
        }

        function searchCards(query) {
            var cards = document.querySelectorAll(".card");
            var lowerQuery = query.toLowerCase();
            cards.forEach(function(card) {
                var title = card.getAttribute("data-title").toLowerCase();
                var desc = card.getAttribute("data-description").toLowerCase();
                if (title.includes(lowerQuery) || desc.includes(lowerQuery)) {
                    card.classList.remove("hidden");
                } else {
                    card.classList.add("hidden");
                }
            });
        }
    </script>
</body>
</html>', generated_date))

# Write with explicit UTF-8 encoding
output_file <- file.path(out_dir, "index.html")
con <- file(output_file, "w", encoding = "UTF-8")
writeLines(html_content, con, useBytes = FALSE)
close(con)

message("Generated: ", output_file)
message("Cards: ", length(viz_cards))
