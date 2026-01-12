# Interactive Geographic & Relationship Explorer
# Purpose: Country dashboard, partner networks, distance effects, tariff distributions

options(stringsAsFactors = FALSE)

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, here, scales, plotly, data.table, htmlwidgets)

message("════════════════════════════════════════════════════════════════")
message("  INTERACTIVE GEOGRAPHIC & RELATIONSHIP EXPLORER")
message("════════════════════════════════════════════════════════════════\n")

# Output directory
out_dir <- here("data_exploration", "output", "interactive")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Load prepared data
message("Loading prepared data...\n")
monthly_by_country <- arrow::read_parquet(here("data", "processed", "monthly_by_country.parquet"))
monthly_by_chapter <- arrow::read_parquet(here("data", "processed", "monthly_by_chapter.parquet"))
hs10 <- arrow::read_parquet(here("data", "processed", "top_entities_hs10.parquet"))
countries <- arrow::read_parquet(here("data", "processed", "top_entities_countries.parquet"))
chapters <- arrow::read_parquet(here("data", "processed", "top_entities_chapters.parquet"))
top_entities <- list(hs10 = hs10, countries = countries, chapters = chapters)
hs_lookup <- arrow::read_parquet(here("data", "processed", "hs_lookup.parquet"))

setDT(monthly_by_country)
setDT(monthly_by_chapter)
setDT(hs_lookup)

# Load centralized tariff events config
trump_events <- fread(here("data", "tariff_events_config.csv"))
trump_events[, date := as.Date(date)]
setDT(trump_events)

# ============================================================================
# EXPLORER 1: COUNTRY DASHBOARD (Value-Tariff scatter with distance)
# ============================================================================

message("Building Explorer 1: Country dashboard...\n")

# Get top 100 countries summary
top_100_countries <- top_entities$countries[1:100]
top_100_countries[, total_trade_bn := total_trade / 1e9]
top_100_countries[, avg_tariff_pct := avg_tariff * 100]

# Derive average sea distance per country from monthly data
country_distance <- monthly_by_country[, .(avg_seadistance = mean(avg_seadistance, na.rm = TRUE)), by = Country]
top_100_countries <- merge(top_100_countries, country_distance, by = "Country", all.x = TRUE)
top_100_countries[, avg_distance_km := avg_seadistance]

# Create scatter: x distance, y avg tariff, bubble size trade value
p1 <- plot_ly(
  data = top_100_countries,
  x = ~avg_distance_km, y = ~avg_tariff_pct,
  text = ~Country,
  mode = "markers",
  type = "scatter",
  marker = list(
    size = ~ pmax(sqrt(total_trade_bn / max(total_trade_bn, na.rm = TRUE)) * 80, 15),
    color = ~avg_tariff_pct,
    colorscale = list(c(0, "#22c55e"), c(0.5, "#eab308"), c(1, "#ef4444")),
    colorbar = list(title = "Avg Tariff (%)", thickness = 15),
    line = list(color = "white", width = 2),
    opacity = 0.85,
    sizemode = "diameter"
  ),
  hovertemplate = "<b>%{text}</b><br>Distance: %{x:.0f} km<br>Avg Tariff: %{y:.2f}%<br>Trade: $%{customdata:.1f}B<extra></extra>",
  customdata = ~total_trade_bn
) %>%
  layout(
    title = list(text = "<b>Country Distance vs Avg Tariff Rate</b><br><span style='font-size:13px;color:#6b7280;'>Bubble size = Total Trade Value | Color = Tariff Rate</span>"),
    xaxis = list(title = "Average Sea Distance (km)", gridcolor = "#e2e8f0"),
    yaxis = list(title = "Average Tariff Rate (%)", gridcolor = "#e2e8f0"),
    plot_bgcolor = "rgba(248, 250, 252, 0.8)",
    paper_bgcolor = "white",
    hovermode = "closest",
    height = 700,
    margin = list(l = 80, r = 100, t = 100, b = 80)
  ) %>%
  add_annotations(
    x = 0.02, xref = "paper",
    y = 0.98, yref = "paper",
    text = "🟢 Low tariff → 🟡 Medium → 🔴 High tariff<br>Larger bubble = More trade",
    showarrow = FALSE,
    bgcolor = "rgba(255,255,255,0.9)",
    bordercolor = "#e2e8f0",
    borderwidth = 1,
    font = list(size = 11)
  ) %>%
  config(responsive = TRUE, displaylogo = FALSE)

