# -----------------------------------------------------------------------------
# Title:   Data Transformation Script
# Purpose: Transform raw data into analysis-ready formats including wide format
#          conversion, country-level summaries, and population-weighted analysis
#          for maternal health coverage indicators
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

# Get total counts for ANC4 and SAB indicators
n_total_anc4 <- unicef_mnch_data %>%
  filter(indicator == "MNCH_ANC4") %>%
  nrow()

n_total_sab <- unicef_mnch_data %>%
  filter(indicator == "MNCH_SAB") %>%
  nrow()

indicator_summary <- unicef_mnch_data %>%
  group_by(indicator) %>%
  summarise(
    n_countries  = n_distinct(country_code),
    mean_value   = mean(value, na.rm = TRUE),
    median_value = median(value, na.rm = TRUE),
    min_value    = min(value, na.rm = TRUE),
    max_value    = max(value, na.rm = TRUE),
    .groups      = "drop"
  ) %>%
  mutate(
    n_total_anc4 = if_else(indicator == "MNCH_ANC4", n_total_anc4, NA_integer_),
    n_total_sab = if_else(indicator == "MNCH_SAB", n_total_sab, NA_integer_)
  ) %>%
  # Add descriptive indicator names
  mutate(
    indicator_name = case_when(
      indicator == "MNCH_ANC4" ~ "Antenatal Care (4+ visits)",
      indicator == "MNCH_SAB" ~ "Skilled Birth Attendance",
      TRUE ~ indicator
    )
  ) %>%
  # Reorder columns for better readability
  select(indicator, indicator_name, n_countries, mean_value, median_value, min_value, max_value, n_total_anc4, n_total_sab)

print(indicator_summary)

# 5. Countries indicators U5MR summary --------------------------------------
message("Creating countries indicators U5MR summary...")
countries_indicators_u5mr_summary <- countries_summary %>%
  group_by(status_u5mr) %>%
  summarise(
    `Population-Weighted ANC4 (%)` = weighted.mean(last_anc4_value, w = births, na.rm = TRUE),
    `Population-Weighted SAB (%)`  = weighted.mean(last_sab_value,  w = births, na.rm = TRUE),
    `Total Births`                 = sum(births, na.rm = TRUE),
    `Total Countries`              = n(),
    `Countries with ANC4 Data`     = sum(!is.na(last_anc4_value)),
    `Countries Missing ANC4 Data`  = sum(is.na(last_anc4_value)),
    `Countries with SAB Data`      = sum(!is.na(last_sab_value)),
    `Countries Missing SAB Data`   = sum(is.na(last_sab_value)),
    .groups = "drop"
  ) %>% 
  mutate(status = ifelse(grepl("off", status_u5mr, ignore.case = TRUE),
                         "u5mr off-track", "u5mr on-track")) %>% 
  select(-status_u5mr) %>%                          # drop code column
  pivot_longer(-status, names_to = "Metric") %>% 
  pivot_wider(names_from = status, values_from = value) %>% 
  select(Metric, `u5mr off-track`, `u5mr on-track`) %>% 
  # Extract birth weights first
  mutate(
    births_off = `u5mr off-track`[Metric == "Total Births"],
    births_on = `u5mr on-track`[Metric == "Total Births"]
  ) %>%
  # replace the Total calculation
  mutate(
    Total = case_when(
      Metric %in% c("Population-Weighted ANC4 (%)",
                    "Population-Weighted SAB (%)") ~
        (`u5mr off-track` * births_off +
         `u5mr on-track`  * births_on) /
        (births_off + births_on),                # weighted average
      TRUE ~ `u5mr off-track` + `u5mr on-track`   # simple sum
    )
  ) %>%
    # Remove the temporary birth weight columns
  select(-births_off, -births_on) %>%
  
  # Round all numeric columns to nearest integer
  mutate(
    `u5mr off-track` = round(`u5mr off-track`),
    `u5mr on-track` = round(`u5mr on-track`),
    Total = round(Total)
  ) %>%
  
  # keep the ordering block exactly as you already had --------------------
  arrange(factor(Metric, levels = c(
    "Total Countries", "Total Births",
    "Population-Weighted ANC4 (%)", "Population-Weighted SAB (%)",
    "Countries with ANC4 Data", "Countries Missing ANC4 Data",
    "Countries with SAB Data",  "Countries Missing SAB Data"
  )))

# 6. Export transformed datasets ----------------------------------------------
message("Exporting transformed datasets...")
write_xlsx(unicef_mnch_data_wide, file.path(OUTPUT_PATH, "unicef_mnch_data_wide.xlsx"))
write_xlsx(countries_summary, file.path(OUTPUT_PATH, "countries_summary.xlsx"))
write_xlsx(countries_indicators_u5mr_summary, file.path(OUTPUT_PATH, "countries_indicators_u5mr_summary.xlsx"))

# 7. Data inspection and preview ----------------------------------------------
cat("\nTransformed Data Overview\n")
cat("Tidy format dimensions:", dim(unicef_mnch_data), "\n")
cat("Wide format dimensions:", dim(unicef_mnch_data_wide), "\n")

cat("\nWide Format Preview (first 10 rows)\n")
print(unicef_mnch_data_wide, n = 10)

cat("\nCountries Summary Preview (first 10 rows)\n")
print(countries_summary, n = 10)

cat("\n=== Countries Indicators U5MR Summary ===\n")
print(countries_indicators_u5mr_summary)

cat("\n=== Transformation Complete ===\n")
