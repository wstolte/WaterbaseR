
require(ggvis)
require(shiny)

runApp(list(
  ui = fluidPage(
    sidebarPanel(
      selectInput("gear", "Gear: ", 
                  choices = unique(mtcars$gear), 
                  helpText("select number of gears"))
    ),
    mainPanel(
      ggvisOutput("tp"),
      uiOutput("tp_ui")
    )
  ),
  server = function(input, output, session) {
    vis = reactive(
      subset(mtcars, mtcars$gear == input$gear) %>% 
      # mtcars %>%
        ggvis(~cyl, ~mpg) %>% 
        gg
        layer_points()
        )
    vis %>% bind_shiny("tp", "tp_ui")
  }
))


