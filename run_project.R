# -----------------------------------------------------------------------------
# Title:   Main Project Runner
# Purpose: Execute the complete UNICEF data analysis pipeline including data
#          loading, transformation, analysis, and report generation
# -----------------------------------------------------------------------------

# Set working directory to project root for consistent execution
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Define project paths for organized file structure
SCRIPTS_PATH <- "scripts/"
DATA_PATH <- "data/"
DOCS_PATH <- "docs/"
OUTPUT_PATH <- "output/"
DATA_PATH <- "data/"

# Create output directory if it doesn't exist
if (!dir.exists(OUTPUT_PATH)) {
  dir.create(OUTPUT_PATH, recursive = TRUE)
  cat("Created output directory:", OUTPUT_PATH, "\n")
}

# Load required libraries for the main runner
library(tidyverse)

# Clear environment (optional - uncomment if you want a clean start)
# rm(list = ls())

cat("=== UNICEF Data Analysis Project ===\n")
cat("Starting data loading and transformation process...\n\n")

# Step 1: Load user profile and setup environment
cat("Step 1: Loading user profile and setting up environment...\n")
source("user_profile.R")

cat("\n", strrep("=", 50), "\n")

# Step 2: Load all data sources
cat("Step 2: Loading data sources...\n")
source(file.path(SCRIPTS_PATH, "load.R"))

cat("\n", strrep("=", 50), "\n")

# Step 3: Transform and analyze data
cat("Step 3: Transforming and analyzing data...\n")
source(file.path(SCRIPTS_PATH, "transform.R"))

cat("\n", strrep("=", 50), "\n")

# Step 4: Create report
cat("Step 4: Creating report...\n")
source(file.path(SCRIPTS_PATH, "create_report.R"))

cat("\n", strrep("=", 50), "\n")

# Step 5: Project completion summary
cat("Step 5: Project completion summary...\n")
cat("✓ Data loading completed\n")
cat("✓ Data transformation completed\n")
cat("✓ Analysis completed\n\n")

cat("Available datasets in environment:\n")
cat("- unicef_mnch_data: UNICEF MNCH indicators from SDMX\n")
cat("- unicef_mnch_data_wide: Wide format MNCH data\n")
cat("- unicef_on_track_countries: On-track/off-track countries data\n")
cat("- un_population: UN Population Division data\n")
cat("- countries_summary: Comprehensive country-level summary\n")
cat("- indicator_summary: Summary statistics by indicator\n")
cat("- pop_weighted: Population-weighted analysis by U5MR status\n\n")

cat("Output files created in:", OUTPUT_PATH, "\n")
cat("- un_population.xlsx\n")
cat("- unicef_on_track_countries.xlsx\n")
cat("- unicef_mnch_data.xlsx\n")
cat("- unicef_mnch_data_wide.xlsx\n")
cat("- countries_summary.xlsx\n")
cat("- indicator_summary.xlsx\n")
cat("- pop_weighted.xlsx\n\n")

cat("Project execution completed successfully!\n")
