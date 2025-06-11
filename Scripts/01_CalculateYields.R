#13.06.24 GC 

# This script is to output a dataframe of yields for each habitat type transition.
# Firstly I calculate the yields of logging, including estimating the timber outcomes of strip-planting 
# Then I calculate and timber from  conversion to plantations - which incorporates a delayed schedule.

#library
library(tidyverse)


#  ---------Define logging transitions -----------------
#Note that for strip-planting treatments, we have to make a decision. 
# (A) If only the 28% enrichment planted area is reharvested then this = 40.76148m3/ha  (see SP_timber derivation)
# (B) If for stripPlanting we assume the enricment planting area is reharvested AND we log for a second time the ~72% of once-logged naturally regenerating forest, then we get  63.07576 m3/ha (see totalSP_timber derivation)

#Let's assume based on reality that (A) is the case and we only get timber from re-harvesting in planted areas. 

# Logging yield transitions 
#Primary -> Primary -> 0
#Primary -> Once-logged -> 112.96 m3/ha #Fisher et al 2009
#Primary -> Restored - >  112.96 + 40.76148   = 153.7215                           
#Primary -> twice-logged -> 112.96 + 31.24 =  144.2 m3/ha #Fisher et al 2009

#Once-logged -> once-logged -> 0
#Once-logged -> twice-logged -> 31.24   #Fisher et al 2009
#Once-logged -> restored -> 40.76148 m3/ha (see how SP_timber is derived below)


#Twice-logged -> twice-logged 0 

#Define logging params #### 

#ACD gain per year (from Philpson et al)
NR_ACD <- 2.9 #naturally regenerating (Mg/ha/-yr)
SP_ACD <- 4.4 # strip-plantng (Mg/ha/-yr

#define years after strip-planting that harvesting can occur
yrs_until_reharvest <- 30

#define standing ACD in 0yr old once-logged forest 
yr0_ACD <- 50 #Mg/ha)

#define salvage loggging yields 
salvageYields <- 24.46 #m3/ha from Fischer et al 2009

#1 Calculate strip planting yields #### 

#(A) Calculate conversion factor 

#According to Ruslandi et al. 30 yr old strip-planted forest (L60L40SP) 
#has an AGB of 380 Mg/ha and 140m3 of merchantable timber. #

#Calculate Ruslandi-et-al-derived conversion factor
#convert AGB to ACD
ACD_30yrStripPlanted <- 380*0.47 #multiply by conversion factor to convert biomass to carbon

#calculate a conversion factor expressing timber available from strip planted forest, if we know the ACD.
convFact <- ACD_30yrStripPlanted/140

# (B) Use Philpson et al ACD in strip-planted versus naturally regenerating logged forest to calculate additional 
# ACD from treatment 

#ACD after 30 years 
NR_ACD_30 <- yr0_ACD + (NR_ACD * yrs_until_reharvest)  #ACD afer 30yrs
SP_ACD_30 <- yr0_ACD + (SP_ACD * yrs_until_reharvest) #Mg/ha  

#convert ACD after 30 years to timber available using conversion factor 
NR_ACD_30 /convFact # supposed timber available at yr 30 from NR forest (Nb, this tends to overestimate available timber in our landscape - so our results are conservative (i.e. we may be slightly overestimate timber yields from logging))
stripTimber <- SP_ACD_30 / convFact #(m3/ha)

#Following Runting et al 2020, we assume that strip-planting is only applied in 28% of the parcel and hence the available timber available from once-logged to restored is 

#This is the volume of timber derived from harvesting the enrichment planted area after 30 years
yields2L <- 31.24 # yields from relogging per ha according to Fischer et al.
SP_timber <- stripTimber *0.285714286 #*percentage harvestable near roads (200/700)
nonSP_timber <- 31.24 * (1- 0.285714286)

#This is the volume of timber we derive if (i) the strip-planted 28% of forest is harvest AND
#(ii) The remaining naturally regenerating area (72%) is subjected to a second logging rotation 
totalSP_timber <- SP_timber + nonSP_timber



#--------Define plantation transitions -----------------
#deforested -> albizia 797,160 (m3/10km2/60yr) - see albYields derivation below
#deforested -> eucalyptus 693,420 (m3/10km2/60yr) - see eucYields derivation below 

#Primary -> albizia 
#Primary -> eucalyptus 
#once-logged -> albizia 
#once-logged -> eucalyptus 
#twice-logged -> albizia 
#twice-logged -> eucalyptus 


#NB - if we want we can also include what would happen if we improved management in each plantation system 
#we just also need to provide yields under improved plantation management


#Define plantation params #### 

#MAI of plantations based on SSB inventory data
MAI_alb <- 17.52
MAI_euc <- 15.24 

