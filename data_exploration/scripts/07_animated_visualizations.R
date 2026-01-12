# Animated Trade Evolution Visualizations
# Purpose: Create animated visualizations showing monthly evolution of trade and tariffs
# Features: ISO code toggle (2-digit only), dramatic music, continent colors, speed controls

options(stringsAsFactors = FALSE)

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, here, scales, plotly, data.table, htmlwidgets, htmltools)

message("════════════════════════════════════════════════════════════════")
message("  ANIMATED TRADE EVOLUTION VISUALIZATIONS")
message("════════════════════════════════════════════════════════════════\n")

# Output directory
out_dir <- here("data_exploration", "output", "interactive")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Colors
colors <- list(primary = "#667eea", secondary = "#764ba2", accent = "#f59e0b", success = "#10b981", danger = "#ef4444")

# ISO 2-digit country code mapping
iso_codes <- data.table(
    Country = c(
        "China", "Japan", "Korea, South", "Taiwan", "Vietnam", "Thailand", "India", "Indonesia",
        "Malaysia", "Philippines", "Bangladesh", "Singapore", "Germany", "United Kingdom", "France",
        "Italy", "Netherlands", "Ireland", "Switzerland", "Belgium", "Spain", "Sweden", "Poland",
        "Austria", "Mexico", "Canada", "Brazil", "Colombia", "Chile", "Peru", "Argentina", "Australia",
        "New Zealand", "South Africa", "Israel", "Saudi Arabia", "United Arab Emirates", "Turkey",
        "Russia", "Norway", "Denmark", "Finland", "Portugal", "Czech Republic", "Hungary", "Greece",
        "Egypt", "Nigeria", "Kenya", "Morocco", "Pakistan"
    ),
    ISO = c(
        "CN", "JP", "KR", "TW", "VN", "TH", "IN", "ID", "MY", "PH", "BD", "SG", "DE", "GB", "FR",
        "IT", "NL", "IE", "CH", "BE", "ES", "SE", "PL", "AT", "MX", "CA", "BR", "CO", "CL", "PE",
        "AR", "AU", "NZ", "ZA", "IL", "SA", "AE", "TR", "RU", "NO", "DK", "FI", "PT", "CZ", "HU",
        "GR", "EG", "NG", "KE", "MA", "PK"
    )
)

# Continent colors
continent_colors <- c(
    "Asia" = "#e11d48", "Europe" = "#2563eb", "North America" = "#16a34a",
    "South America" = "#ea580c", "Oceania" = "#7c3aed", "Africa" = "#ca8a04",
    "Middle East" = "#0891b2", "Other" = "#6b7280"
)

# Load data
message("Loading prepared data...\n")
monthly_by_country <- arrow::read_parquet(here("data", "processed", "monthly_by_country.parquet"))
monthly_by_hs10 <- arrow::read_parquet(here("data", "processed", "monthly_by_hs10.parquet"))
hs_lookup <- arrow::read_parquet(here("data", "processed", "hs_lookup.parquet"))
top_countries <- arrow::read_parquet(here("data", "processed", "top_entities_countries.parquet"))

setDT(monthly_by_country)
setDT(monthly_by_hs10)
setDT(hs_lookup)
setDT(top_countries)

# ============================================================================
# ANIMATION 1: TRADE-TARIFF SCATTER - SIMPLE VERSION
# ============================================================================
message("Building Animation 1: Trade-Tariff Scatter Evolution...\n")

top_products <- monthly_by_hs10[, .(total_trade = sum(trade_value, na.rm = TRUE)), by = HTS_Number][order(-total_trade)][1:100]
anim_data_products <- monthly_by_hs10[HTS_Number %in% top_products$HTS_Number]
anim_data_products[, `:=`(trade_value_bn = trade_value / 1e9, tariff_rate_pct = tariff_rate * 100, month_label = format(date, "%Y-%m"))]
anim_data_products[, chapter := substr(HTS_Number, 1, 2)]
chapter_names <- unique(hs_lookup[!is.na(chapter_name), .(chapter, chapter_name)])
anim_data_products <- merge(anim_data_products, chapter_names, by = "chapter", all.x = TRUE)

months <- sort(unique(anim_data_products$date))
month_labels <- format(months, "%Y-%m")
frames_list <- lapply(seq_along(months), function(i) {
    monthly_data <- anim_data_products[date == months[i], .(monthly_trade = sum(trade_value, na.rm = TRUE), avg_tariff = mean(tariff_rate, na.rm = TRUE)), by = .(HTS_Number, chapter, chapter_name)]
    monthly_data[, `:=`(trade_value_bn = monthly_trade / 1e9, tariff_rate_pct = avg_tariff * 100, frame = month_labels[i])]
})
animation_data <- rbindlist(frames_list)
global_max_trade <- max(animation_data$trade_value_bn, na.rm = TRUE)
animation_data[, bubble_size := pmax(sqrt(trade_value_bn / global_max_trade) * 40, 8)]

