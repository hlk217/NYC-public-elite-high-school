changeNAtoCertainValue = function(data, NAvalue=1){
  
  data[is.na(data)] <- NAvalue
  return (data)

}

getMarkerLocation = function(data, predRangeLow = 0, predRangeHigh = 1, black=F, white=F, asian=F, hispanic=T){
  subData <- data %>% 
    filter ( predictedOfferRatio >= predRangeLow & predictedOfferRatio <= predRangeHigh ) 
  
  result <-  data.frame(dbn=character(),longt=numeric(),latt=numeric(), predictedOfferRatio = numeric(), ethnicity=as.character(), ela.math.group = as.character(), stringsAsFactors=FALSE) 
  if(black){
    blackSet <- subData %>% 
      filter (ethnicity =="black") %>% 
      select(dbn, longt, latt, predictedOfferRatio, ethnicity, ela.math.group)
    result <- rbind(result, blackSet)
  }
  
  if(white){
    whiteSet <- subData %>% 
      filter (ethnicity=="white") %>% 
      select(dbn, longt, latt, predictedOfferRatio, ethnicity, ela.math.group)
    result <- rbind(result, whiteSet)
  }
    
  if(asian){
    asianSet <- subData %>% 
      filter (ethnicity=="asian") %>% 
      select(dbn, longt, latt, predictedOfferRatio, ethnicity, ela.math.group)
    result <- rbind(result, asianSet)
  }
    
  if(hispanic){
    hispanicSet <- subData %>% 
      filter (ethnicity=="hispanic") %>% 
      select(dbn, longt, latt, predictedOfferRatio, ethnicity, ela.math.group)
    result <- rbind(result, hispanicSet)
  }

  return ( result )
}

#data <- cleanTable
#x <- getMarkerLocation(data, 0, 1, T, F, F, F)


getEthGroupColor <- function( data ) {
  sapply(data$ethnicity, function(ethnicity) {
    if(ethnicity == "asian") {
      "green"
    } else if(ethnicity == "black") {
      "blue"
    } else if(ethnicity == "hispanic") {
      "orange"
    } else if(ethnicity == "white") {
      "white"
    } else {
      "black"
    } })
}


getELAMathGroupColor <- function( data ) {
  sapply(data$ela.math.group, function(ela.math.group) {
    if(ela.math.group == "Both Good") {
      "green"
    } else if(ela.math.group == "Need to improve Math") {
      "red"
    } else if(ela.math.group == "Need to improve ELA") {
      "orange"
    } else if(ela.math.group == "Both Bad") {
      "gray"
    } else {
      "gray"
    } 
  })
}



