# UNICEF Data and Analytics Technical Evaluation

This repository contains the tasks for the **UNICEF Data and Analytics technical evaluation** for education.

## Project Overview

This project processes and analyzes UNICEF Maternal, Newborn, and Child Health (MNCH) data along with UN Population Division data.

## Data Sources

### Primary Data Sources
- **UNICEF SDMX API**: Maternal and Child Health indicators (MNCH_ANC4, MNCH_SAB)
- **UN Population Division**: Demographic indicators and country reference data
- **UNICEF On-track Countries**: Country status and classification data

### Caching Mechanism
The indicator data is fetched from the UNICEF SDMX API on the first run and cached locally in Excel format. Subsequent runs load data from the cache for improved performance and reduced API calls.

## Project Structure

```
Consultancy-Assessment/
├── 01_rawdata/                    # Raw input files
│   ├── WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx
│   └── On-track and off-track countries.xlsx
├── data/                          # Cached and processed data
├── output/                        # Exported datasets
├── scripts/
│   ├── load.R                     # Data loading and caching
│   └── transform.R                # Data transformation
├── user_profile.R                 # Project setup and configuration
├── run_project.R                  # Main execution script
└── README.md                      # This file
```

## Data Processing Pipeline

### 1. Project Setup (`user_profile.R`)
- Sets up project paths and directories
- Installs and loads required R packages
- Validates required input files
- Provides project status and utility functions

### 2. Data Loading (`scripts/load.R`)
- Loads UN Population Division data from "Projections" sheet
- Fetches MNCH data from UNICEF SDMX API (first run) or loads from cache
- Processes UNICEF on-track countries data
- Standardizes country codes and names based on UN Population dataset
- Exports cleaned datasets to output directory

### 3. Data Transformation (`scripts/transform.R`)
- Creates wide format datasets for analysis convenience
- Builds comprehensive country summary with population and indicator data
- Computes latest indicator values per country
- Calculates population-weighted coverage by U5MR status
- Exports transformed datasets

## Dataset Structures

### countries_summary
A comprehensive country-level dataset combining multiple sources:

| Column | Description | Source |
|--------|-------------|---------|
| `country_code` | 3-letter ISO country code | Standardized across all sources |
| `country_name` | Country name | UN Population Division |
| `status_u5mr` | U5MR status classification | UNICEF On-track Countries |
| `total_population` | Total population (thousands) | UN Population Division |
| `births` | Annual births (thousands) | UN Population Division |
| `last_anc4_year` | Most recent year with ANC4 data | UNICEF MNCH Data |
| `last_anc4_value` | Latest ANC4 coverage value | UNICEF MNCH Data |
| `last_sab_year` | Most recent year with SAB data | UNICEF MNCH Data |
| `last_sab_value` | Latest SAB coverage value | UNICEF MNCH Data |

### pop_weighted
Population-weighted analysis by U5MR status:

| Column | Description |
|--------|-------------|
| `status_u5mr` | U5MR status classification (On-track/Off-track) |
| `pw_anc4` | Population-weighted ANC4 coverage |
| `pw_sab` | Population-weighted SBA coverage |
| `total_births` | Total births in the status group |
| `n_total` | Number of countries in the status group |
| `n_missing_anc4` | Number of countries missing ANC4 data |
| `n_missing_sab` | Number of countries missing SBA data |

### unicef_mnch_data (Tidy Format)
Long format dataset with one observation per row:

| Column | Description |
|--------|-------------|
| `country_code` | 3-letter ISO country code |
| `country_name` | Country name (from UN Population) |
| `indicator` | Indicator code (MNCH_ANC4, MNCH_SAB) |
| `sex` | Sex classification |
| `year` | Year of observation |
| `value` | Indicator value |

### unicef_mnch_data_wide (Wide Format)
Wide format dataset with indicators as columns:

| Column | Description |
|--------|-------------|
| `country_code` | 3-letter ISO country code |
| `country_name` | Country name |
| `year` | Year of observation |
| `MNCH_ANC4` | ANC4 coverage value |
| `MNCH_SAB` | SAB coverage value |

## Data Standardization

The country codes and names are standardized based on the UN Population Division dataset to ensure consistency across all data sources. This standardization:
- Uses 3-letter ISO country codes as the primary identifier
- Applies UN Population Division country names throughout
- Filters out non-country geographic areas (regions, subregions)
- Ensures data quality through consistent naming conventions

## Usage

### Quick Start
1. Ensure all required raw data files are in the `01_rawdata/` directory
2. Run the main project script:
   ```r
   source("run_project.R")
   ```

### Manual Execution
1. Load project setup:
   ```r
   source("user_profile.R")
   ```
2. Load and process data:
   ```r
   source("scripts/load.R")
   ```
3. Transform and analyze data:
   ```r
   source("scripts/transform.R")
   ```

## Output Files

The project generates the following output files in the `output/` directory:

### Raw Data Exports
- `un_population.xlsx` - Processed UN Population Division data
- `unicef_on_track_countries.xlsx` - Processed on-track countries data (country_code, status_u5mr)
- `unicef_mnch_data.xlsx` - Processed MNCH data from SDMX

### Transformed Data
- `unicef_mnch_data_wide.xlsx` - Wide format MNCH data
- `countries_summary.xlsx` - Comprehensive country-level summary
- `indicator_summary.xlsx` - Summary statistics by indicator
- `pop_weighted.xlsx` - Population-weighted analysis by U5MR status

## Dependencies

### Required R Packages
- `tidyverse`: Data manipulation and analysis
- `rsdmx`: SDMX data import
- `readxl`/`writexl`: Excel file handling
- `httr`/`jsonlite`: API communication
- `glue`: String interpolation
- `stringr`: String manipulation

### Required Input Files
- `WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx` (UN Population Division)
- `On-track and off-track countries.xlsx` (UNICEF)

## Configuration

The project uses centralized configuration in `user_profile.R`:
- File paths and caching settings

