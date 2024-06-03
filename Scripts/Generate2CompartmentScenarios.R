#03/06/2024 - GC 

# BUILD TWO-COMPARTMENT SCENARIOS

# this generates two compartment scenarios for meeting production targets from different starting landscape 

#nb: code for implementing improved (IY) yield plantations is commented out but could be incorporated
#if we uncomment here, and ammend in ScenarioParemtres script 

#rm(list = ls())
# library(tidyverse)
# library(dplyr)
# library(data.table)


# Load the script with parameters and custom functions
source("Scripts/LandscapeParametres.R")
source("Functions/ScenarioFunctions.R")

start.time <- Sys.time()

# Build TWO-COMPARTMENT scenarios ####

#get all starting landscapes into one dataframe 
#1. Scenarios with no deforested land at beginning 
strt_P <- data.frame(hab_code = rep(0, 1000)) %>% CalculateProdTarget() %>% cbind(scenarioStart = "all_primary")
strt_1L <- data.frame(hab_code = c(rep(1, 800), rep(0, 200))) %>%  CalculateProdTarget() %>% cbind(scenarioStart = "mostly_1L")
strt_2L <- data.frame(hab_code = c(rep(2, 800), rep(0, 200))) %>%  CalculateProdTarget() %>% cbind(scenarioStart = "mostly_2L")                 

#2. Scenarios with  deforested land at beginning 
strt_P_df <- data.frame(hab_code = c(rep(0, 800), rep(8, 200))) %>%    CalculateProdTarget() %>% cbind(scenarioStart = "primary_deforested")
strt_1L_df <- data.frame(hab_code = c(rep(1, 600), rep(0, 200),rep(8, 200))) %>%    CalculateProdTarget() %>% cbind(scenarioStart = "mostly_1L_deforested")
strt_2L_df <- data.frame(hab_code = c(rep(2, 600), rep(0, 200),rep(8, 200)))  %>%  CalculateProdTarget() %>%cbind(scenarioStart = "mostly_2L_deforested")  

# all two-compartment scenario production targets 
all_twoComp_P <- rbind(strt_P,strt_1L,strt_2L, strt_P_df,strt_1L_df,strt_2L_df)


# for all availble transitions get all possible two-compartment scenarios

comp2 <- crossing(all_twoComp_P,yield_matrix) %>% 
  mutate(harvested_parcel_num = production_yield/parcel_yield_gained_10km2_60yrs, 
         unharvested_parcel_num = 1000 - harvested_parcel_num) %>% 
  dplyr::select(production_target, production_yield, scenarioStart, habitat, transition_harvest, harvested_parcel_num, unharvested_parcel_num,
                parcel_yield_gained_10km2_60yrs,
                current_yields, improved_yields, no_deforestation, deforestation)

#=======================================================================
#get two compartment scenario for each starting landsscape and rule set ####
#=======================================================================
#function for giving a unique index to each scenario 
add_unique_index_fun <- function(x){
  x %>%  filter(harvested_parcel_num <1000) %>% 
    arrange(production_target) %>% mutate(index = paste(scenarioName,row_number())) %>% na.omit()
}


#........................
#PRIMARY SCENARIOS 
#........................

x <- all_start_landscape %>% filter(scenarioStart == "primary")  

#add extra rule filter; not allowed >200 OG conversion or >800 1L converted
extra_rule_fun <- function(x){
  x %>% filter(scenarioStart == "all_primary") %>%  
    filter(!(habitat == "primary"& harvested_parcel_num >1000))   # cannot have > 1000 primary forest parcels 
  
}

#remaining hab - this function determines how much of the remaining landscape exists 
remaining_landscape_fun <- function(x){
  x %>% mutate(remaining_P = 1000) %>%     #define starting landscape parcel amounts 
    
    #define how much remaining primary there is
    mutate(remaining_P = case_when(habitat == "primary" ~ remaining_P - harvested_parcel_num, TRUE ~ remaining_P))   
  
}

