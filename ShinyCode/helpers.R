changeNAtoCertainValue = function(data, NAvalue=1){
  
  data[is.na(data)] <- NAvalue
  return (data)

}


getMarkerLocation = function(data, predRangeLow = 0, predRangeHigh = 1, black=F, white=F, asian=F, hispanic=T){
  subData <- data %>% 
    filter ( predictedOfferRatio >= predRangeLow & predictedOfferRatio <= predRangeHigh ) 
  
  result <-  data.frame(dbn=character(),longt=numeric(),latt=numeric(), predictedOfferRatio = numeric(), stringsAsFactors=FALSE) 
  if(black){
    blackSet <- subData %>% 
      filter (ethnicity =="black") %>% 
      select(dbn, longt, latt, predictedOfferRatio)
    result <- rbind(result, blackSet)
  }
  
  if(white){
    whiteSet <- subData %>% 
      filter (ethnicity=="white") %>% 
      select(dbn, longt, latt, predictedOfferRatio)
    result <- rbind(result, whiteSet)
  }
    
  if(asian){
    asianSet <- subData %>% 
      filter (ethnicity=="asian") %>% 
      select(dbn, longt, latt, predictedOfferRatio)
    result <- rbind(result, asianSet)
  }
    
  if(hispanic){
    hispanicSet <- subData %>% 
      filter (ethnicity=="hispanic") %>% 
      select(dbn, longt, latt, predictedOfferRatio)
    result <- rbind(result, hispanicSet)
  }

  return ( result )
}

