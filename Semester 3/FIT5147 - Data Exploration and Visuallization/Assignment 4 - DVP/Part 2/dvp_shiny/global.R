# ============================================================
# DVP Part 2 — Interactive Narrative Visualisation
# From Roads to Classrooms: Educational Infrastructure
# Investment, Socioeconomic Equity, and Household Travel
# Behaviour in Victoria (2023-2025)
#
# Author:  Bharath Arun Gandhimani | Student ID: 35501308
# Unit:    FIT5147 Data Exploration and Visualisation
# Session: Applied Session 7 | TA: Michael Niemann, Ayden Zhou
#
# Run: shiny::runApp() from the project root directory
# Packages: shiny, bslib, plotly, dplyr, tidyr, shinyjs
# ============================================================

library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(tidyr)
library(shinyjs)

# ============================================================
# DATA LOADING
# All CSVs are pre-processed by prep_data.R and stored in data/
# The app reads these directly — no runtime wrangling.
# ============================================================

lga_scatter  <- read.csv("data/lga_scatter_final.csv",  stringsAsFactors = FALSE)
p3_data      <- read.csv("data/p3_modeshare.csv",       stringsAsFactors = FALSE)
p4_data      <- read.csv("data/p4_gap_chart.csv",       stringsAsFactors = FALSE)
lga_explorer <- read.csv("data/lga_explorer.csv",       stringsAsFactors = FALSE)
school_mode  <- read.csv("data/p_school_mode.csv",      stringsAsFactors = FALSE)

# ============================================================
# CONSTANTS — palette consistent with DEP report
# ============================================================

TIER_COLS <- c(
  "None (0)"     = "#9BA4B5",
  "Low (1-2)"    = "#F5C518",
  "Medium (3-5)" = "#E87722",
  "High (6+)"    = "#C0392B"
)

MODE_COLS <- c(
  "Private Vehicle"  = "#E87722",
  "Public Transport" = "#2980B9",
  "Active Transport" = "#27AE60"
)

TIER_ORDER <- c("None (0)", "Low (1-2)", "Medium (3-5)", "High (6+)")

BG_CHART <- "#F7F6F3"
BG_WHITE <- "#FFFFFF"
GRID_COL <- "#EAEAE6"

# ============================================================
# HEADLINE STATS — derived from pre-aggregated CSVs
# These drive the stat strip in the title panel.
# Computed here so ui.R never hardcodes findings.
# ============================================================

STAT_CASEY_PROJECTS <- lga_scatter %>%
  filter(lga_standard == "Casey") %>%
  pull(project_count)

STAT_HIGH_CAR_PCT <- p3_data %>%
  filter(investment_tier == "High (6+)", mode_group == "Private Vehicle") %>%
  pull(pct)

STAT_HIGH_PT_RATIO <- p4_data %>%
  filter(panel == "tier", label == "High (6+)") %>%
  pull(pt_ratio)