htmlwidgets::saveWidget(p1, file.path(out_dir, "10_country_dashboard.html"), selfcontained = FALSE)
message("  ✅ Saved: 10_country_dashboard.html\n")

# ============================================================================
# EXPLORER 2: DISTANCE EFFECT (Near vs Far countries over time)
# ============================================================================

message("Building Explorer 2: Distance effect analysis...\n")

# Get mean distance for segmentation
mean_distance <- monthly_by_country[, mean(avg_seadistance, na.rm = TRUE)]

# Create near/far segments
monthly_by_country[, distance_segment := ifelse(avg_seadistance <= mean_distance, "Near (<=mean)", "Far (>mean)")]
monthly_by_country[, trade_value_bn := trade_value / 1e9]
monthly_by_country[, tariff_rate_pct := avg_rate_total * 100]

# Aggregate by segment
segment_ts <- monthly_by_country[, .(
  trade_value = sum(trade_value, na.rm = TRUE),
  tariff_rate = mean(avg_rate_total, na.rm = TRUE),
  n_countries = uniqueN(Country)
), by = .(date, distance_segment)]

segment_ts[, trade_value_bn := trade_value / 1e9]
segment_ts[, tariff_rate_pct := tariff_rate * 100]

# Create dual-axis plot
ax1 <- list(title = "Trade Value (Billions USD)")
ax2 <- list(
  title = "Tariff Rate (%)",
  overlaying = "y",
  side = "right"
)

p2 <- plot_ly(
  data = segment_ts,
  x = ~date
) %>%
  add_trace(
    data = segment_ts[distance_segment == "Near (<=mean)"],
    y = ~trade_value_bn,
    type = "scatter", mode = "lines",
    name = "Near: Trade Value",
    line = list(color = "#1f77b4", width = 3)
  ) %>%
  add_trace(
    data = segment_ts[distance_segment == "Far (>mean)"],
    y = ~trade_value_bn,
    type = "scatter", mode = "lines",
    name = "Far: Trade Value",
    line = list(color = "#ff7f0e", width = 3, dash = "dash")
  ) %>%
  add_trace(
    data = segment_ts[distance_segment == "Near (<=mean)"],
    y = ~tariff_rate_pct,
    yaxis = "y2",
    type = "scatter", mode = "lines",
    name = "Near: Tariff Rate",
    line = list(color = "#2ca02c", width = 2),
    opacity = 0.6
  ) %>%
  add_trace(
    data = segment_ts[distance_segment == "Far (>mean)"],
    y = ~tariff_rate_pct,
    yaxis = "y2",
    type = "scatter", mode = "lines",
    name = "Far: Tariff Rate",
    line = list(color = "#d62728", width = 2, dash = "dash"),
    opacity = 0.6
  ) %>%
  layout(
    title = list(text = "Distance Effect: Near vs Far Countries<br><sub>Jan 2024 - Aug 2025</sub>"),
    xaxis = list(title = "Date"),
    yaxis = ax1,
    yaxis2 = ax2,
    plot_bgcolor = "rgba(240,240,240,0.5)",
    hovermode = "x unified",
    template = "plotly_white",
    height = 600,
    margin = list(l = 80, r = 80, t = 100, b = 80)
  ) %>%
  config(responsive = TRUE)

htmlwidgets::saveWidget(p2, file.path(out_dir, "11_distance_effect.html"), selfcontained = FALSE)
message("  ✅ Saved: 11_distance_effect.html\n")

# ============================================================================
# EXPLORER 3: TOP 20 COUNTRIES HEATMAP (Trade value by month)
# ============================================================================

