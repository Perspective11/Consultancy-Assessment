# UNICEF Data and Analytics Technical Evaluation

This repository contains the tasks for the **UNICEF Data and Analytics technical evaluation** for education.

## Repository Structure

```
Consultancy-Assessment/
├── data/                          # Raw input files and cached data
│   ├── WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx
│   ├── On-track and off-track countries.xlsx
│   └── unicef_mnch_data.xlsx     # Cached UNICEF data
├── output/                        # Exported datasets
│   ├── countries_summary.xlsx     # Comprehensive country-level summary
│   ├── indicator_summary.xlsx     # Summary statistics by indicator
│   ├── pop_weighted.xlsx         # Population-weighted analysis
│   ├── un_population.xlsx        # Processed UN Population data
│   ├── unicef_mnch_data.xlsx     # Processed MNCH data
│   ├── unicef_mnch_data_wide.xlsx # Wide format MNCH data
│   └── unicef_on_track_countries.xlsx # Processed on-track countries
├── reports/                       # Generated reports
│   ├── coverage_report.Rmd        # Streamlined 3-page report
│   ├── coverage_report.pdf        # Final PDF report
│   └── unicef_logo.png           # UNICEF logo for report generation
├── scripts/                       # R scripts for data processing
│   ├── load.R                     # Data loading and caching
│   ├── transform.R                # Data transformation
│   └── create_report.R            # Report generation
├── user_profile.R                 # Project setup and configuration
├── run_project.R                  # Main execution script
├── Consultancy-Assessment.Rproj   # RStudio project file
└── README.md                      # This documentation file
```

## Folder and File Purposes

### 📁 data/
**Purpose:** Contains the original input files required for the analysis and cached data.

**Files:**
- `WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx` - UN Population Division demographic data with country populations and births
- `On-track and off-track countries.xlsx` - UNICEF classification of countries by U5MR achievement status
- `unicef_mnch_data.xlsx` - Cached UNICEF data from API calls

### 📁 output/
**Purpose:** Contains all processed and exported datasets from the analysis pipeline.

**Files:**
- `countries_summary.xlsx` - Main analysis dataset combining all sources
- `indicator_summary.xlsx` - Summary statistics by maternal health indicator
- `pop_weighted.xlsx` - Population-weighted analysis by U5MR status
- `un_population.xlsx` - Processed UN Population Division data
- `unicef_mnch_data.xlsx` - Processed maternal health data from UNICEF API
- `unicef_mnch_data_wide.xlsx` - Wide format of maternal health data
- `unicef_on_track_countries.xlsx` - Processed on-track countries classification

### 📁 reports/
**Purpose:** Contains the final report and its source files.

**Files:**
- `coverage_report.Rmd` - R Markdown source for the analysis report
- `coverage_report.pdf` - Final 3-page PDF report with visualizations
- `unicef_logo.png` - UNICEF logo for report generation

### 📁 scripts/
**Purpose:** Contains the R scripts that perform the data processing pipeline.

**Files:**
- `load.R` - Loads and processes raw data from multiple sources
- `transform.R` - Transforms data into analysis-ready formats
- `create_report.R` - Generates the final PDF report

### 📄 Root Files
**Purpose:** Project configuration and execution files.

**Files:**
- `user_profile.R` - Project setup, package management, and configuration
- `run_project.R` - Main script that executes the entire analysis pipeline
- `Consultancy-Assessment.Rproj` - RStudio project configuration
- `README.md` - This documentation file

## How to Reproduce the Analysis

### Prerequisites

1. **Install R** (version 4.0 or higher)
2. **Install RStudio** (recommended for easier workflow)
3. **Install required R packages** (will be installed automatically by the project)

### Step-by-Step Instructions

#### 1. Clone or Download the Repository
```bash
git clone [repository-url]
cd Consultancy-Assessment
```

#### 2. Verify Required Input Files
Ensure these files are present in the `data/` folder:
- `WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx`
- `On-track and off-track countries.xlsx`

#### 3. Open the Project
- **Option A (RStudio):** Open `Consultancy-Assessment.Rproj` in RStudio
- **Option B (R console):** Set working directory to the project folder

#### 4. Run the Complete Analysis
Execute the main project script:
```r
source("run_project.R")
```

This single command will:
- Set up the project environment
- Install required packages
- Load and process all data
- Generate the final report

#### 5. Alternative: Step-by-Step Execution
If you prefer to run each step individually:

```r
# Step 1: Project setup
source("user_profile.R")

# Step 2: Load and process data
source("scripts/load.R")

# Step 3: Transform and analyze data
source("scripts/transform.R")

# Step 4: Generate the report
source("scripts/create_report.R")
```

### Expected Output

After successful execution, you should see:

1. **Data files** in the `output/` folder:
   - `countries_summary.xlsx` - Main analysis dataset
   - `pop_weighted.xlsx` - Population-weighted results
   - Other processed datasets

2. **Report** in the `reports/` folder:
   - `coverage_report.pdf` - 3-page analysis report with visualizations

### Troubleshooting

#### Common Issues:

1. **Missing input files:**
   - Ensure both Excel files are in `data/` folder
   - Check file names match exactly

2. **Package installation errors:**
   - The project will automatically install required packages
   - If manual installation needed: `install.packages(c("tidyverse", "rmarkdown", "tinytex"))`

3. **PDF generation issues:**
   - Ensure `tinytex` is installed: `tinytex::install_tinytex()`
   - Check that LaTeX is available on your system

4. **API connection issues:**
   - The project caches UNICEF data on first run
   - Subsequent runs use cached data for reliability

### Data Sources

The analysis uses three main data sources:

1. **UNICEF SDMX API** - Maternal health indicators (ANC4, SBA)
2. **UN Population Division** - Demographic data and country reference
3. **UNICEF On-track Countries** - U5MR achievement classification

### Analysis Overview

The project analyzes maternal health coverage indicators in relation to under-5 mortality rate (U5MR) performance:

- **ANC4**: Percentage of women with at least 4 antenatal care visits
- **SBA**: Percentage of deliveries attended by skilled health personnel
- **Population-weighted analysis** comparing on-track vs off-track countries

The final report provides a concise 3-page analysis with professional visualizations and key findings.

## Technical Details

### Required R Packages
- `tidyverse` - Data manipulation and analysis
- `rsdmx` - SDMX data import
- `readxl`/`writexl` - Excel file handling
- `httr`/`jsonlite` - API communication
- `rmarkdown` - Report generation
- `tinytex` - PDF compilation support

### System Requirements
- R 4.0 or higher
- Internet connection (for first-time data download)
- LaTeX installation (for PDF generation)

### Performance Notes
- First run: ~2-3 minutes (includes data download and caching)
- Subsequent runs: ~30 seconds (uses cached data)
- Report generation: ~1 minute

---

## Job Application Information

**Primary Position Applied For:**
- Household Survey Data Analyst Consultant – Req. #581656

**Additional Position of Interest:**
- Administrative Data Analyst – Req. #581696

