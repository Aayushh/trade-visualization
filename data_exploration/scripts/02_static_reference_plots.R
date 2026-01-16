# Enhanced Static Reference Figures for Paper Inclusion
# Purpose: Generate publication-ready static plots (PNG + PDF) with premium aesthetics

options(stringsAsFactors = FALSE)

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, here, scales, patchwork, glue, data.table, showtext, lubridate, arrow)

message("════════════════════════════════════════════════════════════════")
message("  ENHANCED STATIC REFERENCE PLOTS")
message("════════════════════════════════════════════════════════════════\n")

# ============================================================================
# CUSTOM PREMIUM THEME
# ============================================================================

# Add Google Font
font_add_google("Inter", "Inter")
showtext_auto()

# Define color palette
colors <- list(
  primary = "#667eea",
  secondary = "#764ba2",
  accent = "#f59e0b",
  success = "#10b981",
  danger = "#ef4444",
  text_dark = "#1a1a2e",
  text_muted = "#6b7280",
  bg_light = "#f8fafc",
  grid = "#e2e8f0"
)

# Event colors for tariff categories
event_colors <- c(
  "China" = "#ef4444",
  "Mexico-Canada" = "#f59e0b",
  "Steel-Aluminum" = "#10b981",
  "Global" = "#8b5cf6",
  "Biden" = "#6366f1"
)

# Premium ggplot2 theme
theme_premium <- function(base_size = 12) {
  theme_minimal(base_size = base_size, base_family = "Inter") +
    theme(
      # Title and subtitle
      plot.title = element_text(
        face = "bold",
        size = rel(1.3),
        color = colors$text_dark,
        margin = margin(b = 8)
      ),
      plot.subtitle = element_text(
        size = rel(0.95),
        color = colors$text_muted,
        margin = margin(b = 15)
      ),
      plot.caption = element_text(
        size = rel(0.75),
        color = colors$text_muted,
        hjust = 0,
        margin = margin(t = 15)
      ),

      # Axes
      axis.title = element_text(
        size = rel(0.9),
        color = colors$text_dark,
        face = "plain"
      ),
      axis.text = element_text(
        size = rel(0.85),
        color = colors$text_muted
      ),
      axis.line = element_line(color = colors$grid, linewidth = 0.5),

      # Grid
      panel.grid.major = element_line(color = colors$grid, linewidth = 0.3),
      panel.grid.minor = element_blank(),

      # Legend
      legend.title = element_text(face = "bold", size = rel(0.9)),
      legend.text = element_text(size = rel(0.85)),
      legend.background = element_rect(fill = "white", color = NA),
      legend.key = element_rect(fill = "transparent"),

      # Plot background
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = colors$bg_light, color = NA),

      # Margins
      plot.margin = margin(20, 20, 20, 20)
    )
}

# Output directory
out_dir <- here("data_exploration", "output", "static")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Load prepared data
message("Loading prepared data...\n")
monthly_totals <- arrow::read_parquet(here("data", "processed", "monthly_totals.parquet"))
hs10 <- arrow::read_parquet(here("data", "processed", "top_entities_hs10.parquet"))
countries <- arrow::read_parquet(here("data", "processed", "top_entities_countries.parquet"))
chapters <- arrow::read_parquet(here("data", "processed", "top_entities_chapters.parquet"))
top_entities <- list(hs10 = hs10, countries = countries, chapters = chapters)

# Load centralized tariff events config
trump_events <- fread(here("data", "tariff_events_config.csv"), header = FALSE, fill = TRUE)
data.table::setnames(trump_events, c("date", "event_name", "event_type", "description", paste0("extra", 5:13)))
trump_events <- trump_events[date != "date" & !is.na(date) & date != "", .(date, event_name, event_type, description)]
trump_events[, date := lubridate::dmy(date)]
trump_events[, category := fcase(
  grepl("China", event_name, ignore.case = TRUE), "China",
  grepl("Mexico|Canada", event_name, ignore.case = TRUE), "Mexico-Canada",
  grepl("Steel|Alum", event_name, ignore.case = TRUE), "Steel-Aluminum",
  grepl("India", event_name, ignore.case = TRUE), "India",
  grepl("Vietnam|Indonesia|Korea|Brazil", event_name, ignore.case = TRUE), "Bilateral",
  default = "Global"
)]

setDT(monthly_totals)
setDT(trump_events)

# ============================================================================
# PLOT 1: MONTHLY US TOTAL IMPORTS (with Trump event markers)
# ============================================================================