#pivot fun that remolds df so that it's ready for biodiversity assessment 
pivot_fun <- function(x){
  harvested <- x %>% select(production_target, production_yield, scenarioStart,
                            habitat, transition_harvest, harvested_parcel_num,parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    rename(num_parcels = harvested_parcel_num)
  
  stays_primary <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_P,habitat,transition_harvest,
           parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    mutate(habitat = "primary", 
           transition_harvest = "primary",
           parcel_yield_gained_10km2_60yrs = 0) %>% 
    rename(num_parcels = remaining_P)
  
  
  
  df <- rbind(harvested,stays_primary)
  df
}




#all_primary_CY_ND_2comp


scenarioName <- paste("all_primary_CY_ND",".csv", sep = "")
allowable_harvests <- all_primary_CY_ND$transition_harvest
starting_landscape<- x$habitat
all_primary_CY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                              transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>% 
  pivot_fun()




#all_primary_CY_D_2comp
scenarioName <- paste("all_primary_CY_D",".csv", sep = "")
allowable_harvests <- all_primary_CY_D$transition_harvest
starting_landscape<- x$habitat
all_primary_CY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                             transition_harvest %in% allowable_harvests )  %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>% 
  pivot_fun()
# 
# #all_primary_IY_ND_2comp
# scenarioName <- paste("all_primary_IY_ND",".csv", sep = "")
# allowable_harvests <- all_primary_IY_ND$transition_harvest
# starting_landscape<- x$habitat
# all_primary_IY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                               transition_harvest %in% allowable_harvests )  %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 
# 
# 
# #all_primary_IY_D_2comp
# scenarioName <- paste("all_primary_IY_D",".csv", sep = "")
# allowable_harvests <- all_primary_IY_D$transition_harvest
# starting_landscape<- x$habitat
# all_primary_IY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                              transition_harvest %in% allowable_harvests )  %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 

#........................
#MOSTLY 1L SCENARIOS 
#.........................
x2 <- all_start_landscape %>% filter(scenarioStart == "mostly_1L")  

#add extra rule filter; not allowed >200 OG conversion or >800 1L converted
extra_rule_fun <- function(x){
  x %>% filter(scenarioStart == "mostly_1L") %>%  
    filter(!(habitat == "primary"& harvested_parcel_num >200)) %>%  # cannot have > 200 primary forest parcels 
    filter(!(habitat == "once-logged"& harvested_parcel_num >800))
}

#remaining hab - this function determines how much of the remaining landscape exists 
remaining_landscape_fun <- function(x){
  x %>% mutate(remaining_P = 200,    #define starting landscape parcel amounts 
               remaining_1L = 800) %>%  
    #define how much remaining primary there is
    mutate(remaining_P = case_when(habitat == "primary" ~ remaining_P - harvested_parcel_num, TRUE ~ remaining_P)) %>%  
    #define how much remaining once-logged there is 
    mutate(remaining_1L = case_when(habitat == "once-logged" ~ remaining_1L - harvested_parcel_num, TRUE ~ remaining_1L))  
}

