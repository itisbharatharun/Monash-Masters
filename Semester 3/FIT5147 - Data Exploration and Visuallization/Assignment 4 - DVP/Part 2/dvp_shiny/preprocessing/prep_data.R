# ============================================================
# DVP Part 2 — Preprocessing Script
# Bharath Arun Gandhimani | 35501308
# Produces:
#   lga_scatter_final.csv  — P2 Cleveland dot plot
#   p3_modeshare.csv       — P3 slope chart (work trips)
#   p4_gap_chart.csv       — P4 dumbbell gap chart
#   lga_explorer.csv       — LGA Explorer right column
#   p_school_mode.csv      — Policy card 03 school mode chart
#
# Run this script ONCE from the project root before launching the app.
# All source CSVs must be in the project root directory.
# Pre-processed outputs are written to the data/ folder.
# The Shiny app reads from data/ directly and does not require
# this script to be re-run unless source data changes.
# ============================================================

library(dplyr)
library(tidyr)
library(readr)

# Run this script from the project root directory (where global.R lives).
# Source CSVs are expected in the project root.
# Pre-processed outputs go to the data/ subfolder, which global.R reads from.
SOURCE_DIR <- "."
OUT_DIR    <- "data"

# ============================================================
# FILE 1: lga_scatter_final.csv
# 33 VISTA-overlapping LGAs for P2 Cleveland dot plot
# ============================================================

lga_q3 <- read_csv(file.path(SOURCE_DIR, "lga_q3_final.csv"), show_col_types = FALSE)

lga_scatter <- lga_q3 %>%
  filter(in_vista == TRUE) %>%
  select(lga_standard, investment_tier, investment_tier_order, project_count, hh_count) %>%
  arrange(hh_count)

write_csv(lga_scatter, file.path(OUT_DIR, "lga_scatter_final.csv"))
cat("lga_scatter_final.csv written:", nrow(lga_scatter), "rows\n")

# ============================================================
# FILE 2: p3_modeshare.csv
# Mode share % for Work Related weekday trips by investment tier
# For P3 slope chart
# ============================================================

we_trips <- read_csv(file.path(SOURCE_DIR, "we_trips_final.csv"), show_col_types = FALSE)

p3_modeshare <- we_trips %>%
  filter(
    dayType    == "Weekday",
    trippurp   == "Work Related",
    mode_group %in% c("Private Vehicle", "Public Transport", "Active Transport")
  ) %>%
  mutate(
    investment_tier = if_else(is.na(investment_tier), "None (0)", investment_tier),
    investment_tier_order = case_when(
      investment_tier == "None (0)"     ~ 0L,
      investment_tier == "Low (1-2)"    ~ 1L,
      investment_tier == "Medium (3-5)" ~ 2L,
      investment_tier == "High (6+)"    ~ 3L,
      TRUE ~ NA_integer_
    )
  ) %>%
  group_by(investment_tier, investment_tier_order, mode_group) %>%
  summarise(n_trips = n(), .groups = "drop") %>%
  group_by(investment_tier, investment_tier_order) %>%
  mutate(
    total_trips = sum(n_trips),
    pct = round(n_trips / total_trips * 100, 1)
  ) %>%
  ungroup() %>%
  select(investment_tier, investment_tier_order, mode_group, n_trips, total_trips, pct) %>%
  arrange(investment_tier_order, mode_group)

write_csv(p3_modeshare, file.path(OUT_DIR, "p3_modeshare.csv"))
cat("p3_modeshare.csv written:", nrow(p3_modeshare), "rows\n")

# ============================================================
# FILE 3: p4_gap_chart.csv
# Median car vs PT trip time — by tier AND by IRSD decile
# For P4 dumbbell gap chart (two stacked subplots)
# ============================================================

vista_merged <- read_csv(file.path(SOURCE_DIR, "vista_merged_final.csv"), show_col_types = FALSE)

# Panel A: by investment tier
p4_tier <- vista_merged %>%
  filter(
    triptime_flag == FALSE,
    mode_group %in% c("Private Vehicle", "Public Transport")
  ) %>%
  mutate(
    investment_tier = if_else(is.na(investment_tier), "None (0)", investment_tier),
    investment_tier_order = case_when(
      investment_tier == "None (0)"     ~ 0L,
      investment_tier == "Low (1-2)"    ~ 1L,
      investment_tier == "Medium (3-5)" ~ 2L,
      investment_tier == "High (6+)"    ~ 3L,
      TRUE ~ NA_integer_
    )
  ) %>%
  group_by(investment_tier, investment_tier_order, mode_group) %>%
  summarise(median_time = median(triptime, na.rm = TRUE), n = n(), .groups = "drop") %>%
  pivot_wider(names_from = mode_group, values_from = c(median_time, n)) %>%
  rename(
    car_median = `median_time_Private Vehicle`,
    pt_median  = `median_time_Public Transport`,
    n_car      = `n_Private Vehicle`,
    n_pt       = `n_Public Transport`
  ) %>%
  mutate(
    panel       = "tier",
    label       = investment_tier,
    label_order = investment_tier_order,
    penalty_min = pt_median - car_median,
    pt_ratio    = round(pt_median / car_median, 2)
  ) %>%
  select(panel, label, label_order, car_median, pt_median, penalty_min, pt_ratio, n_car, n_pt)

