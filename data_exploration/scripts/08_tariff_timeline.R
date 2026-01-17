# ════════════════════════════════════════════════════════════════
# TARIFF EVENTS TIMELINE
# ════════════════════════════════════════════════════════════════
# Interactive timeline visualization of Trump administration tariff events
# Shows chronological progression with detailed event information

if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, plotly, lubridate, htmlwidgets)

cat("\n════════════════════════════════════════════════════════════════\n")
cat("  TARIFF EVENTS TIMELINE VISUALIZATION\n")
cat("════════════════════════════════════════════════════════════════\n\n")

# Load tariff events
events_path <- file.path("..", "..", "data", "tariff_events_config.csv")
trump_events <- fread(events_path)
trump_events$date <- dmy(trump_events$date)
setorder(trump_events, date)

# Define category colors
event_colors <- c(
  "China" = "#e74c3c",
  "Mexico/Canada" = "#f39c12",
  "EU" = "#3498db",
  "Sectoral" = "#9b59b6",
  "Retaliation" = "#c0392b",
  "Negotiation" = "#27ae60",
  "Sanctions" = "#34495e"
)

# Assign y-positions alternating to prevent overlap
trump_events$y_pos <- ifelse(seq_len(nrow(trump_events)) %% 2 == 1, 1, 0.5)

# Create base timeline plot
fig <- plot_ly(data = trump_events)

# Add event markers
for (i in seq_len(nrow(trump_events))) {
  event <- trump_events[i, ]
  
  # Get category color
  cat_val <- as.character(event$category)
  if (length(cat_val) == 0 || is.na(cat_val) || cat_val == "") {
    marker_color <- "#999999"
  } else if (cat_val %in% names(event_colors)) {
    marker_color <- event_colors[cat_val]
  } else {
    marker_color <- "#999999"
  }
  
  # Create hover text
  hover_text <- paste0(
    "<b>", event$event_name, "</b><br>",
    "<b>Date:</b> ", format(event$date, "%B %d, %Y"), "<br>",
    "<b>Type:</b> ", event$event_type, "<br>",
    "<b>Category:</b> ", cat_val, "<br>",
    "<b>Details:</b> ", event$description
  )
  
  # Add marker
  fig <- fig %>%
    add_trace(
      type = "scatter",
      mode = "markers+text",
      x = event$date,
      y = event$y_pos,
      marker = list(
        size = 20,
        color = marker_color,
        line = list(width = 2, color = "white")
      ),
      text = event$event_name,
      textposition = ifelse(event$y_pos > 0.7, "top center", "bottom center"),
      textfont = list(size = 10, color = marker_color, family = "Inter, sans-serif"),
      hovertext = hover_text,
      hoverinfo = "text",
      hoverlabel = list(
        bgcolor = "white",
        bordercolor = marker_color,
        font = list(size = 12, family = "Inter, sans-serif")
      ),
      showlegend = FALSE,
      name = ""
    )
  
  # Add connecting line to timeline
  fig <- fig %>%
    add_trace(
      type = "scatter",
      mode = "lines",
      x = c(event$date, event$date),
      y = c(0.25, event$y_pos),
      line = list(color = marker_color, width = 2, dash = "dot"),
      hoverinfo = "none",
      showlegend = FALSE
    )
}

# Add baseline
fig <- fig %>%
  add_trace(
    type = "scatter",
    mode = "lines",
    x = c(min(trump_events$date) - 5, max(trump_events$date) + 5),
    y = c(0.25, 0.25),
    line = list(color = "#34495e", width = 3),
    hoverinfo = "none",
    showlegend = FALSE
  )

# Add category legend
legend_text <- paste0(
  "<b>Event Categories:</b><br>",
  paste(
    sprintf('<span style="color:%s">●</span> %s', event_colors, names(event_colors)),
    collapse = "<br>"
  )
)

# Layout configuration
fig <- fig %>%
  layout(
    title = list(
      text = "<b>Trump Administration Tariff Events Timeline</b><br><sub>February 2025 - May 2025</sub>",
      font = list(size = 24, family = "Inter, sans-serif", color = "#2c3e50"),
      x = 0.5,
      xanchor = "center"
    ),
    xaxis = list(
      title = "",
      showgrid = TRUE,
      gridcolor = "#ecf0f1",
      tickformat = "%b %d, %Y",
      tickfont = list(size = 12, family = "Inter, sans-serif"),
      range = c(min(trump_events$date) - 5, max(trump_events$date) + 5)
    ),
    yaxis = list(
      title = "",
      showticklabels = FALSE,
      showgrid = FALSE,
      zeroline = FALSE,
      range = c(0, 1.3)
    ),
    hovermode = "closest",
    plot_bgcolor = "white",
    paper_bgcolor = "white",
    margin = list(l = 50, r = 50, t = 120, b = 80),
    annotations = list(
      list(
        x = 0.02,
        y = 0.98,
        xref = "paper",
        yref = "paper",
        text = legend_text,
        showarrow = FALSE,
        xanchor = "left",
        yanchor = "top",
        align = "left",
        font = list(size = 11, family = "Inter, sans-serif"),
        bgcolor = "#f8f9fa",
        bordercolor = "#dee2e6",
        borderwidth = 1,
        borderpad = 10
      ),
      list(
        x = 0.5,
        y = -0.15,
        xref = "paper",
        yref = "paper",
        text = paste0(
          "<i>Interactive timeline showing ", nrow(trump_events), " major tariff policy events. ",
          "Hover over markers for detailed information about each event.</i>"
        ),
        showarrow = FALSE,
        xanchor = "center",
        font = list(size = 11, family = "Inter, sans-serif", color = "#7f8c8d")
      )
    )
  ) %>%
  config(
    displayModeBar = TRUE,
    modeBarButtonsToRemove = c("lasso2d", "select2d", "autoScale2d"),
    displaylogo = FALSE
  )

# Save output
output_dir <- file.path("..", "output", "interactive")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_file <- file.path(output_dir, "18_tariff_timeline.html")

saveWidget(
  fig,
  file = normalizePath(output_file, mustWork = FALSE),
  selfcontained = FALSE,
  title = "Tariff Events Timeline"
)

cat("  ✅ Saved: 18_tariff_timeline.html\n\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("  ✅ TARIFF EVENTS TIMELINE COMPLETE\n")
cat("════════════════════════════════════════════════════════════════\n\n")
