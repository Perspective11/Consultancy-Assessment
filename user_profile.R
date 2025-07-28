# -----------------------------------------------------------------------------
# Title:   User Profile and Project Configuration
# Purpose: Set up project environment, install required packages, configure
#          paths, and provide utility functions for the UNICEF data analysis
#          project
# -----------------------------------------------------------------------------

# 1. Project paths setup ------------------------------------------------------
PROJECT_ROOT <- getwd()

RAW_DATA_PATH <- file.path(PROJECT_ROOT, "01_rawdata")
DATA_PATH     <- file.path(PROJECT_ROOT, "data")
OUTPUT_PATH   <- file.path(PROJECT_ROOT, "output")
SCRIPTS_PATH  <- file.path(PROJECT_ROOT, "scripts")
REPORT_PATH   <- file.path(PROJECT_ROOT, "reports")

# 2. Create directories if they don't exist ---------------------------------
dirs_to_create <- c(RAW_DATA_PATH, DATA_PATH, OUTPUT_PATH, SCRIPTS_PATH, REPORT_PATH)
for (dir in dirs_to_create) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    message("Created directory: ", dir)
  }
}

# 3. Required packages -------------------------------------------------------
required_packages <- c(
  # Core data manipulation
  "tidyverse", "readxl", "writexl",
  # SDMX / API
  "rsdmx", "httr", "jsonlite",
  # Utilities
  "glue", "stringr", "scales",
  # Reporting
  "rmarkdown", "knitr",
  # LaTeX engine
  "tinytex",
  # Colour tools
  "colorspace"
)

# 4. Install missing packages -----------------------------------------------
install_missing_packages <- function(packages) {
  missing_packages <- packages[!packages %in% installed.packages()[, "Package"]]
  if (length(missing_packages) > 0) {
    message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
    install.packages(missing_packages, dependencies = TRUE)
    message("Package installation complete!")
  } else {
    message("All required packages are already installed.")
  }
}

install_missing_packages(required_packages)

# 5. Load libraries ----------------------------------------------------------
for (pkg in required_packages) {
  library(pkg, character.only = TRUE)
  message("Loaded package: ", pkg)
}

# 6. Install TinyTeX if needed ----------------------------------------------
# Install minimal TeX distribution for PDF rendering capability
if (!tinytex::is_tinytex()) {
  message("Installing TinyTeX for PDF rendering...")
  tinytex::install_tinytex()
  tinytex::tlmgr_update(self = TRUE, all = TRUE)
} else {
  message("TinyTeX already installed.")
}

# Define color palette for consistent visualization styling
category_colors  <- c("#1CABE2", "#80BD41", "#F26A21")

# 7. Utility functions ------------------------------------------------------
# Function to check if required raw files exist
check_required_files <- function() {
  required_files <- c(
    file.path(RAW_DATA_PATH, "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx"),
    file.path(RAW_DATA_PATH, "On-track and off-track countries.xlsx")
  )
  missing_files <- required_files[!file.exists(required_files)]
  if (length(missing_files) > 0) {
    warning("Missing required files:\n", paste(missing_files, collapse = "\n"))
    return(FALSE)
  }
  message("All required files are present.")
  TRUE
}

# Function to display project status
get_project_status <- function() {
  cat("\n=== UNICEF Data and Analytics Project Status ===\n")
  cat("Project root:      ", PROJECT_ROOT, "\n")
  cat("Raw data path:     ", RAW_DATA_PATH, "\n")
  cat("Data cache path:   ", DATA_PATH, "\n")
  cat("Output path:       ", OUTPUT_PATH, "\n")
  cat("Scripts path:      ", SCRIPTS_PATH, "\n")
  cat("Reports path:      ", REPORT_PATH, "\n")
  cat("Packages loaded:   ", length(required_packages), "\n")
  cat("Files check:       ", ifelse(check_required_files(), "PASS", "FAIL"), "\n")
}

# 8. Initialize project -----------------------------------------------------
message("Initializing UNICEF Data and Analytics Project...")
get_project_status()

# Clean up temporary variables
rm(dirs_to_create, install_missing_packages, pkg, check_required_files, get_project_status)

message("User profile loaded successfully!")
