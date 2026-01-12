#!/usr/bin/env Rscript
message("\n════════════════════════════════════════════════════════════════")
message("  MASTER REGENERATION: ALL DASHBOARDS")
message("════════════════════════════════════════════════════════════════\n")

options(stringsAsFactors = FALSE)

# Time the full run
start_time <- Sys.time()

# Run script 03: Time series
message("Running Script 03: Time Series Explorers (01-05)...")
source(here::here("data_exploration", "scripts", "03_interactive_time_series.R"))
message("✅ Script 03 complete\n")

# Run script 04: Product explorer
message("Running Script 04: Product Explorers (06-09)...")
source(here::here("data_exploration", "scripts", "04_interactive_product_explorer.R"))
message("✅ Script 04 complete\n")

# Run script 10: Country dashboard with filter
message("Running Script 10: Country Dashboard with Date Filter...")
source(here::here("data_exploration", "scripts", "10_country_dashboard_filtered.R"))
message("✅ Script 10 complete\n")

# Run script 05: Geo explorers
message("Running Script 05: Geo Explorers (11-13)...")
source(here::here("data_exploration", "scripts", "05_interactive_geo_relationships.R"))
message("✅ Script 05 complete\n")

# Run script 06: Index generator
message("Running Script 06: Index Generator...")
source(here::here("data_exploration", "scripts", "06_generate_viz_index_simple.R"))
message("✅ Script 06 complete\n")

elapsed <- difftime(Sys.time(), start_time, units = "secs")

message("\n════════════════════════════════════════════════════════════════")
message(sprintf("✅ ALL DASHBOARDS REGENERATED IN %.1f SECONDS", as.numeric(elapsed)))
message("════════════════════════════════════════════════════════════════\n")

message("Output location: data_exploration/output/interactive/\n")
