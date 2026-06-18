server <- function(input, output, session) {

  # ============================================================
  # COORDINATED HIGHLIGHT STATE
  # Hovering P3 tier highlights matching LGAs in P2 and P4_tier
  # Mouse leaving P3 plot area resets via JS mouseleave event
  # ============================================================
  selected_tier <- reactiveVal(NULL)

  observe({
    ev <- event_data("plotly_hover", source = "p3")
    if (!is.null(ev)) {
      xv <- ev$x[1]
      if (is.numeric(xv)) {
        selected_tier(TIER_ORDER[as.integer(xv) + 1L])
      } else {
        selected_tier(as.character(xv))
      }
    }
  })

  observeEvent(input$p3_mouseleave, {
    selected_tier(NULL)
  })

  # ============================================================
  # P2 — Cleveland Dot Plot (narrative, Beat 1)
  # ============================================================
  output$p2_plot <- renderPlotly({

    ht <- selected_tier()

    df <- lga_scatter %>%
      arrange(hh_count) %>%
      mutate(
        lga_standard = factor(lga_standard, levels = lga_standard),
        dot_colour   = TIER_COLS[investment_tier],
        dot_opacity  = if (!is.null(ht)) ifelse(investment_tier == ht, 1.0, 0.10) else rep(0.88, n()),
        border_width = if (!is.null(ht)) ifelse(investment_tier == ht, 2.5, 0.4)  else rep(1.2, n()),
        label_text   = ifelse(
          lga_standard %in% c("Casey", "Greater Geelong"),
          as.character(lga_standard), ""),
        tooltip_text = paste0(
          "<b>", lga_standard, "</b><br>",
          "Investment tier: ", investment_tier, "<br>",
          "Projects: ", project_count, "<br>",
          "Households surveyed: <b>", hh_count, "</b>"
        )
      )

    plot_ly(
      data         = df,
      x            = ~project_count,
      y            = ~lga_standard,
      type         = "scatter",
      mode         = "markers+text",
      marker       = list(
        color   = ~dot_colour,
        size    = 11,
        opacity = ~dot_opacity,
        line    = list(color = "#555555", width = ~border_width)
      ),
      text         = ~label_text,
      textposition = "middle right",
      textfont     = list(size = 9, color = "#444444"),
      hovertext    = ~tooltip_text,
      hoverinfo    = "text",
      showlegend   = FALSE,
      source       = "p2"
    ) %>%
      add_annotations(
        x = 1, y = -0.06,
        xref = "paper", yref = "paper",
        xanchor = "right", yanchor = "top",
        text = paste0(
          "<span style='color:", TIER_COLS["High (6+)"],   "'>●</span> High (6+) &nbsp;",
          "<span style='color:", TIER_COLS["Medium (3-5)"],"'>●</span> Medium (3–5) &nbsp;",
          "<span style='color:", TIER_COLS["Low (1-2)"],   "'>●</span> Low (1–2)"
        ),
        showarrow = FALSE, font = list(size = 10.5)
      ) %>%
      # Spearman rho — investment tier (ordinal) vs household count (continuous).
      # Spearman is appropriate here: tier is an ordered categorical variable,
      # not continuous, so Pearson would be wrong.
      add_annotations(
        x = 0, y = 1.01,
        xref = "paper", yref = "paper",
        xanchor = "left", yanchor = "bottom",
        text = "Spearman \u03c1 = 0.597 (investment tier vs households surveyed)",
        showarrow = FALSE,
        font = list(size = 10, color = "#888888")
      ) %>%
      # Y-axis label clarifying sort order — LGAs sorted ascending by households surveyed
      add_annotations(
        x = -0.01, y = 0.5,
        xref = "paper", yref = "paper",
        xanchor = "right", yanchor = "middle",
        text = "LGAs sorted by\nhouseholds surveyed \u2191",
        showarrow = FALSE,
        textangle = -90,
        font = list(size = 9, color = "#AAAAAA")
      ) %>%
      layout(
        xaxis = list(
          title     = "Number of State-Funded Education Projects",
          range     = c(-0.5, 18),
          gridcolor = GRID_COL,
          zeroline  = FALSE,
          tickfont  = list(size = 11)
        ),
        yaxis = list(title = "", tickfont = list(size = 9.5)),
        margin        = list(l = 145, r = 75, t = 30, b = 50),
        plot_bgcolor  = BG_CHART,
        paper_bgcolor = BG_WHITE,
        hovermode     = "closest"
      ) %>%
      config(displayModeBar = FALSE)
  })

  # ============================================================
  # P3 — Slope Chart (narrative, Beat 2)
  # Broadcasts hover source="p3" to drive P2 and P4_tier
  # ============================================================
  output$p3_plot <- renderPlotly({

    df <- p3_data %>%
      mutate(investment_tier = factor(investment_tier, levels = TIER_ORDER)) %>%
      arrange(investment_tier_order)

    modes <- c("Private Vehicle", "Public Transport", "Active Transport")
    p <- plot_ly(source = "p3")

    for (m in modes) {
      d <- filter(df, mode_group == m)
      p <- add_trace(p,
        data      = d,
        x         = ~investment_tier,
        y         = ~pct,
        type      = "scatter",
        mode      = "lines+markers",
        name      = m,
        line      = list(
          color     = MODE_COLS[m],
          width     = if (m == "Private Vehicle") 3.5 else 2,
          shape     = "spline",
          smoothing = 0.4
        ),
        marker    = list(
          color = MODE_COLS[m], size = 11,
          line  = list(color = "white", width = 2)
        ),
        hovertext = paste0(
          "<b>", d$investment_tier, " — ", m, "</b><br>",
          "Mode share: <b>", d$pct, "%</b><br>",
          "Weekday work trips: ", d$n_trips
        ),
        hoverinfo  = "text",
        showlegend = FALSE
      )
    }

    for (m in modes) {
      d_high <- filter(df, mode_group == m, investment_tier == "High (6+)")
      p <- add_annotations(p,
        x = "High (6+)", y = d_high$pct,
        text      = paste0("  ", m),
        xanchor   = "left", yanchor = "middle",
        showarrow = FALSE,
        font      = list(size = 10.5, color = MODE_COLS[m])
      )
    }

    d_low_pv <- filter(df, mode_group == "Private Vehicle", investment_tier == "Low (1-2)")
    p <- add_annotations(p,
      x = "Low (1-2)", y = d_low_pv$pct,
      text      = "Inner-city LGAs<br>(geography effect)",
      xanchor   = "center", yanchor = "top",
      showarrow = TRUE, arrowhead = 2, arrowsize = 0.8, ax = 0, ay = 44,
      font      = list(size = 9, color = "#888888"),
      arrowcolor = "#BBBBBB"
    )

    d_high_pv <- filter(df, mode_group == "Private Vehicle", investment_tier == "High (6+)")
    p <- add_annotations(p,
      x = "High (6+)", y = d_high_pv$pct,
      text      = "9 in 10 work trips by car",
      xanchor   = "right", yanchor = "bottom",
      showarrow = TRUE, arrowhead = 2, arrowsize = 0.8, ax = -38, ay = -26,
      font      = list(size = 9, color = MODE_COLS["Private Vehicle"]),
      arrowcolor = MODE_COLS["Private Vehicle"]
    )

    p %>%
      layout(
        xaxis = list(
          title         = "Education Investment Tier",
          categoryorder = "array",
          categoryarray = TIER_ORDER,
          gridcolor     = GRID_COL,
          tickfont      = list(size = 12)
        ),
        yaxis = list(
          title      = "Share of Weekday Work Trips (%)",
          range      = c(0, 100),
          gridcolor  = GRID_COL,
          ticksuffix = "%",
          tickfont   = list(size = 11)
        ),
        hovermode     = "closest",
        showlegend    = FALSE,
        margin        = list(l = 65, r = 140, t = 20, b = 55),
        plot_bgcolor  = BG_CHART,
        paper_bgcolor = BG_WHITE
      ) %>%
      config(displayModeBar = FALSE)
  })

  # ============================================================
  # P4a — Dumbbell by Investment Tier (narrative, Beat 3 top)
  # Legend removed — encoding explained in panel-subhead text
  # ============================================================
  output$p4_tier_plot <- renderPlotly({

    ht <- selected_tier()

    df <- p4_data %>%
      filter(panel == "tier") %>%
      arrange(label_order) %>%
      mutate(
        row_opacity = if (!is.null(ht)) ifelse(label == ht, 1.0, 0.15) else rep(0.92, n()),
        tooltip_car = paste0(
          "<b>", label, "</b><br>",
          "Car (median): <b>", car_median, " min</b><br>",
          "n = ", n_car, " trips"),
        tooltip_pt  = paste0(
          "<b>", label, "</b><br>",
          "PT (median): <b>", pt_median, " min</b><br>",
          "Time penalty: +", penalty_min, " min (", pt_ratio, "× slower)<br>",
          "n = ", n_pt, " trips")
      )

    y_order <- rev(TIER_ORDER)
    p <- plot_ly()

    for (i in seq_len(nrow(df))) {
      r <- df[i, ]
      p <- add_trace(p,
        x = c(r$car_median, r$pt_median), y = c(r$label, r$label),
        type = "scatter", mode = "lines",
        line = list(color = "#CCCCCC", width = 2.5),
        opacity = r$row_opacity, showlegend = FALSE, hoverinfo = "skip"
      )
    }

    p <- add_trace(p,
      data = df, x = ~car_median, y = ~label,
      type = "scatter", mode = "markers", name = "Car (median min)",
      marker = list(color = MODE_COLS["Private Vehicle"], size = 14,
                    line = list(color = "white", width = 2)),
      opacity = ~row_opacity, hovertext = ~tooltip_car, hoverinfo = "text",
      showlegend = TRUE
    )

    p <- add_trace(p,
      data = df, x = ~pt_median, y = ~label,
      type = "scatter", mode = "markers", name = "Public transport (median min)",
      marker = list(color = MODE_COLS["Public Transport"], size = 14,
                    line = list(color = "white", width = 2)),
      opacity = ~row_opacity, hovertext = ~tooltip_pt, hoverinfo = "text",
      showlegend = TRUE
    )

    high_row <- filter(df, label == "High (6+)")
    if (nrow(high_row) > 0) {
      p <- add_annotations(p,
        x = high_row$pt_median + 1, y = "High (6+)",
        text = "  6× longer by PT",
        xanchor = "left", yanchor = "middle", showarrow = FALSE,
        font = list(size = 10, color = MODE_COLS["Public Transport"])
      )
    }

    p %>% layout(
      xaxis = list(
        title = "", range = c(0, 80), gridcolor = GRID_COL,
        zeroline = FALSE, showticklabels = FALSE
      ),
      yaxis = list(
        title = "", categoryorder = "array", categoryarray = y_order,
        tickfont = list(size = 11)
      ),
      showlegend = TRUE,
      legend     = list(
        orientation = "h", x = 0, y = -0.18,
        font        = list(size = 10),
        bgcolor     = "rgba(0,0,0,0)"
      ),
      hovermode     = "closest",
      margin        = list(l = 120, r = 30, t = 8, b = 42),
      plot_bgcolor  = BG_CHART,
      paper_bgcolor = BG_WHITE
    ) %>% config(displayModeBar = FALSE)
  })

  # ============================================================
  # P4b — Dumbbell by IRSD Decile (narrative, Beat 3 bottom)
  # Independent of P3 hover — IRSD is a separate dimension
  # ============================================================
  output$p4_irsd_plot <- renderPlotly({

    df_raw <- p4_data %>%
      filter(panel == "irsd") %>%
      arrange(label_order)

    gap_row <- data.frame(
      panel = "irsd",
      label = "  — Deciles 4–5: no VISTA households —",
      label_order = 4.5,
      car_median = NA_real_, pt_median = NA_real_,
      penalty_min = NA_real_, pt_ratio = NA_real_,
      n_car = NA_real_, n_pt = NA_real_,
      stringsAsFactors = FALSE
    )

    df <- bind_rows(
      filter(df_raw, label_order <= 3), gap_row,
      filter(df_raw, label_order >= 6)
    ) %>%
      mutate(
        tooltip_car = ifelse(is.na(car_median), "",
          paste0("<b>", label, "</b><br>Car (median): <b>", car_median,
                 " min</b><br>n = ", n_car, " trips")),
        tooltip_pt = ifelse(is.na(pt_median), "",
          paste0("<b>", label, "</b><br>PT (median): <b>", pt_median,
                 " min</b><br>Penalty: +", penalty_min, " min (",
                 pt_ratio, "× slower)<br>n = ", n_pt, " trips"))
      )

    y_order  <- rev(df$label)
    df_valid <- filter(df, !is.na(car_median))
    p <- plot_ly()

    for (i in seq_len(nrow(df_valid))) {
      r <- df_valid[i, ]
      p <- add_trace(p,
        x = c(r$car_median, r$pt_median), y = c(r$label, r$label),
        type = "scatter", mode = "lines",
        line = list(color = "#CCCCCC", width = 2.5),
        opacity = 0.85, showlegend = FALSE, hoverinfo = "skip"
      )
    }

    p <- add_trace(p,
      data = df_valid, x = ~car_median, y = ~label,
      type = "scatter", mode = "markers", name = "Car (median min)",
      marker = list(color = MODE_COLS["Private Vehicle"], size = 14,
                    line = list(color = "white", width = 2)),
      opacity = 0.85,
      hovertext = ~tooltip_car, hoverinfo = "text", showlegend = TRUE
    )

    p <- add_trace(p,
      data = df_valid, x = ~pt_median, y = ~label,
      type = "scatter", mode = "markers", name = "Public transport (median min)",
      marker = list(color = MODE_COLS["Public Transport"], size = 14,
                    line = list(color = "white", width = 2)),
      opacity = 0.85,
      hovertext = ~tooltip_pt, hoverinfo = "text", showlegend = TRUE
    )

    d6 <- filter(df_valid, label == "Decile 6")
    if (nrow(d6) > 0) {
      p <- add_annotations(p,
        x = d6$pt_median + 0.5, y = "Decile 6",
        text = "Worst PT gap<br>in VISTA data",
        xanchor = "left", yanchor = "middle",
        showarrow = TRUE, arrowhead = 2, arrowsize = 0.7, ax = 16, ay = 0,
        font = list(size = 9, color = "#888888"), arrowcolor = "#BBBBBB"
      )
    }

    d10 <- filter(df_valid, label == "Decile 10")
    if (nrow(d10) > 0) {
      p <- add_annotations(p,
        x = d10$pt_median + 0.5, y = "Decile 10",
        text = paste0("Still ", d10$pt_ratio, "× slower"),
        xanchor = "left", yanchor = "middle", showarrow = FALSE,
        font = list(size = 9, color = "#888888")
      )
    }

    p %>% layout(
      xaxis = list(
        title      = "Median Trip Time (minutes)",
        range      = c(0, 85), gridcolor = GRID_COL,
        zeroline   = FALSE, ticksuffix = " min", tickfont = list(size = 11)
      ),
      yaxis = list(
        title = "", categoryorder = "array", categoryarray = y_order,
        tickfont = list(size = 10.5)
      ),
      showlegend = TRUE,
      legend     = list(
        orientation = "h", x = 0, y = -0.12,
        font        = list(size = 10),
        bgcolor     = "rgba(0,0,0,0)"
      ),
      hovermode     = "closest",
      margin        = list(l = 265, r = 30, t = 5, b = 52),
      plot_bgcolor  = BG_CHART,
      paper_bgcolor = BG_WHITE
    ) %>% config(displayModeBar = FALSE)
  })

  # ============================================================
  # COVERAGE BAR — right column
  # ============================================================
  output$coverage_plot <- renderPlotly({

    df <- data.frame(
      category = c("33 LGAs analysed", "29 outside VISTA coverage"),
      count    = c(33, 29),
      colour   = c("#2980B9", "#DDDDDD"),
      label    = c("33 analysed", "29 outside VISTA")
    )

    plot_ly(df,
      x = ~count,
      y = rep("LGAs with education investment", 2),
      type = "bar", orientation = "h",
      marker       = list(color = ~colour, line = list(color = "white", width = 1)),
      text         = ~label, textposition = "inside",
      insidetextanchor = "middle",
      textfont     = list(color = "white", size = 11),
      hovertext    = ~paste0(category, ": ", count, " LGAs"),
      hoverinfo    = "text", showlegend = FALSE
    ) %>%
      layout(
        barmode       = "stack",
        xaxis         = list(visible = FALSE, range = c(0, 66)),
        yaxis         = list(visible = TRUE, tickfont = list(size = 10)),
        margin        = list(l = 5, r = 5, t = 5, b = 5),
        paper_bgcolor = "white", plot_bgcolor = "white"
      ) %>%
      config(displayModeBar = FALSE)
  })

  # ============================================================
  # SCHOOL MODE CHART — Policy Implication Card 03
  # ============================================================
  output$school_mode_plot <- renderPlotly({

    df <- school_mode %>%
      mutate(investment_tier = factor(investment_tier,
               levels = c("Low (1-2)", "Medium (3-5)", "High (6+)")))

    p <- plot_ly()

    for (m in c("Private Vehicle", "Public Transport", "Active Transport")) {
      d <- filter(df, mode_group == m)
      p <- add_trace(p,
        data         = d,
        x            = ~pct,
        y            = ~investment_tier,
        type         = "bar",
        orientation  = "h",
        name         = m,
        marker       = list(color = MODE_COLS[m],
                            line  = list(color = "white", width = 1)),
        text         = ~ifelse(pct >= 8, paste0(pct, "%"), ""),
        textposition = "inside",
        insidetextanchor = "middle",
        textfont     = list(color = "white", size = 10),
        hovertext    = ~paste0("<b>", investment_tier, "</b><br>",
                               m, ": <b>", pct, "%</b><br>",
                               "n = ", n_trips, " of ", total_trips, " trips"),
        hoverinfo    = "text",
        showlegend   = TRUE
      )
    }

    p %>% layout(
      barmode = "stack",
      xaxis   = list(visible = FALSE, range = c(0, 105)),
      yaxis   = list(
        title         = "",
        tickfont      = list(size = 10.5),
        categoryorder = "array",
        categoryarray = c("Low (1-2)", "Medium (3-5)", "High (6+)")
      ),
      legend  = list(orientation = "h", x = 0, y = -0.25,
                     font = list(size = 9.5)),
      margin        = list(l = 10, r = 10, t = 5, b = 5),
      paper_bgcolor = BG_WHITE,
      plot_bgcolor  = BG_WHITE,
      showlegend    = TRUE
    ) %>% config(displayModeBar = FALSE)
  })

  # ============================================================
  # LGA EXPLORER — three reactive outputs from one selectInput
  # ============================================================

  lga_row <- reactive({
    req(input$selected_lga, input$selected_lga != "")
    lga_explorer %>% filter(lga_standard == input$selected_lga)
  })

  tier_avg_row <- reactive({
    req(lga_row())
    tier <- lga_row()$investment_tier
    p4_data %>% filter(panel == "tier", label == tier)
  })

  tier_mode_row <- reactive({
    req(lga_row())
    tier <- lga_row()$investment_tier
    p3_data %>% filter(investment_tier == tier)
  })

  # ---- 1. Summary card ----
  output$lga_summary_card <- renderUI({

    row  <- lga_row()
    tier <- row$investment_tier

    identity <- paste0(
      row$project_count,
      if (row$project_count == 1) " education project" else " education projects",
      " · ", row$hh_count, " households surveyed"
    )

    sowhat <- if (tier == "High (6+)") {
      paste0(
        row$lga_standard, " sits at the centre of this visualisation's argument — ",
        "high investment, near-total car dependency, and a severe PT time penalty. ",
        "The charts below show exactly where it stands."
      )
    } else if (tier == "Medium (3-5)") {
      paste0(
        row$lga_standard, " is in the Medium tier — the largest group. ",
        "See how its car dependency and PT penalty compare to the High-tier LGAs ",
        "that anchor the narrative."
      )
    } else {
      paste0(
        row$lga_standard, " is a Low-investment LGA. ",
        "Its transport profile — especially if it is an inner-city suburb — ",
        "illustrates how geography, not investment, drives the patterns seen in Parts 1–3."
      )
    }

    tags$div(class = "lga-summary-card",
      tags$div(class = "lga-summary-header",
        tags$div(class = "lga-summary-name", row$lga_standard),
        tags$div(class = paste0("lga-tier-badge tier-", gsub("[^a-z]", "", tolower(tier))), tier)
      ),
      tags$div(class = "lga-identity-line", identity),
      tags$p(class = "lga-summary-sowhat", sowhat)
    )
  })

  # ---- 2. Mode share bar ----
  output$lga_modeshare_plot <- renderPlotly({

    row      <- lga_row()
    tier_row <- tier_mode_row()

    if (is.na(row$car_pct)) {
      plot_ly() %>%
        layout(
          annotations = list(list(
            x = 0.5, y = 0.5, text = "Insufficient work-trip data for this LGA",
            xref = "paper", yref = "paper", showarrow = FALSE,
            font = list(size = 12, color = "#AAAAAA")
          )),
          paper_bgcolor = BG_WHITE, plot_bgcolor = BG_WHITE
        ) %>% config(displayModeBar = FALSE)
    } else {
      tier_car <- tier_row %>% filter(mode_group == "Private Vehicle") %>% pull(pct)
      tier_pt  <- tier_row %>% filter(mode_group == "Public Transport") %>% pull(pct)
      tier_act <- tier_row %>% filter(mode_group == "Active Transport") %>% pull(pct)

      lga_label  <- row$lga_standard
      tier_label <- paste0(row$investment_tier, " tier avg")

      df_bar <- data.frame(
        label = c(lga_label, tier_label, lga_label, tier_label, lga_label, tier_label),
        mode  = c("Private Vehicle", "Private Vehicle",
                  "Public Transport", "Public Transport",
                  "Active Transport", "Active Transport"),
        pct   = c(row$car_pct, tier_car, row$pt_pct, tier_pt, row$active_pct, tier_act),
        stringsAsFactors = FALSE
      )

      p <- plot_ly()
      for (m in c("Private Vehicle", "Public Transport", "Active Transport")) {
        d <- df_bar %>% filter(mode == m)
        p <- add_trace(p,
          data         = d,
          x            = ~pct,
          y            = ~label,
          type         = "bar",
          orientation  = "h",
          name         = m,
          marker       = list(color = MODE_COLS[m],
                              line  = list(color = "white", width = 1)),
          text         = ~ifelse(pct >= 8, paste0(pct, "%"), ""),
          textposition = "inside",
          insidetextanchor = "middle",
          textfont     = list(color = "white", size = 10.5),
          hovertext    = ~paste0("<b>", label, "</b><br>", m, ": ", pct, "%"),
          hoverinfo    = "text",
          showlegend   = TRUE
        )
      }

      car_diff  <- round(row$car_pct - tier_car, 1)
      diff_label <- if (car_diff >= 10) {
        "Much more car-dependent than tier"
      } else if (car_diff >= 3) {
        "More car-dependent than tier"
      } else if (car_diff <= -10) {
        "Much less car-dependent than tier"
      } else if (car_diff <= -3) {
        "Less car-dependent than tier"
      } else {
        "Similar to tier average"
      }
      diff_col <- if (car_diff >= 3)  MODE_COLS["Private Vehicle"] else
                  if (car_diff <= -3) "#27AE60" else "#888888"

      p <- add_annotations(p,
        x         = 101,
        y         = lga_label,
        text      = diff_label,
        xref      = "x", yref = "y",
        xanchor   = "left", yanchor = "middle",
        showarrow = FALSE,
        font      = list(size = 10, color = diff_col)
      )

      p %>% layout(
        barmode = "stack",
        xaxis   = list(visible = FALSE, range = c(0, 140)),
        yaxis   = list(
          title         = "",
          tickfont      = list(size = 11),
          categoryorder = "array",
          categoryarray = c(tier_label, lga_label)
        ),
        legend  = list(orientation = "h", x = 0, y = -0.18,
                       font = list(size = 10)),
        margin        = list(l = 10, r = 10, t = 5, b = 5),
        paper_bgcolor = BG_WHITE,
        plot_bgcolor  = BG_WHITE,
        showlegend    = TRUE
      ) %>% config(displayModeBar = FALSE)
    }
  })

  # ---- 3. Dumbbell: LGA vs tier average ----
  output$lga_dumbbell_plot <- renderPlotly({

    row <- lga_row()
    tar <- tier_avg_row()

    if (is.na(row$pt_median)) {
      plot_ly() %>%
        layout(
          annotations = list(list(
            x = 0.5, y = 0.5,
            text = "No public transport trips recorded for this LGA in VISTA",
            xref = "paper", yref = "paper", showarrow = FALSE,
            font = list(size = 12, color = "#AAAAAA")
          )),
          paper_bgcolor = BG_WHITE, plot_bgcolor = BG_WHITE
        ) %>% config(displayModeBar = FALSE)
    } else {
      lga_label  <- row$lga_standard
      tier_label <- paste0(row$investment_tier, " tier avg")

      df_db <- data.frame(
        label      = c(lga_label, tier_label),
        car_median = c(row$car_median, tar$car_median),
        pt_median  = c(row$pt_median,  tar$pt_median),
        pt_ratio   = c(row$pt_ratio,   tar$pt_ratio),
        stringsAsFactors = FALSE
      )

      p <- plot_ly()

      for (i in seq_len(nrow(df_db))) {
        r <- df_db[i, ]
        p <- add_trace(p,
          x = c(r$car_median, r$pt_median), y = c(r$label, r$label),
          type = "scatter", mode = "lines+markers",
          line = list(
            color = if (r$label == lga_label) "#999999" else "#DDDDDD",
            width = if (r$label == lga_label) 3 else 2
          ),
          marker = list(size = 1, opacity = 0),
          showlegend = FALSE, hoverinfo = "skip"
        )
      }

      p <- add_trace(p,
        data = df_db, x = ~car_median, y = ~label,
        type = "scatter", mode = "markers",
        name = "Car (median)",
        marker = list(
          color  = MODE_COLS["Private Vehicle"], size = 14,
          line   = list(color = "white", width = 2)
        ),
        hovertext = ~paste0("<b>", label, "</b><br>Car: <b>", car_median, " min</b>"),
        hoverinfo = "text", showlegend = TRUE
      )

      p <- add_trace(p,
        data = df_db, x = ~pt_median, y = ~label,
        type = "scatter", mode = "markers",
        name = "Public transport (median)",
        marker = list(
          color  = MODE_COLS["Public Transport"], size = 14,
          line   = list(color = "white", width = 2)
        ),
        hovertext = ~paste0("<b>", label, "</b><br>PT: <b>", pt_median,
                            " min</b><br>", pt_ratio, "× slower than car"),
        hoverinfo = "text", showlegend = TRUE
      )

      lga_r <- df_db %>% filter(label == lga_label)
      ann_x  <- lga_r$pt_median + 1

      p <- add_annotations(p,
        x = ann_x, y = lga_label,
        text      = paste0("  <b>", lga_r$pt_ratio, "×</b> slower"),
        xanchor   = "left", yanchor   = "bottom",
        showarrow = FALSE,
        font      = list(size = 10, color = MODE_COLS["Public Transport"])
      )
      p <- add_annotations(p,
        x = ann_x, y = lga_label,
        text      = paste0("  +", lga_r$penalty_min, " min penalty"),
        xanchor   = "left", yanchor   = "top",
        showarrow = FALSE,
        font      = list(size = 9.5, color = "#888888")
      )

      p %>% layout(
        xaxis = list(
          title      = "Median trip time (minutes)",
          range      = c(0, max(df_db$pt_median, na.rm = TRUE) * 1.35),
          gridcolor  = GRID_COL,
          zeroline   = FALSE,
          ticksuffix = " min", tickfont = list(size = 10)
        ),
        yaxis = list(
          title         = "",
          categoryorder = "array",
          categoryarray = c(tier_label, lga_label),
          tickfont      = list(size = 10.5)
        ),
        legend = list(
          orientation = "h", x = 0, y = -0.22,
          font = list(size = 10)
        ),
        showlegend    = TRUE,
        hovermode     = "closest",
        margin        = list(l = 10, r = 30, t = 8, b = 8),
        plot_bgcolor  = BG_CHART,
        paper_bgcolor = BG_WHITE
      ) %>% config(displayModeBar = FALSE)
    }
  })

  # ============================================================
  # STATE TOGGLE — Martini glass
  # ============================================================
  observeEvent(input$open_explore, {
    hide("right-overlay", anim = TRUE, animType = "fade", time = 0.35)
    addClass("right-inner-content", "visible")
    runjs("window.scrollTo({ top: 0, behavior: 'smooth' });")
  })

  observeEvent(input$back_narrative, {
    show("right-overlay", anim = TRUE, animType = "fade", time = 0.25)
    removeClass("right-inner-content", "visible")
  })

} # end server