# ════════════════════════════════════════════════════════════════
# TARIFF EVENTS TIMELINE - CARD VIEW
# ════════════════════════════════════════════════════════════════

if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, lubridate)

cat("\n════════════════════════════════════════════════════════════════\n")
cat("  TARIFF EVENTS TIMELINE VISUALIZATION\n")
cat("════════════════════════════════════════════════════════════════\n\n")

# Load tariff events
events_path <- file.path("..", "..", "data", "tariff_events_config.csv")
trump_events <- fread(events_path)
trump_events$date <- dmy(trump_events$date)
setorder(trump_events, date)

# Add formatted date
trump_events$formatted_date <- format(trump_events$date, "%B %d, %Y")

# Add category based on event name
trump_events$category <- ifelse(grepl("China", trump_events$event_name, ignore.case = TRUE), "🇨🇳 China",
                          ifelse(grepl("Mexico|Canada", trump_events$event_name, ignore.case = TRUE), "🌎 Mexico/Canada",
                          ifelse(grepl("Vietnam|Indonesia|Korea", trump_events$event_name, ignore.case = TRUE), "🤝 Bilateral Deal",
                          ifelse(grepl("Steel|Alum|Auto", trump_events$event_name, ignore.case = TRUE), "🏭 Sectoral",
                          ifelse(grepl("Brazil|India", trump_events$event_name, ignore.case = TRUE), "⚠️ Sanctions",
                          ifelse(grepl("Global", trump_events$event_name, ignore.case = TRUE), "🌐 Global",
                          "📋 Other"))))))

# Create output directory
output_dir <- file.path("..", "output", "interactive")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_file <- file.path(output_dir, "18_tariff_timeline.html")

# Build HTML
html_content <- '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trump Tariff Events Timeline</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: "Inter", sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 2rem;
            min-height: 100vh;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { 
            text-align: center; 
            color: white; 
            font-size: 2.5rem; 
            margin-bottom: 0.5rem;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        .subtitle { 
            text-align: center; 
            color: rgba(255,255,255,0.9); 
            font-size: 1.1rem; 
            margin-bottom: 2rem;
        }
        .stats {
            background: rgba(255,255,255,0.95);
            padding: 1.5rem;
            border-radius: 16px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 2rem;
        }
        .stat-item { text-align: center; }
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            color: #667eea;
        }
        .stat-label {
            color: #6b7280;
            font-size: 0.9rem;
            margin-top: 0.25rem;
        }
        .event-card { 
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            transition: all 0.3s;
            border-left: 6px solid #667eea;
        }
        .event-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.25);
        }
        .event-card.china { border-left-color: #e74c3c; }
        .event-card.mexico { border-left-color: #f39c12; }
        .event-card.global { border-left-color: #3498db; }
        .event-card.sectoral { border-left-color: #9b59b6; }
        .event-card.deal { border-left-color: #27ae60; }
        .event-card.sanctions { border-left-color: #c0392b; }
        
        .event-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
            gap: 1rem;
        }
        .event-title {
            font-size: 1.4rem;
            font-weight: 600;
            color: #2c3e50;
            flex: 1;
        }
        .event-date {
            background: #f0f4f8;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-size: 0.9rem;
            color: #5a6c7d;
            white-space: nowrap;
        }
        .event-meta {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }
        .meta-badge {
            padding: 0.35rem 0.75rem;
            background: #e8f4f8;
            border-radius: 6px;
            font-size: 0.85rem;
            color: #2c5f7d;
            font-weight: 500;
        }
        .event-description {
            color: #4a5568;
            line-height: 1.6;
            font-size: 1rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 Trump Administration Tariff Events Timeline</h1>
        <p class="subtitle">February 2025 - August 2025 | Complete Policy Chronology</p>
        
        <div class="stats">
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-number">14</div>
                    <div class="stat-label">Total Events</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">6</div>
                    <div class="stat-label">Tariff Increases</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">3</div>
                    <div class="stat-label">Bilateral Deals</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">3</div>
                    <div class="stat-label">Sectoral Tariffs</div>
                </div>
            </div>
        </div>
        
        <div class="timeline">
'

# Add event cards
for (i in seq_len(nrow(trump_events))) {
  event <- trump_events[i,]
  
  # Determine card class
  card_class <- if (grepl("China", event$category)) "china"
                else if (grepl("Mexico", event$category)) "mexico"
                else if (grepl("Global", event$category)) "global"
                else if (grepl("Sectoral", event$category)) "sectoral"
                else if (grepl("Bilateral", event$category)) "deal"
                else if (grepl("Sanctions", event$category)) "sanctions"
                else "default"
  
  html_content <- paste0(html_content, sprintf('
            <div class="event-card %s">
                <div class="event-header">
                    <div class="event-title">%s</div>
                    <div class="event-date">%s</div>
                </div>
                <div class="event-meta">
                    <span class="meta-badge">%s</span>
                    <span class="meta-badge">%s</span>
                </div>
                <div class="event-description">%s</div>
            </div>
', card_class, event$event_name, event$formatted_date, event$category, event$event_type, event$description))
}

html_content <- paste0(html_content, '
        </div>
    </div>
</body>
</html>
')

# Write file
writeLines(html_content, output_file)

cat("  ✅ Saved: 18_tariff_timeline.html\n\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("  ✅ TARIFF EVENTS TIMELINE COMPLETE\n")
cat("════════════════════════════════════════════════════════════════\n\n")
