# -----------------------------------------------------------------------------
# Title:   User Profile - UNICEF Data and Analytics Project
# Author:  Your Name
# Date:    2025‑07‑27
# Purpose: Project configuration, path setup, and library management
# -----------------------------------------------------------------------------

# 1. Project paths setup ------------------------------------------------------
# Base project directory (adjust if needed)
PROJECT_ROOT <- getwd()

# Data directories
RAW_DATA_PATH <- file.path(PROJECT_ROOT, "01_rawdata")
DATA_PATH     <- file.path(PROJECT_ROOT, "data")
OUTPUT_PATH   <- file.path(PROJECT_ROOT, "output")

# Scripts directory
SCRIPTS_PATH  <- file.path(PROJECT_ROOT, "scripts")

# 2. Create directories if they don't exist --------------------------------
dirs_to_create <- c(RAW_DATA_PATH, DATA_PATH, OUTPUT_PATH, SCRIPTS_PATH)
for (dir in dirs_to_create) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    message("Created directory: ", dir)
  }
}

# 3. Required packages ------------------------------------------------------
required_packages <- c(
  # Core data manipulation
  "tidyverse",    # dplyr, ggplot2, tidyr, readr, purrr, tibble
  "readxl",       # Excel file reading
  "writexl",      # Excel file writing
  
  # SDMX and API handling
  "rsdmx",        # SDMX data import
  "httr",         # HTTP requests
  "jsonlite",     # JSON parsing
  
  # Utilities
  "glue",         # String interpolation
  "stringr"       # String manipulation
)

# 4. Install missing packages ----------------------------------------------
install_missing_packages <- function(packages) {
  missing_packages <- packages[!packages %in% installed.packages()[,"Package"]]
  
  if (length(missing_packages) > 0) {
    message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
    install.packages(missing_packages, dependencies = TRUE)
    message("Package installation complete!")
  } else {
    message("All required packages are already installed.")
  }
}

# Install packages
install_missing_packages(required_packages)

# 5. Load libraries --------------------------------------------------------
load_libraries <- function(packages) {
  for (package in packages) {
    library(package, character.only = TRUE)
    message("Loaded: ", package)
  }
}

# Load all required libraries
load_libraries(required_packages)

# 6. Utility functions ----------------------------------------------------
# Function to check if required files exist
check_required_files <- function() {
  required_files <- c(
    file.path(RAW_DATA_PATH, "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx"),
    file.path(RAW_DATA_PATH, "On-track and off-track countries.xlsx")
  )
  
  missing_files <- required_files[!file.exists(required_files)]
  
  if (length(missing_files) > 0) {
    warning("Missing required files:\n", paste(missing_files, collapse = "\n"))
    return(FALSE)
  } else {
    message("All required files are present.")
    return(TRUE)
  }
}

# Function to get project status
get_project_status <- function() {
  cat("\n=== UNICEF Data and Analytics Project Status ===\n")
  cat("Project root:", PROJECT_ROOT, "\n")
  cat("Raw data path:", RAW_DATA_PATH, "\n")
  cat("Data path:", DATA_PATH, "\n")
  cat("Output path:", OUTPUT_PATH, "\n")
  cat("Scripts path:", SCRIPTS_PATH, "\n")
  cat("Required packages loaded:", length(required_packages), "\n")
  cat("Files check:", ifelse(check_required_files(), "PASS", "FAIL"), "\n")
}

# 7. Initialize project ---------------------------------------------------
message("Initializing UNICEF Data and Analytics Project...")
get_project_status()

# 8. Clean up ------------------------------------------------------------
# Remove temporary variables
rm(dirs_to_create, install_missing_packages, load_libraries, check_required_files, get_project_status)

message("User profile loaded successfully!")
