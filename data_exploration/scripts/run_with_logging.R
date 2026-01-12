# Wrapper script to run master regeneration with logging
# Purpose: Capture all output to a log file for debugging

# Set working directory first (required for here::here() to work)
setwd("c:/Code/trade_updated")

log_file <- "c:/Code/trade_updated/data_exploration/scripts/regeneration_log.txt"

# Start logging - use file() for better error capture
con <- file(log_file, open = "wt")
sink(con, type = "output")
sink(con, type = "message", append = TRUE)

cat("=== Starting regeneration at", as.character(Sys.time()), "===\n\n")
cat("Working directory:", getwd(), "\n\n")

tryCatch(
    {
        source("c:/Code/trade_updated/data_exploration/scripts/00_master_regenerate_dashboards.R")
        cat("\n=== Regeneration completed successfully at", as.character(Sys.time()), "===\n")
    },
    error = function(e) {
        cat("\n=== ERROR ===\n")
        cat("Message:", conditionMessage(e), "\n")
        cat("Call:", deparse(conditionCall(e)), "\n")
    }
)

# Stop logging
sink(type = "message")
sink(type = "output")
close(con)
