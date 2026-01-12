# Data Preparation for Interactive Visualizations (Optimized)
# Strategy: Minimize memory footprint by reading only needed columns, 
# aggregating incrementally, and writing to disk immediately

options(stringsAsFactors = FALSE)

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(arrow, data.table, jsonlite, here)

message("════════════════════════════════════════════════════════════════")
message("  INTERACTIVE DATA PREPARATION (OPTIMIZED)")
message("════════════════════════════════════════════════════════════════\n")

# ============================================================================
# 1. HTS JSON PARSING WITH BREADCRUMB DESCRIPTIONS
# ============================================================================

message("Step 1: Parsing htsdata.json and building hierarchical descriptions...\n")

hts_json <- fromJSON(here("data", "raw", "htsdata.json"), simplifyDataFrame = TRUE)
setDT(hts_json)

# Clean HTS numbers and convert indent to numeric
hts_json[, htsno_clean := gsub("[. ]", "", htsno)]
hts_json[, indent := as.integer(indent)]
hts_json[, row_id := .I]  # Add row ID for tracking hierarchy

# Build breadcrumb descriptions efficiently using parent tracking
# Strategy: Track last-seen description at each indent level
message("  Building hierarchical breadcrumb descriptions...\n")

# Sort to ensure proper sequential order
setorder(hts_json, row_id)

# Track the most recent description at each indent level
parent_stack <- character(20)  # Support up to 20 levels of indentation

# Build breadcrumbs by maintaining a stack of parents
breadcrumbs <- character(nrow(hts_json))

for (i in seq_len(nrow(hts_json))) {
  if (i %% 5000 == 0) cat(sprintf("\r    Processed %d/%d rows (%.0f%%)", i, nrow(hts_json), 100*i/nrow(hts_json)))
  
  curr_indent <- hts_json$indent[i]
  curr_desc <- trimws(hts_json$description[i])
  
  # Skip empty descriptions
  if (nchar(curr_desc) == 0 || grepl("^\\s*$", curr_desc)) {
    breadcrumbs[i] <- ""
    next
  }
  
  # Update stack at current level
  parent_stack[curr_indent + 1] <- curr_desc
  
  # Build breadcrumb from levels 0 to current
  parts <- parent_stack[1:(curr_indent + 1)]
  parts <- parts[nchar(parts) > 0]  # Remove empty
  
  breadcrumbs[i] <- paste(parts, collapse = " > ")
}

cat("\n")

hts_json[, breadcrumb_desc := breadcrumbs]

message("  ✅ Breadcrumb descriptions built\n")

# Extract chapter names from JSON (HS2 level with indent=0)
# Chapter codes in htsno_clean are 4 digits like "0101", extract first 2
# Take only first occurrence of each chapter (some chapters have multiple entries)
chapter_names <- hts_json[as.integer(indent) == 0 & nchar(trimws(htsno_clean)) == 4, .(
  chapter = substr(trimws(htsno_clean), 1, 2),
  chapter_name = trimws(description)
)][!is.na(chapter) & nchar(chapter) > 0]

# Keep only unique chapters (first occurrence)
chapter_names <- unique(chapter_names, by = "chapter")

message(sprintf("  Extracted %d unique chapter names from JSON\n", nrow(chapter_names)))

# Extract only 10-digit codes with full breadcrumb descriptions
hs_lookup <- hts_json[nchar(htsno_clean) == 10, .(
  HTS_Number = htsno_clean,
  chapter = substr(htsno_clean, 1, 2),
  item_desc = breadcrumb_desc,  # Use full hierarchical description
  item_desc_short = description  # Keep original for short labels
)]

message(sprintf("  Extracted %s HS 10-digit codes with breadcrumb descriptions\n", format(nrow(hs_lookup), big.mark = ",")))

# Merge with chapter names from JSON
hs_lookup <- merge(hs_lookup, chapter_names, by = "chapter", all.x = TRUE)

# Clean up
rm(hts_json, chapter_names)
gc()

message(sprintf("  ✅ Created %s HS 10-digit codes with chapters\n", nrow(hs_lookup)))
arrow::write_parquet(hs_lookup, here("data", "processed", "hs_lookup.parquet"))
message("  ✅ Saved: data/processed/hs_lookup.parquet\n")

# ============================================================================
# 2. CREATE TRUMP TARIFF EVENTS TIMELINE
# ============================================================================

message("Step 2: Creating Trump tariff events timeline...\n")

trump_events <- data.table(
  date = as.Date(c(
    "2024-02-04", "2024-03-04", "2024-03-12", "2024-04-03", "2024-04-05",
    "2024-04-10", "2024-05-12", "2024-05-14", "2024-06-04", "2024-06-06",
    "2024-07-30", "2024-08-01", "2024-08-07", "2024-08-27",
    "2024-09-27", "2024-11-01", "2025-01-01"
  )),
  label = c(
    "China 10% Tariff", "Mex/Can 25%, China 20%", "Global Steel/Alum 25%", "Auto 25%", "Global Baseline 10%",
    "Peak China ~145%", "China De-escalation", "Biden Announced", "Steel/Alum 50%", "Solar Freeze Ends",
    "De Minimis Ends", "India Reciprocal 25%", "Global Reciprocal", "India Oil 50%",
    "Section 301 Hikes", "China 10% Cut", "Tech Phase II"
  ),
  category = c(
    "China", "Mexico-Canada", "Steel-Aluminum", "Auto", "Global",
    "China", "China", "Biden", "Steel-Aluminum", "Solar",
    "Global", "India", "Global", "India",
    "Biden", "China", "Biden"
  )
)

