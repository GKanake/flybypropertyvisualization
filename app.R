library(shiny)
#rsconnect::writeManifest()
library(mapgl)
library(mapboxapi)

# Property location
property <- c(36.817223, -1.286389)

# Isochrones for each profile
isochrone_drive <- mb_isochrone(property, profile = "driving", time = 20)
isochrone_walk  <- mb_isochrone(property, profile = "walking", time = 20)
isochrone_bike  <- mb_isochrone(property, profile = "cycling", time = 20)

ui <- fluidPage(
  tags$link(href = "https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap", rel = "stylesheet"),
  story_map(
    map_id = "map",
    font_family = "Poppins",
    sections = list(
      "intro" = story_section(
        title = "NESTOPIA GROUP PROPERTIES",
        content = list(
          p("New Class A Apartments in City Center, Nairobi"),
          img(src = "https://imgs.search.brave.com/D_ie1GjQmkEpnf1ppg0fdqW8KWMzAdzletOwflmD98E/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzA0Lzk5LzQ4LzU5/LzM2MF9GXzQ5OTQ4/NTk4NF9SWHBrYzFz/U2NkTU93SUNhc2JY/VTl6V2R0cFlYdlFu/OS5qcGc", width = "300px")
        ),
        position = "center"
      ),
      "marker" = story_section(
        title = "PROPERTY LOCATION",
        content = list(
          p("The property will be located in the thriving Central Business District, home to some of the city's best shopping, dining, and entertainment.")
        )
      ),
      "isochrone" = story_section(
        title = "NAIROBI AT YOUR FINGERTIPS",
        content = list(
          p("The property is within a 20-minute walk, bike, or drive to key Nairobi destinations."),
          img(src = "isochrones_legend.png", width = "152px")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$map <- renderMapboxgl({
    mapboxgl(scrollZoom = FALSE,
             center = c(36.8050, -1.2649),
             zoom = 12) |>
      add_navigation_control(position = "top-left")
  })
  
  on_section("map", "intro", {
    mapboxgl_proxy("map") |>
      clear_markers() |>
      fly_to(center = c(36.8050, -1.2649),
             zoom = 12,
             pitch = 0,
             bearing = 0)
  })
  
  on_section("map", "marker", {
    mapboxgl_proxy("map") |>
      clear_layer("isochrone_drive") |>
      clear_layer("isochrone_walk") |>
      clear_layer("isochrone_bike") |>
      add_markers(data = property, color = "#CC5500") |>
      fly_to(center = property,
             zoom = 16,
             pitch = 45,
             bearing = -90)
  })
  
  on_section("map", "isochrone", {
    mapboxgl_proxy("map") |>
      add_fill_layer(
        id = "isochrone_drive",
        source = isochrone_drive,
        fill_color = "#CC5500",  # orange (driving)
        fill_opacity = 0.4
      ) |>
      add_fill_layer(
        id = "isochrone_bike",
        source = isochrone_bike,
        fill_color = "#32CD32",  # green (cycling)
        fill_opacity = 0.4
      ) |>
      add_fill_layer(
        id = "isochrone_walk",
        source = isochrone_walk,
        fill_color = "#1E90FF",  # blue (walking)
        fill_opacity = 0.4
      ) |>
      fit_bounds(
        isochrone_drive,
        animate = TRUE,
        duration = 8000,
        pitch = 45
      )
  })
}

shinyApp(ui, server)