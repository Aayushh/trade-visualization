options(stringsAsFactors = FALSE)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, here, data.table)

message("\n════════════════════════════════════════════════════════════════")
message("  DATA GAP DIAGNOSTIC")
message("════════════════════════════════════════════════════════════════\n")

monthly_totals <- readRDS(here("data", "processed", "monthly_totals.rds"))
setDT(monthly_totals)

# Get date range
date_range <- monthly_totals[, .(min_date = min(date), max_date = max(date))]
message(sprintf("Data range: %s to %s\n", 
                format(date_range$min_date, "%b %Y"), 
                format(date_range$max_date, "%b %Y")))

# Check for gaps
monthly_totals <- monthly_totals[order(date)]
monthly_totals[, date_lag := shift(date, 1)]
monthly_totals[, gap_days := as.numeric(date - date_lag)]
gaps <- monthly_totals[gap_days > 35][!is.na(gap_days)]

message("Gaps > 35 days detected:\n")
if (nrow(gaps) > 0) {
  for (i in seq_len(nrow(gaps))) {
    message(sprintf("  %s to %s (gap: %d days)\n", 
                    format(gaps$date_lag[i], "%b %d, %Y"), 
                    format(gaps$date[i], "%b %d, %Y"),
                    gaps$gap_days[i]))
  }
} else {
  message("  None detected\n")
}

# Show all dates present
message("All dates in dataset:\n")
print(monthly_totals[, .(date = format(date, "%b %Y"))])

message("\n════════════════════════════════════════════════════════════════\n")
