#03/06/24 
#this code outlines the parametres, including
#(1) rules for which habitat transitions are permitted
#(2) reads in yields for different habitat transitions, calculated in CalculateYields.R 
#(3) defines the starting lanscape composition 

#all scenarios are 1Mha landscape level scenarios developed for Sabah, Borneo 


#nb: code for implementing improved (IY) yield plantations is commented out but could be incorporated
#if we included these values in the YieldMatrix read-in

#rm(list = ls())
options(scipen = 999)

library(tidyverse)
library(dplyr)
library(sampling)

#Inputs

#read in transition yield matrix outline yields from different conversion

#yields here assume both roundwood and pulp volumes
# plantation harvests staggered (ie. established)  1/30 each year
yield_matrix <- read_csv("Outputs/MasterHabTransitionYields.csv") %>% 
  
  #add habitat codes 
  mutate(hab_code = case_when(habitat == "primary" ~ 0, 
                              habitat == "once-logged" ~1, 
                              habitat == "twice-logged" ~2,
                              habitat == "restored" ~3,
                              habitat == "albizia_current" ~4,
                              habitat == "eucalyptus_current" ~5,
                              habitat == "albizia_improved" ~6,
                              habitat == "eucalyptus_improved" ~7,
                              habitat == "deforested" ~8))



names(yield_matrix)

#determine the max yields that can be derived from a primary, once-logged without post-logging interventions or deforestation
max_natural <- yield_matrix %>% filter(habitat == "primary" & transition_harvest == "twice-logged" |
                                         habitat == "once-logged" & transition_harvest == "twice-logged") %>% 
  dplyr::select(habitat,transition_harvest, parcel_yield_gained_10km2_60yrs, hab_code)


#define the error that is allowed about the production targets (how close do we need to get to the extact production target?)
error <- 0.02 # 2%


#define the starting landscape parameters  
all_primary <- yield_matrix %>% filter(habitat == "primary")
mostly_1L <- yield_matrix %>% filter(habitat == "primary"| habitat == "once-logged")
mostly_2L <- yield_matrix %>% filter(habitat == "primary"| habitat == "twice-logged")
primary_deforested <- yield_matrix %>% filter(habitat == "primary"|habitat =="deforested") 
mostly_1L_deforested <- yield_matrix %>% filter(habitat == "primary"| habitat == "once-logged"| habitat == "deforested") 
mostly_2L_deforested <- yield_matrix %>% filter(habitat == "primary"| habitat == "twice-logged"| habitat == "deforested") 


#define the parametres, depending on the different rules and starting landscapes (D = deforestion, ND = nodeforestation, CY = current yields, IY = improved yields) 
all_primary_CY_ND <- all_primary %>% filter(current_yields == 1 & no_deforestation == 1) 
all_primary_CY_D <- all_primary %>% filter(current_yields == 1 & deforestation == 1) 

#for incorporating improved plantation yields
#all_primary_IY_ND <- all_primary %>% filter(improved_yields == 1 & no_deforestation == 1) 
#all_primary_IY_D <- all_primary %>% filter(improved_yields == 1 & deforestation == 1) 


mostly_1L_CY_ND <- mostly_1L %>% filter(current_yields == 1 & no_deforestation == 1) 
mostly_1L_CY_D <- mostly_1L %>% filter(current_yields == 1 & deforestation == 1) 

#for incorporating improved plantation yields
#mostly_1L_IY_ND <- mostly_1L %>% filter(improved_yields == 1 & no_deforestation == 1) 
#mostly_1L_IY_D <- mostly_1L %>% filter(improved_yields == 1 & deforestation == 1) 

mostly_2L_CY_ND <- mostly_2L %>% filter(current_yields == 1 & no_deforestation == 1) 
mostly_2L_CY_D <- mostly_2L %>% filter(current_yields == 1 & deforestation == 1) 
#mostly_2L_IY_ND <- mostly_2L %>% filter(improved_yields == 1 & no_deforestation == 1) 
#mostly_2L_IY_D <- mostly_2L %>% filter(improved_yields == 1 & deforestation == 1) 

primary_deforested_CY_ND <- primary_deforested %>% filter(current_yields == 1 & no_deforestation == 1) 
primary_deforested_CY_D <- primary_deforested %>% filter(current_yields == 1 & deforestation == 1) 
#primary_deforested_IY_ND <- primary_deforested %>% filter(improved_yields == 1 & no_deforestation == 1) 
#primary_deforested_IY_D <- primary_deforested %>% filter(improved_yields == 1 & deforestation == 1) 

mostly_1L_deforested_CY_ND <- mostly_1L_deforested %>% filter(current_yields == 1 & no_deforestation == 1) 
mostly_1L_deforested_CY_D <- mostly_1L_deforested %>% filter(current_yields == 1 & deforestation == 1) 
#mostly_1L_deforested_IY_ND <- mostly_1L_deforested %>% filter(improved_yields == 1 & no_deforestation == 1) 
#mostly_1L_deforested_IY_D <- mostly_1L_deforested %>% filter(improved_yields == 1 & deforestation == 1) 

mostly_2L_deforested_CY_ND <- mostly_2L_deforested %>% filter(current_yields == 1 & no_deforestation == 1) 
mostly_2L_deforested_CY_D <- mostly_2L_deforested %>% filter(current_yields == 1 & deforestation == 1) 
#mostly_2L_deforested_IY_ND <- mostly_2L_deforested %>% filter(improved_yields == 1 & no_deforestation == 1) 
#mostly_2L_deforested_IY_D <- mostly_2L_deforested %>% filter(improved_yields == 1 & deforestation == 1) 



#build the starting landscapes (each made of 1000 planning units)

#1. Scenarios with no deforested land at beginning 
strt_P <- data.frame(hab_code = rep(0, 1000))
strt_1L <- data.frame(hab_code = c(rep(1, 800), rep(0, 200)))
strt_2L <- data.frame(hab_code = c(rep(2, 800), rep(0, 200)))                     

#2. Scenarios with  deforested land at beginning 
strt_P_df <- data.frame(hab_code = c(rep(0, 800), rep(8, 200)))
strt_1L_df <- data.frame(hab_code = c(rep(1, 600), rep(0, 200),rep(8, 200)))
strt_2L_df <- data.frame(hab_code = c(rep(2, 600), rep(0, 200),rep(8, 200)))    

#define a daraframe showing all starting landscapes  
all_start_landscape <- data.frame(
  scenarioStart = 
    c("primary", 
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
)

# # # visualise starting landscapes 
# plot_raster <- function(x){
#  matrix_val <- matrix(x$hab_code, nrow =25, ncol = 40, byrow = TRUE)
#  raster_obj <- raster(matrix_val)
#  plot(raster_obj)
# }
# 
# plot_raster(strt_P_df)

