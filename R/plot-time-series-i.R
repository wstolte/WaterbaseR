setwd("D://GitHubClones/WaterbaseR")

require(readr)
require(ggvis)
require(shiny)
coll <- read_csv2("DATA/collected-data.csv")
runApp(list(
  ui = fluidPage(
    sidebarPanel(
      selectInput("location", "Location:", 
                  choices = unique(coll$locatie), 
                  helpText("select location")),
      selectInput("substance", "Substance:", 
                  choices = levels(as.factor(coll$waarnemingssoort)),
                  helpText("select substance")),
      sliderInput("interval", "Interval", min = as.numeric(format(min(coll$datum), "%Y")), max = as.numeric(format(max(coll$datum), "%Y")), c(1970, 2014), step = 1, sep = "",
                  helpText("select time interval")),
      numericInput("high", "Highest value: ", 1000)
    ),
    mainPanel(
      ggvisOutput("tp"),
      uiOutput("tp_ui")
    )
  ),
  server = function(input,output,session) {
    
    subdf = head(coll, 20)    
    subdf = reactive(subset(coll, coll$locatie == input$location &     
                              coll$waarnemingssoort == input$substance   &          
                              as.numeric(format(coll$datum, "%Y")) >= input$interval[1] &
                              as.numeric(format(coll$datum, "%Y")) <= input$interval[2] &
                              coll$waarde < input$high))

  #     subdf <- cbind(subdf, id = seq(nrow(subdf)))
  #     # Create a linked brush object
  #     lb <- linked_brush(keys = subdf$id, "red")
    lb <- linked_brush(keys = 1:nrow(subdf), "red")
    
    # Just the brushed points
    selected <- lb$selected
    subdf_selected <- reactive({
      if (!any(selected())) return(subdf)
      subdf[selected(), ]
    })
    
    subdf %>% 
      ggvis(~datum, ~waarde) %>% 
      layer_points(fill := lb$fill, fill.brush := "red") %>%
      #       lb$input() %>%
      #       add_data(subdf_selected) %>%
      # layer_model_predictions(model = "lm") %>%
      bind_shiny("tp", "tp_ui")
    
    
  }
))

