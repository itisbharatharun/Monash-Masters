# ------------------------------------------------------------------------------
### DATA CHECKING FIGURES — Appendix
# These figures were produced during the checking process to visually identify
# non-numeric string values in totalbikes and numstops, and overnight codes
# in the starthour field
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(scales)
library(patchwork)

# ---- Figure A1: Checking totalbikes and numstops for non-numeric entries ----
hh_raw      <- read_csv("household_vista_2024_2025.csv")
persons_raw <- read_csv("person_vista_2024_2025.csv")

bikes_check <- hh_raw %>%
  count(totalbikes) %>%
  mutate(
    is_error  = totalbikes == "Missing/Refused",
    totalbikes = fct_reorder(totalbikes, n)
  )

stops_check <- persons_raw %>%
  count(numstops) %>%
  mutate(
    is_error      = numstops == "Refused to complete diary/Missing",
    display_label = ifelse(numstops == "Refused to complete diary/Missing",
                           "Refused/\nMissing", numstops),
    display_label = fct_reorder(display_label, n)
  )

pA1a <- ggplot(bikes_check, aes(x = fct_reorder(totalbikes, n), y = n,
                                fill = is_error)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = n), hjust = -0.2, size = 3, colour = "grey25") +
  coord_flip() +
  scale_fill_manual(
    values = c("FALSE" = "#999999", "TRUE" = "#D95F02"),
    labels = c("FALSE" = "Valid numeric value",
               "TRUE"  = "Non-numeric string — converted to NaN"),
    name = NULL
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "totalbikes: 244 entries contain non-numeric string",
    x = "Field Value",
    y = "Number of Records"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        panel.grid.major.y = element_blank())

pA1b <- ggplot(stops_check, aes(x = display_label, y = n,
                                fill = is_error)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = n), hjust = -0.2, size = 3, colour = "grey25") +
  coord_flip() +
  scale_fill_manual(
    values = c("FALSE" = "#999999", "TRUE" = "#D95F02"),
    labels = c("FALSE" = "Valid numeric value",
               "TRUE"  = "Non-numeric string — converted to NaN"),
    name = NULL
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "numstops: 60 entries contain non-numeric string",
    x = "Field Value",
    y = "Number of Records"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        panel.grid.major.y = element_blank())

pA1 <- pA1a + pA1b +
  plot_annotation(
    title    = "Non-Numeric String Values Detected in totalbikes and numstops Fields",
    subtitle = paste0(
      "Orange bars = records coded as string refusal values rather than numeric counts\n",
      "These were converted to NaN prior to analysis"
    ),
    caption  = "Source: VISTA 2024-25 household and person files (pre-cleaning)",
    theme = theme(
      plot.title    = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 9.5, colour = "grey40"),
      plot.caption  = element_text(size = 8, colour = "grey50")
    )
  )

print(pA1)
ggsave("AppA1_checking_string_errors.png", plot = pA1,
       width = 12, height = 5, dpi = 300)


# ---- Figure A2: Checking starthour for overnight trip codes ----
trips_raw <- read_csv("trips_vista_2024_2025.csv")

starthour_check <- trips_raw %>%
  count(starthour) %>%
  mutate(is_error = starthour > 23)

pA2 <- ggplot(starthour_check, aes(x = starthour, y = n, fill = is_error)) +
  geom_bar(stat = "identity", width = 0.8) +
  geom_vline(xintercept = 23.5, linetype = "dashed",
             colour = "#D95F02", linewidth = 0.8) +
  annotate("label",
           x = 25.5, y = max(starthour_check$n) * 0.7,
           label = "80 records\nwith values 24-27\n(overnight trips\ncrossing midnight)",
           size = 3, fill = "white", colour = "#D95F02",
           label.size = 0.3, lineheight = 1.2) +
  scale_fill_manual(
    values = c("FALSE" = "#999999", "TRUE" = "#D95F02"),
    labels = c("FALSE" = "Valid hour value (0-23)",
               "TRUE"  = "Overnight trip code (24-27) — recoded to 0-3"),
    name = "starthour value"
  ) +
  scale_x_continuous(breaks = seq(0, 27, 3)) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "starthour Field Contains 80 Records with Values Above 23",
    subtitle = paste0(
      "Values 24-27 represent overnight trips that crossed midnight | ",
      "Dashed line marks the boundary of the valid 0-23 hour scale\n",
      "These were recoded to 0-3 in a new derived column starthour_norm"
    ),
    x       = "Trip Start Hour",
    y       = "Number of Records",
    caption = "Source: VISTA 2024-25 trips file (pre-cleaning)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 9.5, colour = "grey40"),
    legend.position  = "bottom",
    panel.grid.minor = element_blank()
  )

print(pA2)
ggsave("AppA2_checking_starthour.png", plot = pA2,
       width = 11, height = 5.5, dpi = 300)

# ---- Figure A3: Checking triptime for implausible outliers ----
trips_raw <- read_csv("trips_vista_2024_2025.csv")