message("Building Explorer 3: Countries heatmap...\n")

# Get top 20 countries
top_20_countries <- top_entities$countries[1:20]

# Filter monthly data for top countries
heatmap_data <- monthly_by_country[Country %in% top_20_countries$Country]
heatmap_data[, trade_value_bn := trade_value / 1e9]

# Pivot for heatmap
heatmap_pivot <- heatmap_data[, .(trade_value = sum(trade_value, na.rm = TRUE)),
  by = .(Country, date)
]
heatmap_pivot[, trade_value_bn := trade_value / 1e9]
heatmap_pivot[, month := format(date, "%b %Y")]

# Create heatmap
p3 <- plot_ly(
  z = ~trade_value_bn,
  x = ~month,
  y = ~ reorder(Country, trade_value_bn, FUN = max),
  type = "heatmap",
  colorscale = "Viridis",
  hovertemplate = "<b>%{y}</b> | %{x}<br>Trade: $%{z:.1f}B<extra></extra>",
  data = heatmap_pivot[order(date)]
) %>%
  layout(
    title = list(text = "Monthly Import Value Heatmap<br><sub>Top 20 countries (Jan 2024 - Aug 2025)</sub>"),
    xaxis = list(title = "Month"),
    yaxis = list(title = "Country"),
    height = 700,
    margin = list(l = 120, r = 60, t = 100, b = 100)
  ) %>%
  config(responsive = TRUE)

htmlwidgets::saveWidget(p3, file.path(out_dir, "12_countries_heatmap.html"), selfcontained = FALSE)
message("  ✅ Saved: 12_countries_heatmap.html\n")

# ============================================================================
# EXPLORER 4: TARIFF RATE HISTOGRAM BY COUNTRY ORIGIN
# ============================================================================

message("Building Explorer 4: Tariff distribution by country...\n")

# Get tariff distribution for top 15 countries
tariff_by_country <- monthly_by_country[Country %in% top_entities$countries[1:15]$Country]
tariff_by_country[, tariff_rate_pct := avg_rate_total * 100]

# Create histogram with density curves
p4 <- plot_ly(
  data = tariff_by_country,
  x = ~tariff_rate_pct,
  color = ~Country,
  type = "histogram",
  nbinsx = 30,
  opacity = 0.5,
  hovertemplate = "Tariff: %{x:.2f}%<br>Count: %{y}<extra></extra>"
) %>%
  layout(
    title = list(text = "Tariff Rate Distribution by Country of Origin<br><sub>Top 15 countries</sub>"),
    xaxis = list(title = "Tariff Rate (%)"),
    yaxis = list(title = "Frequency (months)"),
    barmode = "overlay",
    plot_bgcolor = "rgba(240,240,240,0.5)",
    template = "plotly_white",
    height = 600,
    margin = list(l = 80, r = 80, t = 100, b = 80),
    showlegend = TRUE,
    legend = list(
      orientation = "v",
      yanchor = "top",
      y = 0.99,
      xanchor = "right",
      x = 0.99
    )
  ) %>%
  config(responsive = TRUE)

htmlwidgets::saveWidget(p4, file.path(out_dir, "13_tariff_distribution_by_country.html"), selfcontained = FALSE)
message("  ✅ Saved: 13_tariff_distribution_by_country.html\n")

# ============================================================================
# SUMMARY
# ============================================================================

message("\n════════════════════════════════════════════════════════════════")
message("  ✅ INTERACTIVE GEOGRAPHIC & RELATIONSHIP EXPLORER COMPLETE")
message("════════════════════════════════════════════════════════════════\n")

message("Output files in data_exploration/output/interactive/:\n")
message("  10. 10_country_dashboard.html - Countries by value, tariff, distance\n")
message("  11. 11_distance_effect.html - Near vs Far country comparison\n")
message("  12. 12_countries_heatmap.html - Monthly trade heatmap (top 20 countries)\n")
message("  13. 13_tariff_distribution_by_country.html - Tariff distribution by origin\n")
