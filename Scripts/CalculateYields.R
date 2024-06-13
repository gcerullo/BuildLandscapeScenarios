#13,06.24

# This script is to output a dataframe of yields for each habitat type transition.
# Firstly I calculate the yields of logging, then of any conversion to plantations - which incorporates a delayed schedule.

# Logging yield transitions 
#Primary -> Primary -> 0
#Primary -> Once-logged -> 112.96 m3/ha 
#Primary -> Restored - > calculation below, based on Ruslandi et al conversion facor and Phillipson recovery rates 
#Primary -> twice-logged -> 112.96 + 31.24 =  144.2 m3/ha 

#Once-logged -> once-logged -> 0
#Once-logged -> restored -> 

#Twice-logged -> twice-logged 0 


#1 Calculate timber yields available from strip planting #### 

#(A) Calculate conversion factor 

#According to Ruslandi et al. 30 yr old strip-planted forest (L60L40SP) 
#has an AGB of 380 Mg/ha and 140m3 of merchantable timber. #

#Calculate Ruslandi-et-al-derived conversion factor
#convert AGB to ACD
ACD_30yrStripPlanted <- 380*0.47

#calculate a conversion factor expressing timber available from strip planted forest, if we know the ACD.
convFact <- ACD_30yrStripPlanted/140

# (B) Use Philpson et al ACD in strip-planted versus naturally regenerating logged forest to calculate additional 
# ACD from treatment 

#ACD gain per year (from Philpson et al)
NR_ACD <- 2.9 #naturally regenerating (Mg/ha/-yr)
SP_ACD <- 4.4 # strip-plantng (Mg/ha/-yr

#define years after strip-planting that harvesting can occur
yrs_until_reharvest <- 30

#timber gain after 30 years 
NR_ACD_30 <- NR_ACD * yrs_until_reharvest  #ACD afer 30yrs
SP_ACD_30 <- SP_ACD * yrs_until_reharvest



#convert ACD after 30 years to timber available using conversion factor 
NR_ACD_30 /convFact # supposed timber available at yr 30 from NR forest (Nb, this tends to overestimate available timber in our landscape - so our results are conservative (i.e. we may be slightly overestimate timber yields from logging))
stripTimber <- SP_ACD_30 / convFact #(m3/ha)

#Following Runting et al 2020, we assume that strip-planting is only applied in 28% of the parcel and hence the available timber available from once-logged to restored is 
stripTimber *0.285714286 #*percentage harvestable near roads (200/700)






