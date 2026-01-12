# Run animation script with logging
setwd("c:/Code/trade_updated")
log_file <- "c:/Code/trade_updated/data_exploration/scripts/animation_log.txt"

con <- file(log_file, open = "wt")
sink(con, type = "output")
sink(con, type = "message", append = TRUE)

cat("=== Starting animation script at", as.character(Sys.time()), "===\n\n")

tryCatch(
    {
        source("c:/Code/trade_updated/data_exploration/scripts/07_animated_visualizations.R")
        cat("\n=== Animation script completed successfully ===\n")
    },
    error = function(e) {
        cat("\n=== ERROR ===\n")
        cat("Message:", conditionMessage(e), "\n")
        cat("Call:", deparse(conditionCall(e)), "\n")
    }
)

sink(type = "message")
sink(type = "output")
close(con)
