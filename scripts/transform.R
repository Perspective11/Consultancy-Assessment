# -----------------------------------------------------------------------------
# Title:   Data Transformation Script - UNICEF SDMX and Excel Files
# Author:  Your Name
# Date:    2025‑07‑27
# -----------------------------------------------------------------------------

# Note: Libraries are loaded from user_profile.R

# 1. Create wide format for MNCH data -----------------------------------------
message("Creating wide format for MNCH data...")
unicef_mnch_data_wide <- unicef_mnch_data %>%
  select(-sex) %>%
  pivot_wider(
    names_from  = indicator,
    values_from = value
  )

# 2. Build comprehensive countries summary ------------------------------------
message("Building countries summary dataset...")

# 2a. Start with on-track countries and add population data
countries_summary <- unicef_on_track_countries %>%
  left_join(un_population, by = "country_code")

# 2b. Compute latest MNCH_ANC4 values per country
anc4_last <- unicef_mnch_data %>%
  filter(indicator == "MNCH_ANC4") %>%
  group_by(country_code) %>%
  summarise(
    last_anc4_year  = max(year),
    last_anc4_value = value[which.max(year)],
    .groups = "drop"
  )

# 2c. Compute latest MNCH_SAB values per country
sab_last <- unicef_mnch_data %>%
  filter(indicator == "MNCH_SAB") %>%
  group_by(country_code) %>%
  summarise(
    last_sab_year  = max(year),
    last_sab_value = value[which.max(year)],
    .groups = "drop"
  )

# 2d. Combine all data into final countries summary
countries_summary <- countries_summary %>%
  left_join(anc4_last, by = "country_code") %>%
  left_join(sab_last, by = "country_code")

# 3. Data quality assessment --------------------------------------------------
cat("\n=== Data Quality Summary ===\n")
cat("Number of unique countries:", n_distinct(unicef_mnch_data$country_code), "\n")
cat("Number of unique indicators:", n_distinct(unicef_mnch_data$indicator), "\n")
cat("Year range:", min(unicef_mnch_data$year), "to", max(unicef_mnch_data$year), "\n")
cat("Missing values in value column:", sum(is.na(unicef_mnch_data$value)), "\n")
cat("Countries with complete data:", sum(!is.na(countries_summary$last_anc4_value) & !is.na(countries_summary$last_sab_value)), "\n")

# 4. Summary statistics by indicator ------------------------------------------
cat("\n=== Summary Statistics by Indicator ===\n")
indicator_summary <- unicef_mnch_data %>%
  group_by(indicator) %>%
  summarise(
    n_countries  = n_distinct(country_code),
    mean_value   = mean(value, na.rm = TRUE),
    median_value = median(value, na.rm = TRUE),
    min_value    = min(value, na.rm = TRUE),
    max_value    = max(value, na.rm = TRUE),
    .groups      = "drop"
  )

print(indicator_summary)

head(countries_summary)

pop_weighted <- countries_summary %>%
  group_by(status_u5mr) %>%
  summarise(
    # ANC4 weighted by births in 2022:
    pw_anc4 = weighted.mean(last_anc4_value,
                             w = births,
                             na.rm = TRUE),
    # SBA weighted by births in 2022:
    pw_sab  = weighted.mean(last_sab_value,
                             w = births,
                             na.rm = TRUE),
    total_births = sum(births, na.rm = TRUE),
    n_total       = n(),
    n_missing_anc4 = sum(is.na(last_anc4_value) | is.na(births)),
    n_missing_sab  = sum(is.na(last_sab_value)  | is.na(births)),
    .groups = "drop"
  )

print(pop_weighted)

# 5. Export transformed datasets ----------------------------------------------
message("Exporting transformed datasets...")
write_xlsx(unicef_mnch_data_wide, file.path(OUTPUT_PATH, "unicef_mnch_data_wide.xlsx"))
write_xlsx(countries_summary, file.path(OUTPUT_PATH, "countries_summary.xlsx"))
write_xlsx(indicator_summary, file.path(OUTPUT_PATH, "indicator_summary.xlsx"))
write_xlsx(pop_weighted, file.path(OUTPUT_PATH, "pop_weighted.xlsx"))

# 6. Data inspection and preview ----------------------------------------------
cat("\n=== Transformed Data Overview ===\n")
cat("Tidy format dimensions:", dim(unicef_mnch_data), "\n")
cat("Wide format dimensions:", dim(unicef_mnch_data_wide), "\n")
cat("Countries summary dimensions:", dim(countries_summary), "\n")

cat("\n=== Wide Format Preview (first 10 rows) ===\n")
print(unicef_mnch_data_wide, n = 10)

cat("\n=== Countries Summary Preview (first 10 rows) ===\n")
print(countries_summary, n = 10)

cat("\n=== Transformation Complete ===\n")
