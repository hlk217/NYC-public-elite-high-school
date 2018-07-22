library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)
library(googleVis)
source("helpers.R")


zipdata <- cleanTable

function(input, output, session) {

  ## Interactive Map ###########################################

  # Create the map. centered in NYC and zoom in to proper size
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -73.9663211, lat = 40.7777476, zoom = 12) 
      #addProviderTiles("Stamen.Toner") %>% 
      #addProviderTiles("OpenTopoMap") %>% 
      
  })

  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(zipdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(zipdata,
          latt >= latRng[1] & latt <= latRng[2] &
          longt >= lngRng[1] & longt <= lngRng[2]
      )
  })

  output$scatterProficiency <- renderGvis({
    
    if (nrow(zipsInBounds()) == 0)
      return(NULL)
    else
      my_options <- list(width="300px", height="300px",
                         #title="Motor Trend Car Road Tests",
                         hAxis=paste( "{title:' Avg. ELA Proficiency', minValue:", min(cleanTable$ela.proficiency, na.rm=T) ,", maxValue:", max(cleanTable$ela.proficiency, na.rm=T) + 1, "}" ),
                         vAxis="{title:'Avg. Math Proficiency'}",
                         pointSize= 8,
                         dataOpacity= 0.5,
                         #backgroundColor = "black"
                         #colors= "['#e0440e', '#e6693e', '#ec8f6e', '#f3b49f', '#f6c7b6']",
                         legend= "bottom"
                         )
      #my_options$explorer <- "{actions:['dragToZoom', 'rightClickToReset']}"
    
      dt <- zipsInBounds() %>% 
        mutate(black = ifelse(ethnicity=="black", math.proficiency, NA), 
               white = ifelse(ethnicity=="white", math.proficiency, NA), 
               asian = ifelse(ethnicity=="asian", math.proficiency, NA), 
               hispanic = ifelse(ethnicity=="hispanic", math.proficiency, NA)) %>% 
        select(ela.proficiency, black, hispanic, white, asian) 
      dt <- dt[,colSums(is.na(dt))<nrow(dt)] #when a column is full of NA, googleVis will throw error. So, have to remove it in order to plot
      gvisScatterChart(data = dt , options=my_options)
  })
  
  
  # This observer is responsible for maintaining the circles, marker and legend,
  # according to the variables the user has chosen to map to color and size.
  # based on the prediction value, the user can ID the potentail school by placing markers
  observe({
   
    colorBy <- input$color
    sizeBy <- input$size
    
    colorData <- zipdata[[colorBy]]
    pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
    
    radiusData <- changeNAtoCertainValue( zipdata[[sizeBy]] , min( zipdata[[sizeBy]], na.rm=T ) )
    
    radius <- radiusData / max(radiusData, na.rm = T) * 1000
    
    # 
    baseMap <- leafletProxy("map", data = zipdata) %>% clearShapes()
    if (input$show){
      baseMap %>%  
        addCircles(~longt, ~latt, radius=radius, layerId=~name,
                   stroke=F, fillOpacity=0.4, fillColor=pal(colorData))  %>% 
        addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
    }
    
   if (input$addmarker){
      markerLayerLocInfo <- getMarkerLocation(zipdata, input$predRange[1], input$predRange[2], input$black, input$white, input$asian, input$hispanic)
      
      baseMap %>% 
        removeMarker(layerId = ~dbn ) %>% 
        addMarkers(lng=markerLayerLocInfo$longt, lat=markerLayerLocInfo$latt, popup=paste("Predict Offer Ratio =", markerLayerLocInfo$predictedOfferRatio), layerId = markerLayerLocInfo$dbn)
      
    }else(
      baseMap %>% 
        removeMarker(layerId = ~dbn )
    )
    
  })

  
  # Show a popup at the given location
  showSchoolPopup <- function(name, lat, lng) {
    selectedSchool <- cleanTable[ cleanTable$name == name, ]
    
    content <- as.character(tagList(
      tags$h4("Name:", selectedSchool$name),
      tags$strong(HTML(sprintf("%s, %s",
          selectedSchool$city, selectedSchool$zip
      ))), tags$br(),
      sprintf("Est. Shool Income : %s", dollar(selectedSchool$income * 1)), tags$br(),
      sprintf("District: %s", as.integer(selectedSchool$district)),tags$br(),
      sprintf("# of students take SHSAT: %s", as.integer(selectedSchool$takeExam)),tags$br(),
      sprintf("# of students got offers from SH: %s", as.integer(selectedSchool$offer)),tags$br(),
      sprintf("Predicted SH offer ratio: %s%%", format(round( selectedSchool$combinedOfferRate*100 , 2), nsmall = 2) )
    ))
    
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = name)
    
  }

  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()

    isolate({
      showSchoolPopup(event$id, event$lat, event$lng)
    })
  })


  ## Data Explorer ###########################################

  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
      map %>% clearPopups()
      dist <- 0.02
      name <- input$goto$name
      lat <- input$goto$lat
      lng <- input$goto$lng
     
      showSchoolPopup(name, lat, lng)
      map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist) 
    })
  })

  output$schoolTable <- DT::renderDataTable({
    zoom <- 12
    df <- cleanTable %>%
      mutate(Action = paste('<a class="go-map" href="" data-lat="', latt, '" data-long="', longt, '" data-name="', name, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    action <- DT::dataTableAjax(session, df)

    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
}
