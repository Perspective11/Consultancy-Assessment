# -----------------------------------------------------------------------------
# Title:   Data Loading Script - UNICEF SDMX and Excel Files
# Author:  Your Name
# Date:    2025‑07‑27
# -----------------------------------------------------------------------------

# Note: Libraries and paths are loaded from user_profile.R

# 1. Project configuration ----------------------------------------------------
# UNICEF SDMX API configuration
UNICEF_API_CONFIG <- list(
  agency_id  = "UNICEF",
  flow_id    = "GLOBAL_DATAFLOW",
  version    = "1.0",
  base_url   = "https://sdmx.data.unicef.org/ws/public/sdmxapi/rest"
)

# Data parameters
DATA_CONFIG <- list(
  indicators = c("MNCH_ANC4", "MNCH_SAB"),
  year_range = 2018:2022
)

# 2. Load UN Population Division data ------------------------------------------
message("Loading UN Population Division data...")
un_population <- read_excel(
  file.path(RAW_DATA_PATH, "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx"),
  sheet = "Projections",
  col_names = FALSE
)

# Find "Index" row and use as column headers
index_row <- which(apply(un_population, 1, function(x) any(x == "Index", na.rm = TRUE)))
if (length(index_row) > 0) {
  header_row <- index_row[1]
  col_names <- as.character(un_population[header_row, ])
  un_population <- un_population[-(1:header_row), ]
  colnames(un_population) <- col_names
} else {
  warning("Could not find row containing 'Index' in the Projections sheet")
}

# Filter for 2022 country-level data and select relevant columns
un_population <- un_population %>%
  filter(Type == "Country/Area", Year == 2022) %>%
  select(
    country_code = `ISO3 Alpha-code`,
    total_population = `Total Population, as of 1 July (thousands)`,
    births = `Births (thousands)`,
    country_name = `Region, subregion, country or area *`
  ) %>%
  mutate(
    total_population = as.numeric(total_population),
    births = as.numeric(births)
  )

# 3. Load or fetch UNICEF MNCH data -------------------------------------------
# Build SDMX‑ML data URL using configuration from load.R
dq       <- str_c(".", str_c(DATA_CONFIG$indicators, collapse = "+"), ".")
data_url <- glue(
  "{UNICEF_API_CONFIG$base_url}/data/{UNICEF_API_CONFIG$agency_id},{UNICEF_API_CONFIG$flow_id},{UNICEF_API_CONFIG$version}/{dq}",
  "?startPeriod={min(DATA_CONFIG$year_range)}",
  "&endPeriod={max(DATA_CONFIG$year_range)}",
  "&format=sdmx-2.1"
)

# Cache file path
mnch_excel_file <- file.path(DATA_PATH, "unicef_mnch_data.xlsx")

if (file.exists(mnch_excel_file)) {
  message("Loading MNCH data from cache: ", mnch_excel_file)
  unicef_mnch_data <- read_excel(mnch_excel_file)
} else {
  message("Fetching MNCH data from UNICEF SDMX API...")
  sdmx_obj <- readSDMX(data_url)
  
  unicef_mnch_data <- as_tibble(as.data.frame(sdmx_obj, stringsAsFactors = FALSE)) %>%
    # Filter for country codes that exist in un_population
    filter(REF_AREA %in% un_population$country_code) %>%
    select(
      country_code  = REF_AREA,
      indicator     = INDICATOR,
      sex           = SEX,
      year          = TIME_PERIOD,
      value         = OBS_VALUE
    ) %>%
    mutate(
      year  = as.integer(year),
      value = as.numeric(value)
    ) %>%
    left_join(
      un_population %>% select(country_code, country_name),
      by = "country_code"
    )
  
  message("Writing MNCH data to Excel cache: ", mnch_excel_file)
  write_xlsx(unicef_mnch_data, mnch_excel_file)
}

# 4. Load UNICEF on-track countries data --------------------------------------
message("Loading UNICEF on-track countries data...")
unicef_on_track_countries <- read_excel(file.path(RAW_DATA_PATH, "On-track and off-track countries.xlsx")) %>%
  select(
    country_code = `ISO3Code`,
    status_u5mr = `Status.U5MR`
  ) %>%
  # Convert status_u5mr to on-track or off-track
  mutate(status_u5mr = case_when(
    str_to_lower(status_u5mr) %in% c("achieved", "on-track", "on track") ~ "on-track",
    str_to_lower(status_u5mr) %in% c("acceleration needed", "off-track") ~ "off-track",
    TRUE ~ NA_character_
  )) %>%
  # Replace Kosovo with the updated ISO3 code XKX
  mutate(country_code = case_when(
    country_code == "RKS" ~ "XKX",
    TRUE ~ country_code
  ))
# 5. Export cleaned datasets ---------------------------------------------------
message("Exporting cleaned datasets...")
write_xlsx(un_population, file.path(OUTPUT_PATH, "un_population.xlsx"))
write_xlsx(unicef_on_track_countries, file.path(OUTPUT_PATH, "unicef_on_track_countries.xlsx"))
write_xlsx(unicef_mnch_data, file.path(OUTPUT_PATH, "unicef_mnch_data.xlsx"))

# 6. Data inspection ----------------------------------------------------------
cat("\n=== Data Loading Summary ===\n")
cat("UN Population data dimensions:", dim(un_population), "\n")
cat("UNICEF MNCH data dimensions:", dim(unicef_mnch_data), "\n")
cat("On-track countries dimensions:", dim(unicef_on_track_countries), "\n")
cat("Number of countries with MNCH data:", n_distinct(unicef_mnch_data$country_code), "\n")
