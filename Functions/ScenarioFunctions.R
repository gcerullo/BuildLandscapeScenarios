#24.05.2023
#this code inludes functions for the creation of many different landscape-level timber production scenarios (Cerullo et al 2023.)

rm(list = ls())
library(tidyverse)
library(dplyr)
library(data.table)




#setwd 
#set the path where scenario outputs will be stored
folder <- "Outputs"

#TO RUN ON HPC 
#setwd('/home/grc38/scenarioC')
#folder <- "/home/grc38/scenarioC/Outputs"

# Load the script with parameters
source("Scripts/LandscapeParametres.R")


#=================================================================================================================================
#FUNCTION DESCRIPTIONS 
#.................................................................................................................................
#NB: 100,000 iterations runs in 39 mins

#........................
#CalculateProdTarget()
#........................
# # DESCRIPTION: calculates the production target of between 0.1 and 1, by 0.1 incremenens for a given starting lanscape 

#I define P = 1 as the yield if all natural forest in the landscape is logged at maximum intensity without allowing deforestation or post-logging silvicultre.

# INPUTS: 
#requires a starting landscape, as defined in the Parameters script. 


#........................
#downsizeProduction()
#........................
# Downsizes production values so that we can use our approach in the createScenarios function, which imagines we have 10 lanscape parcels, that we subsequently multiply
#up to give 1000 parcels 

# INPUTS: 
#requires a starting landscape, as defined in the Parameters script. 


#........................
#CreateScenarios()
#........................
# DESCRIPTION: 

#The master CreateScenarios() function builds scenarios based on pulling 10 plausible harvest intensities given a starting landscape and rules. 
# These intensities are pulled based on two probabilities: a uniform probability, that randomly selects with replacement a harvest intensity from those available
# and an unequal probability draw, that gives a higher number of scenarios containing old-growth parcels.
# From the ten parcel harvests drawn, we keep those that meet a production target.We then convert to a 1000 parcel landscape by multiplying each parcel by 100. 

# INPUTS:
#1. P - the range of production targets for a given starting landscape and set of rules. 

#I define P = 1 as the yield if all natural forest in the landscape is logged at maximum intensity without allowing deforestation or post-logging silvicultre.
#NB; P must be passed thru the downsizeProduction() function. 

#2. startLandscape_rules 

#This defines the starting landscape and thus the range of harvest intensities available under a given scenarios. 
#It also defines whether current or future plantation yields are used, and whether or not  deforestation is allowed. 

#3. scenarioName - the name of the file the will store the scenarios as a csv.

#NB can change num_replications to a large number to build more scenarios. 
#=================================================================================================================================

#Make key parametre decisions #####
#define number of unique intensities to draw  
num_draws <- 10
#define number of iterations (more iterations = more combinatiions per production target)
num_replications <- 1000



CalculateProdTarget <-function(x){
  production_target <- data.frame(production_target = seq(0,1, by = 0.01)) 
  production_yield  <- x %>% left_join(max_natural, by = "hab_code") %>% na.omit() %>%  
    summarise(yield = sum(parcel_yield_gained_10km2_60yrs)) %>% as.numeric
  production_target <- production_target %>% mutate(production_yield = production_target*production_yield) 
  allowableRange <-  error # set allowable error about P
  
  #also add a 2% error around the production target
  production_target_min <- production_target %>% 
    mutate(minYield = production_yield - (production_yield*allowableRange)) %>% 
    dplyr::select(production_target, minYield)
  
  production_target_max <- production_target %>% 
    mutate(maxYield = production_yield + (production_yield*allowableRange)) %>% 
    dplyr::select(production_target, maxYield)
  
  #combine 
  production_target <- production_target %>% left_join(production_target_max, by = "production_target") %>% left_join(production_target_min, by = "production_target")
  #return production targets, plus errors 
  production_target
}



downsizeProduction <- function(x) {
  CalculateProdTarget(x) %>% 
    mutate(production_yield = production_yield/100,      # convert yield from 10,000km2 (1000 parcels of 10km2) to 100km2 (10 parcels of 10km2) 
           maxYield = maxYield/100, 
           minYield = minYield/100) 
}





#-----------------------------------------------------------------------------------------------
# #FOR REPLICABILITY: here is an example of the parametres that must be provided to the CreateScenarios() function 
# [MAKE SURE THIS IS COMMENTED OUT WHEN YOU RUN THE CREATE_SCENARIOS SCRIPT]