#pivot fun that remolds df so that it's ready for biodiversity assessment 
pivot_fun <- function(x){
  harvested <- x %>% select(production_target, production_yield, scenarioStart,
                            habitat, transition_harvest, harvested_parcel_num,parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    rename(num_parcels = harvested_parcel_num)
  
  stays_primary <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_P,habitat,transition_harvest,
           parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    mutate(habitat = "primary", 
           transition_harvest = "primary",
           parcel_yield_gained_10km2_60yrs = 0) %>% 
    rename(num_parcels = remaining_P)
  
  
  stays_onceL <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_1L,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    #if habitat is primary, parcel_yield_gained = 0, if not keep as is
    
    mutate(habitat = "once-logged", 
           transition_harvest = "once-logged") %>% 
    rename(num_parcels = remaining_1L) 
  df <- rbind(harvested,stays_primary,stays_onceL)
  df
}


#mostly_1L_CY_ND_2comp
scenarioName <- paste("mostly_1L_CY_ND",".csv", sep = "")
allowable_harvests <- mostly_1L_CY_ND$transition_harvest
starting_landscape<- x2$habitat
mostly_1L_CY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                            transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


#mostly_1L_CY_D_2comp
scenarioName <- paste("mostly_1L_CY_D",".csv", sep = "")

allowable_harvests <- mostly_1L_CY_D$transition_harvest
starting_landscape<- x2$habitat
mostly_1L_CY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                           transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>% 
  pivot_fun()
# 
# 
# #mostly_1L_IY_ND_2comp
# scenarioName <- paste("mostly_1L_IY_ND",".csv", sep = "")
# allowable_harvests <- mostly_1L_IY_ND$transition_harvest %>% unique
# starting_landscape<- x2$habitat 
# mostly_1L_IY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                             transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 
# 
# 
# #mostly_1L_IY_D_2comp
# scenarioName <- paste("mostly_1L_IY_D",".csv", sep = "")
# allowable_harvests <- mostly_1L_IY_D$transition_harvest %>% unique
# starting_landscape<- x2$habitat
# mostly_1L_IY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                            transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 

#=============================
#MOSTLY_TWICE_LOGGED
#=============================
x3 <- all_start_landscape %>% filter(scenarioStart == "mostly_2L")  

#add extra rule filter; not allowed >200 OG conversion or >800 1L converted
extra_rule_fun <- function(x){
  x %>% filter(scenarioStart == "mostly_2L") %>%  
    filter(!(habitat == "primary"& harvested_parcel_num >200)) %>%  # cannot have > 200 primary forest parcels 
    filter(!(habitat == "twice-logged"& harvested_parcel_num >800))
}

#remaining hab - this function determines how much of the remaining landscape exists 
remaining_landscape_fun <- function(x){
  x %>% mutate(remaining_P = 200,    #define starting landscape parcel amounts 
               remaining_2L = 800) %>%  
    #define how much remaining primary there is
    mutate(remaining_P = case_when(habitat == "primary" ~ remaining_P - harvested_parcel_num, TRUE ~ remaining_P)) %>%  
    #define how much remaining twice-logged there is 
    mutate(remaining_2L = case_when(habitat == "twice-logged" ~ remaining_2L - harvested_parcel_num, TRUE ~ remaining_2L))  
}

#pivot fun that remolds df so that it's ready for biodiversity assessment 
pivot_fun <- function(x){
  harvested <- x %>% select(production_target, production_yield, scenarioStart,
                            habitat, transition_harvest, harvested_parcel_num,parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    rename(num_parcels = harvested_parcel_num)
  
  stays_primary <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_P,habitat,transition_harvest,
           parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    mutate(habitat = "primary", 
           transition_harvest = "primary",
           parcel_yield_gained_10km2_60yrs = 0) %>% 
    rename(num_parcels = remaining_P)
  
  
  stays_twiceL <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_2L,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    #if habitat is primary, parcel_yield_gained = 0, if not keep as is
    
    mutate(habitat = "twice-logged", 
           transition_harvest = "twice-logged") %>% 
    rename(num_parcels = remaining_2L) 
  df <- rbind(harvested,stays_primary,stays_twiceL)
  df
}



#mostly_2L_CY_ND_2comp
scenarioName <- paste("mostly_2L_CY_ND",".csv", sep = "")
allowable_harvests <- mostly_2L_CY_ND$transition_harvest
starting_landscape<- x3$habitat
mostly_2L_CY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                            transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


#mostly_2L_CY_D_2comp
scenarioName <- paste("mostly_2L_CY_D",".csv", sep = "")

allowable_harvests <- mostly_2L_CY_D$transition_harvest
starting_landscape<- x3$habitat
mostly_2L_CY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                           transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>% 
  pivot_fun()

# 
# #mostly_2L_IY_ND_2comp
# scenarioName <- paste("mostly_2L_IY_ND",".csv", sep = "")
# allowable_harvests <- mostly_2L_IY_ND$transition_harvest %>% unique
# starting_landscape<- x3$habitat 
# mostly_2L_IY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                             transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 
# 
# #mostly_2L_IY_D_2comp
# scenarioName <- paste("mostly_2L_IY_D",".csv", sep = "")
# allowable_harvests <- mostly_2L_IY_D$transition_harvest %>% unique
# starting_landscape<- x3$habitat
# mostly_2L_IY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                            transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()

#========================================
###DEFORESTED 
#========================================

comp2 %>%  select(scenarioStart) %>% unique


#..........................
#Primary_deforested
#..........................
x4 <- all_start_landscape %>% filter(scenarioStart == "primary_deforested")  

#add extra rule filter; not allowed >200 OG conversion or >800 1L converted
extra_rule_fun <- function(x){
  x %>% filter(scenarioStart == "primary_deforested") %>%  
    filter(!(habitat == "primary"& harvested_parcel_num >800)) %>%  # cannot have > 200 primary forest parcels 
    filter(!(habitat == "deforested"& harvested_parcel_num >200))
}

#remaining hab - this function determines how much of the remaining landscape exists 
remaining_landscape_fun <- function(x){
  x %>% mutate(remaining_P = 800,    #define starting landscape parcel amounts 
               remaining_D = 200) %>%  
    #define how much remaining primary there is
    mutate(remaining_P = case_when(habitat == "primary" ~ remaining_P - harvested_parcel_num, TRUE ~ remaining_P)) %>%  
    #define how much remaining twice-logged there is 
    mutate(remaining_D = case_when(habitat == "deforested" ~ remaining_D - harvested_parcel_num, TRUE ~ remaining_D))  
}

#pivot fun that remolds df so that it's ready for biodiversity assessment 
pivot_fun <- function(x){
  harvested <- x %>% select(production_target, production_yield, scenarioStart,
                            habitat, transition_harvest, harvested_parcel_num,parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    rename(num_parcels = harvested_parcel_num)
  
  stays_primary <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_P,habitat,transition_harvest,
           parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    mutate(habitat = "primary", 
           transition_harvest = "primary",
           parcel_yield_gained_10km2_60yrs = 0) %>% 
    rename(num_parcels = remaining_P)
  
  
  stays_D <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_D,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    #if habitat is primary, parcel_yield_gained = 0, if not keep as is
    
    mutate(habitat = "deforested", 
           transition_harvest = "deforested") %>% 
    rename(num_parcels = remaining_D) 
  df <- rbind(harvested,stays_primary,stays_D)
  df
}



#primary_deforested_CY_ND_2comp
scenarioName <- paste("primary_deforested_CY_ND",".csv", sep = "")
allowable_harvests <- primary_deforested_CY_ND$transition_harvest
starting_landscape<- x4$habitat
primary_deforested_CY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                                     transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


#primary_deforested_CY_D_2comp
scenarioName <- paste("primary_deforested_CY_D",".csv", sep = "")
allowable_harvests <- primary_deforested_CY_D$transition_harvest
starting_landscape<- x4$habitat
primary_deforested_CY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                                    transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


# 
# #primary_deforested_IY_ND_2comp
# scenarioName <- paste("primary_deforested_IY_ND",".csv", sep = "")
# allowable_harvests <- primary_deforested_IY_ND$transition_harvest %>% unique
# starting_landscape<- x4$habitat 
# primary_deforested_IY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                                      transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 
# #primary_deforested_IY_D_2comp
# scenarioName <- paste("primary_deforested_IY_D",".csv", sep = "")
# allowable_harvests <- primary_deforested_IY_D$transition_harvest %>% unique
# starting_landscape<- x4$habitat
# primary_deforested_IY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                                     transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()


#..........................
#mostly1L_deforested
#..........................

x5 <- all_start_landscape %>% filter(scenarioStart == "mostly_1L_deforested")  

#add extra rule filter; not allowed >200 OG conversion, >200 deforested converted, or >600 1L converted
extra_rule_fun <- function(x){
  x %>% filter(scenarioStart == "mostly_1L_deforested") %>%  
    filter(!(habitat == "primary"& harvested_parcel_num >200)) %>%  # cannot have > 200 primary forest parcels 
    filter(!(habitat == "deforested"& harvested_parcel_num >200)) %>% 
    filter(!(habitat == "mostly_1L"& harvested_parcel_num > 600))
}

#remaining hab - this function determines how much of the remaining landscape exists 
remaining_landscape_fun <- function(x){
  x %>% mutate(remaining_P = 200,    #define starting landscape parcel amounts 
               remaining_D = 200, 
               remaining_1L = 600) %>%  
    #define how much remaining primary there is
    mutate(remaining_P = case_when(habitat == "primary" ~ remaining_P - harvested_parcel_num, TRUE ~ remaining_P)) %>%  
    #define how much remaining deforested there is 
    mutate(remaining_D = case_when(habitat == "deforested" ~ remaining_D - harvested_parcel_num, TRUE ~ remaining_D)) %>% 
    #define how much once logged there is 
    mutate(remaining_1L = case_when(habitat == "once-logged" ~ remaining_1L - harvested_parcel_num, TRUE ~ remaining_1L)) 
}

#pivot fun that remolds df so that it's ready for biodiversity assessment 
pivot_fun <- function(x){
  harvested <- x %>% select(production_target, production_yield, scenarioStart,
                            habitat, transition_harvest, harvested_parcel_num,parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    rename(num_parcels = harvested_parcel_num)
  
  stays_primary <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_P,habitat,transition_harvest,
           parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    mutate(habitat = "primary", 
           transition_harvest = "primary",
           parcel_yield_gained_10km2_60yrs = 0) %>% 
    rename(num_parcels = remaining_P)
  
  
  stays_D <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_D,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    #if habitat is primary, parcel_yield_gained = 0, if not keep as is
    
    mutate(habitat = "deforested", 
           transition_harvest = "deforested") %>% 
    rename(num_parcels = remaining_D) 
  
  stays_onceL <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_1L,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    #if habitat is primary, parcel_yield_gained = 0, if not keep as is
    
    mutate(habitat = "once-logged", 
           transition_harvest = "once-logged") %>% 
    rename(num_parcels = remaining_1L) 
  
  
  df <- rbind(harvested,stays_primary,stays_D, stays_onceL)
  df
}




#mostly1L_deforested_CY_ND_2comp
scenarioName <- paste("mostly_1L_deforested_CY_ND",".csv", sep = "")
allowable_harvests <- mostly_1L_deforested_CY_ND$transition_harvest
starting_landscape<- x5$habitat
mostly_1L_deforested_CY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                                       transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


#mostly_1L_deforested_CY_D_2comp
scenarioName <- paste("mostly_1L_deforested_CY_D",".csv", sep = "")
allowable_harvests <- mostly_1L_deforested_CY_D$transition_harvest
starting_landscape<- x5$habitat
mostly_1L_deforested_CY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                                      transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()

# 
# #mostly_1L_deforested_IY_ND_2comp
# scenarioName <- paste("mostly_1L_deforested_IY_ND",".csv", sep = "")
# allowable_harvests <- mostly_1L_deforested_IY_ND$transition_harvest %>% unique
# starting_landscape<- x5$habitat 
# mostly_1L_deforested_IY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                                        transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 
# #mostly_1L_IY_D_2comp
# scenarioName <- paste("mostly_1L_deforested_IY_D",".csv", sep = "")
# allowable_harvests <- mostly_1L_deforested_IY_D$transition_harvest %>% unique
# starting_landscape<- x5$habitat
# mostly_1L_deforested_IY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                                       transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 


#..........................
#mostly2L_deforested
#..........................

x6 <- all_start_landscape %>% filter(scenarioStart == "mostly_2L_deforested")  

#add extra rule filter; not allowed >200 OG conversion, >200 deforested converted, or >600 1L converted
extra_rule_fun <- function(x){
  x %>% filter(scenarioStart == "mostly_2L_deforested") %>%  
    filter(!(habitat == "primary"& harvested_parcel_num >200)) %>%  # cannot have > 200 primary forest parcels 
    filter(!(habitat == "deforested"& harvested_parcel_num >200)) %>% 
    filter(!(habitat == "mostly_2L"& harvested_parcel_num > 600))
}

#remaining hab - this function determines how much of the remaining landscape exists 
remaining_landscape_fun <- function(x){
  x %>% mutate(remaining_P = 200,    #define starting landscape parcel amounts 
               remaining_D = 200, 
               remaining_2L = 600) %>%  
    #define how much remaining primary there is
    mutate(remaining_P = case_when(habitat == "primary" ~ remaining_P - harvested_parcel_num, TRUE ~ remaining_P)) %>%  
    #define how much remaining deforested there is 
    mutate(remaining_D = case_when(habitat == "deforested" ~ remaining_D - harvested_parcel_num, TRUE ~ remaining_D)) %>% 
    #define how much once logged there is 
    mutate(remaining_2L = case_when(habitat == "twice-logged" ~ remaining_2L - harvested_parcel_num, TRUE ~ remaining_2L)) 
}

#pivot fun that remolds df so that it's ready for biodiversity assessment 
pivot_fun <- function(x){
  harvested <- x %>% select(production_target, production_yield, scenarioStart,
                            habitat, transition_harvest, harvested_parcel_num,parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    rename(num_parcels = harvested_parcel_num)
  
  stays_primary <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_P,habitat,transition_harvest,
           parcel_yield_gained_10km2_60yrs,index) %>% 
    mutate(scenarioName = paste(scenarioName)) %>% 
    mutate(habitat = "primary", 
           transition_harvest = "primary",
           parcel_yield_gained_10km2_60yrs = 0) %>% 
    rename(num_parcels = remaining_P)
  
  
  stays_D <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_D,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    
    mutate(habitat = "deforested", 
           transition_harvest = "deforested") %>% 
    rename(num_parcels = remaining_D) 
  
  stays_twiceL <- x %>% 
    select(production_target, production_yield, scenarioStart, remaining_2L,habitat,
           parcel_yield_gained_10km2_60yrs,index) %>%
    mutate(scenarioName = paste(scenarioName)) %>% 
    #if habitat is primary, parcel_yield_gained = 0, if not keep as is
    
    mutate(habitat = "twice-logged", 
           transition_harvest = "twice-logged") %>% 
    rename(num_parcels = remaining_2L) 
  
  
  df <- rbind(harvested,stays_primary,stays_D, stays_twiceL)
  df
}


#mostly2L_deforested_CY_ND_2comp
scenarioName <- paste("mostly_2L_deforested_CY_ND",".csv", sep = "")
allowable_harvests <- mostly_2L_deforested_CY_ND$transition_harvest
starting_landscape<- x6$habitat
mostly_2L_deforested_CY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                                       transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


#mostly_2L_deforested_CY_D_2comp
scenarioName <- paste("mostly_2L_deforested_CY_D",".csv", sep = "")
allowable_harvests <- mostly_2L_deforested_CY_D$transition_harvest
starting_landscape<- x6$habitat
mostly_2L_deforested_CY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
                                                      transition_harvest %in% allowable_harvests ) %>% 
  extra_rule_fun() %>%
  remaining_landscape_fun() %>% 
  add_unique_index_fun() %>%  
  pivot_fun()


# #mostly_2L_deforested_IY_ND_2comp
# scenarioName <- paste("mostly_2L_deforested_IY_ND",".csv", sep = "")
# allowable_harvests <- mostly_2L_deforested_IY_ND$transition_harvest %>% unique
# starting_landscape<- x6$habitat 
# mostly_2L_deforested_IY_ND_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                                        transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 
# #mostly_2L_IY_D_2comp
# scenarioName <- paste("mostly_2L_deforested_IY_D",".csv", sep = "")
# allowable_harvests <- mostly_2L_deforested_IY_D$transition_harvest %>% unique
# starting_landscape<- x6$habitat
# mostly_2L_deforested_IY_D_2comp <- comp2 %>% filter(habitat %in% starting_landscape &
#                                                       transition_harvest %in% allowable_harvests ) %>% 
#   extra_rule_fun() %>%
#   remaining_landscape_fun() %>% 
#   add_unique_index_fun() %>% 
#   pivot_fun()
# 

#==================================================================================
#MAKE A LIST HOLDING ALL 2 COMP SCENARIOS
#================================================================================

two_compScenarios <- list(
  
  all_primary_CY_D_2comp,        
  all_primary_CY_ND_2comp,         
  #all_primary_IY_D_2comp,          
  #all_primary_IY_ND_2comp,
  
  mostly_1L_CY_D_2comp,           
  mostly_1L_CY_ND_2comp,          
  mostly_1L_deforested_CY_D_2comp, 
  mostly_1L_deforested_CY_ND_2comp,
  
  #mostly_1L_deforested_IY_D_2comp,
  #mostly_1L_deforested_IY_ND_2comp, 
  #mostly_1L_IY_D_2comp,    
  #mostly_1L_IY_ND_2comp,  
  
  mostly_2L_CY_D_2comp,        
  mostly_2L_CY_ND_2comp,           
  mostly_2L_deforested_CY_D_2comp,
  mostly_2L_deforested_CY_ND_2comp,
  
  #mostly_2L_deforested_IY_D_2comp, 
  #mostly_2L_deforested_IY_ND_2comp,
  #mostly_2L_IY_D_2comp,        
  #mostly_2L_IY_ND_2comp, 
  
  primary_deforested_CY_D_2comp,    
  primary_deforested_CY_ND_2comp  
  #primary_deforested_IY_D_2comp,    
  #primary_deforested_IY_ND_2comp
)
#ouput and save

getwd()
saveRDS(two_compScenarios, "Outputs/TwoCompartmentScenarios.rds")
