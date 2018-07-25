library(dplyr)


nycSchool <- readRDS("data/school.rds")
colnames(nycSchool)


# Use 90% quantile as benchmark?
# elaGroupCutoff <-  quantile(nycSchool$ela.proficiency, na.rm=T, probs=c(0.90)) 
# mathGroupCutoff <- quantile(nycSchool$math.proficiency, na.rm=T, probs=c(0.90) )

# So far, I use the top school's information as the benchmark. But it can be changed later.
SucessfulOfferGroup <-  nycSchool %>% 
  mutate (meanOfferRate = mean(offerRate, na.rm = T)) %>% 
  filter (offerRate >= meanOfferRate) %>% 
  select(ela.proficiency, math.proficiency) 
elaGroupCutoff = colMeans(SucessfulOfferGroup)[1]
mathGroupCutoff = colMeans(SucessfulOfferGroup)[2]

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
  mutate(combinedOfferRate = ifelse(!is.na(offerRate), offerRate, predictedOfferRatio )) %>% 
  mutate(ela.math.group = case_when(
    ela.proficiency >  elaGroupCutoff & math.proficiency > mathGroupCutoff ~ "Both Good", 
    ela.proficiency >  elaGroupCutoff & math.proficiency <= mathGroupCutoff ~ "Need to improve Math", 
    ela.proficiency <= elaGroupCutoff & math.proficiency > mathGroupCutoff ~ "Need to improve ELA", 
    ela.proficiency <= elaGroupCutoff & math.proficiency <= mathGroupCutoff ~ "Both Bad", 
    TRUE ~ "NA"))




