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
        description = "Publication-ready time series showing total US imports from January 2024 to August 2025. Vertical dashed lines mark major Trump-era tariff implementation dates.",
        insights = "Import values show seasonal patterns with notable disruptions following major tariff announcements.",
        chart_type = "Time Series", link = "./static/monthly_imports.png", link_type = "image"
    ),
    list(
        id = "static-2", category = "static", num = "S2", icon = "📊", title = "Top 30 HS Chapters",
        subtitle = "Trade Volume by Category",
        description = "Horizontal bar chart ranking the top 30 HS chapters by total import value. Bar colors indicate average tariff rate.",
        insights = "Electronics (Chapter 85) and machinery (Chapter 84) dominate US imports by value.",
        chart_type = "Bar Chart", link = "./static/top_chapters.png", link_type = "image"
    ),
    list(
        id = "static-3", category = "static", num = "S3", icon = "📊", title = "Top 30 Countries",
        subtitle = "Trade Partners by Value",
        description = "Horizontal bar chart of the 30 largest US import partners by total trade value.",
        insights = "China remains the largest source of US imports despite elevated tariff rates.",
        chart_type = "Bar Chart", link = "./static/top_countries.png", link_type = "image"
    ),

    # Time Series
    list(
        id = "ts-1", category = "timeseries", num = "01", icon = "📈", title = "Monthly Imports Interactive",
        subtitle = "With Event Markers and Filtering",
        description = "Interactive exploration of monthly US imports with dropdown to filter by country or HS chapter.",
        insights = "Toggle between aggregate view and individual country/chapter trends to identify patterns.",
        chart_type = "Interactive Line Chart", link = "01_monthly_imports_interactive.html", link_type = "html"
    ),
    list(
        id = "ts-2", category = "timeseries", num = "02", icon = "📈", title = "Tariff Rate Evolution",
        subtitle = "4-Rate Decomposition",
        description = "Four tariff rate metrics tracked over time: Overall rate, Dutiable rate, Section 61 (China), and Section 69 (Steel/Aluminum).",
        insights = "Section 61 and 69 rates show step increases aligned with tariff implementation dates.",
        chart_type = "Line Chart", link = "02_tariff_evolution_interactive.html", link_type = "html"
    ),
    list(
        id = "ts-3", category = "timeseries", num = "03", icon = "📈", title = "Trade vs Tariff Scatter",
        subtitle = "Bubble Size = Tariffs Paid",
        description = "Monthly scatter plot with trade value on X-axis and tariff rate on Y-axis.",
        insights = "Larger bubbles indicate months with higher tariff revenue collection.",
        chart_type = "Bubble Chart", link = "03_trade_vs_tariff_scatter.html", link_type = "html"
    ),
    list(
        id = "ts-4", category = "timeseries", num = "04", icon = "📈", title = "Countries Evolution",
        subtitle = "Top 20 Partners Over Time",
        description = "Line chart showing monthly import values for the top 20 trading partners.",
        insights = "Watch how China's import share changes relative to other major partners.",
        chart_type = "Multi-Line Chart", link = "04_countries_evolution.html", link_type = "html"
    ),
    list(
        id = "ts-5", category = "timeseries", num = "05", icon = "📈", title = "HS Chapters Stacked Area",
        subtitle = "Market Share Over Time",
        description = "Stacked area chart showing the composition of US imports by HS chapter over time.",
        insights = "Market share shifts reveal which sectors gained or lost ground during the tariff period.",
        chart_type = "Stacked Area", link = "05_chapters_stacked_area.html", link_type = "html"
    ),
    list(
        id = "ts-6", category = "timeseries", num = "18", icon = "📈", title = "Tariff Events Timeline",
        subtitle = "Interactive Policy Timeline",
        description = "Interactive timeline showing all 14 major Trump administration tariff events from February to May 2025.",
        insights = "Explore the chronological progression of tariff policy changes with detailed event information.",
        chart_type = "Interactive Timeline", link = "18_tariff_timeline.html", link_type = "html"
    ),

    # Products
    list(
        id = "prod-1", category = "products", num = "06", icon = "📦", title = "Trade-Tariff Scatter",
        subtitle = "500 Products by Volume and Rate",
        description = "Interactive scatter plot of the top 500 HS10 products. X-axis: cumulative trade value. Y-axis: average tariff rate. Color: HS chapter.",
        insights = "Identify high-value products with unusual tariff rates by exploring outliers.",
        chart_type = "Scatter Plot", link = "06_trade_tariff_scatter.html", link_type = "html"
    ),
    list(
        id = "prod-2", category = "products", num = "07", icon = "📦", title = "Top Products Table",
        subtitle = "Searchable HS10 Details",
        description = "Interactive data table of the top 500 HS10 products with full descriptions, trade values, and tariff rates.",
        insights = "Use the search box to find specific products.",
        chart_type = "Data Table", link = "07_top_products_table.html", link_type = "html"
    ),
    list(
        id = "prod-3", category = "products", num = "08", icon = "📦", title = "Trade Concentration Lorenz",
        subtitle = "Gini Coefficient Analysis",
        description = "Lorenz curve showing the concentration of US trade value across products.",
        insights = "A steep curve indicates high concentration - few products account for most trade.",
        chart_type = "Lorenz Curve", link = "08_concentration_lorenz.html", link_type = "html"
    ),
    list(
        id = "prod-4", category = "products", num = "09", icon = "📦", title = "Tariff Distribution Violin",
        subtitle = "By HS Chapter",
        description = "Violin plots showing the distribution of tariff rates within each major HS chapter.",
        insights = "Wide violins indicate high tariff variability within a chapter.",
        chart_type = "Violin Plot", link = "09_tariff_distribution_violin.html", link_type = "html"
    ),
    list(
        id = "prod-5", category = "products", num = "14", icon = "📦", title = "HS10 Product Treemap",
        subtitle = "200 Products Hierarchical View",
        description = "Treemap visualization of the top 200 HS10 products, nested by HS chapter.",
        insights = "Explore the hierarchical structure of trade by clicking into chapters.",
        chart_type = "Treemap", link = "14_hs10_treemap.html", link_type = "html"
    ),

    # Geographic
    list(
        id = "geo-1", category = "geographic", num = "10", icon = "🌍", title = "Country Dashboard",
        subtitle = "Trade Partner Overview",
        description = "Bubble chart of top 30 trading partners. X-axis: sea distance from US. Y-axis: average tariff rate. Bubble size: total trade value.",
        insights = "Explore whether distance correlates with tariff treatment or trade volume.",
        chart_type = "Bubble Chart", link = "10_country_dashboard.html", link_type = "html"
    ),
    list(
        id = "geo-2", category = "geographic", num = "11", icon = "🌍", title = "Distance Effect Analysis",
        subtitle = "Near vs Far Countries",
        description = "Box plots comparing tariff rates for near vs. far trading partners.",
        insights = "Test whether geographic proximity affects tariff treatment.",
        chart_type = "Box Plot", link = "11_distance_effect.html", link_type = "html"
    ),
    list(
        id = "geo-3", category = "geographic", num = "12", icon = "🌍", title = "Countries Heatmap",
        subtitle = "Monthly Trade Patterns",
        description = "Heatmap showing monthly import values for the top 20 countries.",
        insights = "Visual patterns reveal whether trade disruptions affected multiple countries simultaneously.",
        chart_type = "Heatmap", link = "12_countries_heatmap.html", link_type = "html"
    ),
    list(
        id = "geo-4", category = "geographic", num = "13", icon = "🌍", title = "Tariff by Country Origin",
        subtitle = "Distribution Histogram",
        description = "Overlapping histograms showing the distribution of monthly tariff rates for top 15 countries.",
        insights = "Some countries have consistent tariff rates while others show high variability.",
        chart_type = "Histogram", link = "13_tariff_distribution_by_country.html", link_type = "html"
    ),

    # Animations
    list(
        id = "anim-1", category = "animations", num = "15", icon = "🎬", title = "Trade-Tariff Animation",
        subtitle = "Top 100 Products Evolution",
        description = "Animated scatter plot showing how the top 100 products evolve over time. Use Play button or drag slider.",
        insights = "Watch products accumulate trade volume over time.",
        chart_type = "Animated Scatter", link = "15_trade_tariff_animation.html", link_type = "html"
    ),
    list(
        id = "anim-2", category = "animations", num = "16", icon = "🎬", title = "Country Evolution Animation",
        subtitle = "Top 50 Partners Over Time",
        description = "Animated bubble chart tracking the top 50 trading partners from January 2024 to present. Features ISO country codes, continent colors, and audio effects.",
        insights = "Observe how tariff rates spike for specific countries following tariff announcements.",
        chart_type = "Animated Scatter", link = "16_country_evolution_animation.html", link_type = "html"
    ),

    # Tools
    list(
        id = "tool-1", category = "tools", num = "17", icon = "🔍", title = "HS Code Lookup",
        subtitle = "Interactive Code Search",
        description = "Search and explore HS 10-digit product codes with full descriptions, chapter names, and section information.",
        insights = "Use this tool to understand product classifications and find specific HS codes.",
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
        .viz-modal .modal-content { width: 95%; height: 95%; margin: auto; background: #1e1e2e; border-radius: 16px; overflow: hidden; }
        .viz-modal .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 24px; background: #2d2d4a; }
        .viz-modal .modal-title { font-size: 18px; font-weight: 600; color: white; }
        .viz-modal .close-btn { padding: 10px 20px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; }
        .viz-modal .close-btn:hover { background: #dc2626; }
        .viz-modal .modal-body { width: 100%; height: calc(100% - 60px); background: white; display: flex; align-items: center; justify-content: center; overflow: auto; }
        .viz-modal iframe { width: 100%; height: 100%; border: none; }
        .viz-modal img { max-width: 100%; max-height: 100%; object-fit: contain; }

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
    card_html <- sprintf(
        '
            <div class="card" data-category="%s" data-title="%s" data-description="%s">
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
                            <a href="#" class="card-link" onclick="openInModal(\'%s\', \'%s\', %s); return false;">Open</a>
                        </div>
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
        viz$link,
        gsub("'", "\\\\'", viz$title),
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

        function openInModal(url, title, isImage) {
            var modal = document.getElementById("vizModal");
            var body = document.getElementById("modalBody");
            var titleEl = document.getElementById("modalTitle");
            titleEl.textContent = title || "Visualization";
            if (isImage) {
                body.innerHTML = "<img src=\\"" + url + "\\" alt=\\"" + title + "\\">";
            } else {
                body.innerHTML = "<iframe src=\\"" + url + "\\" allowfullscreen></iframe>";
            }
            modal.classList.add("active");
            document.body.style.overflow = "hidden";
        }

        function closeModal() {
            var modal = document.getElementById("vizModal");
            document.getElementById("modalBody").innerHTML = "";
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