triptime_check <- trips_raw %>%
  mutate(is_outlier = triptime > 480)

# Panel A: main distribution (0-200 min), note about outliers
pA3_main <- ggplot(
  triptime_check %>% filter(triptime <= 200),
  aes(x = triptime, fill = is_outlier)
) +
  geom_histogram(binwidth = 5, colour = "white", linewidth = 0.2) +
  annotate("label",
           x = 150, y = 6000,
           label = "5 records above 480 min\nexist but are not visible\nat this scale — see right panel",
           size = 3, fill = "#FFF3EE", colour = "#D95F02",
           label.size = 0.3, lineheight = 1.2) +
  scale_fill_manual(
    values = c("FALSE" = "#999999", "TRUE" = "#D95F02"),
    labels = c("FALSE" = "Plausible trip duration",
               "TRUE"  = "Implausible outlier (> 480 min)"),
    name = NULL
  ) +
  scale_x_continuous(
    breaks = seq(0, 200, 20),
    labels = function(x) paste0(x, " min")
  ) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Full distribution (0-200 min shown)",
    x     = "Trip Duration (minutes)",
    y     = "Number of Records"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position    = "none",
    panel.grid.minor   = element_blank(),
    plot.title         = element_text(size = 11, colour = "grey30")
  )

# Panel B: zoomed view — only the 5 outlier records
outlier_data <- triptime_check %>% filter(triptime > 480)

pA3_zoom <- ggplot(outlier_data, aes(x = triptime, fill = is_outlier)) +
  geom_histogram(binwidth = 20, colour = "white", linewidth = 0.2) +
  geom_text(
    stat = "bin", binwidth = 20,
    aes(label = after_stat(ifelse(count > 0, count, ""))),
    vjust = -0.5, size = 3.5, colour = "#D95F02", fontface = "bold"
  ) +
  scale_fill_manual(
    values = c("TRUE" = "#D95F02"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(480, 1500),
    breaks = seq(500, 1500, 200),
    labels = function(x) paste0(x, " min")
  ) +
  scale_y_continuous(
    limits = c(0, 4),
    breaks = 0:4
  ) +
  labs(
    title = "Zoomed: records above 480 min (n = 5)",
    x     = "Trip Duration (minutes)",
    y     = "Number of Records"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "none",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(size = 11, colour = "#D95F02",
                                    face = "bold")
  )

# Combine
pA3 <- pA3_main + pA3_zoom +
  plot_annotation(
    title    = "triptime Field Contains 5 Records Exceeding 480 Minutes",
    subtitle = paste0(
      "Left panel = full trip duration distribution | ",
      "Right panel = zoomed view of the 5 implausible outlier records\n",
      "Outliers were flagged with a boolean column and excluded from duration ",
      "visualisations but retained in the dataset"
    ),
    caption  = "Source: VISTA 2024-25 trips file (pre-cleaning)",
    theme = theme(
      plot.title    = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 9.5, colour = "grey40"),
      plot.caption  = element_text(size = 8, colour = "grey50")
    )
  )

print(pA3)
ggsave("AppA3_checking_triptime.png", plot = pA3,
       width = 12, height = 10, dpi = 300)


### Q1 - A

library(tidyverse)
library(ggplot2)
library(scales)
library(viridis)

# Load data
we <- read_csv("we_trips_final.csv")

# Fix investment tier NAs and set factor order
we <- we %>%
  mutate(
    investment_tier = replace_na(investment_tier, "None"),
    investment_tier = factor(investment_tier,
                             levels = c("None", "Low (1-2)", "Medium (3-5)", "High (6+)")),
    mode_group = factor(mode_group,
                        levels = c("Private Vehicle", "Public Transport",
                                   "Active Transport", "Ride-hailing", "Other")),
    trippurp = factor(trippurp, levels = c("Work Related", "Education"))
  )
we <- we %>% filter(dayType == "Weekday")

# Calculate mode share % within each tier x purpose group
mode_share <- we %>%
  group_by(trippurp, investment_tier, mode_group) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(trippurp, investment_tier) %>%
  mutate(pct = n / sum(n) * 100)

# Define colour palette for mode groups
mode_colours <- c(
  "Private Vehicle"  = "#D95F02",
  "Public Transport" = "#1B9E77",
  "Active Transport" = "#7570B3",
  "Ride-hailing"     = "#E7298A",
  "Other"            = "#999999"
)

