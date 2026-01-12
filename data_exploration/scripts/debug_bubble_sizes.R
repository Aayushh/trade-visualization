# Debug script to check bubble size calculations for multiple countries
library(data.table)
library(arrow)
library(here)

setwd("c:/Code/trade_updated")

# Redirect output to file
sink("data_exploration/scripts/debug_output.txt")

# Load data
monthly_by_country <- arrow::read_parquet(here("data", "processed", "monthly_by_country.parquet"))
top_countries <- arrow::read_parquet(here("data", "processed", "top_entities_countries.parquet"))
setDT(monthly_by_country)
setDT(top_countries)

# Get top 50 countries
top_50_countries <- top_countries[1:50]$Country

# Prepare monthly country data
anim_country_data <- monthly_by_country[Country %in% top_50_countries]
anim_country_data[, `:=`(
    trade_value_bn = trade_value / 1e9,
    tariff_rate_pct = avg_rate_total * 100,
    month_label = format(date, "%Y-%m")
)]

# Create monthly data for each frame
months <- sort(unique(anim_country_data$date))
month_labels <- format(months, "%Y-%m")

frames_list <- list()
for (i in seq_along(months)) {
    current_month <- months[i]

    monthly_data <- anim_country_data[date == current_month, .(
        monthly_trade = sum(trade_value, na.rm = TRUE),
        monthly_tariff = mean(avg_rate_total, na.rm = TRUE),
        sea_distance = first(avg_seadistance)
    ), by = Country]

    monthly_data[, `:=`(
        trade_value_bn = monthly_trade / 1e9,
        tariff_rate_pct = monthly_tariff * 100,
        frame = month_labels[i]
    )]

    frames_list[[i]] <- monthly_data
}

animation_country_data <- rbindlist(frames_list)

# Compute global max
global_max <- max(animation_country_data$trade_value_bn, na.rm = TRUE)
cat("Global max trade (billions):", global_max, "\n\n")

# Add bubble size column
animation_country_data[, bubble_size := pmax(sqrt(trade_value_bn / global_max) * 80, 12)]

# Check multiple countries
countries_to_check <- c("India", "China", "Vietnam", "Bangladesh", "Mexico", "Germany")

for (country in countries_to_check) {
    cat("=================================================\n")
    cat(country, " data across all months:\n")
    cat("=================================================\n")
    country_data <- animation_country_data[Country == country, .(frame, trade_value_bn, bubble_size, tariff_rate_pct)]
    print(country_data)
    cat("\nBubble size range for", country, ":\n")
    cat("Trade Min:", round(min(country_data$trade_value_bn), 2), "B -> Bubble:", round(min(country_data$bubble_size), 1), "\n")
    cat("Trade Max:", round(max(country_data$trade_value_bn), 2), "B -> Bubble:", round(max(country_data$bubble_size), 1), "\n\n")
}

# Show 2025-02 comparison (user's example)
cat("\n=================================================\n")
cat("2025-02 COMPARISON (India vs Bangladesh):\n")
cat("=================================================\n")
feb2025 <- animation_country_data[
    frame == "2025-02" & Country %in% c("India", "Bangladesh"),
    .(Country, trade_value_bn, bubble_size)
]
print(feb2025)
cat(
    "\nExpected bubble ratio (sqrt of trade ratio):",
    round(sqrt(feb2025[Country == "India"]$trade_value_bn / feb2025[Country == "Bangladesh"]$trade_value_bn), 2), "\n"
)
cat(
    "Actual bubble ratio:",
    round(feb2025[Country == "India"]$bubble_size / feb2025[Country == "Bangladesh"]$bubble_size, 2), "\n"
)

sink()
cat("Output saved to data_exploration/scripts/debug_output.txt\n")