message("Generating Plot 1: Monthly US Imports (Enhanced)...\n")

# Convert trade value to billions
monthly_totals[, trade_value_bn := trade_value / 1e9]

# Create event lines data (select major events for clarity)
major_events <- trump_events[!grepl("Deal|Agreement", event_type)][1:8]  # First 8 major tariff changes

# Calculate statistics for annotation
avg_imports <- mean(monthly_totals$trade_value_bn, na.rm = TRUE)
max_imports <- max(monthly_totals$trade_value_bn, na.rm = TRUE)
max_date <- monthly_totals$date[which.max(monthly_totals$trade_value_bn)]

p1 <- ggplot(monthly_totals, aes(x = date, y = trade_value_bn)) +
  # Shaded area under curve
  geom_area(fill = colors$primary, alpha = 0.15) +
  # Event markers (vertical lines)
  geom_vline(
    data = major_events, aes(xintercept = date, color = category),
    linetype = "dashed", alpha = 0.7, linewidth = 0.6
  ) +
  # Event labels
  geom_text(
    data = major_events,
    aes(x = date, y = max_imports * 0.95, label = substr(event_name, 1, 15), color = category),
    angle = 90, hjust = 1, vjust = -0.3, size = 2.5, fontface = "bold", alpha = 0.8
  ) +
  # Average line
  geom_hline(
    yintercept = avg_imports, linetype = "dotted",
    color = colors$text_muted, linewidth = 0.5
  ) +
  # Main line chart with gradient effect (approximated with multiple layers)
  geom_line(color = colors$primary, linewidth = 1.5, lineend = "round") +
  geom_point(color = colors$primary, size = 2.5, fill = "white", shape = 21, stroke = 1.5) +
  # Annotation for average
  annotate("text",
    x = min(monthly_totals$date) + 30, y = avg_imports + 2,
    label = paste0("Average: $", round(avg_imports, 1), "B"),
    hjust = 0, size = 3, color = colors$text_muted, fontface = "italic"
  ) +
  # Labels and scales
  scale_y_continuous(
    labels = dollar_format(prefix = "$", suffix = "B"),
    breaks = pretty_breaks(n = 8),
    expand = expansion(mult = c(0.02, 0.1))
  ) +
  scale_x_date(date_labels = "%b\n%Y", date_breaks = "2 months") +
  scale_color_manual(
    values = event_colors,
    name = "Tariff Event Category"
  ) +
  labs(
    title = "Monthly US Imports",
    subtitle = "January 2024 – August 2025 | Dashed lines indicate major tariff implementation dates",
    x = NULL,
    y = "Import Value (Billions USD)",
    caption = "Source: US International Trade Commission (USITC) | Visualization: Trade Data Analysis Suite"
  ) +
  theme_premium() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = rel(0.8)),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box = "horizontal"
  ) +
  guides(color = guide_legend(nrow = 1, title.position = "left"))

# Save PNG and PDF at higher quality
ggsave(file.path(out_dir, "monthly_imports.png"), p1,
  width = 12, height = 7, dpi = 300, bg = "white"
)
ggsave(file.path(out_dir, "monthly_imports.pdf"), p1,
  width = 12, height = 7, device = cairo_pdf
)

message("  ✅ Saved: monthly_imports.png/.pdf\n")

# ============================================================================
# PLOT 2: TOP 30 HS CHAPTERS BY TRADE VALUE
# ============================================================================

message("Generating Plot 2: Top HS Chapters (Enhanced)...\n")

# Get top 30 chapters with names
top30_chapters <- top_entities$chapters[1:30]
top30_chapters[, chapter_label := paste0(
  "Ch.", chapter, ": ",
  ifelse(nchar(chapter_name) > 40,
    paste0(substr(chapter_name, 1, 37), "..."),
    chapter_name
  )
)]
top30_chapters[, trade_bn := total_trade / 1e9]
top30_chapters[, avg_tariff_pct := avg_tariff * 100]

# Reorder for plotting
top30_chapters[, chapter_label := fct_reorder(chapter_label, trade_bn)]