# Plot
p1a <- ggplot(mode_share, aes(x = investment_tier, y = pct, fill = mode_group)) +
  geom_bar(stat = "identity", position = "stack", width = 0.7) +
  geom_text(aes(label = ifelse(pct >= 5, paste0(round(pct, 0), "%"), "")),
            position = position_stack(vjust = 0.5),
            size = 3, colour = "white", fontface = "bold") +
  facet_wrap(~ trippurp, ncol = 2) +
  scale_fill_manual(values = mode_colours, name = "Mode Group") +
  scale_y_continuous(labels = label_percent(scale = 1), expand = c(0, 0)) +
  labs(
    title    = "How Do Travel Choices Differ Across Areas with More Education Infrastructure?",
    subtitle = "Tiers based on count of state-funded education projects per LGA | Victoria VISTA 2024-25 & State Budget 2023-24",
    x        = "Education Investment Tier (no. of projects per LGA)",
    y        = "Share of Trips (%)",
    caption  = "Weekday trips only | None = 0 projects | Low = 1-2 | Medium = 3-5 | High = 6+"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 13),
    plot.subtitle      = element_text(size = 10, colour = "grey40"),
    strip.text         = element_text(face = "bold", size = 11),
    legend.position    = "bottom",
    axis.text.x        = element_text(angle = 15, hjust = 1),
    panel.grid.major.x = element_blank()
  )

print(p1a)
ggsave("Q1A_mode_share_by_tier.png", plot = p1a, width = 10, height = 6, dpi = 300)


# ------------------------------------------------------------------------------
### Q1 - C
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(scales)
library(rstatix)
library(ggpubr)

we <- read_csv("we_trips_final.csv") %>%
  mutate(
    investment_tier = replace_na(investment_tier, "None"),
    investment_tier = factor(investment_tier,
                             levels = c("None", "Low (1-2)", "Medium (3-5)", "High (6+)")),
    trippurp = factor(trippurp, levels = c("Work Related", "Education"))
  ) %>%
  filter(triptime_flag == FALSE, triptime <= 120)
we <- we %>% filter(dayType == "Weekday")

# --- Kruskal-Wallis + Dunn post-hoc per trip purpose ---
kw_results <- we %>%
  group_by(trippurp) %>%
  kruskal_test(triptime ~ investment_tier)

dunn_results <- we %>%
  group_by(trippurp) %>%
  dunn_test(triptime ~ investment_tier, p.adjust.method = "bonferroni") %>%
  add_xy_position(x = "investment_tier", step.increase = 0.08)

# Print stats to console for reporting
print(kw_results)
print(dunn_results %>% select(trippurp, group1, group2, statistic, p.adj, p.adj.signif))

