library(leaflet)
library(markdown)

# Choices for drop-downs
# Different column names of the table data ... use to select input variable.

vars <- c(
  "School district" = "district",
  "School income" = "income",
  "Number of Student taking SHSAT" = "takeExam",
  "Number of Student received SH Offer" = "offer",
  "Average ELA proficiency"="ela.proficiency",
  "Average MATH proficiency"="math.proficiency",
  "Offer Rate"="offerRate",
  "Predicted Offer Rate"="combinedOfferRate"
  )


navbarPage("NYCpass", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("www/styles.css"),
        includeScript("www/gomap.js")
      ),

      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="100%"),

      # Shiny versions prior to 0.11 should use class = "modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
        width = 330, height = "auto",

        h2("Area Stats"),
        
        checkboxInput("show", "Show Color and Size", TRUE),
        
        
        selectInput("color", "Color", vars, selected = "offer"),
        selectInput("size", "Size", vars, selected = "takeExam"),
      
        
        checkboxInput("addmarker", "Place the marker based on :", FALSE),
        sliderInput('predRange', 'Predicted Offer Rate Range', min=as.numeric( format(round(min(nycSchool$predictedOfferRatio, na.rm=T), 2), nsmall = 2)), max=as.numeric( format(round(max(nycSchool$predictedOfferRatio, na.rm=T), 2), nsmall = 2)),
                    value=c( as.numeric( format(round(max(nycSchool$predictedOfferRatio, na.rm=T), 2), nsmall = 2))  -0.1 , as.numeric( format(round(max(nycSchool$predictedOfferRatio, na.rm=T), 2), nsmall = 2) )  ), step=0.01, round=0),
        selectInput("markerColor", "Color markers by", c("None"="none", "School Major Ethnicity"="eth.group", "ELA and Math Proficiency"="ela.math.group"), selected = "none"),
        
        htmlOutput("scatterProficiency")
      ),

      tags$div(id="cite",
        'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
      )
    )
  ),

  tabPanel("Data explorer",
           
    DT::dataTableOutput("schoolTable")  #show the rawData table output
  ),

  tabPanel("Data Analysis",
         includeMarkdown("Data_Analysis.md")
         ),

  conditionalPanel("false", icon("crosshair"))
)