arrow::write_parquet(trump_events, here("data", "processed", "trump_tariff_events.parquet"))
message(sprintf("  ✅ Created %s tariff events\n", nrow(trump_events)))
message("  ✅ Saved: data/processed/trump_tariff_events.rds\n")

# ============================================================================
# 3. LOAD USITC DATA & ENRICH (Read only needed columns)
# ============================================================================

message("Step 3: Loading USITC data (reading only essential columns)...\n")

usitc_path <- here("data", "clean", "usitc_long_aggregated.parquet")

# Define columns we need (minimize memory)
needed_cols <- c(
  "Country", "HTS Number", "date", "Description", "chapter",
  "value_total", "duties_total", "cif_value_total", "freight_ins_total", "quantity_total",
  "value_dutiable", "duties_dutiable", "value_61", "duties_61", "value_69", "duties_69",
  "rate_total", "rate_dutiable", "rate_61", "rate_69", "seadistance"
)

usitc <- as.data.table(read_parquet(usitc_path, col_select = needed_cols))
gc()

message(sprintf("  Loaded %s rows\n", format(nrow(usitc), big.mark = ",")))

# Clean HTS Number and merge descriptions
usitc[, HTS_clean := gsub("[. ]", "", `HTS Number`)]

# Merge chapter names only (minimal merge)
usitc <- merge(
  usitc,
  hs_lookup[, .(HTS_Number, chapter_name)],
  by.x = "HTS_clean",
  by.y = "HTS_Number",
  all.x = TRUE
)
gc()

message(sprintf("  Enriched with chapter names: %.1f%% matched\n",
                100 * mean(!is.na(usitc$chapter_name))))

# ============================================================================
# 4. AGGREGATE MONTHLY BY HS 10-DIGIT (Write immediately, free memory)
# ============================================================================

message("\nStep 4: Aggregating by HS 10-digit and date...\n")

monthly_hs10 <- usitc[, .(
  trade_value = sum(value_total, na.rm = TRUE),
  tariff_paid = sum(duties_total, na.rm = TRUE),
  n_countries = uniqueN(Country)
), by = .(HTS_Number = HTS_clean, date, chapter)]

monthly_hs10[, tariff_rate := ifelse(trade_value > 0, tariff_paid / trade_value, NA)]

arrow::write_parquet(monthly_hs10, here("data", "processed", "monthly_by_hs10.parquet"))
message(sprintf("  ✅ Saved %s HS10-date combinations\n", format(nrow(monthly_hs10), big.mark = ",")))

rm(monthly_hs10)
gc()

# ============================================================================
# 5. AGGREGATE MONTHLY BY HS 6-DIGIT
# ============================================================================

message("Step 5: Aggregating by HS 6-digit and date...\n")

usitc[, hs6 := substr(HTS_clean, 1, 6)]

monthly_hs6 <- usitc[, .(
  trade_value = sum(value_total, na.rm = TRUE),
  tariff_paid = sum(duties_total, na.rm = TRUE),
  n_countries = uniqueN(Country),
  n_hs10_codes = uniqueN(HTS_clean)
), by = .(hs6, date, chapter)]

monthly_hs6[, tariff_rate := ifelse(trade_value > 0, tariff_paid / trade_value, NA)]

arrow::write_parquet(monthly_hs6, here("data", "processed", "monthly_by_hs6.parquet"))
message(sprintf("  ✅ Saved %s HS6-date combinations\n", format(nrow(monthly_hs6), big.mark = ",")))

rm(monthly_hs6)
gc()

# ============================================================================
# 6. AGGREGATE MONTHLY BY CHAPTER
# ============================================================================

message("Step 6: Aggregating by HS Chapter and date...\n")

monthly_chapter <- usitc[, .(
  trade_value = sum(value_total, na.rm = TRUE),
  tariff_paid = sum(duties_total, na.rm = TRUE),
  n_countries = uniqueN(Country),
  n_hs10_codes = uniqueN(HTS_clean)
), by = .(chapter, date)]

monthly_chapter[, tariff_rate := ifelse(trade_value > 0, tariff_paid / trade_value, NA)]

arrow::write_parquet(monthly_chapter, here("data", "processed", "monthly_by_chapter.parquet"))
message(sprintf("  ✅ Saved %s chapter-date combinations\n", format(nrow(monthly_chapter), big.mark = ",")))

rm(monthly_chapter)
gc()

# ============================================================================
# 7. AGGREGATE MONTHLY BY COUNTRY
# ============================================================================

message("Step 7: Aggregating by Country and date...\n")