p_anim1 <- plot_ly(
    data = animation_data, x = ~trade_value_bn, y = ~tariff_rate_pct, text = ~HTS_Number,
    color = ~chapter_name, frame = ~frame, type = "scatter", mode = "markers",
    marker = list(size = ~bubble_size, sizemode = "diameter", sizeref = 1, sizemin = 4, opacity = 0.7),
    hovertemplate = "<b>%{text}</b><br>Trade: $%{x:.2f}B<br>Tariff: %{y:.1f}%<extra></extra>"
) %>%
    layout(
        title = list(text = "<b>Trade-Tariff Evolution</b>", font = list(family = "Inter", size = 20)),
        xaxis = list(title = "Trade Value ($B)", type = "log"), yaxis = list(title = "Tariff Rate (%)"),
        showlegend = FALSE, height = 700
    ) %>%
    animation_opts(frame = 800, transition = 400, redraw = TRUE) %>%
    animation_slider(currentvalue = list(prefix = "Month: ")) %>%
    animation_button(x = 0.5, y = -0.08, label = "▶ Play") %>%
    config(displaylogo = FALSE)

htmlwidgets::saveWidget(p_anim1, file.path(out_dir, "15_trade_tariff_animation.html"), selfcontained = FALSE)
message("  ✅ Saved: 15_trade_tariff_animation.html\n")

# ============================================================================
# ANIMATION 2: COUNTRY DASHBOARD - WITH ALL FIXES
# ============================================================================
message("Building Animation 2: Country Dashboard Evolution...\n")

top_50_countries <- top_countries[1:50]$Country
anim_country_data <- monthly_by_country[Country %in% top_50_countries]
anim_country_data[, `:=`(trade_value_bn = trade_value / 1e9, tariff_rate_pct = avg_rate_total * 100)]

months <- sort(unique(anim_country_data$date))
month_labels <- format(months, "%Y-%m")
frames_list <- lapply(seq_along(months), function(i) {
    monthly_data <- anim_country_data[date == months[i], .(
        monthly_trade = sum(trade_value, na.rm = TRUE),
        monthly_tariff = mean(avg_rate_total, na.rm = TRUE), sea_distance = first(avg_seadistance)
    ), by = Country]
    monthly_data[, `:=`(trade_value_bn = monthly_trade / 1e9, tariff_rate_pct = monthly_tariff * 100, frame = month_labels[i])]
})
animation_country_data <- rbindlist(frames_list)

animation_country_data <- merge(animation_country_data, iso_codes, by = "Country", all.x = TRUE)
animation_country_data[is.na(ISO), ISO := substr(Country, 1, 2)]

animation_country_data[, continent := case_when(
    Country %in% c(
        "China", "Japan", "Korea, South", "Taiwan", "Vietnam", "Thailand", "India", "Indonesia",
        "Malaysia", "Philippines", "Bangladesh", "Singapore", "Pakistan"
    ) ~ "Asia",
    Country %in% c(
        "Germany", "United Kingdom", "France", "Italy", "Netherlands", "Ireland", "Switzerland",
        "Belgium", "Spain", "Sweden", "Poland", "Austria", "Denmark", "Finland", "Norway"
    ) ~ "Europe",
    Country %in% c("Mexico", "Canada") ~ "North America",
    Country %in% c("Brazil", "Colombia", "Chile", "Peru", "Argentina", "Ecuador", "Costa Rica") ~ "South America",
    Country %in% c("Australia", "New Zealand") ~ "Oceania",
    Country %in% c("South Africa", "Nigeria", "Egypt", "Kenya", "Morocco") ~ "Africa",
    Country %in% c("Israel", "Saudi Arabia", "United Arab Emirates", "Turkey", "Qatar") ~ "Middle East",
    TRUE ~ "Other"
)]

global_max_country_trade <- max(animation_country_data$trade_value_bn, na.rm = TRUE)
animation_country_data[, bubble_size := pmax(sqrt(trade_value_bn / global_max_country_trade) * 80, 15)]

message(sprintf("  %d countries, %d frames\n", length(unique(animation_country_data$Country)), length(months)))

unique_continents <- unique(animation_country_data$continent)

