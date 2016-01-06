require(readr)
require(ggplot2)
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
      plotOutput("timeplot", width = "450px", height = "350px")  
    )
  ),
  server = function(input,output,session) {
    
    subdf = reactive(subset(coll, coll$locatie == input$location &     
                              coll$waarnemingssoort == input$substance   &          
                              as.numeric(format(coll$datum, "%Y")) >= input$interval[1] &
                              as.numeric(format(coll$datum, "%Y")) <= input$interval[2] &
                              coll$waarde < input$high))
    
    output$timeplot <- renderPlot({
      p <- ggplot(subdf, aes(datum, waarde))
      p + geom_point()
    })
    #     
    #         subdf %>% 
    #       ggvis(~datum, ~waarde) %>% 
    #       layer_points() %>%
    #       bind_shiny("tp", "tp_ui")
  }
))