# Panel B: by IRSD decile
p4_irsd <- vista_merged %>%
  filter(
    triptime_flag == FALSE,
    mode_group %in% c("Private Vehicle", "Public Transport"),
    !is.na(IRSD_Decile)
  ) %>%
  group_by(IRSD_Decile, mode_group) %>%
  summarise(median_time = median(triptime, na.rm = TRUE), n = n(), .groups = "drop") %>%
  pivot_wider(names_from = mode_group, values_from = c(median_time, n)) %>%
  rename(
    car_median = `median_time_Private Vehicle`,
    pt_median  = `median_time_Public Transport`,
    n_car      = `n_Private Vehicle`,
    n_pt       = `n_Public Transport`
  ) %>%
  mutate(
    panel       = "irsd",
    label       = paste0("Decile ", IRSD_Decile),
    label_order = IRSD_Decile,
    penalty_min = pt_median - car_median,
    pt_ratio    = round(pt_median / car_median, 2)
  ) %>%
  select(panel, label, label_order, car_median, pt_median, penalty_min, pt_ratio, n_car, n_pt)

p4_gap_chart <- bind_rows(p4_tier, p4_irsd) %>%
  arrange(panel, label_order)

write_csv(p4_gap_chart, file.path(OUT_DIR, "p4_gap_chart.csv"))
cat("p4_gap_chart.csv written:", nrow(p4_gap_chart), "rows\n")

# ============================================================
# FILE 4: lga_explorer.csv
# Per-LGA mode share + trip time for the LGA Explorer
# ============================================================

lga_explorer <- we_trips %>%
  filter(dayType == "Weekday", trippurp == "Work Related") %>%
  mutate(investment_tier = if_else(is.na(investment_tier), "None (0)", investment_tier)) %>%
  group_by(lga_standard, investment_tier, investment_tier_order, project_count) %>%
  summarise(
    hh_count   = n_distinct(hhid),
    n_work_trips = n(),
    .groups = "drop"
  ) %>%
  left_join(
    we_trips %>%
      filter(dayType == "Weekday", trippurp == "Work Related",
             mode_group %in% c("Private Vehicle", "Public Transport", "Active Transport")) %>%
      mutate(investment_tier = if_else(is.na(investment_tier), "None (0)", investment_tier)) %>%
      group_by(lga_standard) %>%
      mutate(total = n()) %>%
      group_by(lga_standard, mode_group) %>%
      summarise(pct = round(n() / first(total) * 100, 1), .groups = "drop") %>%
      pivot_wider(names_from = mode_group, values_from = pct, values_fill = 0) %>%
      rename(
        car_pct    = `Private Vehicle`,
        pt_pct     = `Public Transport`,
        active_pct = `Active Transport`
      ),
    by = "lga_standard"
  ) %>%
  left_join(
    vista_merged %>%
      filter(
        triptime_flag == FALSE,
        mode_group %in% c("Private Vehicle", "Public Transport")
      ) %>%
      mutate(investment_tier = if_else(is.na(investment_tier), "None (0)", investment_tier)) %>%
      group_by(lga_standard, mode_group) %>%
      summarise(median_time = median(triptime, na.rm = TRUE), n = n(), .groups = "drop") %>%
      pivot_wider(names_from = mode_group, values_from = c(median_time, n)) %>%
      rename(
        car_median = `median_time_Private Vehicle`,
        pt_median  = `median_time_Public Transport`
      ) %>%
      mutate(
        penalty_min = pt_median - car_median,
        pt_ratio    = round(pt_median / car_median, 2)
      ) %>%
      select(lga_standard, car_median, pt_median, penalty_min, pt_ratio),
    by = "lga_standard"
  )

write_csv(lga_explorer, file.path(OUT_DIR, "lga_explorer.csv"))
cat("lga_explorer.csv written:", nrow(lga_explorer), "rows\n")

# ============================================================
# FILE 5: p_school_mode.csv
# Mode share for PRIMARY SCHOOL children by investment tier
# Weekday trips only, mainact == "Primary School"
# Supports Policy Implication Card 03 claim:
# "67% of primary school children in High-investment LGAs travel by private car"
# ============================================================

p_school_mode <- we_trips %>%
  filter(
    dayType  == "Weekday",
    mainact  == "Primary School",
    mode_group %in% c("Private Vehicle", "Public Transport", "Active Transport"),
    !is.na(investment_tier),
    investment_tier != ""
  ) %>%
  mutate(
    investment_tier_order = case_when(
      investment_tier == "Low (1-2)"    ~ 1L,
      investment_tier == "Medium (3-5)" ~ 2L,
      investment_tier == "High (6+)"    ~ 3L,
      TRUE ~ NA_integer_
    )
  ) %>%
  filter(!is.na(investment_tier_order)) %>%
  group_by(investment_tier, investment_tier_order, mode_group) %>%
  summarise(n_trips = n(), .groups = "drop") %>%
  group_by(investment_tier, investment_tier_order) %>%
  mutate(
    total_trips = sum(n_trips),
    pct = round(n_trips / total_trips * 100, 1)
  ) %>%
  ungroup() %>%
  select(investment_tier, investment_tier_order, mode_group, n_trips, total_trips, pct) %>%
  arrange(investment_tier_order, mode_group)

write_csv(p_school_mode, file.path(OUT_DIR, "p_school_mode.csv"))
cat("p_school_mode.csv written:", nrow(p_school_mode), "rows\n")
print(p_school_mode)

cat("\n=== All preprocessing complete. Files written to data/ ===\n")