# --- Violin + boxplot ---
p1c <- ggplot(we, aes(x = investment_tier, y = triptime, fill = investment_tier)) +
  geom_violin(alpha = 0.6, trim = TRUE, colour = NA) +
  geom_boxplot(width = 0.18, outlier.shape = NA,
               colour = "grey20", fill = "white", alpha = 0.8) +
  stat_pvalue_manual(
    dunn_results,
    label       = "p.adj.signif",
    tip.length  = 0.01,
    hide.ns     = TRUE,
    size        = 3.5
  ) +
  facet_wrap(~ trippurp, ncol = 2) +
  scale_fill_viridis_d(option = "D", direction = -1) +
  scale_y_continuous(
    breaks = seq(0, 120, 20),
    labels = function(x) paste0(x, " min")
  ) +
  labs(
    title    = "Do People in Higher-Investment Areas Spend More Time Travelling\nto Work or Education?",
    subtitle = paste0(
      "Violin shape shows spread of trip durations | Box shows median and interquartile range\n",
      "Brackets show statistically significant differences (Dunn test, Bonferroni correction)"
    ),
    x        = "Education Investment Tier (no. of projects per LGA)",
    y        = "Trip Duration (minutes)",
    caption  = paste0(
      "Weekday trips only | Trips over 120 minutes excluded from display (0.6% of data) | ",
      "Flagged outliers removed\n",
      "None = 0 projects | Low = 1-2 | Medium = 3-5 | High = 6+\n",
      "Source: VISTA 2024-25; State Budget 2023-24"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(face = "bold", size = 13),
    plot.subtitle    = element_text(size = 9.5, colour = "grey40"),
    strip.text       = element_text(face = "bold", size = 11),
    legend.position  = "none",
    axis.text.x      = element_text(angle = 15, hjust = 1),
    panel.grid.minor = element_blank()
  )

print(p1c)
ggsave("Q1C_trip_duration_violin.png", plot = p1c, width = 11, height = 7, dpi = 300)


# ------------------------------------------------------------------------------
### Q2 - A
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(scales)

vm <- read_csv("vista_merged_final.csv") %>%
  filter(!is.na(IRSD_Decile),
         mode_group %in% c("Private Vehicle", "Public Transport", "Active Transport"))

# Calculate mode share per decile
mode_line <- vm %>%
  group_by(IRSD_Decile, mode_group) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(IRSD_Decile) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup() %>%
  mutate(mode_group = factor(mode_group,
                             levels = c("Private Vehicle",
                                        "Public Transport",
                                        "Active Transport")))

# Gap segment: dashed line between Decile 3 and Decile 6
gap_data <- mode_line %>%
  filter(IRSD_Decile %in% c(3, 6)) %>%
  select(IRSD_Decile, mode_group, pct)

gap_start <- gap_data %>% filter(IRSD_Decile == 3) %>%
  rename(x = IRSD_Decile, y = pct)
gap_end   <- gap_data %>% filter(IRSD_Decile == 6) %>%
  rename(xend = IRSD_Decile, yend = pct)
gap_segments <- left_join(gap_start, gap_end, by = "mode_group")

# Solid line data (exclude the 3-6 gap)
solid_data <- mode_line %>%
  mutate(group_segment = case_when(
    IRSD_Decile <= 3 ~ "low",
    IRSD_Decile >= 6 ~ "high"
  ))

# Mode colours consistent with Q1 charts
mode_colours <- c(
  "Private Vehicle"  = "#D95F02",
  "Public Transport" = "#1B9E77",
  "Active Transport" = "#7570B3"
)

# X axis labels
x_labels <- c(
  "2"  = "2\n(Most Disadvantaged\nin VISTA area)",
  "3"  = "3",
  "6"  = "6",
  "7"  = "7",
  "8"  = "8",
  "9"  = "9",
  "10" = "10\n(Least Disadvantaged)"
)

p2a_new <- ggplot() +
  # Dashed gap between Decile 3 and 6
  geom_segment(data = gap_segments,
               aes(x = x, xend = xend, y = y, yend = yend,
                   colour = mode_group),
               linetype = "dashed", linewidth = 0.7, alpha = 0.5) +
  # Solid lines within each segment group
  geom_line(data = solid_data %>% filter(group_segment == "low"),
            aes(x = IRSD_Decile, y = pct, colour = mode_group,
                group = mode_group),
            linewidth = 1.2) +
  geom_line(data = solid_data %>% filter(group_segment == "high"),
            aes(x = IRSD_Decile, y = pct, colour = mode_group,
                group = mode_group),
            linewidth = 1.2) +
  # Points at each decile
  geom_point(data = mode_line,
             aes(x = IRSD_Decile, y = pct, colour = mode_group),
             size = 4, shape = 21, fill = "white", stroke = 2) +
  # Percentage labels above/below points
  geom_text(data = mode_line %>%
              mutate(vjust_val = ifelse(mode_group == "Public Transport", 2.0, -1.1)),
            aes(x = IRSD_Decile, y = pct, colour = mode_group,
                label = paste0(round(pct, 0), "%"),
                vjust = vjust_val),
            size = 3.2, fontface = "bold",
            show.legend = FALSE) +
  # Gap annotation
  annotate("text", x = 4.5, y = 50,
           label = "← Deciles 4 & 5\nnot in VISTA\ncoverage area",
           size = 2.8, colour = "grey50", hjust = 0.5, lineheight = 0.9) +
  scale_colour_manual(values = mode_colours, name = "Transport Mode") +
  scale_x_continuous(
    breaks = c(2, 3, 6, 7, 8, 9, 10),
    labels = x_labels,
    limits = c(1.5, 10.5)
  ) +
  scale_y_continuous(
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%"),
    limits = c(0, 100)
  ) +
  labs(
    title    = "As Neighbourhoods Get Wealthier, Do People Drive Less and Walk More?",
    subtitle = paste0(
      "Each point = share of all trips using that mode in that neighbourhood type | ",
      "Dashed line = gap in data (no VISTA households in those rankings)\n",
      "Neighbourhood ranking based on IRSD: Index of Relative Socio-Economic Disadvantage"
    ),
    x        = "Neighbourhood Disadvantage Ranking (1 = Most Disadvantaged, 10 = Least Disadvantaged)",
    y        = "Share of All Trips (%)",
    caption  = "Ride-hailing and Other excluded (<2% of trips combined)\nSource: VISTA 2024-25; ABS SEIFA 2021"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(face = "bold", size = 13),
    plot.subtitle    = element_text(size = 9.5, colour = "grey40"),
    legend.position  = "bottom",
    legend.title     = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(size = 9)
  )

print(p2a_new)
ggsave("Q2A_mode_dotplot_IRSD.png", plot = p2a_new, width = 12, height = 6.5, dpi = 300)


# ------------------------------------------------------------------------------
### Q2 - B
# FIX 1: Added Dunn post-hoc test (was missing entirely)
# FIX 2: Annotation box now built dynamically from Dunn test output (no hardcoding)
# FIX 3: ggsave call was incomplete — now has filename and dimensions
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(scales)
library(rstatix)
library(viridis)

vm <- read_csv("vista_merged_final.csv") %>%
  filter(triptime_flag == FALSE, triptime <= 120, !is.na(IRSD_Decile)) %>%
  mutate(IRSD_Decile = factor(IRSD_Decile))

# Kruskal-Wallis
kw_q2 <- vm %>% kruskal_test(triptime ~ IRSD_Decile)
print(kw_q2)

# Dunn post-hoc with Bonferroni correction — filter to significant pairs only
dunn_q2 <- vm %>%
  dunn_test(triptime ~ IRSD_Decile, p.adjust.method = "bonferroni") %>%
  filter(p.adj < 0.05) %>%
  arrange(p.adj)

# Print to console for reporting
print(dunn_q2 %>% select(group1, group2, statistic, p.adj, p.adj.signif))

# Build annotation label dynamically from Dunn output
dunn_rows <- apply(dunn_q2, 1, function(r) {
  p_val <- as.numeric(r["p.adj"])
  p_str <- ifelse(p_val < 0.001, "p < 0.001", paste0("p = ", round(p_val, 3)))
  paste0("Ranking ", r["group1"], " vs ", r["group2"],
         ": ", p_str, " (", r["p.adj.signif"], ")")
})

dunn_label <- paste(
  c("Significant differences (Dunn test, Bonferroni):", dunn_rows),
  collapse = "\n"
)

# Median labels positioned above each violin
medians <- vm %>%
  group_by(IRSD_Decile) %>%
  summarise(
    med     = median(triptime),
    vio_top = quantile(triptime, 0.95),
    .groups = "drop"
  )

decile_labels <- c(
  "2"  = "2\n(Most\nDisadvantaged)",
  "3"  = "3",
  "6"  = "6",
  "7"  = "7",
  "8"  = "8",
  "9"  = "9",
  "10" = "10\n(Least\nDisadvantaged)"
)

p2b <- ggplot(vm, aes(x = IRSD_Decile, y = triptime, fill = IRSD_Decile)) +
  geom_violin(alpha = 0.6, trim = TRUE, colour = NA) +
  geom_boxplot(width = 0.15, outlier.shape = NA,
               colour = "grey20", fill = "white", alpha = 0.9) +
  # Median labels above each violin
  geom_text(data = medians,
            aes(x = IRSD_Decile, y = vio_top + 4,
                label = paste0("Median\n", round(med, 0), " min")),
            size = 2.8, fontface = "bold", colour = "grey25",
            lineheight = 0.85, inherit.aes = FALSE) +
  # Dynamic significance annotation box
  annotate("label",
           x = 4, y = 128,
           label    = dunn_label,
           size     = 3, hjust = 0.5, vjust = 1,
           fill     = "white", colour = "grey30",
           label.size = 0.3, lineheight = 1.3) +
  scale_fill_viridis_d(option = "D", direction = 1) +
  scale_x_discrete(labels = decile_labels) +
  scale_y_continuous(
    breaks = seq(0, 120, 20),
    labels = function(x) paste0(x, " min"),
    limits = c(0, 140)
  ) +
  labs(
    title    = "Do People in More Disadvantaged Neighbourhoods\nSpend Longer Travelling?",
    subtitle = paste0(
      "Violin shape = spread of all trip durations | ",
      "Box = interquartile range | ",
      "Label above each violin = median trip duration\n",
      "Significant pairwise differences listed in annotation box (Dunn test, Bonferroni correction)"
    ),
    x        = "Neighbourhood Disadvantage Ranking (1 = Most Disadvantaged, 10 = Least)",
    y        = "Trip Duration (minutes)",
    caption  = paste0(
      "All trip purposes included | Trips over 120 minutes excluded from display (0.5% of data)\n",
      "Disadvantage rankings 1, 4 and 5 not present in VISTA survey coverage area\n",
      "Source: VISTA 2024-25; ABS SEIFA 2021"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(face = "bold", size = 13),
    plot.subtitle    = element_text(size = 9.5, colour = "grey40"),
    legend.position  = "none",
    axis.text.x      = element_text(size = 9),
    panel.grid.minor = element_blank()
  )

print(p2b)
ggsave("Q2B_trip_duration_violin_IRSD.png", plot = p2b, width = 11, height = 7, dpi = 300)


# ------------------------------------------------------------------------------
### Q2 - C
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(scales)

# ---- Data preparation ----
hh <- read_csv("hh_seifa_final.csv") %>%
  filter(hhinc_group != "Not Stated") %>%
  mutate(
    # Recode top-band households to sort=5000 so Spearman ordering is correct
    hhinc_sort = ifelse(hhinc_group == "$8,000 or more ($416,000 or more)", 5000, hhinc_sort),
    inc_band = case_when(
      hhinc_sort < 1000  ~ "Under $52k",
      hhinc_sort < 2000  ~ "$52k-$104k",
      hhinc_sort < 3000  ~ "$104k-$156k",
      hhinc_sort < 4000  ~ "$156k-$208k",
      TRUE               ~ "Over $208k"
    ),
    inc_band = factor(inc_band,
                      levels = c("Under $52k", "$52k-$104k",
                                 "$104k-$156k", "$156k-$208k",
                                 "Over $208k"))
  )

# ---- Spearman correlation computed dynamically ----
spearman_q2c <- cor.test(hh$hhinc_sort, hh$totalvehs,
                         method = "spearman", exact = FALSE)

rho_q2c     <- round(spearman_q2c$estimate, 3)
p_q2c       <- spearman_q2c$p.value
p_q2c_label <- ifelse(p_q2c < 0.001, "p < 0.001",
                      paste0("p = ", round(p_q2c, 3)))

print(paste("Spearman rho:", rho_q2c, "| p-value:", p_q2c_label))

# ---- Summary stats per income band ----
summary_hh <- hh %>%
  group_by(inc_band) %>%
  summarise(
    mean_veh   = mean(totalvehs),
    se         = sd(totalvehs) / sqrt(n()),
    no_car_pct = mean(totalvehs == 0) * 100,
    n          = n(),
    .groups    = "drop"
  )

print(summary_hh)

# ---- Plot ----
p2c <- ggplot(summary_hh, aes(x = inc_band, y = mean_veh)) +
  # Error bars first so dots sit on top
  geom_errorbar(aes(ymin = mean_veh - 1.96 * se,
                    ymax = mean_veh + 1.96 * se),
                width = 0.15, colour = "grey50", linewidth = 0.8) +
  # Connecting line
  geom_line(aes(group = 1), colour = "#D95F02",
            linewidth = 1.2, linetype = "solid") +
  # Points
  geom_point(size = 5, shape = 21,
             fill = "#D95F02", colour = "white", stroke = 2) +
  # Mean label above each point
  geom_text(aes(label = round(mean_veh, 2)),
            vjust = -3.5, size = 3.5,
            fontface = "bold", colour = "grey25") +
  # Car-free % label below each point
  geom_text(aes(y = mean_veh - 0.18,
                label = paste0(round(no_car_pct, 0), "% car-free")),
            size = 2.8, colour = "grey45", fontface = "italic") +
  # Dynamic Spearman annotation
  annotate("label",
           x = 2, y = 2.15,
           label = paste0(
             "Spearman Rank Correlation:\n",
             "Correlation strength (rho) = ", rho_q2c, "\n",
             "Significance: ", p_q2c_label, "\n",
             "(less than 0.1% chance this is random)"
           ),
           size = 3, hjust = 0.5, vjust = 1,
           fill = "white", colour = "grey30",
           label.size = 0.3, lineheight = 1.3) +
  scale_y_continuous(
    breaks = seq(0, 3, 0.5),
    limits = c(0.8, 2.75),
    labels = function(x) ifelse(x == 1, "1 car", paste0(x, " cars"))
  ) +
  labs(
    title    = "Do Higher-Income Households Own More Cars -\nand Does This Explain How They Travel?",
    subtitle = paste0(
      "Each point = average number of vehicles owned per household in that income group\n",
      "Error bars = 95% confidence interval | ",
      "% below each point = share of households with no car"
    ),
    x        = "Annual Household Income",
    y        = "Average Number of Vehicles per Household",
    caption  = paste0(
      "73 households with unknown income excluded\n",
      "Source: VISTA 2024-25"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 13),
    plot.subtitle      = element_text(size = 9.5, colour = "grey40"),
    axis.text.x        = element_text(size = 10),
    panel.grid.minor   = element_blank(),
    panel.grid.major.x = element_blank()
  )

print(p2c)
ggsave("Q2C_vehicles_by_income.png", plot = p2c,
       width = 11, height = 6.5, dpi = 300)


# ------------------------------------------------------------------------------
### Q3 - A
# FIX 1: Stray lone comma removed from labs() — was a syntax error
# FIX 2: hh_count for None-tier LGAs corrected to actual values from hh_seifa_final
# FIX 3: scale_size_area() replaces scale_size_continuous() — uses sqrt scaling
#         so bubble area is proportional to household count, not radius
# FIX 4: City labels added for Melbourne and Geelong (map labelling requirement)
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(sf)
library(ozmaps)
library(ggrepel)
library(scales)

# ---- Data preparation ----
lga <- read_csv("lga_q3_final.csv") %>%
  mutate(investment_tier = factor(investment_tier,
                                  levels = c("Low (1-2)",
                                             "Medium (3-5)",
                                             "High (6+)")))

# 5 None-tier VISTA LGAs
# hh_count values verified against hh_seifa_final.csv (unique household IDs per LGA)
# Centroids approximated from ABS LGA boundary references
none_lgas <- tibble(
  lga_standard      = c("Manningham", "Stonnington", "Yarra Ranges",
                        "Queenscliffe", "Surf Coast"),
  project_count     = 0,
  lat_mean          = c(-37.770, -37.857, -37.780, -38.270, -38.350),
  long_mean         = c(145.200, 145.010, 145.550, 144.670, 144.150),
  investment_tier   = factor("None (0)",
                             levels = c("None (0)", "Low (1-2)",
                                        "Medium (3-5)", "High (6+)")),
  investment_tier_order = 0,
  hh_count          = c(54, 52, 81, 18, 27),
  in_vista          = TRUE
)

lga <- lga %>%
  mutate(investment_tier = fct_expand(investment_tier, "None (0)") %>%
           fct_relevel("None (0)", "Low (1-2)", "Medium (3-5)", "High (6+)"))

lga_full <- bind_rows(lga, none_lgas)

# Victoria boundary
vic_boundary <- ozmap_states %>% filter(NAME == "Victoria")

# Tier colours
tier_colours <- c(
  "None (0)"     = "#AAAAAA",
  "Low (1-2)"    = "#FEE08B",
  "Medium (3-5)" = "#F46D43",
  "High (6+)"    = "#A50026"
)

# High-tier VISTA LGAs for labels
high_labels <- lga_full %>%
  filter(investment_tier == "High (6+)", in_vista == TRUE)

# ---- Plot ----
p3a <- ggplot() +
  geom_sf(data = vic_boundary,
          fill = "#F5F5F0", colour = "grey60", linewidth = 0.5) +
  # Non-VISTA LGAs: open circles (fixed size, not mapped to hh_count)
  geom_point(data = lga_full %>% filter(in_vista == FALSE),
             aes(x = long_mean, y = lat_mean,
                 colour = investment_tier),
             size = 2.2, shape = 1, stroke = 1.0, alpha = 0.75) +
  # VISTA LGAs: filled circles sized by households
  # scale_size_area() maps bubble AREA proportionally to hh_count (sqrt scaling)
  geom_point(data = lga_full %>% filter(in_vista == TRUE),
             aes(x = long_mean, y = lat_mean,
                 fill = investment_tier,
                 size = hh_count),
             shape = 21, colour = "grey25",
             stroke = 0.3, alpha = 0.85) +
  # Labels for High-tier VISTA LGAs only
  geom_text_repel(
    data = high_labels,
    aes(x = long_mean, y = lat_mean,
        label = paste0(lga_standard, "\n(", project_count, " projects)")),
    size           = 2.6, colour = "#7B0000", fontface = "bold",
    box.padding    = 0.6,
    point.padding  = 0.3,
    max.overlaps   = 15,
    segment.colour = "grey50",
    segment.size   = 0.3
  ) +
  # Legend annotation box
  annotate("label",
           x = 141.8, y = -34.8,
           label = paste0(
             "VISTA LGA (filled circle):\n",
             "Included in household travel survey\n",
             "Circle size = households surveyed\n\n",
             "Non-VISTA LGA (open circle):\n",
             "Outside VISTA survey coverage"
           ),
           size = 2.8, hjust = 0, vjust = 1,
           fill = "white", colour = "grey40",
           label.size = 0.3, lineheight = 1.25,
           family = "sans") +
  # City labels — required for geographic orientation
  annotate("text", x = 145.15, y = -37.50,
           label = "Melbourne", size = 3.2, colour = "grey25",
           fontface = "italic") +
  annotate("text", x = 143.85, y = -38.05,
           label = "Geelong", size = 3.2, colour = "grey25",
           fontface = "italic") +
  coord_sf(xlim = c(140.9, 150.1), ylim = c(-39.2, -33.9)) +
  scale_fill_manual(
    values = tier_colours,
    name   = "Education Investment Tier\n(no. of state-funded projects per LGA)"
  ) +
  scale_colour_manual(values = tier_colours, guide = "none") +
  # scale_size_area: bubble area is proportional to hh_count (sqrt scaling applied internally)
  # This prevents large-count LGAs from visually dominating disproportionately
  scale_size_area(
    max_size = 12,
    name     = "VISTA Households\nSurveyed in LGA",
    breaks   = c(10, 50, 100, 200)
  ) +
  guides(
    fill = guide_legend(
      order        = 1,
      override.aes = list(size = 4.5, shape = 21,
                          colour = "grey25", stroke = 0.4)
    ),
    size = guide_legend(
      order        = 2,
      override.aes = list(fill = "grey60", shape = 21,
                          colour = "grey25")
    )
  ) +
  labs(
    title    = "Where Is Education Infrastructure Investment Going -\nand Does It Match Where Victorian Households Live?",
    subtitle = paste0(
      "High-investment LGAs concentrate in Melbourne's outer growth corridors, ",
      "aligning with the largest VISTA household clusters"
    ),
    x        = NULL,
    y        = NULL,
    caption  = paste0(
      "5 VISTA LGAs with zero education investment shown in grey\n",
      "Centroids for zero-investment VISTA LGAs approximated from ABS LGA boundary references\n",
      "Bubble area proportional to household count (square-root scaling)\n",
      "Source: VISTA 2024-25; State Budget 2023-24"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    plot.subtitle   = element_text(size = 9, colour = "grey35",
                                   lineheight = 1.3),
    legend.position = "right",
    legend.title    = element_text(size = 9, face = "bold"),
    legend.text     = element_text(size = 8.5),
    axis.text       = element_blank(),
    panel.grid      = element_blank(),
    plot.caption    = element_text(size = 8, colour = "grey50",
                                   lineheight = 1.3)
  )

print(p3a)
ggsave("Q3A_investment_bubble_map.png", plot = p3a,
       width = 14, height = 9, dpi = 300)


# ------------------------------------------------------------------------------
### Q3 - B
# ------------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(ggrepel)
library(scales)

# ---- Data preparation ----
lga <- read_csv("lga_q3_final.csv") %>%
  filter(in_vista == TRUE) %>%
  mutate(investment_tier = factor(investment_tier,
                                  levels = c("Low (1-2)",
                                             "Medium (3-5)",
                                             "High (6+)")))

# 5 None-tier VISTA LGAs
# hh_count values verified against hh_seifa_final.csv
none_lgas <- tibble(
  lga_standard    = c("Manningham", "Stonnington", "Yarra Ranges",
                      "Queenscliffe", "Surf Coast"),
  project_count   = 0,
  hh_count        = c(54, 52, 81, 18, 27),
  investment_tier = factor("None (0)",
                           levels = c("None (0)", "Low (1-2)",
                                      "Medium (3-5)", "High (6+)")),
  in_vista        = TRUE
)

lga <- lga %>%
  mutate(investment_tier = fct_expand(investment_tier, "None (0)") %>%
           fct_relevel("None (0)", "Low (1-2)", "Medium (3-5)", "High (6+)"))

lga_full <- bind_rows(lga, none_lgas)

# ---- Spearman correlation computed dynamically ----
spearman_q3 <- cor.test(lga_full$project_count, lga_full$hh_count,
                        method = "spearman", exact = FALSE)

rho_q3     <- round(spearman_q3$estimate, 3)
p_q3       <- spearman_q3$p.value
p_q3_label <- ifelse(p_q3 < 0.001, "p < 0.001",
                     paste0("p = ", round(p_q3, 3)))

print(paste("Spearman rho:", rho_q3, "| p-value:", p_q3_label))

# ---- LGAs to label ----
label_lgas <- lga_full %>%
  filter(
    investment_tier == "High (6+)" |
      lga_standard %in% c("Greater Geelong", "Yarra Ranges", "Boroondara")
  )

# ---- Tier colours consistent with Q3-A ----
tier_colours <- c(
  "None (0)"     = "#AAAAAA",
  "Low (1-2)"    = "#D4A017",
  "Medium (3-5)" = "#F46D43",
  "High (6+)"    = "#A50026"
)

# ---- Plot ----
p3b <- ggplot(lga_full,
              aes(x = project_count, y = hh_count,
                  fill = investment_tier)) +
  # Linear trend line with confidence band
  geom_smooth(method = "lm", se = TRUE,
              colour = "grey40", fill = "grey85",
              linewidth = 0.8, linetype = "dashed",
              show.legend = FALSE) +
  # Points
  geom_point(shape = 21, colour = "grey25",
             size = 4, stroke = 0.4, alpha = 0.9) +
  # Labels for key LGAs
  geom_text_repel(
    data           = label_lgas,
    aes(label      = lga_standard),
    size           = 2.8, colour = "grey25", fontface = "bold",
    box.padding    = 0.5,
    point.padding  = 0.3,
    max.overlaps   = 15,
    segment.colour = "grey60",
    segment.size   = 0.3
  ) +
  # Dynamic Spearman annotation
  annotate("label",
           x = 8, y = 240,
           label = paste0(
             "Spearman Rank Correlation:\n",
             "Correlation strength (rho) = ", rho_q3, "\n",
             "Significance: ", p_q3_label, "\n",
             "(less than 0.1% chance this is random)"
           ),
           size = 3, hjust = 0.5, vjust = 1,
           fill = "white", colour = "grey30",
           label.size = 0.3, lineheight = 1.3) +
  scale_fill_manual(
    values = tier_colours,
    name   = "Education Investment Tier\n(no. of projects per LGA)"
  ) +
  scale_x_continuous(
    breaks = seq(0, 15, 3),
    labels = function(x) paste0(x, " projects")
  ) +
  scale_y_continuous(
    breaks = seq(0, 300, 50),
    labels = function(x) paste0(x, " households")
  ) +
  guides(
    fill = guide_legend(
      override.aes = list(size = 4, shape = 21,
                          colour = "grey25", stroke = 0.4)
    )
  ) +
  labs(
    title    = "Do Areas with More Education Investment Also Have\nMore Households Being Surveyed?",
    subtitle = paste0(
      "Each point = one Victorian LGA in the VISTA survey (n = 38) | ",
      "Dashed line = linear trend with 95% confidence band\n",
      "A positive relationship suggests investment is broadly aligned ",
      "with where households are located"
    ),
    x        = "Number of State-Funded Education Projects in LGA",
    y        = "Number of VISTA Households Surveyed in LGA",
    caption  = paste0(
      "5 LGAs with zero education investment included (shown in grey)\n",
      "VISTA household count used as proxy for household density per LGA\n",
      "Source: VISTA 2024-25; State Budget 2023-24"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(face = "bold", size = 13),
    plot.subtitle    = element_text(size = 9.5, colour = "grey40",
                                    lineheight = 1.3),
    legend.position  = "right",
    legend.title     = element_text(size = 9, face = "bold"),
    panel.grid.minor = element_blank()
  )

print(p3b)
ggsave("Q3B_scatter_projects_vs_households.png", plot = p3b,
       width = 11, height = 7, dpi = 300)