# -----------------------------------------------------------------------------
# Title:   Report Generation Script
# Purpose: Generate PDF report from R Markdown template with professional
#          formatting and visualizations for maternal health coverage analysis
# -----------------------------------------------------------------------------

# Generate PDF report from R Markdown template
rmarkdown::render(
  input         = file.path(REPORT_PATH, "coverage_report.Rmd"),
  output_format = c("pdf_document"),
  output_dir    = REPORT_PATH,
  knit_root_dir = getwd()  # Set project root as knitting directory
)

# Display completion message
message("📝 All done! Plots and report written to report/") 
