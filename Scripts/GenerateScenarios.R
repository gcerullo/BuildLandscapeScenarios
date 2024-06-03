#03.06.24 - GC

#1. builds multicomp scenarios 
#2. Reads in multicomp scenarios - can start script here
#3. Reads in two-compartment scenarios
#4. combines multi-comp and two-comp in one master scenarios list  
#5. saves all scenarios for use in subsequent analyses

#RUN SCENARIOS; 
#this code will run the multi-comparment scenarios for my different starting landscape and rule combinations. Landscapes and different rules are explained in the 
#parametres script. The main function createScenarios() generates lots of multi-comp scenarios for different production target, starting landscapes and  and rules. 

#nb: code for implementing improved (IY) yield plantations is commented out but could be incorporated
#if we uncomment here, and ammend in ScenarioParemtres script 

#information on how custom functions operate can be found in the ScenarioFunctions scripts
rm(list = ls())
# library(tidyverse)
# library(dplyr)
# library(data.table)

# Load the script with parameters and custom functions
source("Scripts/LandscapeParametres.R")
source("Functions/ScenarioFunctions.R")

start.time <- Sys.time()
#=======================================================================
# 1. Build  multi-comparment scenario  ####
#=======================================================================
#EACH CODE BLOCK COMPRISES 1 STARTING LANDSCAPE AND 4 RULES - CURRENT/IMPROVED YIELDS AND DEFORESTATION/NO DEFORESTATION  
##NB: 100,000 iterations runs in 1.51hours

#RUN ONCE 

