# ─────────────────────────────────────────────────
# FIT5147 PE2 — R Shiny Application
# ALA Bird Observations: Seasonal & Spatial Analysis
# ─────────────────────────────────────────────────

library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(leaflet)
library(RColorBrewer)
library(scales)
library(htmltools)

# ── 1. DATA LOADING & PRE-PROCESSING ─────────────────────────────────────
df <- read.csv("ALA_PE2S12026.csv", stringsAsFactors = FALSE)

df <- df %>%
  mutate(
    date_parsed   = as.Date(observationDate),
    month         = month(date_parsed),
    season        = case_when(
      month %in% c(12, 1, 2)  ~ "Summer",
      month %in% c(3, 4, 5)   ~ "Autumn",
      month %in% c(6, 7, 8)   ~ "Winter",
      month %in% c(9, 10, 11) ~ "Spring"
    ),
    season        = factor(season, levels = c("Summer", "Autumn", "Winter", "Spring")),
    stateProvince = ifelse(
      is.na(stateProvince) | stateProvince == "",
      "Not recorded",
      stateProvince
    )
  )

# ── 2. SUMMARY COUNTS (computed dynamically — no hard-coding) ─────────────
total_obs <- format(nrow(df), big.mark = ",")
obp_count <- format(sum(df$vernacularName == "Orange-bellied Parrot"), big.mark = ",")

# ── 3. PRE-AGGREGATIONS (done ONCE, outside server) ──────────────────────

# VIS 1: proportion per season-species combination out of all observations
vis1_data <- df %>%
  count(season, vernacularName) %>%
  mutate(prop = n / sum(n))

# MAP: aggregated by location + species + season (for seasonal filter)
map_by_season <- df %>%
  group_by(
    decimalLatitude, decimalLongitude,
    scientificName, vernacularName,
    stateProvince, season
  ) %>%
  summarise(obs_count = n(), .groups = "drop")

# MAP: aggregated by location + species only (for Full Year view)
map_full_year <- df %>%
  group_by(
    decimalLatitude, decimalLongitude,
    scientificName, vernacularName,
    stateProvince
  ) %>%
  summarise(obs_count = n(), .groups = "drop")

# ── 4. COLOUR PALETTE (Dark2 — consistent across both VIS 1 and MAP) ─────
species_choices <- sort(unique(df$vernacularName))
dark2_colors    <- brewer.pal(length(species_choices), "Dark2")
species_pal     <- colorFactor(palette = dark2_colors, domain = species_choices)

# ── 5. VIS 1 PLOT (built once outside server — static) ───────────────────
vis1_plot <- ggplot(
  vis1_data,
  aes(x = season, y = prop, fill = vernacularName)
) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(
    values = setNames(dark2_colors, species_choices),
    name   = "Species"
  ) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Proportion of Bird Observations by Season (2004–2024)",
    x     = "Season",
    y     = "Proportion of All Observations"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title         = element_text(face = "bold", size = 13, hjust = 0.5),
    legend.position    = "bottom",
    legend.title       = element_text(face = "bold"),
    panel.grid.major.x = element_blank(),
    axis.title         = element_text(face = "bold")
  )

# ── 6. UI ─────────────────────────────────────────────────────────────────
ui <- fixedPage(
  
  # --- TITLE ---
  fixedRow(
    column(12,
           h1(
             "Australian Parrots: Seasonal Patterns and Geographic Distribution (2004–2024)",
             style = paste(
               "text-align: center;",
               "font-family: Georgia, serif;",
               "font-size: 22px;",
               "padding: 18px 0 10px 0;",
               "color: #2c3e50;"
             )
           )
    )
  ),
  
  tags$hr(style = "border-top: 2px solid #bdc3c7;"),
  
  # --- VIS 1 ROW ---
  fixedRow(
    # Left: chart
    column(7,
           plotOutput("vis1", height = "380px")
    ),
    # Right: description — counts injected dynamically via textOutput
    column(5,
           h4("Seasonal Distribution of Observations",
              style = "font-family: Georgia, serif; color: #2c3e50;"),
           p(
             style = "font-size: 13px; line-height: 1.6; text-align: justify;",
             textOutput("vis1_desc", inline = TRUE)
           )
    )
  ),
  
  tags$hr(style = "border-top: 1px solid #bdc3c7; margin-top: 10px;"),
  
  # --- MAP ROW (controls left, map right) ---
  fixedRow(
    # Left: filter controls
    column(3,
           h4("Filter by Species",
              style = "font-family: Georgia, serif; color: #2c3e50; margin-top: 10px;"),
           checkboxGroupInput(
             inputId  = "species_filter",
             label    = NULL,
             choices  = species_choices,
             selected = species_choices
           ),
           tags$hr(),
           h4("Filter by Season",
              style = "font-family: Georgia, serif; color: #2c3e50;"),
           radioButtons(
             inputId  = "season_filter",
             label    = NULL,
             choices  = c("Full Year", "Summer", "Autumn", "Winter", "Spring"),
             selected = "Full Year"
           )
    ),
    # Right: map
    column(9,
           leafletOutput("map", height = "500px")
    )
  ),
  
  tags$hr(style = "border-top: 1px solid #bdc3c7; margin-top: 10px;"),
  
  # --- MAP DESCRIPTION ---
  fixedRow(
    column(12,
           h4("Geographic Distribution and Migration Patterns",
              style = "font-family: Georgia, serif; color: #2c3e50;"),
           p(
             "The proportional symbol map displays bird observation locations across
        Australia. Each circle represents a unique coordinate, with colour
        indicating species (consistent with the chart above) and circle size
        reflecting the number of observations at that location. Use the species
        checkboxes to isolate individual species, and the season radio buttons
        to filter by time of year. The Swift Parrot (pink) shows a clear
        migratory signal — it clusters heavily in Tasmania during Summer and
        spreads northward into Victoria, New South Wales and the ACT during
        Autumn and Winter. The Orange-bellied Parrot (orange) mirrors this
        south-east coastal pattern but with very sparse records. The
        Purple-crowned and Little Lorikeets are distributed across southern and
        western Australia with minimal seasonal displacement, suggesting
        predominantly sedentary or locally nomadic behaviour. Hover over any
        circle for species details, observation count and state or territory.",
             style = "font-size: 13px; line-height: 1.6; text-align: justify;"
           )
    )
  ),
  
  tags$hr(style = "border-top: 2px solid #bdc3c7;"),
  
  # --- FOOTER ---
  fixedRow(
    column(12,
           p(
             HTML(
               "Data source: <b>Atlas of Living Australia (ALA)</b>.
          Available at: <a href='http://www.ala.org.au' target='_blank'>
          http://www.ala.org.au</a>.
          Licensor: ALA. Version date: 24 March, 2026."
             ),
             style = paste(
               "text-align: center;",
               "color: #7f8c8d;",
               "font-size: 12px;",
               "padding: 10px 0 16px 0;"
             )
           )
    )
  )
)

