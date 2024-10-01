# 1. BuildLandscapeScenarios
Ths project generates many different scenarios. Make sure you define the parametres in the LandscapeParametres folder and that you also check over descriptions of what functions are doing in the 
scenarioFunctions script. 


Builds many 1Mha landscape level timber production scenarios based on provided parametres 


#FUNCTIONS
#ScenarioFunctions.R 
This contains the function for generating lots of different scenarios from different starting landscapes based on different rulesets. These functions are executed in the GenerateScenarios script



#SCRIPTS 

#CalculateYields.R 
This code provided a replicable backbone for determining the yields of different habitat transitions. 
It estimates yields likely from harvesting strip-plantated forest. 
It also estimates yields from staggered harvest of plantations - e.g. where 1/30 of plantations are established in yr1, or yr2 ... to yr30. 

The output is a MasterHabTransitionYields.csv that feeds into the LandscapeParametres.R script, and enables the construction of a wide set of scenarios. 

#LandscapeParametres.R
Inputs - needs csv definining the yields associated with different habitat transitions.
This is produced in CalculateYields.R
Thereafter this script defines scenario  parametres: 
including
#(1) rules for habitat transitions are permitted
#(2) reads in yields for different habitat transitions 
#(3) defines the starting lanscape composition 
#all scenarios are 1Mha landscape level scenarios developed for malaysian borneo 

#Generate2CompartmentScenarios.R
This generates all two compartment scenarios for meeting production targets. Two-compartment scenarios 
are defined as in the traditional sparing-sharing paradigm, to represent one harvested and one zero-yielding managment type


#GenerateScenarios.R
Using functions from ScenarioFunctions and Parametres defined in LandscapeParametres.R, this code uses a brute-force approach (alike to Cerullo et al. 2023; Biological Conservation) to generate a wide-range of multi-compartment 1Mha landcape level scenarios. It then joins these to the 2-compartment scenarios built in the code above - so be sure to run that script first. 

#AddTemporalDelayToScenarios.R 
Since our scenarios assume staggered harvests, e.g. 1/30th of total plantation is converted each year, we need to capture the habitat that is present prior to conversion, as this is important for calculating bird, dung beetle, and megatree outcomes. This script adds delays prior to harvests for each scenario. This script adds this temporal delay to scenario and outputs the scenarios with time delays as both 
#1. MasterAllScenarios_withHarvestDelays.rds
#2. csvs, where each csv is a scenario set. This is because we improve memory allocation by processing one scenario set at a time in the R. Environement. 