# Build plot - Keep legend for filtering, hide only slider trace markers
p_anim2 <- plot_ly() %>%
    layout(
        title = list(
            text = "<b>Country Trade Evolution</b><br><span style='font-size:13px;color:#6b7280;'>Top 50 trading partners | Click legend to filter</span>",
            font = list(family = "Inter, sans-serif", size = 20), x = 0.02
        ),
        xaxis = list(title = "Sea Distance (km)", gridcolor = "#e2e8f0", range = c(0, 22000)),
        yaxis = list(title = "Average Tariff Rate (%)", gridcolor = "#e2e8f0", range = c(-2, 55)),
        plot_bgcolor = "rgba(248, 250, 252, 0.8)",
        paper_bgcolor = "white",
        height = 700,
        margin = list(l = 80, r = 30, t = 100, b = 120),
        showlegend = TRUE, # Keep legend for filtering
        legend = list(
            orientation = "h",
            y = -0.15,
            x = 0.5,
            xanchor = "center",
            font = list(size = 11),
            itemclick = "toggle",
            itemdoubleclick = "toggleothers"
        ),
        updatemenus = list(list(
            type = "buttons", showactive = TRUE, x = 0.85, y = 1.12,
            buttons = list(
                list(label = "🐢", method = "animate", args = list(NULL, list(frame = list(duration = 1500), transition = list(duration = 600)))),
                list(label = "▶", method = "animate", args = list(NULL, list(frame = list(duration = 800), transition = list(duration = 400)))),
                list(label = "⚡", method = "animate", args = list(NULL, list(frame = list(duration = 300), transition = list(duration = 150))))
            )
        ))
    )

# Add one trace per country - text is JUST THE ISO CODE
for (cont in unique_continents) {
    cont_countries <- unique(animation_country_data[continent == cont]$Country)
    color <- continent_colors[cont]

    for (j in seq_along(cont_countries)) {
        country_name <- cont_countries[j]
        country_data <- animation_country_data[Country == country_name]
        iso_code <- country_data$ISO[1]

        # First country of each continent shows in legend with continent name
        show_legend <- (j == 1)

        p_anim2 <- p_anim2 %>%
            add_trace(
                data = country_data,
                x = ~sea_distance, y = ~tariff_rate_pct, frame = ~frame,
                type = "scatter", mode = "markers",
                name = cont, legendgroup = cont, showlegend = show_legend,
                marker = list(
                    size = ~bubble_size, sizemode = "diameter", sizeref = 1, sizemin = 12,
                    color = color, opacity = 0.85, line = list(color = "white", width = 1.5)
                ),
                text = iso_code, # JUST 2-digit code
                textfont = list(size = 10, color = "white", family = "Arial Black"),
                textposition = "middle center",
                hovertemplate = paste0(
                    "<b>", country_name, "</b> (", iso_code, ")<br>",
                    "Continent: ", cont, "<br>Distance: %{x:.0f} km<br>",
                    "Tariff: %{y:.1f}%<br>Trade: $%{customdata:.1f}B<extra></extra>"
                ),
                customdata = ~trade_value_bn
            )
    }
}

# Animation controls - hide slider steps to remove "trace" labels
p_anim2 <- p_anim2 %>%
    animation_opts(frame = 800, transition = 400, easing = "cubic-in-out", redraw = TRUE) %>%
    animation_slider(
        currentvalue = list(prefix = "Month: ", font = list(size = 14, color = colors$primary)),
        steps = list(), # Empty steps to hide trace markers
        y = -0.02
    ) %>%
    animation_button(x = 0.1, y = 1.12, label = "▶ Play") %>%
    config(responsive = TRUE, displaylogo = FALSE)