# ── 7. SERVER ─────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  
  # --- Dynamic VIS 1 description (uses computed counts, not hard-coded values) ---
  output$vis1_desc <- renderText({
    paste0(
      "This grouped bar chart displays the proportion of all ", total_obs,
      " observations falling within each Australian season, broken down by species. ",
      "Grouping bars side-by-side allows direct comparison of each species within ",
      "and across seasons from a shared zero baseline. Spring (Sep\u2013Nov) and ",
      "Autumn (Mar\u2013May) account for the highest overall observation volumes. ",
      "The Swift Parrot shows notably higher proportions in Autumn and Winter, ",
      "consistent with its migratory movement from Tasmanian breeding grounds to ",
      "mainland Australia. The Orange-bellied Parrot's bars are barely visible ",
      "across all seasons, reflecting its critically low record count (", obp_count,
      " total) and endangered status. Purple-crowned and Little Lorikeets contribute ",
      "relatively evenly across seasons, suggesting more sedentary or locally ",
      "nomadic behaviour."
    )
  })
  
  # --- Static VIS 1 plot ---
  output$vis1 <- renderPlot({
    vis1_plot
  })
  
  # --- Base map rendered once ---
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 133.9453, lat = -30.4486, zoom = 3) %>%
      addLegend(
        position = "bottomright",
        pal      = species_pal,
        values   = species_choices,
        title    = "Species",
        opacity  = 0.85
      )
  })
  
  # --- Reactive filter (minimal computation) ---
  filtered_data <- reactive({
    if (input$season_filter == "Full Year") {
      base <- map_full_year
    } else {
      base <- map_by_season %>%
        filter(season == input$season_filter) %>%
        group_by(
          decimalLatitude, decimalLongitude,
          scientificName, vernacularName, stateProvince
        ) %>%
        summarise(obs_count = sum(obs_count), .groups = "drop")
    }
    base %>%
      filter(vernacularName %in% input$species_filter) %>%
      arrange(desc(obs_count))  # larger circles drawn first so smaller ones render on top
  })
  
  # --- Update markers without re-rendering the whole map ---
  observe({
    data <- filtered_data()
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      addCircleMarkers(
        data        = data,
        lng         = ~decimalLongitude,
        lat         = ~decimalLatitude,
        radius      = ~pmax(4, sqrt(obs_count) * 2.5),
        color       = ~species_pal(vernacularName),
        fillColor   = ~species_pal(vernacularName),
        fillOpacity = 0.65,
        stroke      = TRUE,
        weight      = 0.5,
        opacity     = 0.9,
        label = ~lapply(paste0(
          "<b>Common name:</b> ", vernacularName, "<br/>",
          "<b>Scientific name:</b> <i>", scientificName, "</i><br/>",
          "<b>Observations:</b> ", obs_count, "<br/>",
          "<b>State/Territory:</b> ", stateProvince
        ), HTML),
        labelOptions = labelOptions(
          style = list(
            "font-size"        = "13px",
            "background-color" = "white",
            "border"           = "1px solid #ccc",
            "padding"          = "6px 10px"
          ),
          direction = "auto"
        )
      )
  })
}

# ── 8. RUN APP ────────────────────────────────────────────────────────────
shinyApp(ui = ui, server = server)