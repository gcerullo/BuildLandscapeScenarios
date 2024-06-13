#13.06.24 GC 

# This script is to output a dataframe of yields for each habitat type transition.
# Firstly I calculate the yields of logging, including estimating the timber outcomes of strip-planting 
# Then I calculate and timber from  conversion to plantations - which incorporates a delayed schedule.

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
#Once-logged -> restored -> 40.76148 m3/ha (see how SP_timber is derived below)

#Twice-logged -> twice-logged 0 

#--------Define plantation transitions -----------------

#1 Calculate timber yields available from strip planting #### 

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

#ACD gain per year (from Philpson et al)
NR_ACD <- 2.9 #naturally regenerating (Mg/ha/-yr)
SP_ACD <- 4.4 # strip-plantng (Mg/ha/-yr

#define years after strip-planting that harvesting can occur
yrs_until_reharvest <- 30

#define standing ACD in 0yr old once-logged forest 
yr0_ACD <- 50 #Mg/ha)

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

#READ IN FOREST-FOREST transition YIELDs - where all forest yields are derived as above
forest_forest <- read.csv(Inouts/)