# HTML with dramatic music, controls, Edge-compatible
control_html <- '
<style>
/* Edge/Firefox compatible styles */
.trade-controls { max-width:1200px; margin:15px auto; padding:20px; background:linear-gradient(135deg,#f8fafc,#e2e8f0); border-radius:16px; border-left:5px solid #667eea; font-family:system-ui,-apple-system,sans-serif; }
.trade-controls h3 { margin:0 0 12px 0; color:#667eea; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.trade-controls button { padding:10px 16px; border:none; border-radius:8px; cursor:pointer; font-size:14px; transition:opacity 0.2s; }
.trade-controls button:hover { opacity:0.85; }
.legend-row { display:flex; flex-wrap:wrap; gap:14px; margin:12px 0; font-size:14px; }
.legend-item { display:flex; align-items:center; gap:4px; }
.legend-dot { width:14px; height:14px; border-radius:50%; display:inline-block; }
.info-box { background:white; padding:14px; border-radius:10px; margin-top:12px; font-size:13px; color:#4a5568; line-height:1.7; }
</style>

<div class="trade-controls">
  <h3>
    <span>🌍 Country Trade Evolution</span>
    <button id="btn-music" onclick="toggleMusic()" style="background:#667eea; color:white;">🎵 Music OFF</button>
    <button id="btn-iso" onclick="toggleISO()" style="background:#10b981; color:white;">🏷️ Labels OFF</button>
    <span id="tension-level" style="margin-left:auto; font-size:14px; font-weight:normal;">Press Play</span>
  </h3>

  <div class="legend-row">
    <span class="legend-item"><span class="legend-dot" style="background:#e11d48;"></span> Asia</span>
    <span class="legend-item"><span class="legend-dot" style="background:#2563eb;"></span> Europe</span>
    <span class="legend-item"><span class="legend-dot" style="background:#16a34a;"></span> North America</span>
    <span class="legend-item"><span class="legend-dot" style="background:#ea580c;"></span> South America</span>
    <span class="legend-item"><span class="legend-dot" style="background:#7c3aed;"></span> Oceania</span>
    <span class="legend-item"><span class="legend-dot" style="background:#ca8a04;"></span> Africa</span>
    <span class="legend-item"><span class="legend-dot" style="background:#0891b2;"></span> Middle East</span>
  </div>

  <div class="info-box">
    <b>🎮 Controls:</b> ▶ Play/Pause | Drag slider for months | 🐢▶⚡ Speed | 🎵 Dramatic music | 🏷️ Show country codes | Hover for details
  </div>
</div>

<audio id="dramatic-music" loop>
  <source src="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" type="audio/mpeg">
</audio>

<script>
// Music control
var musicPlaying = false;
function toggleMusic() {
    var audio = document.getElementById("dramatic-music");
    var btn = document.getElementById("btn-music");
    if (!musicPlaying) {
        audio.volume = 0.3;
        audio.play().catch(function(e) { console.log("Audio blocked:", e); });
        btn.textContent = "🎵 Music ON";
        musicPlaying = true;
    } else {
        audio.pause();
        btn.textContent = "🎵 Music OFF";
        musicPlaying = false;
    }
}

// ISO toggle - show ONLY 2-digit codes
var isoEnabled = false;
function toggleISO() {
    isoEnabled = !isoEnabled;
    document.getElementById("btn-iso").textContent = isoEnabled ? "🏷️ Labels ON" : "🏷️ Labels OFF";
    var plotDiv = document.querySelector(".js-plotly-plot");
    if (plotDiv && window.Plotly) {
        var update = { mode: isoEnabled ? "markers+text" : "markers" };
        var indices = [];
        for (var i = 0; i < plotDiv.data.length; i++) indices.push(i);
        Plotly.restyle(plotDiv, update, indices);
    }
}

// Tension display
function setupFrameMonitor() {
    var plotDiv = document.querySelector(".js-plotly-plot");
    if (!plotDiv) { setTimeout(setupFrameMonitor, 500); return; }

    plotDiv.on("plotly_animatingframe", function(data) {
        var totalTariff = 0, count = 0;
        plotDiv.data.forEach(function(t) {
            if (t.y) t.y.forEach(function(v) { if (typeof v === "number") { totalTariff += v; count++; } });
        });
        var avg = count > 0 ? totalTariff / count : 0;
        var el = document.getElementById("tension-level");
        if (el) {
            var text = avg < 10 ? "🌿 Calm" : avg < 20 ? "⚠️ Rising" : avg < 35 ? "🔥 High" : "💥 TRADE WAR!";
            var color = avg < 10 ? "#16a34a" : avg < 20 ? "#eab308" : avg < 35 ? "#ea580c" : "#dc2626";
            el.innerHTML = "<span style=\\"color:" + color + ";font-weight:bold\\">" + text + "</span> (" + avg.toFixed(0) + "% avg)";
        }
    });
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setupFrameMonitor);
} else {
    setupFrameMonitor();
}
</script>
'

p_anim2_with_desc <- htmlwidgets::prependContent(p_anim2, HTML(control_html))
htmlwidgets::saveWidget(p_anim2_with_desc, file.path(out_dir, "16_country_evolution_animation.html"), selfcontained = FALSE)
message("  ✅ Saved: 16_country_evolution_animation.html\n")

message("\n════════════════════════════════════════════════════════════════")
message("  ✅ ANIMATED VISUALIZATIONS COMPLETE")
message("════════════════════════════════════════════════════════════════\n")
message("Fixes: ISO shows 2-digit only, Music track, Better legend, No trace markers, Edge compatible\n")