#strt_P 1000 blocks OG  ####
# production target to be met 
P <- downsizeProduction(strt_P)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- all_primary_CY_ND
ScenarioName <- paste("all_primary_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- all_primary_CY_D
ScenarioName <- paste("all_primary_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- all_primary_IY_ND
# ScenarioName <- paste("all_primary_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- all_primary_IY_D
# ScenarioName <- paste("all_primary_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)


#strt_1L 800 blocks 1L, 200 OG####
# production target to be met 
P <- downsizeProduction(strt_1L)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- mostly_1L_CY_ND
ScenarioName <- paste("mostly_1L_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- mostly_1L_CY_D
ScenarioName <- paste("mostly_1L_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- mostly_1L_IY_ND
# ScenarioName <- paste("mostly_1L_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- mostly_1L_IY_D
# ScenarioName <- paste("mostly_1L_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)



# production target to be met 
P <- downsizeProduction(strt_1L)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- mostly_1L_CY_ND
ScenarioName <- paste("mostly_1L_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- mostly_1L_CY_D
ScenarioName <- paste("mostly_1L_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- mostly_1L_IY_ND
# ScenarioName <- paste("mostly_1L_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- mostly_1L_IY_D
# ScenarioName <- paste("mostly_1L_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)

#strt_2L 800 blocks 2L, 200 OG ####
P <- downsizeProduction(strt_2L)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- mostly_2L_CY_ND
ScenarioName <- paste("mostly_2L_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- mostly_2L_CY_D
ScenarioName <- paste("mostly_2L_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- mostly_2L_IY_ND
# ScenarioName <- paste("mostly_2L_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- mostly_2L_IY_D
# ScenarioName <- paste("mostly_2L_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)

#strt_P_df 800 blocks OG, 200 DF####
P <- downsizeProduction(strt_P_df)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- primary_deforested_CY_ND
ScenarioName <- paste("primary_deforested_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- primary_deforested_CY_D
ScenarioName <- paste("primary_deforested_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- primary_deforested_IY_ND
# ScenarioName <- paste("primary_deforested_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- primary_deforested_IY_D
# ScenarioName <- paste("primary_deforested_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)

#strt_1L_df 600 blocks 1L, 200 DF, 200 OG####
P <- downsizeProduction(strt_1L_df)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- mostly_1L_deforested_CY_ND
ScenarioName <- paste("mostly_1L_deforested_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- mostly_1L_deforested_CY_D
ScenarioName <- paste("mostly_1L_deforested_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- mostly_1L_deforested_IY_ND
# ScenarioName <- paste("mostly_1L_deforested_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- mostly_1L_deforested_IY_D
# ScenarioName <- paste("mostly_1L_deforested_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)

#strt_2L_df 600 blocks 2L, 200DF, 200 OG #### 
P <- downsizeProduction(strt_2L_df)

# define starting landscape and rules (current yield(CY)/improved yield (IY) and deforestion (D)/no-deforestation (ND)) 
startLandscape_rules <- mostly_2L_deforested_CY_ND
ScenarioName <- paste("mostly_2L_deforested_CY_ND",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

startLandscape_rules <- mostly_2L_deforested_CY_D
ScenarioName <- paste("mostly_2L_deforested_CY_D",".csv", sep = "")
CreateScenarios(P,startLandscape_rules,ScenarioName)

# startLandscape_rules <- mostly_2L_deforested_IY_ND
# ScenarioName <- paste("mostly_2L_deforested_IY_ND",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)
# 
# startLandscape_rules <- mostly_2L_deforested_IY_D
# ScenarioName <- paste("mostly_2L_deforested_IY_D",".csv", sep = "")
# CreateScenarios(P,startLandscape_rules,ScenarioName)


end.time <- Sys.time()
time.taken <- round(end.time - start.time,2)
time.taken

#=================================================
#2 Read back in multicomp scenarios####
#=================================================
scenario_files<-list.files('Outputs/MidPointOutputs',
                           pattern = '*.csv',
                           full.names = TRUE)
scenarios <-lapply(scenario_files, read.csv)


#=================================================
#3. ADD IN TWO COMPARTMENT SCENARIOS ####
#=================================================
#two-comp scenarios 
twoComp <- readRDS("TwoCompartmentScenarios.rds") 

#=================================================
#4.Post-process and scenario combination (multi- and two-comp) ####
#=================================================

#define all starting landscapes: 
all_start_landscape <- {data.frame(
  scenarioStart = 
    c("all_primary", 
      "mostly_1L","mostly_1L",
      "mostly_2L","mostly_2L",
      "primary_deforested","primary_deforested",
      "mostly_1L_deforested","mostly_1L_deforested","mostly_1L_deforested",
      "mostly_2L_deforested", "mostly_2L_deforested", "mostly_2L_deforested"),
  
  habitat = 
    c("primary", 
      "primary", "once-logged", 
      "primary", "twice-logged",
      "primary", "deforested", 
      "primary", "once-logged", "deforested", 
      "primary", "twice-logged", "deforested"),
  
  num_parcels = 
    c(1000, 
      200, 800, 
      200, 800,
      800, 200, 
      200, 600, 200, 
      200, 600, 200)
)}



twoCompfun <- function(x){
  x <- x %>% rename(original_habitat = habitat, 
                    habitat = transition_harvest, 
                    hab_yield = parcel_yield_gained_10km2_60yrs) %>% 
    mutate(scenario_filt = 0) %>%  
    select(-scenarioStart)  
  
  #scenario correction; some scenarios have negative num of parcels - if this is the case, remove these parcels 
  
  x <- x %>%  # Group by scenarioIndex
    group_by(index) %>%
    # Filter out the groups where numParcels has a negative value
    filter(!any(grepl("^-", num_parcels))) %>%
    # Remove the grouping
    ungroup()
  
  #scenario correction 2; only keep scenarios that add up to 1000 parcels  
  
  x %>%  # Group by scenarioIndex
    group_by(index) %>%
    # Filter out the groups where numParcels has a negative value
    filter(sum(num_parcels) == 1000) %>%
    ungroup()
  
}

twoComp <- lapply(twoComp, twoCompfun)



#rename scenario to correct hab name 
rename_fun<- function(x){
  x %>%  rename(habitat = transition_harvest) %>% distinct()
}
scenarios <- lapply(scenarios, rename_fun)

#check names of two-compartment and multicompartment models are the same 
tc <- twoComp[[12]]
J <- scenarios[[12]]
names(tc)
names(J)

#join two-compartment snad multicompartment 
combine_scenarios <- function(l1,l2){
  rbind(l1,l2)
} 

scenarios <- Map(combine_scenarios, scenarios, twoComp)
J <- scenarios[[13]]


#add starting landscape for each scenario 
names_fun <- function(x){
  names<-  x %>% dplyr::select(scenarioName)
  
}
names <- lapply(scenarios,names_fun)
names <- rbindlist(names) %>% unique

#get a new column called starting landscape 
names <- names %>% mutate(scenarioStart = scenarioName) %>% 
  mutate(scenarioStart = str_remove(scenarioStart, "_IY_ND.csv")) %>%
  mutate(scenarioStart = str_remove(scenarioStart, "_CY_ND.csv")) %>%
  mutate(scenarioStart = str_remove(scenarioStart, "_IY_D.csv")) %>%
  mutate(scenarioStart = str_remove(scenarioStart, "_CY_D.csv")) %>% na.omit 

J <- scenarios[[12]]
J$scenarioName
names(J)

#join starting landscape to each scenario Name 
add_SL_name_fun <- function(x){
  x %>% mutate(scenarioName = as.character(scenarioName)) %>% 
    left_join(names, by = "scenarioName") 
}

scenarios <- lapply(scenarios, add_SL_name_fun)

J <- scenarios[[5]]

#finally scenario correction; make sure that there are not more than the amount of starting parcels in the landscape 
#for a given parcel (e.g. if there are 600 once-logged or orignal habitat, then there can't be 700 parcels converted from once-logged to twice-logged)
correct_fun <- function(x){
  all_start_landscape <- all_start_landscape %>% rename(total_hab_parcels_lim = num_parcels)
  x %>% group_by(index,production_target,original_habitat) %>% 
    mutate(total_hab_parcels = sum(num_parcels)) %>% 
    left_join(all_start_landscape, by = c("scenarioStart", "original_habitat" = "habitat")) %>%  
    #remove any scenario where the sum of the parcels of original habitat cover is > than actually available in the starting scenario 
    ungroup %>% group_by(index) %>%  
    filter(!any(total_hab_parcels > total_hab_parcels_lim)) %>%
    ungroup() %>%  
    select(-c(total_hab_parcels, total_hab_parcels_lim))
}
scenarios <- lapply(scenarios, correct_fun)

#correct hab_yield column, so that where habitat shows no transition, habitat_yield =0; 
#(this doesnt change the underlying structure of scenarios, which are meeting yield targets 
#correctly, but hab_yield during joins has been lost, so correcting this info)

correct_hab_yield_fun <- function(x){
  x %>%  mutate(hab_yield = ifelse(habitat == original_habitat, 0, hab_yield))
}

scenarios <- lapply(scenarios, correct_hab_yield_fun)

J <- scenarios[[12]]
#get parcel composition for each scenario 
scenario_composition <- rbindlist(scenarios)


#=======================================================================
#5. Save all scenarios for all subsequent analyses#### 
#=======================================================================
saveRDS(scenarios, "allScenariosStaggered.rds")
J <- scenarios[[12]]

#get parcel composition for each scenario 
scenario_composition <- rbindlist(scenarios)

# #read.scenarios back in #####
# 
# scenario_files<-list.files('ScenarioOutputs/iterations100000/Outputs/',
#                        pattern = '*.csv',
#                        full.names = TRUE)
# scenarios <-lapply(scenario_files, read.csv)
# 
# J <- scenarios[[12]]
# n <- J %>% group_by(production_target) %>%  slice_max(order_by = scenario_filt) %>% 
#   dplyr::select(production_target, scenario_filt) %>% unique()
# 
# #run checks summarising the number of scenarios created 
# scen_num <- function(x){
#  x %>%  group_by(production_target) %>%  slice_max(order_by = scenario_filt) %>% 
#     dplyr::select(production_target, scenario_filt,scenarioName) %>% unique()
# }
# num <- lapply(scenarios, scen_num)
# num <- rbindlist(num)
