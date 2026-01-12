options(stringsAsFactors = FALSE)

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, here, scales, plotly, data.table, jsonlite)

message("════════════════════════════════════════════════════════════════")
message("  COUNTRY DASHBOARD WITH DATE RANGE FILTER")
message("════════════════════════════════════════════════════════════════\n")

# Output directory
out_dir <- here("data_exploration", "output", "interactive")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Load prepared data
message("Loading prepared data...\n")
monthly_by_country <- arrow::read_parquet(here("data", "processed", "monthly_by_country.parquet"))
hs10 <- arrow::read_parquet(here("data", "processed", "top_entities_hs10.parquet"))
countries <- arrow::read_parquet(here("data", "processed", "top_entities_countries.parquet"))
chapters <- arrow::read_parquet(here("data", "processed", "top_entities_chapters.parquet"))
top_entities <- list(hs10 = hs10, countries = countries, chapters = chapters)

setDT(monthly_by_country)

# Load centralized tariff events config
trump_events <- fread(here("data", "tariff_events_config.csv"))
trump_events[, date := as.Date(date)]
setDT(trump_events)

# Get date range
min_date <- min(monthly_by_country$date)
max_date <- max(monthly_by_country$date)

message(sprintf("Building interactive dashboard (dates: %s to %s)...\n",
                format(min_date, "%b %Y"), format(max_date, "%b %Y")))

# Create interactive HTML with date range filter
html_content <- sprintf('
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Country Dashboard with Date Filter</title>
  <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; background: #f5f7fb; }
    .controls { background: white; padding: 15px; border-radius: 8px; margin-bottom: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .controls label { margin-right: 10px; font-weight: bold; }
    .controls input { padding: 5px; margin-right: 20px; }
    #plotDiv { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    h1 { color: #4455aa; }
    .info { color: #666; font-size: 0.9em; margin-top: 10px; }
  </style>
</head>
<body>
  <h1>Country Trading Dashboard</h1>
  <p>X: Average Sea Distance (km) | Y: Average Tariff Rate (%%%%) | Bubble Size: Total Trade Value</p>
  
  <div class="controls">
    <label>Start Date:</label>
    <input type="date" id="startDate" value="%s" min="%s" max="%s">
    
    <label>End Date:</label>
    <input type="date" id="endDate" value="%s" min="%s" max="%s">
    
    <button onclick="updatePlot()" style="padding: 6px 15px; background: #4455aa; color: white; border: none; border-radius: 4px; cursor: pointer;">Update</button>
    <span class="info" id="dateRange"></span>
  </div>
  
  <div id="plotDiv" style="width: 100%%%%; height: 700px;"></div>
  
  <script>
    const allCountries = %s;
    const trumpEvents = %s;
    
    function updatePlot() {
      const startDate = new Date(document.getElementById("startDate").value);
      const endDate = new Date(document.getElementById("endDate").value);
      
      // Filter countries by date range
      const filtered = allCountries.filter(c => {
        const d = new Date(c.date);
        return d >= startDate && d <= endDate;
      });
      
      // Aggregate by country
      const grouped = {};
      filtered.forEach(c => {
        if (!grouped[c.Country]) {
          grouped[c.Country] = {
            Country: c.Country,
            total_trade_bn: 0,
            avg_tariff_pct: [],
            avg_distance_km: []
          };
        }
        grouped[c.Country].total_trade_bn += c.total_trade_bn;
        grouped[c.Country].avg_tariff_pct.push(c.avg_tariff_pct);
        grouped[c.Country].avg_distance_km.push(c.avg_distance_km);
      });
      
      const plotData = Object.values(grouped).map(c => ({
        ...c,
        avg_tariff_pct: c.avg_tariff_pct.reduce((a,b) => a+b) / c.avg_tariff_pct.length,
        avg_distance_km: c.avg_distance_km.reduce((a,b) => a+b) / c.avg_distance_km.length
      }));
      
      // Create Plotly trace
      const trace = {
        x: plotData.map(d => d.avg_distance_km),
        y: plotData.map(d => d.avg_tariff_pct),
        mode: "markers",
        type: "scatter",
        text: plotData.map(d => d.Country),
        marker: {
          size: plotData.map(d => Math.sqrt(d.total_trade_bn) * 5),
          color: plotData.map(d => d.avg_tariff_pct),
          colorscale: "Plasma",
          showscale: true,
          colorbar: { title: "Tariff (%%%%" },
          line: { color: "white", width: 1 },
          opacity: 0.7
        },
        customdata: plotData.map(d => d.total_trade_bn),
        hovertemplate: "<b>%%{text}</b><br>Distance: %%{x:.0f} km<br>Tariff: %%{y:.2f}%%%%<br>Trade: $%%{customdata:.1f}B<extra></extra>"
      };
      
      // Add event lines
      const shapes = trumpEvents.map(e => ({
        type: "line",
        xref: "paper", yref: "paper",
        x0: 0.1, x1: 0.9, y0: 0.5, y1: 0.5,
        line: { color: "#d62728", width: 2, dash: "dash" }
      }));
      
      const layout = {
        title: "Country Trading Dashboard (Distance vs Tariff Rate)",
        xaxis: { title: "Average Sea Distance (km)" },
        yaxis: { title: "Average Tariff Rate (%%%%)" },
        height: 600,
        hovermode: "closest",
        plot_bgcolor: "rgba(240,240,240,0.5)",
        template: "plotly_white",
        margin: { l: 80, r: 80, t: 100, b: 80 }
      };
      
      Plotly.newPlot("plotDiv", [trace], layout);
      document.getElementById("dateRange").innerText = `(${startDate.toLocaleDateString()} to ${endDate.toLocaleDateString()})`;
    }
    
    // Initial plot
    updatePlot();
  </script>
</body>
</html>
',
  format(min_date, "%Y-%m-%d"), format(min_date, "%Y-%m-%d"), format(max_date, "%Y-%m-%d"),
  format(max_date, "%Y-%m-%d"), format(min_date, "%Y-%m-%d"), format(max_date, "%Y-%m-%d"),
  jsonlite::toJSON(monthly_by_country[, .(Country, date = format(date, "%Y-%m-%d"), 
                                           total_trade_bn = trade_value/1e9,
                                           avg_tariff_pct = avg_rate_total*100,
                                           avg_distance_km = avg_seadistance)]),
  jsonlite::toJSON(trump_events[, .(date, event_name)])
)

writeLines(html_content, file.path(out_dir, "10_country_dashboard.html"))
message("  ✅ Saved: 10_country_dashboard.html (with date range filter)\n")