monthly_country <- usitc[, .(
  trade_value = sum(value_total, na.rm = TRUE),
  tariff_paid = sum(duties_total, na.rm = TRUE),
  cif_value = sum(cif_value_total, na.rm = TRUE),
  freight = sum(freight_ins_total, na.rm = TRUE),
  quantity = sum(quantity_total, na.rm = TRUE),
  n_hs10_codes = uniqueN(HTS_clean),
  n_chapters = uniqueN(chapter),
  avg_rate_total = weighted.mean(rate_total, value_total, na.rm = TRUE),
  avg_rate_dutiable = weighted.mean(rate_dutiable, value_dutiable, na.rm = TRUE),
  avg_seadistance = weighted.mean(seadistance, value_total, na.rm = TRUE)
), by = .(Country, date)]

arrow::write_parquet(monthly_country, here("data", "processed", "monthly_by_country.parquet"))
message(sprintf("  ✅ Saved %s country-date combinations\n", format(nrow(monthly_country), big.mark = ",")))

rm(monthly_country)
gc()

# ============================================================================
# 8. AGGREGATE OVERALL MONTHLY TOTALS
# ============================================================================

message("Step 8: Computing overall monthly totals...\n")

monthly_totals <- usitc[, .(
  trade_value = sum(value_total, na.rm = TRUE),
  tariff_paid = sum(duties_total, na.rm = TRUE),
  cif_value = sum(cif_value_total, na.rm = TRUE),
  freight = sum(freight_ins_total, na.rm = TRUE),
  quantity = sum(quantity_total, na.rm = TRUE),
  n_countries = uniqueN(Country),
  n_hs10_codes = uniqueN(HTS_clean),
  n_chapters = uniqueN(chapter),
  avg_rate_total = weighted.mean(rate_total, value_total, na.rm = TRUE),
  avg_rate_dutiable = weighted.mean(rate_dutiable, value_dutiable, na.rm = TRUE),
  avg_rate_61 = weighted.mean(rate_61, value_61, na.rm = TRUE),
  avg_rate_69 = weighted.mean(rate_69, value_69, na.rm = TRUE)
), by = .(date)]

arrow::write_parquet(monthly_totals, here("data", "processed", "monthly_totals.parquet"))
message(sprintf("  ✅ Saved %s months of data\n", nrow(monthly_totals)))

rm(monthly_totals)
gc()

# ============================================================================
# 9. CREATE TOP ENTITIES LOOKUP
# ============================================================================

message("Step 9: Computing top entities by total trade value...\n")

# Top countries
top_countries <- usitc[, .(
  total_trade = sum(value_total, na.rm = TRUE),
  avg_tariff = weighted.mean(rate_total, value_total, na.rm = TRUE),
  avg_distance = weighted.mean(seadistance, value_total, na.rm = TRUE)
), by = Country][order(-total_trade)]

# Top chapters with names
top_chapters <- usitc[, .(
  total_trade = sum(value_total, na.rm = TRUE),
  avg_tariff = weighted.mean(rate_total, value_total, na.rm = TRUE),
  n_hs10_codes = uniqueN(HTS_clean),
  chapter_name = first(chapter_name)
), by = chapter][order(-total_trade)]

# Top HS 10-digit codes  
top_hs10 <- usitc[, .(
  total_trade = sum(value_total, na.rm = TRUE),
  avg_tariff = weighted.mean(rate_total, value_total, na.rm = TRUE),
  n_countries = uniqueN(Country),
  chapter = first(chapter)
), by = .(HTS_Number = HTS_clean)][order(-total_trade)][1:500]  # Top 500

top_entities <- list(
  countries = top_countries,
  chapters = top_chapters,
  hs10 = top_hs10
)

# Save top_entities as separate parquet files (since it's a list)
arrow::write_parquet(top_entities$hs10, here("data", "processed", "top_entities_hs10.parquet"))
arrow::write_parquet(top_entities$countries, here("data", "processed", "top_entities_countries.parquet"))
arrow::write_parquet(top_entities$chapters, here("data", "processed", "top_entities_chapters.parquet"))
message(sprintf("  ✅ Saved top entities (countries: %s, chapters: %s, HS10: %s)\n",
                nrow(top_countries), nrow(top_chapters), nrow(top_hs10)))

# Final cleanup
rm(usitc, top_countries, top_chapters, top_hs10, top_entities, hs_lookup, trump_events)
gc()

# ============================================================================
# SUMMARY
# ============================================================================

message("\n════════════════════════════════════════════════════════════════")
message("  ✅ DATA PREPARATION COMPLETE")
message("════════════════════════════════════════════════════════════════\n")

message("Output files created in data/processed/:\n")
message("  ✅ hs_lookup.rds\n")
message("  ✅ trump_tariff_events.rds\n")
message("  ✅ monthly_by_hs10.rds\n")
message("  ✅ monthly_by_hs6.rds\n")
message("  ✅ monthly_by_chapter.rds\n")
message("  ✅ monthly_by_country.rds\n")
message("  ✅ monthly_totals.rds\n")
message("  ✅ top_entities.rds\n\n")

message("Ready for interactive visualization generation!\n")