# #1. set the specific  parametres' and rules for a landscape and divide area so that we are working over 10 unique parcels (we multiply this back up later)####
# 
# #starting landscape and rules are set out in the parametres script.mostly_1L_CY_D
# 
# #DEFINE INPUTS
#production target to be met
#P <- downsizeProduction(strt_1L_df)
#starting landscape and rules (current/improved and deforestion/no-deforestation)
#startLandscape_rules <- mostly_1L_CY_D
#set the names of scenario
#scenarioName <- "mostly_1L_CY_D"
#------------------------------------------------------------------------------------------------


#===============================================================================================
#scenario-building method tracks that used in Biological Conservation paper Cerullo et al. 2023,
CreateScenarios <- function(P, startLandscape_rules, scenarioName){
  
  
  #which yield values are available in the specific scenario?
  #order this smallest to largest (so primary always comes first)
  values <- sort(startLandscape_rules$parcel_yield_gained_10km2_60yrs) # intensities available,always ordered smallest to largest 
  
 
  # Create a list to store the scenarios for each replication
  equal_prob_draws <- list(length = num_replications) # store combinations where intensities are selected with replacement with equal probability
  unequal_prob_draws <- list(length = num_replications) #store combinations where old-growth parcels are selected more often to ensure large number of zero-yield parcels in scenarios 
  unequal_prob_draws_random <- list(length = num_replications) #store combinations where a random parcel is selected more often (0.5 prob) to expand scenario space explored more efficiently 
  unequal_prob_draws_random2 <- list(length = num_replications) #store combinations where a 2 random parcels are selected more often (0.25, 0.25) to expand scenario space explored more efficiently
  #define the probability of drawing a given harvest intensity for unequal draws that disporoprtionately leave OG unlogged
  unique_intensities <- length(values)
  #OG is selected with a prob of .5, other intensities are selected with equal remaining prob
  probabilities <- c((unique_intensities/2)/unique_intensities, rep(0.5/(unique_intensities-1), unique_intensities-1)) #scenario that increases likelihood of zeros (or of 1 parcel value being selected)
  sum(probabilities) #should always be 1 
  #give two random parcels a 0.25 chance of being selected, with the rest having equal remaining prob 
  probabilities2 <- c(
    rep((unique_intensities/4)/unique_intensities,2)   #2lots of 0.25
    ,
    rep(0.5/(unique_intensities-2),unique_intensities-2) #the remainder
  ) 
  
  #.......................................................................................
  
  #EQUAL PROB DRAWS 
  
  # build scenarios by randomly pulling one of the yield values available for the scenario
  # this version draws each value with equal chance, leading to not many mostly OG scenarios being drawn 
  for (i in 1:num_replications) {
    draw_combinations <- replicate(num_draws, 
                                   sample(values, 1,
                                          replace = TRUE))
    equal_prob_draws[[i]] <- draw_combinations
    
    # Assign an index to the iteratiion
    equal_prob_draws[[i]]$index <- i
    
    # Display the iteration number
    print(paste("IterationEQ:", i))
    
  }
  
  #UNEQUAL PROB DRAWS (priority to primary forest )
  
  for (i in 1:num_replications) {
    draw_combinations <- replicate(num_draws, 
                                   sample(values, 1, 
                                          prob = probabilities, # <- this part has to add up to one [as is a probability]
                                          replace = TRUE))
    unequal_prob_draws[[i]] <- draw_combinations
    
    # Assign an index to the iteratiion
    unequal_prob_draws[[i]]$index <- paste("unq",i, sep = "_")
    
    # Display the iteration number
    print(paste("IterationUNQ:", i))
    
  }
  
  
  
  # RANDOM PROB DRAW (priority to a random habitat)
  #for each draw a random parcel is given a 0.5 chance of being pulled and the rest are pulled equally  
  
  for (i in 1:num_replications) {
    shuffled_probabilities <- sample(probabilities) # randomly give one parcel value a 0.5 chance of being selected 
    
    draw_combinations <- replicate(num_draws, 
                                   sample(values, 1, 
                                          prob = shuffled_probabilities, # <- this part has to add up to one [as is a probability]
                                          replace = TRUE))
    unequal_prob_draws_random[[i]] <- draw_combinations
    
    # Assign an index to the iteratiion
    unequal_prob_draws_random[[i]]$index <- paste("unq2",i, sep = "_")
    
    # Display the iteration number
    print(paste("IterationUNQ2:", i))
    
  }
  
  # RANDOM PROB DRAW 2  (priority to 2 random habitats)
  
  for (i in 1:num_replications) {
    shuffled_probabilities <- sample(probabilities2) # randomly give two parcels  0.25 chance of being selected 
    draw_combinations <- replicate(num_draws, 
                                   sample(values, 1, 
                                          prob = shuffled_probabilities, # <- this part has to add up to one [as is a probability]
                                          replace = TRUE))
    unequal_prob_draws_random2[[i]] <- draw_combinations
    
    # Assign an index to the iteratiion
    unequal_prob_draws_random2[[i]]$index <- paste("unq3",i, sep = "_")
    
    # Display the iteration number
    print(paste("IterationUNQ3:", i))
    
  }
  
  #bind all equal prob scenarios into df
  eq_df  <-rbindlist(equal_prob_draws)
  #bind all UNEQUAL OG-favouring prob scenarios into a df 
  uneq_df  <-rbindlist(unequal_prob_draws)
  #bind all UNEQUAL random-favouringprob scenarios into a df 
  uneq_df2 <- rbindlist(unequal_prob_draws_random)
  #bind all UNEQUAL random-favouringprob scenarios into a df 
  uneq_df3 <- rbindlist(unequal_prob_draws_random2)
  #bring  probability draws together
  all_comb <-rbind(eq_df,uneq_df,uneq_df2,uneq_df3)
  
  #remove uneeded files from environment 
  rm(eq_df)
  rm(uneq_df)
  rm(uneq_df2)
  rm(uneq_df3)
  
  
  #calculate total yield of each scenario 
  all_comb_totalYield <- all_comb %>%  pivot_longer(!index, names_to = "v", values_to = "value") %>% dplyr::select(-v) %>% 
    group_by(index) %>% summarise(production_yield = sum(value))
  
  #match the scenarios to the production targets (+/- % error assigned in parametres script) that they meet. 
  # Join based on yield falling between min and max permissible P values (throw away combinations that don't meet production)
  scenarios  <- all_comb_totalYield %>% 
    left_join(P,
              join_by(production_yield >= minYield, production_yield < maxYield)) %>% na.omit
  
  
  #take the index of scenarios that meet yield and determine full scenario
  scenarios <- scenarios %>% dplyr::select(index, production_target, production_yield.y) %>% 
    rename(production_yield = production_yield.y) %>% 
    left_join(all_comb, by = "index")
  
  
  #multiply the scenario back up to 10,000km2 and regain important information
  scenarios <- scenarios %>%  pivot_longer(!c(index, production_target,production_yield), names_to = "b", values_to = "hab_yield") %>% 
    mutate(production_yield = production_yield *100,
           num_parcels = 100)
  
  hab_codes <- yield_matrix %>% dplyr::select(transition_harvest, parcel_yield_gained_10km2_60yrs, habitat) %>% rename(hab_yield = 2, 
                                                                                                                       original_habitat = 3)
  
  #summarise amount of habitat type in each scenario
  scenarios <- scenarios %>% left_join(hab_codes, by = "hab_yield") %>% 
    ungroup %>% 
    group_by(index,hab_yield, transition_harvest) %>%
    mutate(num_parcels = sum(num_parcels)) %>% 
    dplyr::select(-b) %>% 
    unique %>% 
    ungroup
  
  #add a column that describes the scenario
  scenarios$scenarioName = scenarioName
  
  #---------------------------------------------------------------------------------------------------------------------
  #carry out post-hoc sorting to remove rule-breaking scenarios #### 
  #---------------------------------------------------------------------------------------------------------------------
  #1. If scenario involves "deforested" , scenarios cannot have original deforested cover of > 200 parcels 
  
  scenarios <- scenarios %>% group_by(index) %>% 
    #if scenarioName contains "mostly..."deforested"...
    mutate(sum_deforested = ifelse(grepl("deforested", scenarioName), 
                                   #then summarise number of deforested forest parcels in a scenario
                                   sum(num_parcels[original_habitat == "deforested"]), 
                                   # if scenario names doesn't contain "deforested, make sum_deforested 0 
                                   0)) %>%
    #remove scenarios where more than 200 parcels are orignally deforested 
    filter(!sum_deforested > 201) %>%
    dplyr::select(-sum_deforested) %>% ungroup()
  
  
  #2. If scenario is mostly 1L or mostly 2L then scenarios cannot have  > 200 parcels of original primary forest
  scenarios <- scenarios %>% group_by(index) %>% 
    #if scenarioName contains "mostly"...
    mutate(sum_primary = ifelse(grepl("mostly", scenarioName), 
                                #then summarise number of primary forest parcels in a scenario
                                sum(num_parcels[original_habitat == "primary"]), 
                                # if scenario names doesn't contain "mostly, make sum_primary 0 
                                0)) %>%
    #remove scenarios where more than 200 parcels are orignally primary  
    filter(!sum_primary > 201) %>%
    dplyr::select(-sum_primary) %>% ungroup()
  
  
  #3. Remove scenarios that are identical (e.g. where there are the same number of parcels of a given habitat type in the scenario)
  #(we do this by sorting then concetanning harvest and num_parcels to create unique indexes)
  
  #get unique parcels nums 
  scenarios <- scenarios %>%  group_by(index) %>%
    arrange(num_parcels) %>% 
    mutate(temp_parcels = num_parcels/100) %>% 
    mutate(temp_parcels = paste(num_parcels, collapse = "_")) %>% ungroup 
  
  #get unique tranition harvests  
  scenarios <- scenarios %>%  group_by(index) %>%
    arrange(transition_harvest) %>% 
    mutate(temp_harvest = paste(transition_harvest, collapse = "_")) %>% 
    ungroup %>% 
    # unite to get a scenario index describing scenario composition
    unite(unique_scenarios, temp_parcels,temp_harvest)
  
  #get uniqe parcel index (one of each scenario compositions)
  unique_scenario_index  <- scenarios %>% 
    group_by(unique_scenarios) %>%  
    slice(1) %>% ungroup %>% 
    dplyr::select(index) %>% 
    unique
  
  #filter out unique scenarios and drop unwanted columns 
  scenarios <- unique_scenario_index %>% left_join(scenarios, by = "index") %>%  
    dplyr::select(-unique_scenarios)
  
  #4 Select no more than 1000 scenarios for each production target 
  filt_ID <- scenarios %>% dplyr::select(index,production_target) %>% 
    group_by(index, production_target) %>%  
    slice(1) %>% ungroup %>% 
    group_by(production_target) %>% 
    # mutate(scenario_filt = 1:n()) %>%  
    mutate(scenario_filt =dplyr::row_number() - min(dplyr::row_number()) + 1) %>% # 
    ungroup %>% 
    dplyr::select(index,scenario_filt) %>% ungroup
  
  #remove if > 1000 different scenarios for a given production target to save memory      
  scenarios <- scenarios %>% left_join(filt_ID, by = "index") %>% 
    filter(scenario_filt < 1000) %>% ungroup()
  
  #5 no scenario should comprise of more than 1000 parcels 
  
  scenarios <- scenarios %>% group_by(index, production_target) %>%  
    filter(!sum(num_parcels) > 1000) %>% 
    ungroup()
  
  
  
  #---------------------------------------------------------------------------------------------------------------------
  # Create the file path by combining folder and filename
  file_path <- file.path(folder, scenarioName)
  
  # Write the data frame to the specified location
  write.csv(scenarios, file = file_path, row.names = FALSE)
  
  
  #temporarily write csv - alter this to add scenario string name automatically 
  #  write.csv(scenarios, scenarioName)
  
  print("All done you clever bastard")
  
  #END OF MASTER createScenarios function
}
# 
# #unique number of scenarios
# scenario_count <- scenarios %>%ungroup %>%  dplyr::select(index,production_target) %>% unique %>%  nrow
# 
# #scenario space coverage
# scenario_count <- scenarios %>%ungroup %>%  dplyr::select(index,production_target) %>% unique
# 
# scenario_count %>% ggplot(aes(x = production_target)) +
#   geom_histogram(binwidth = 0.1, fill = "steelblue", color = "black") +
#   labs(x = "Production Target", y = "Count") +
#   ggtitle("Histogram of Scenarios")

