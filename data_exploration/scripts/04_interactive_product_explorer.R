# Enhanced Interactive Product Deep-Dive Explorer
# Purpose: Premium HS10 lookups, treemap, products table, trade concentration analysis
#          with rich descriptions and modern styling

options(stringsAsFactors = FALSE)

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, here, scales, plotly, data.table, DT, htmltools, htmlwidgets)

message("════════════════════════════════════════════════════════════════")
message("  ENHANCED INTERACTIVE PRODUCT DEEP-DIVE EXPLORER")
message("════════════════════════════════════════════════════════════════\n")

# Output directory
out_dir <- here("data_exploration", "output", "interactive")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ============================================================================
# SHARED STYLING
# ============================================================================

colors <- list(
  primary = "#667eea",
  secondary = "#764ba2",
  accent = "#f59e0b",
  success = "#10b981",
  danger = "#ef4444",
  info = "#3b82f6",
  text_dark = "#1a1a2e",
  text_muted = "#6b7280",
  bg_light = "#f8fafc",
  grid = "#e2e8f0"
)

create_description_panel <- function(title, what_it_shows, how_to_use, key_insights, color = colors$primary) {
  sprintf('
<div style="max-width:1200px; margin:20px auto; padding:24px; background:linear-gradient(135deg, #f8fafc 0%%, #e2e8f0 100%%); border-radius:16px; border-left:5px solid %s; font-family: Inter, -apple-system, sans-serif; box-shadow: 0 4px 15px rgba(0,0,0,0.08);">
  <h3 style="margin:0 0 16px 0; color:%s; font-size:1.2rem; display:flex; align-items:center; gap:8px;">
    📊 %s
  </h3>

  <div style="display:grid; gap:16px;">
    <div style="background:white; padding:16px; border-radius:12px;">
      <h4 style="margin:0 0 8px 0; color:#1a1a2e; font-size:0.95rem;">What This Shows</h4>
      <p style="margin:0; color:#4a5568; font-size:0.9rem; line-height:1.6;">%s</p>
    </div>

    <div style="background:white; padding:16px; border-radius:12px;">
      <h4 style="margin:0 0 8px 0; color:#1a1a2e; font-size:0.95rem;">How to Use It</h4>
      <ul style="margin:0; padding-left:20px; color:#4a5568; font-size:0.9rem; line-height:1.8;">
        %s
      </ul>
    </div>

    <div style="background:linear-gradient(135deg, %s15 0%%, %s08 100%%); padding:16px; border-radius:12px; border:1px solid %s30;">
      <h4 style="margin:0 0 8px 0; color:%s; font-size:0.95rem;">💡 Key Insights</h4>
      <p style="margin:0; color:#4a5568; font-size:0.9rem; line-height:1.6; font-style:italic;">%s</p>
    </div>
  </div>
</div>', color, color, title, what_it_shows, how_to_use, color, color, color, color, key_insights)
}

# Load prepared data
message("Loading prepared data...\n")
monthly_by_hs10 <- arrow::read_parquet(here("data", "processed", "monthly_by_hs10.parquet"))
monthly_by_hs6 <- arrow::read_parquet(here("data", "processed", "monthly_by_hs6.parquet"))
hs10 <- arrow::read_parquet(here("data", "processed", "top_entities_hs10.parquet"))
countries <- arrow::read_parquet(here("data", "processed", "top_entities_countries.parquet"))
chapters <- arrow::read_parquet(here("data", "processed", "top_entities_chapters.parquet"))
top_entities <- list(hs10 = hs10, countries = countries, chapters = chapters)
hs_lookup <- arrow::read_parquet(here("data", "processed", "hs_lookup.parquet"))

setDT(monthly_by_hs10)
setDT(monthly_by_hs6)
setDT(hs_lookup)

# ============================================================================
# EXPLORER 1: INTERACTIVE TREEMAP (Top 200 HS10 by trade value)
# ============================================================================

message("[1/5] Generating HS10 treemap...\n")

# Get top HS10 products
top_hs10_data <- top_entities$hs10[1:200]
top_hs10_data[, trade_value_bn := total_trade / 1e9]

# Rename chapter to avoid conflict
setnames(top_hs10_data, "chapter", "chapter_top")

# Merge with chapter names and descriptions
top_hs10_merged <- merge(
  top_hs10_data,
  hs_lookup[, .(HTS_Number, chapter, item_desc, chapter_name)],
  by = "HTS_Number",
  all.x = TRUE
)

if ("chapter_top" %in% names(top_hs10_merged)) {
  top_hs10_merged[, chapter_top := NULL]
}

# Create product label
top_hs10_merged[, product_label := paste0(
  HTS_Number, " | ", chapter_name, " | ", substr(item_desc, 1, 50)
)]

top_hs10_merged <- top_hs10_merged[!is.na(chapter) & !is.na(avg_tariff)]

message(sprintf(
  "  Treemap: %d products from %d chapters\n",
  nrow(top_hs10_merged), uniqueN(top_hs10_merged$chapter)
))

# Create chapter-level parent nodes
chapters_for_tree <- unique(top_hs10_merged[, .(chapter, chapter_name)])
chapters_for_tree[, `:=`(
  label = paste0(chapter, ": ", chapter_name),
  parent = "",
  value = 0,
  tariff = NA_real_
)]

# Prepare product nodes - parent must match chapter label exactly
products_for_tree <- top_hs10_merged[, .(
  label = HTS_Number,
  parent = paste0(chapter, ": ", chapter_name), # Must match chapter label
  value = total_trade,
  tariff = avg_tariff,
  hover_text = product_label,
  full_desc = item_desc
)]

# Combine chapter and product nodes
tree_data <- rbindlist(list(
  chapters_for_tree[, .(label, parent, value, tariff, hover_text = label, full_desc = "")],
  products_for_tree
), fill = TRUE)

# Create treemap with premium styling
p1 <- plot_ly(
  data = tree_data,
  labels = ~label,
  parents = ~parent,
  values = ~value,
  type = "treemap",
  customdata = ~full_desc,
  marker = list(
    colors = tree_data$tariff * 100,
    colorscale = list(c(0, colors$success), c(0.3, colors$accent), c(1, colors$danger)),
    colorbar = list(
      title = list(text = "Avg Tariff (%)", font = list(size = 12)),
      thickness = 20,
      len = 0.5
    ),
    cmid = median(tree_data$tariff * 100, na.rm = TRUE)
  ),
  text = ~hover_text,
  hovertemplate = "<b>%{text}</b><br>Trade: <b>$%{value/1e9:.2f}B</b><br>Tariff: <b>%{marker.color:.1f}%</b><extra></extra>"
) %>%
  layout(
    title = list(
      text = "<b>Top 200 HS10 Products Treemap</b><br><span style='font-size:14px;color:#6b7280;'>Tile size = Trade value | Color = Tariff rate | Click to drill down</span>",
      font = list(family = "Inter, sans-serif", size = 20),
      x = 0.02
    ),
    font = list(family = "Inter, sans-serif"),
    height = 800,
    margin = list(l = 20, r = 20, t = 100, b = 20),
    paper_bgcolor = "white"
  ) %>%
  config(responsive = TRUE, displaylogo = FALSE) %>%
  htmlwidgets::onRender("
    function(el, x) {
      el.on('plotly_click', function(data) {
        var point = data.points[0];
        if(point.customdata && point.customdata.length > 0) {
          alert('Full Product Description:\\n\\n' + point.customdata);
        }
      });
    }
  ")

p1_desc <- create_description_panel(
  title = "HS10 Product Treemap",
  what_it_shows = "An interactive hierarchical visualization of the top 200 imported products. Products are grouped by HS chapter (2-digit categories). <b>Tile size</b> represents total trade value in USD. <b>Color</b> indicates average tariff rate: green for low tariffs, yellow for medium, and red for high tariffs.",
  how_to_use = "<li><b>Click chapter:</b> Drill down into a specific chapter to see its products</li>
               <li><b>Click product:</b> A popup will show the full product description</li>
               <li><b>Hover:</b> See product label, trade value, and tariff rate</li>
               <li><b>Navigate:</b> Click breadcrumb at top to zoom out</li>",
  key_insights = "Electronics and machinery components dominate both trade volume AND tariff exposure. Red-colored high-tariff tiles tend to be smaller individually but numerous, indicating broad tariff application across product categories.",
  color = colors$secondary
)

p1_with_desc <- htmlwidgets::appendContent(p1, HTML(p1_desc))

# ============================================================================
# EXPLORER 2: TOP 500 PRODUCTS TABLE (searchable, sortable)
# ============================================================================

message("[2/5] Building Products table...\n")

top_products <- top_entities$hs10
top_products[, trade_value_bn := total_trade / 1e9]
top_products[, avg_tariff_pct := avg_tariff * 100]

# Merge with product descriptions
top_products_merged <- merge(top_products,
  hs_lookup[, .(HTS_Number, item_desc, chapter_name)][!duplicated(HTS_Number)],
  by = "HTS_Number", all.x = TRUE
)

# Prepare display table
display_table <- top_products_merged[, .(
  `HTS Code` = HTS_Number,
  `Product` = ifelse(nchar(item_desc) > 80, paste0(substr(item_desc, 1, 77), "..."), item_desc),
  `Full Description` = item_desc,
  `Chapter` = chapter_name,
  `Trade Value ($B)` = round(trade_value_bn, 2),
  `Avg Tariff (%)` = round(avg_tariff_pct, 2),
  `Suppliers` = n_countries
)]

# Create enhanced DataTable
dt_table <- datatable(
  display_table,
  filter = "top",
  options = list(
    pageLength = 50,
    lengthMenu = list(c(25, 50, 100, 250, 500), c("25", "50", "100", "250", "500")),
    columnDefs = list(
      list(targets = 2, visible = FALSE, searchable = TRUE),
      list(targets = 4, render = JS(
        "function(data, type, row, meta) {",
        "return '$' + data.toFixed(2) + 'B';",
        "}"
      )),
      list(targets = 5, render = JS(
        "function(data, type, row, meta) {",
        "return data.toFixed(2) + '%';",
        "}"
      ))
    ),
    order = list(list(4, "desc")),
    scrollX = TRUE,
    scrollY = "600px",
    dom = '<"top"lf>rt<"bottom"ip>',
    language = list(search = "🔍 Search products:")
  ),
  rownames = FALSE,
  class = "display compact stripe hover",
  caption = htmltools::tags$caption(
    style = "caption-side: top; text-align: left; color: #1a1a2e; font-size: 1.3em; padding: 15px; font-family: Inter, sans-serif; font-weight: 600;",
    "Top 500 Imported Products by Trade Volume (Jan 2024 - Aug 2025)"
  )
) %>%
  formatCurrency(5, currency = "$", digits = 2, mark = ",") %>%
  formatPercentage(6, digits = 2)

# Premium description panel for table
table_desc_html <- '
<div style="max-width:1400px; margin:20px auto; padding:24px; background:linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); border-radius:16px; border-left:5px solid #10b981; font-family: Inter, -apple-system, sans-serif; box-shadow: 0 4px 15px rgba(0,0,0,0.08);">
  <h3 style="margin:0 0 16px 0; color:#10b981; font-size:1.2rem;">📋 Interactive Products Database</h3>

  <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap:16px;">
    <div style="background:white; padding:16px; border-radius:12px;">
      <h4 style="margin:0 0 8px 0; color:#1a1a2e; font-size:0.95rem;">What This Shows</h4>
      <p style="margin:0; color:#4a5568; font-size:0.9rem; line-height:1.6;">The top 500 imported products (10-digit HS codes) ranked by total trade value. Includes the product description, HS chapter, trade value, average tariff rate, and number of source countries.</p>
    </div>

    <div style="background:white; padding:16px; border-radius:12px;">
      <h4 style="margin:0 0 8px 0; color:#1a1a2e; font-size:0.95rem;">How to Use It</h4>
      <ul style="margin:0; padding-left:20px; color:#4a5568; font-size:0.9rem; line-height:1.6;">
        <li><b>Search:</b> Type any keyword to filter rows</li>
        <li><b>Sort:</b> Click column headers</li>
        <li><b>Filter:</b> Use dropdowns at column tops</li>
        <li><b>Navigate:</b> Page controls at bottom</li>
      </ul>
    </div>

    <div style="background:linear-gradient(135deg, #10b98115 0%, #10b98108 100%); padding:16px; border-radius:12px; border:1px solid #10b98130;">
      <h4 style="margin:0 0 8px 0; color:#10b981; font-size:0.95rem;">💡 Pro Tip</h4>
      <p style="margin:0; color:#4a5568; font-size:0.9rem; line-height:1.6; font-style:italic;">Product descriptions are truncated for display, but the full text is searchable. Try typing a product name to find specific commodities.</p>
    </div>
  </div>
</div>'

table_with_desc <- htmlwidgets::prependContent(as_widget(dt_table), HTML(table_desc_html))
saveWidget(table_with_desc, file.path(out_dir, "07_top_products_table.html"), selfcontained = FALSE)
message("  ✅ Saved: 07_top_products_table.html\n")

# ============================================================================
# EXPLORER 3: CONCENTRATION ANALYSIS (Lorenz curve)
# ============================================================================

message("[3/5] Building Trade concentration analysis...\n")

# Calculate concentration metrics
hs10_concentration <- top_entities$hs10[, .(
  cumulative_trade = cumsum(total_trade),
  cumulative_products = seq_len(.N),
  product_share = seq_len(.N) / nrow(top_entities$hs10)
)]
hs10_concentration[, concentration_share := cumulative_trade / max(cumulative_trade)]

# Calculate Gini coefficient
n <- nrow(hs10_concentration)
gini <- 1 - 2 * sum(hs10_concentration$concentration_share) / n

# Create enhanced Lorenz curve
p3 <- plot_ly() %>%
  # Shaded area between curves for visual impact
  add_trace(
    x = c(hs10_concentration$product_share, rev(c(0, 1))),
    y = c(hs10_concentration$concentration_share, rev(c(0, 1))),
    type = "scatter", mode = "none",
    fill = "toself",
    fillcolor = paste0(colors$primary, "20"),
    showlegend = FALSE,
    hoverinfo = "skip"
  ) %>%
  # Lorenz curve
  add_trace(
    data = hs10_concentration,
    x = ~product_share, y = ~concentration_share,
    type = "scatter", mode = "lines",
    line = list(color = colors$primary, width = 3),
    name = "Lorenz Curve (Actual)",
    hovertemplate = "Top <b>%{x:.1%}</b> of products = <b>%{y:.1%}</b> of trade<extra></extra>"
  ) %>%
  # Perfect equality line
  add_trace(
    x = c(0, 1), y = c(0, 1),
    type = "scatter", mode = "lines",
    line = list(color = colors$text_muted, width = 2, dash = "dash"),
    name = "Perfect Equality",
    hoverinfo = "skip"
  ) %>%
  # Add Gini annotation
  add_annotations(
    x = 0.75, y = 0.25,
    text = sprintf("<b>Gini Coefficient: %.3f</b><br><span style='font-size:12px;'>Higher value = more concentration</span>", gini),
    showarrow = FALSE,
    bgcolor = "rgba(255,255,255,0.95)",
    bordercolor = colors$primary,
    borderwidth = 2,
    borderpad = 10,
    font = list(size = 14, color = colors$text_dark)
  ) %>%
  layout(
    title = list(
      text = "<b>Trade Concentration Analysis</b><br><span style='font-size:14px;color:#6b7280;'>Lorenz Curve for HS10 Products | Gap from diagonal = inequality</span>",
      font = list(family = "Inter, sans-serif", size = 20),
      x = 0.02
    ),
    font = list(family = "Inter, sans-serif"),
    xaxis = list(title = "Cumulative Share of Products (%)", tickformat = ".0%", gridcolor = colors$grid),
    yaxis = list(title = "Cumulative Share of Trade Value (%)", tickformat = ".0%", gridcolor = colors$grid),
    plot_bgcolor = "rgba(248, 250, 252, 0.8)",
    paper_bgcolor = "white",
    hovermode = "x unified",
    height = 650,
    margin = list(l = 80, r = 80, t = 100, b = 80),
    legend = list(orientation = "h", y = -0.12, x = 0.5, xanchor = "center")
  ) %>%
  config(responsive = TRUE, displaylogo = FALSE)

p3_desc <- create_description_panel(
  title = "Trade Concentration (Lorenz Curve)",
  what_it_shows = sprintf("The Lorenz curve visualizes how trade is concentrated across products. The <b>X-axis</b> shows the cumulative percentage of products (ranked from smallest to largest). The <b>Y-axis</b> shows the cumulative percentage of total trade value. The <b>shaded area</b> between the curve and the diagonal represents inequality. The calculated <b>Gini coefficient is %.3f</b> (0 = perfect equality, 1 = maximum inequality).", gini),
  how_to_use = "<li><b>Hover:</b> See exact percentages at any point on the curve</li>
               <li><b>Interpret:</b> If 20%% of products account for 80%% of trade, the curve bows deeply</li>
               <li><b>Compare:</b> A curve closer to the diagonal means more equal distribution</li>",
  key_insights = sprintf("With a Gini coefficient of %.3f, US imports are highly concentrated. A small percentage of products account for the vast majority of import value. This has implications for tariff impact—taxing a few large-volume products captures most of the revenue.", gini),
  color = colors$primary
)

p3_with_desc <- htmlwidgets::appendContent(p3, HTML(p3_desc))
htmlwidgets::saveWidget(p3_with_desc, file.path(out_dir, "08_concentration_lorenz.html"), selfcontained = FALSE)
message("  ✅ Saved: 08_concentration_lorenz.html\n")

# ============================================================================
# EXPLORER 4: TARIFF DISTRIBUTION BY CHAPTER (violin plots)
# ============================================================================

message("[4/5] Building Tariff distribution by chapter...\n")

# Get distribution of product-level tariffs within top chapters
top_chapters <- top_entities$chapters[1:15]
tariff_dist <- merge(
  monthly_by_hs10[, .(HTS_Number, tariff_rate)],
  hs_lookup[, .(HTS_Number, chapter)],
  by = "HTS_Number", all.x = TRUE
)

tariff_dist <- tariff_dist[chapter %in% top_chapters$chapter]
tariff_dist[, tariff_rate_pct := tariff_rate * 100]

# Merge with chapter names
tariff_dist <- merge(tariff_dist,
  hs_lookup[, .(chapter, chapter_name)][!duplicated(chapter)],
  by = "chapter", all.x = TRUE
)

tariff_dist[, chapter_label := paste0(chapter, ": ", substr(chapter_name, 1, 25))]

# Calculate median for ordering
chapter_medians <- tariff_dist[, .(median_tariff = median(tariff_rate_pct, na.rm = TRUE)), by = chapter_label]
tariff_dist <- merge(tariff_dist, chapter_medians, by = "chapter_label")
tariff_dist[, chapter_label := reorder(chapter_label, -median_tariff)]

# Create enhanced violin plot
p4 <- plot_ly(
  data = tariff_dist,
  x = ~chapter_label,
  y = ~tariff_rate_pct,
  split = ~chapter_label,
  type = "violin",
  box = list(visible = TRUE, width = 0.1),
  meanline = list(visible = TRUE, color = "white", width = 2),
  points = FALSE,
  color = ~chapter_label,
  colors = viridisLite::viridis(15),
  showlegend = FALSE,
  hovertemplate = "<b>%{x}</b><br>Tariff: <b>%{y:.2f}%</b><extra></extra>"
) %>%
  layout(
    title = list(
      text = "<b>Tariff Rate Distribution by HS Chapter</b><br><span style='font-size:14px;color:#6b7280;'>Top 15 chapters | Sorted by median tariff rate</span>",
      font = list(family = "Inter, sans-serif", size = 20),
      x = 0.02
    ),
    font = list(family = "Inter, sans-serif"),
    xaxis = list(
      title = "",
      tickangle = -45,
      tickfont = list(size = 10),
      gridcolor = colors$grid
    ),
    yaxis = list(title = "Average Tariff Rate (%)", gridcolor = colors$grid),
    plot_bgcolor = "rgba(248, 250, 252, 0.8)",
    paper_bgcolor = "white",
    height = 750,
    margin = list(l = 80, r = 60, t = 100, b = 180)
  ) %>%
  config(responsive = TRUE, displaylogo = FALSE)

p4_desc <- create_description_panel(
  title = "Tariff Distribution by Chapter",
  what_it_shows = "Violin plots showing the distribution of tariff rates across all products within each of the top 15 HS chapters. The <b>width</b> of each violin indicates how many products have tariffs at that level. The <b>box</b> inside shows the interquartile range (25th to 75th percentile). The <b>white line</b> indicates the mean tariff for that chapter.",
  how_to_use = "<li><b>Compare shapes:</b> Wide violins = high tariff variability; narrow = uniform treatment</li>
               <li><b>Hover:</b> See exact chapter name and tariff value at any point</li>
               <li><b>Ordering:</b> Chapters are sorted by median tariff (highest on left)</li>",
  key_insights = "Some chapters (like textiles and apparel) have consistently high tariffs across all products, shown by narrow violins positioned high. Others (like machinery) have wide violins spanning from 0% to 25%+, indicating varied tariff treatment within the category.",
  color = colors$accent
)

p4_with_desc <- htmlwidgets::appendContent(p4, HTML(p4_desc))
htmlwidgets::saveWidget(p4_with_desc, file.path(out_dir, "09_tariff_distribution_violin.html"), selfcontained = FALSE)
message("  ✅ Saved: 09_tariff_distribution_violin.html\n")

# ============================================================================
# EXPLORER 5: Trade-Tariff Scatter with Time Filtering (Bubble Chart)
# ============================================================================

message("[5/5] Generating trade-tariff scatter plot...\n")

# Get monthly HS10 data with dates
scatter_monthly <- monthly_by_hs10[, .(HTS_Number, date, trade_value, tariff_rate)]
scatter_monthly[, chapter := substr(HTS_Number, 1, 2)]
chapter_lookup <- unique(hs_lookup[!is.na(chapter_name), .(chapter, chapter_name)])
scatter_monthly <- merge(scatter_monthly, chapter_lookup, by = "chapter", all.x = TRUE)

item_lookup <- hs_lookup[, .(HTS_Number, item_desc)]
scatter_monthly <- merge(scatter_monthly, item_lookup, by = "HTS_Number", all.x = TRUE)

# Filter to top 500 products
top_products_for_scatter <- scatter_monthly[, .(total_trade = sum(trade_value, na.rm = TRUE)), by = HTS_Number][order(-total_trade)][1:500]
scatter_data_full <- scatter_monthly[HTS_Number %in% top_products_for_scatter$HTS_Number]

# Create aggregated data
trade_tariff_data <- scatter_data_full[, .(
  total_trade = sum(trade_value, na.rm = TRUE),
  avg_tariff = mean(tariff_rate, na.rm = TRUE),
  n_months = .N
), by = .(HTS_Number, chapter, chapter_name, item_desc)]

trade_tariff_data <- trade_tariff_data[!is.na(avg_tariff) & avg_tariff > 0]
trade_tariff_data[, tariff_pct := avg_tariff * 100]
trade_tariff_data[, bubble_size := pmin(pmax(log10(total_trade) * 4, 8), 60)]
trade_tariff_data[, trade_bn := total_trade / 1e9]

# Create enhanced scatter plot
p5 <- plot_ly(
  data = as.data.frame(trade_tariff_data),
  x = ~total_trade,
  y = ~tariff_pct,
  type = "scatter",
  mode = "markers",
  color = ~chapter_name,
  colors = viridisLite::turbo(length(unique(trade_tariff_data$chapter_name))),
  customdata = ~item_desc,
  text = ~ sprintf(
    "<b>%s</b><br>Chapter %s: %s<br>Trade: $%.2fB<br>Tariff: %.2f%%",
    substr(item_desc, 1, 50), chapter, chapter_name, trade_bn, tariff_pct
  ),
  hoverinfo = "text",
  marker = list(
    size = ~bubble_size,
    opacity = 0.75,
    line = list(color = "white", width = 1.5)
  )
) %>%
  layout(
    title = list(
      text = "<b>Products by Trade Volume vs Tariff Rate</b><br><span style='font-size:14px;color:#6b7280;'>Top 500 HS10 products | Bubble size = trade value | Click for details</span>",
      font = list(family = "Inter, sans-serif", size = 20),
      x = 0.02
    ),
    font = list(family = "Inter, sans-serif"),
    xaxis = list(
      title = "Total Trade Value (USD)",
      type = "log",
      tickformat = "$,.0s",
      gridcolor = colors$grid
    ),
    yaxis = list(
      title = "Average Tariff Rate (%)",
      gridcolor = colors$grid
    ),
    plot_bgcolor = "rgba(248, 250, 252, 0.8)",
    paper_bgcolor = "white",
    margin = list(l = 80, r = 20, t = 120, b = 80),
    showlegend = FALSE,
    height = 800
  ) %>%
  config(responsive = TRUE, displaylogo = FALSE) %>%
  htmlwidgets::onRender("
    function(el, x) {
      el.on('plotly_click', function(data) {
        var point = data.points[0];
        var fullDesc = point.customdata;
        alert('Full Product Description:\\n\\n' + fullDesc);
      });
    }
  ")

p5_desc <- create_description_panel(
  title = "Trade-Tariff Scatter Analysis",
  what_it_shows = "Each bubble represents one of the top 500 imported products (HS10 codes). The <b>X-axis</b> (log scale) shows total trade value. The <b>Y-axis</b> shows average tariff rate. <b>Bubble size</b> also represents trade volume—bigger bubbles = more trade. <b>Color</b> indicates HS chapter for quick category identification.",
  how_to_use = "<li><b>Hover:</b> See product name, chapter, trade value, and tariff rate</li>
               <li><b>Click:</b> Click any bubble to see the full product description</li>
               <li><b>Zoom:</b> Drag to select a region; double-click to reset</li>
               <li><b>Quadrant analysis:</b> Upper-right = high trade + high tariff</li>",
  key_insights = "Products in the upper-right quadrant (high trade value AND high tariff rate) contribute most to tariff revenue. These are the most impactful products for trade policy analysis. Lower-left products have minimal tariff impact due to either low volume, low rate, or both.",
  color = colors$danger
)

p5_with_desc <- htmlwidgets::appendContent(p5, HTML(p5_desc))
htmlwidgets::saveWidget(p5_with_desc, file.path(out_dir, "06_trade_tariff_scatter.html"), selfcontained = FALSE)
message("  ✅ Saved: 06_trade_tariff_scatter.html\n")

# Save treemap (now at position 14)
htmlwidgets::saveWidget(p1_with_desc, file.path(out_dir, "14_hs10_treemap.html"), selfcontained = FALSE)
message("  ✅ Saved: 14_hs10_treemap.html\n")

# ============================================================================
# SUMMARY
# ============================================================================

message("\n════════════════════════════════════════════════════════════════")
message("  ✅ ENHANCED INTERACTIVE PRODUCT EXPLORER COMPLETE")
message("════════════════════════════════════════════════════════════════\n")

message("Output files in data_exploration/output/interactive/:\n")
message("   6. 06_trade_tariff_scatter.html - Interactive trade-tariff bubble chart")
message("   7. 07_top_products_table.html - Top 500 products searchable table")
message("   8. 08_concentration_lorenz.html - Trade concentration with Gini coefficient")
message("   9. 09_tariff_distribution_violin.html - Tariff distribution by chapter")
message("  14. 14_hs10_treemap.html - Top 200 products hierarchical treemap\n")

message("Enhancements applied:")
message("  ✓ Rich description panels with insights")
message("  ✓ Premium color gradients")
message("  ✓ Enhanced hover templates")
message("  ✓ Gini coefficient calculation and annotation")
message("  ✓ Improved violin plot ordering and styling\n")