#define clearance yields 
#Primary -> Primary -> 0
#Primary -> Once-logged -> 112.96 m3/ha #Fisher et al 2009
#Primary -> twice-logged -> 112.96 + 31.24 =  144.2 m3/ha #Fisher et al 2009
#Primary -> Restored - >  112.96 + 40.76148   = 153.7215  

#define upon forest conversion the amount of pulpwood derived from forest clearance, in relation to roundwood
#Conversion factors (CF) from From Runting et al.20
pulpCF_primary <- 1.47
pulpCF_logged <-  2.57 

#2. Calculate clearance yields ####

#roundwood (RW) clearance yields
#NB - our results are conservative here, as we do not calculate the additional roundwood that would become avaible from 
#regrowth of forest stands which are left to grow during the harvest delay (e.g. forests deforested in yr 30 vs yr 0)
PrimaryClearanceRW <-  (144.2 + salvageYields) *1000 #m3/10km2/60yrs 
OnceLoggedClearanceRW <- (31.24 + salvageYields) *1000 #m3/10km2/60yrs  # yields from second rotation + salvage 
TwiceLoggedClearanceRW <- salvageYields *1000 #m3/10km2/60yrs 

#clearance pulp +roundwood yields
PrimaryClearance <- (PrimaryClearanceRW*pulpCF_primary) + PrimaryClearanceRW 
OnceLoggedClearance <- (OnceLoggedClearanceRW*pulpCF_logged) + OnceLoggedClearanceRW 
TwiceLoggedClearance <- (TwiceLoggedClearanceRW*pulpCF_logged) + TwiceLoggedClearanceRW 


#3. Calculate plantation yields ####

#If all plantation were established in the first year of my scenarios then they would generate timber for ~60 yrs
#based on the allocation where I average annual plantation yields across the scenario 

#Hence 
MAI_alb*60  #1051.2 m3 of albizia over 60 yrs 
MAI_euc*60  #914.4 m3 of eucalyptus over 60 years

#However in reality, plantation establishement would be staggered such that conversion does not 
#all happen in yr one. For our scenarios, we make the simplifying assumption that 
#(A) No plantation conversion can happen after yr 30
#(B) All plantation conversion happens evenly across the first 30 years (i.e. 1/30th of conversion in each year)

#Thus annual timber flows from staggered plantation establishment can be calculated as follows:  

# Let's assume the oldest plantation (established in yr 0 can be running for 60 yrs), whereas the most 
#recently established plantation (established in yr 30 can run for only 30 or so yrs)
sequence_data <- data.frame(age = seq(31, 60, by = 1))
albYields <- sequence_data %>%
  mutate(plantYield = MAI_alb * age,  # Multiply MAI by the sequence
         plantYield_10km2 = plantYield * 1000,  # Multiply by 1000 to get yield from ha to 10km2
         divided_by_30 = plantYield_10km2 / 30) %>% #lets assume 1/30th of each establishment time
          summarise(sum(divided_by_30)) #summarise yields across all staggered harvests

# Perform the required operations using dplyr

eucYields <- sequence_data %>%
  mutate(plantYield = MAI_euc * age,  # Multiply 210 by the sequence
         plantYield_10km2 = plantYield * 1000,  # Multiply by 1000
         divided_by_30 = plantYield_10km2 / 30) %>%
  summarise(sum(divided_by_30)) #summarise yields across all staggered harvests

#Summarise plantation transition yields (m3/10km2/60yr) ####

#deforested -> albizia 
albYields

#deforested -> eucalyptus 
eucYields

#Primary -> albizia 
PrimaryClearance+ albYields

#Primary -> eucalyptus 
PrimaryClearance+ eucYields

#once-logged -> albizia
OnceLoggedClearance + albYields 

#once-logged -> eucalyptus 
OnceLoggedClearance + eucYields 

#twice-logged -> albizia 
TwiceLoggedClearance+albYields

#twice-logged -> eucalyptus 
TwiceLoggedClearance+eucYields



#Bring together plantation and forest data ####
#The above derivations of yields are shown for replicability 
#Now read in these vals as CSV and combine to make Master output 

#READ IN FOREST-FOREST transition YIELDs - where all forest yields are derived as above
forest_forest <- read.csv("Inputs/ForestYields.csv")
#READ IN FOREST-FOREST transition YIELDs - where all forest yields are derived as above
plantation <- read.csv("Inputs/PlantationYields.csv")

#NB - if you want to include improved plantation varieties, need to enter valid values. 
#Included as vals here as this enables propagation thru scenario creation, for future reference.
master_df <- forest_forest %>% 
  rbind(plantation) %>%  
  select(-parcelYield_ha)

#Export Master yields data 
write.csv(master_df, "Outputs/MasterHabTransitionYields.csv")