# Custom color scale - using a refined blue-purple-red gradient
p2 <- ggplot(top30_chapters, aes(x = trade_bn, y = chapter_label, fill = avg_tariff_pct)) +
  geom_col(width = 0.8) +
  # Add value labels
  geom_text(aes(label = paste0("$", round(trade_bn, 1), "B")),
    hjust = -0.1, size = 2.8, color = colors$text_muted
  ) +
  scale_fill_gradientn(
    colors = c("#667eea", "#8b5cf6", "#ec4899", "#ef4444"),
    name = "Avg Tariff\nRate (%)",
    labels = function(x) paste0(round(x, 1), "%")
  ) +
  scale_x_continuous(
    labels = dollar_format(prefix = "$", suffix = "B"),
    breaks = pretty_breaks(n = 5),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = "Top 30 HS Chapters by Total Import Value",
    subtitle = "January 2024 – August 2025 | Bar color indicates average tariff rate",
    x = "Total Import Value (Billions USD)",
    y = NULL,
    caption = "Source: USITC | HS Chapter = 2-digit Harmonized Schedule product category"
  ) +
  theme_premium() +
  theme(
    axis.text.y = element_text(size = rel(0.8)),
    legend.position = "right",
    panel.grid.major.y = element_blank()
  )

# Save
ggsave(file.path(out_dir, "top_chapters.png"), p2,
  width = 13, height = 10, dpi = 300, bg = "white"
)
ggsave(file.path(out_dir, "top_chapters.pdf"), p2,
  width = 13, height = 10, device = cairo_pdf
)

message("  ✅ Saved: top_chapters.png/.pdf\n")

# ============================================================================
# PLOT 3: TOP 30 COUNTRIES BY TRADE VALUE
# ============================================================================

message("Generating Plot 3: Top Countries (Enhanced)...\n")

# Get top 30 countries
top30_countries <- top_entities$countries[1:30]
top30_countries[, trade_bn := total_trade / 1e9]
top30_countries[, avg_tariff_pct := avg_tariff * 100]
top30_countries[, Country := fct_reorder(Country, trade_bn)]

# Flag specific countries for annotation (high tariff countries)
high_tariff_cutoff <- quantile(top30_countries$avg_tariff_pct, 0.75)

p3 <- ggplot(top30_countries, aes(x = trade_bn, y = Country)) +
  geom_col(aes(fill = avg_tariff_pct), width = 0.8) +
  # Add value labels
  geom_text(aes(label = paste0("$", round(trade_bn, 1), "B")),
    hjust = -0.1, size = 2.8, color = colors$text_muted
  ) +
  # Highlight high-tariff countries with a symbol
  geom_point(
    data = top30_countries[avg_tariff_pct >= high_tariff_cutoff],
    aes(x = trade_bn + max(trade_bn) * 0.12),
    shape = "★", size = 3, color = colors$danger
  ) +
  scale_fill_gradientn(
    colors = c("#10b981", "#22d3ee", "#8b5cf6", "#ef4444"),
    name = "Avg Tariff\nRate (%)",
    labels = function(x) paste0(round(x, 1), "%")
  ) +
  scale_x_continuous(
    labels = dollar_format(prefix = "$", suffix = "B"),
    breaks = pretty_breaks(n = 5),
    expand = expansion(mult = c(0, 0.18))
  ) +
  labs(
    title = "Top 30 Trading Partners by US Import Value",
    subtitle = "January 2024 – August 2025 | ★ = Top 25% tariff rate | Color = average tariff",
    x = "Total Import Value (Billions USD)",
    y = NULL,
    caption = "Source: USITC | Trade values are FOB (Free on Board)"
  ) +
  theme_premium() +
  theme(
    axis.text.y = element_text(size = rel(0.9)),
    legend.position = "right",
    panel.grid.major.y = element_blank()
  )

# Save
ggsave(file.path(out_dir, "top_countries.png"), p3,
  width = 11, height = 10, dpi = 300, bg = "white"
)
ggsave(file.path(out_dir, "top_countries.pdf"), p3,
  width = 11, height = 10, device = cairo_pdf
)

message("  ✅ Saved: top_countries.png/.pdf\n")

# ============================================================================
# SUMMARY
# ============================================================================

message("\n════════════════════════════════════════════════════════════════")
message("  ✅ ENHANCED STATIC REFERENCE PLOTS COMPLETE")
message("════════════════════════════════════════════════════════════════\n")

message("Output files in data_exploration/output/static/:\n")
message("  1. monthly_imports.png/.pdf    - Monthly US imports with event markers")
message("  2. top_chapters.png/.pdf       - Top 30 HS chapters with tariff coloring")
message("  3. top_countries.png/.pdf      - Top 30 countries with tariff indicators\n")

message("Enhancements applied:")
message("  ✓ Premium Inter font styling")
message("  ✓ Refined color gradients")
message("  ✓ Value labels and annotations")
message("  ✓ High-tariff country indicators")
message("  ✓ Area fill and average line on time series\n")
