library(dplyr)

nycSchool <- readRDS("data/school.rds")
colnames(nycSchool)
cleanTable <- nycSchool %>% 
  mutate(ethnicity.new = sub("^percent.(.*)$","\\1", ethnicity) ) %>% 
  select(
    dbn,
    name = school.name,
    district ,
    city,
    zip,
    latt = latitude,
    longt = longitude,
    income,
    ela.proficiency,
    math.proficiency,
    takeExam,
    offer,
    offerRate,
    predictedOfferRatio, 
    ethnicity = ethnicity.new,
    ethnicityRatio
  ) %>% 
  mutate(combinedOfferRate = ifelse(!is.na(offerRate), offerRate, predictedOfferRatio ))
