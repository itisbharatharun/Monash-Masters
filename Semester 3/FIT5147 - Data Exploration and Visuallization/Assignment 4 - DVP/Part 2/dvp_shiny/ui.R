ui <- fluidPage(
  theme = bs_theme(version = 5),
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com",
              crossorigin = "anonymous"),
    tags$script(HTML("
      $(document).on('mouseleave', '#p3_plot', function() {
        Shiny.setInputValue('p3_mouseleave', Math.random());
      });
    "))
  ),


  fluidRow(

    column(7, class = "left-col",

      # ---- P1: Title Panel ----
      tags$div(class = "panel-card title-panel",

        tags$div(class = "stat-row",
          tags$div(class = "stat-box",
            tags$div(class = "stat-number", STAT_CASEY_PROJECTS),
            tags$div(class = "stat-label",
              "education projects in Casey — Victoria's most-invested growth suburb")
          ),
          tags$div(class = "stat-box",
            tags$div(class = "stat-number", paste0(STAT_HIGH_CAR_PCT, "%")),
            tags$div(class = "stat-label",
              "of work trips in those same suburbs made by private car")
          ),
          tags$div(class = "stat-box",
            tags$div(class = "stat-number", paste0(STAT_HIGH_PT_RATIO, "\u00d7")),
            tags$div(class = "stat-label",
              "longer to make that trip by public transport than by car")
          )
        ),

        tags$h1(class = "app-title",
          "Victoria Is Building Schools. But Not Transport."),
        tags$p(class = "app-subtitle",
          "Education infrastructure investment in Victoria is landing in the right suburbs. ",
          "The problem is that it arrived without buses, trains, or bike lanes. ",
          "This visualisation shows what that means for how families travel — ",
          "and what it will cost if nothing changes."
        ),

        tags$div(class = "alert-box",
          tags$span("⚠ ", style = "font-size:13px;"),
          tags$strong("Coverage note: "),
          "29 Victorian LGAs with education investment are not covered by the VISTA travel survey. ",
          "Analysis is restricted to 33 overlapping LGAs in Greater Melbourne and Geelong."
        ),

        tags$div(class = "data-source",
          tags$a(
            href   = "https://opendata.transport.vic.gov.au/dataset/174fbf40-bef0-434a-8af0-891c7f3d2323",
            target = "_blank", "VISTA 2024–25 Open Data ↗"
          )
        ),
        tags$p(class = "scroll-hint", "Scroll to follow the argument ↓")
      ),

      # ---- P2: Cleveland Dot Plot — Beat 1 ----
      tags$div(class = "panel-card",
        tags$div(class = "panel-number", "Part 1 of 3"),
        tags$div(class = "panel-headline",
          "The investment is going to the right places."),
        tags$div(class = "narrative-text",
          "Victoria's 2023–24 budget directed education spending toward outer-suburban ",
          "growth corridors — exactly where household population has grown fastest. ",
          "The chart below shows this alignment: LGAs with more surveyed households ",
          "tend to receive more education projects. The government is reading the ",
          "population correctly."
        ),
        tags$p(class = "panel-subhead",
          "Each dot = one LGA. X-axis = number of state-funded education projects. Y-axis = LGAs ranked ascending by households surveyed. Colour = investment tier. Hover a tier on Part 2 below to highlight matching LGAs here — move mouse away to reset."),
        plotlyOutput("p2_plot", height = "520px"),
        tags$div(class = "callout-box",
          tags$strong("But the fit is not perfect."),
          " Both Greater Geelong (263 households, 8 projects) and Casey (144 households, 15 projects) ",
          "fall in the same High investment tier — yet Casey receives nearly twice the projects ",
          "from a smaller household base. Investment follows outer-suburban growth broadly, ",
          "but there is meaningful variation even within tiers. ",
          "This matters for the next question: what are those high-investment suburbs actually like to get around in?"
        ),
        tags$div(class = "data-source", "Source: VISTA 2024–25 | State Budget 2023–24")
      ),

      # ---- P3: Slope Chart — Beat 2 ----
      tags$div(class = "panel-card",
        tags$div(class = "panel-number", "Part 2 of 3"),
        tags$div(class = "panel-headline",
          "But those suburbs run almost entirely on cars."),
        tags$div(class = "narrative-text",
          "Here is the problem. The LGAs receiving the most education investment are ",
          "outer-suburban growth corridors: Casey, Hume, Melton, Wyndham. ",
          "In these same areas, ",
          tags$strong("89% of weekday work trips are made by private vehicle"),
          " — the highest car dependency of any investment tier. ",
          "Public transport and active transport barely register. ",
          "More school buildings did not produce more transport options."
        ),
        tags$p(class = "panel-subhead",
          "Weekday work-related trips only. Hover any tier point to highlight matching LGAs in Part 1 above — move mouse away to reset."),
        plotlyOutput("p3_plot", height = "390px"),
        tags$div(class = "callout-box",
          "The dip at Low (1–2) is not evidence that less investment helps — it reflects ",
          "inner-city LGAs like Port Phillip and Boroondara, where trams and walkable streets ",
          "exist independent of education investment. ",
          tags$strong("Geography determines transport options in this data, not investment level."),
          " The question then is: why is transport so bad in these outer suburbs? Part 3 shows the answer."
        ),
        tags$div(class = "data-source", "Source: VISTA 2024–25 | State Budget 2023–24")
      ),

      # ---- P4: Dumbbell Gap Chart — Beat 3 ----
      tags$div(class = "panel-card",
        tags$div(class = "panel-number", "Part 3 of 3"),
        tags$div(class = "panel-headline",
          "Because public transport is 6 times slower than driving there."),
        tags$div(class = "narrative-text",
          "Families in High-investment LGAs are not choosing cars because they prefer them. ",
          "They are choosing cars because public transport takes ",
          tags$strong("60 minutes"), " for a trip that takes just ",
          tags$strong("10 minutes by car"),
          " — a ", tags$strong("50-minute penalty"), ", or 6 times longer. ",
          "No rational commuter chooses the slower option. ",
          "The charts below show this penalty across both investment tier (top) ",
          "and neighbourhood disadvantage (bottom). The pattern is consistent: ",
          "outer growth suburbs face the worst PT access in the entire VISTA survey area."
        ),
        tags$p(class = "panel-subhead",
          "Orange dot = median car trip time. Blue dot = median PT trip time. The line is the time penalty."),
        tags$div(class = "gap-chart-label", "By education investment tier"),
        plotlyOutput("p4_tier_plot", height = "230px"),
        tags$div(class = "gap-divider",
          "The same structural penalty by neighbourhood disadvantage (IRSD decile)"),
        tags$div(class = "gap-chart-label",
          "Decile 2 = most disadvantaged in VISTA · Decile 10 = least disadvantaged"),
        plotlyOutput("p4_irsd_plot", height = "285px"),
        tags$div(class = "callout-box",
          tags$strong("This is not a behaviour problem. It is a service problem."),
          " Decile 6 outer-growth suburbs face a 57-minute PT penalty against a 13-minute car trip. ",
          "Even the least disadvantaged areas (Decile 10) still face a 3.6× penalty. ",
          "Victoria is building schools in car-dependent suburbs and doing nothing to change ",
          "the transport conditions that make car dependency inevitable. ",
          tags$strong("Without complementary transport investment, the next generation will commute by car too.")
        ),
        tags$div(class = "data-source",
          "Source: VISTA 2024–25 | ABS SEIFA 2021 | State Budget 2023–24")
      ),

      # ---- Section Break ----
      tags$div(class = "section-break",
        tags$hr(),
        tags$p(
          "You have seen the argument. Schools are in the right suburbs. ",
          "Those suburbs are car-dependent. Public transport cannot compete. ",
          "Now look up your own LGA and see the policy implications."
        ),
        actionButton("open_explore", "Explore Your LGA →",
                     class = "btn btn-explore")
      )

    ), # end left-col

    # ===========================================================
    # RIGHT COLUMN — LGA Explorer + Policy Implications (40%)
    # ===========================================================
    column(5, id = "right-col", class = "right-col",

      # Locked overlay — State A
      tags$div(id = "right-overlay",
        tags$div(class = "overlay-icon", "◎"),
        tags$p(class = "overlay-title", "LGA Explorer"),
        tags$p(class = "overlay-text",
          "Scroll through the three-part argument on the left. ",
          "Once you have read the evidence, click ",
          tags$strong("Explore Your LGA"),
          " to see how these findings apply to a specific Victorian suburb."
        )
      ),

      # Back button — State B
      actionButton("back_narrative", "← Back to the Argument",
                   class = "btn-back"),

      tags$div(id = "right-inner-content", class = "right-inner",

        tags$h3(class = "right-title", "How Does Your LGA Compare?"),

        tags$p(class = "explorer-intro",
          "The three-part argument above shows Victoria-wide patterns. ",
          "Select any LGA below to see how the same findings play out ",
          "for a specific suburb — its investment level, car dependency, ",
          "and public transport time penalty."
        ),

        tags$div(class = "explorer-select-wrap",
          selectInput(
            inputId  = "selected_lga",
            label    = NULL,
            choices  = c("Select an LGA..." = "", sort(unique(lga_explorer$lga_standard))),
            selected = "",
            width    = "100%"
          )
        ),

        uiOutput("lga_summary_card"),

        tags$div(id = "lga-charts-wrap",
          tags$div(id = "lga-modeshare-wrap",
            tags$div(class = "explorer-chart-label",
              "Mode share for weekday work trips in this LGA"),
            plotlyOutput("lga_modeshare_plot", height = "110px"),
            tags$div(class = "explorer-chart-label", style = "margin-top:18px;",
              "Car vs public transport trip time — this LGA vs tier average"),
            plotlyOutput("lga_dumbbell_plot", height = "130px")
          )
        ),

        tags$div(class = "panel-card", style = "margin-top:20px;",
          tags$div(class = "panel-headline",
            "What this analysis does and does not cover"),
          plotlyOutput("coverage_plot", height = "85px"),
          tags$p(class = "coverage-note",
            "29 LGAs received education investment in 2023–24 but have no VISTA survey data. ",
            "Regional Victoria is almost entirely absent. ",
            tags$strong("All findings apply to Greater Melbourne and Geelong only."),
            " The transport penalty in regional LGAs is likely worse."
          )
        ),

        tags$h4(class = "implications-heading", "Policy Implications"),

        tags$div(class = "implication-card",
          tags$div(class = "implication-number", "01"),
          tags$div(class = "implication-title",
            "Education investment is well-targeted. Transport investment is not."),
          tags$div(class = "implication-body",
            "The data shows government is correctly identifying outer-suburban growth corridors ",
            "as the priority for school construction. The same corridors show 89% car dependency ",
            "and a 50-minute public transport penalty. Bus frequency, rail extensions, and safe ",
            "cycling routes must be planned in parallel with school construction — not retrofitted years later."
          )
        ),

        tags$div(class = "implication-card",
          tags$div(class = "implication-number", "02"),
          tags$div(class = "implication-title",
            "The 50-minute PT penalty is a specific, measurable target."),
          tags$div(class = "implication-body",
            "High-investment LGAs have a median PT trip time of 60 minutes versus 10 minutes by car — ",
            "a 50-minute penalty. Inner-city Low-investment LGAs achieve 37 minutes by PT. ",
            "That 23-minute gap between tiers is not geography — ",
            "it is service frequency and route coverage. It is a problem transport investment can solve."
          )
        ),

        tags$div(class = "implication-card",
          tags$div(class = "implication-number", "03"),
          tags$div(class = "implication-title",
            "Car dependency formed in childhood is durable. The window is now."),
          tags$div(class = "implication-body",
            tags$strong("67% of primary school children in High-investment LGAs travel by private car"),
            " — as shown in the chart below. The commute habits and infrastructure expectations ",
            "formed before age 18 are difficult to reverse. Children growing up in Casey and Hume ",
            "today will be commuting adults in 2040. The cost of inaction compounds every year."
          ),
          tags$div(class = "explorer-chart-label", style = "margin-top:12px;",
            "How primary school children travel — by investment tier"),
          plotlyOutput("school_mode_plot", height = "120px")
        ),

        tags$div(class = "data-source-right",
          tags$a(href = "https://opendata.transport.vic.gov.au/dataset/174fbf40-bef0-434a-8af0-891c7f3d2323",
                 target = "_blank", "VISTA 2024–25"),
          " | ",
          tags$a(href = "https://discover.data.vic.gov.au/dataset/ed30724b-6ae7-4713-aff3-4f00b3666684",
                 target = "_blank", "State Budget 2023–24"),
          " | ",
          tags$a(href = "https://www.abs.gov.au/statistics/people/people-and-communities/socio-economic-indexes-areas-seifa-australia/2021",
                 target = "_blank", "ABS SEIFA 2021")
        )
      )
    ) # end right-col
  )
)