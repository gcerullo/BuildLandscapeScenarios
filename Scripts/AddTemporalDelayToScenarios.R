#GC 18/06/2024

#This script takes our scenarios and adds a temporal delay to the application of habitat transitions, 
# such that 1/30th of each transition happens per year 

library(tidyverse)
library(data.table)

#define params ####
scenario_folder <- "Outputs/ScenariosWithDelaysCSVS"
#read in inputs ####

#shows habitat by year for different transitions, without delays
hab_by_year <- read.csv("Inputs/HabByYears.csv", strip.white = TRUE) %>%  
  rename(true_year = year, 
         functionalhabAge = functional_habAge, 
         habitat = transition_habitat) %>% select(-X)

#shows scenarios without delays, as contructed in GenerateScenarios.R 
scenarios <- readRDS("Outputs/MasterAllScenarios.rds")

# ---------1. add time-delay to temporal information, so that we allow a 30 year harvest window  ------
#hab_by year currently assumes all harvesting starts in year 0. 
#what if delay harvests/first plantation plants? 

hab_by_year0 <- hab_by_year %>% cbind(harvest_delay = "delay 0")
#for a time window of 30 years apply harvesting annually
delay <- seq(1:29)

output_list <- list()


for (i in delay) {
  #make a datafrmae of 0s to add to beginning, to cause delay and leave habitat as original cover for the time of delay
  yearZ <- hab_by_year %>%
    filter(true_year == 0) %>%
    uncount(i) %>%
    group_by(original_habitat,habitat) %>%
    mutate(true_year = seq_along(true_year)-1 ) %>%
    ungroup() %>% 
    #give age of original habitat during harvest delay, except for primary and deforested
    mutate(functionalhabAge = case_when(
      functional_habitat != "primary" & functional_habitat != "deforested" ~ true_year,
      TRUE ~ functionalhabAge)) 
  
  #push true years by the length of the delay (e.g. add in 0s) and remove true year >60 
  delayed_df <-hab_by_year %>%   
    mutate(true_year = true_year + i ) %>% 
    filter(true_year <61)
  
  #combine then remove beyond 60th years 
  output <- yearZ %>%  rbind(delayed_df) %>% cbind(harvest_delay = paste("delay",i))
  
  output_list[[as.character(i)]] <- output
}


#make sure we have all the years with same amount of rows
x <-  rbindlist(output_list)
test <- x %>% group_by(true_year) %>% count()
plot(test) # ;looks good 

#this hab_by_year now includes the temporal dimension assuming different delays until first harvest
hab_by_year<- rbindlist(output_list) %>% rbind(hab_by_year0)

#adjust to make sure that if original habitat = transition habitat for scenario duration
#then functionalhabAge age doesn't reset after the delay
hab_by_year <- hab_by_year %>% mutate(functionalhabAge = case_when(
  original_habitat == habitat ~ true_year,
  TRUE ~ functionalhabAge))


#---------- ADD TEMPORAL INFORMATION TO SCENARIOS --------  ####

#nb: only original habitat -> transition_habitat is possible
scenarios[[12]] %>% select(scenarioName, original_habitat) %>% unique
scenarios[[10]] %>% select(scenarioName, original_habitat) %>% unique
scenarios[[11]] %>% select(scenarioName, original_habitat) %>% unique

add_temporal_fun <- function(x){
  x %>% left_join(hab_by_year, by = c("original_habitat" = "original_habitat", 
                                      "habitat" = "habitat"), relationship = "many-to-many") 
}

scenarios <- lapply(scenarios, add_temporal_fun)


#save outputs #####

##As RDS ####
#save all scenarios with time delays included as .rds file 
saveRDS(scenarios, "Outputs/MasterAllScenarios_withHarvestDelays.rds")

## As Csvs ####

# save all scenarios with time delays, where each scenario type is saved as its own csv
# We do this because in later post-processing, to increase memory allocation, we will process each scenario type  seperately 


# Assuming your list of tibbles is called `scenarios`
# Iterate over each tibble and save as CSV
walk(scenarios, function(tibble) {
  # Extract the scenario name
  scenario_name <- tibble$scenarioName[1]
  
  # Construct the file path
  file_path <- file.path(scenario_folder, paste0(scenario_name, ".csv"))
  
  # Save the tibble to CSV
  write_csv(tibble, file_path)
})

