# 1. BuildLandscapeScenarios
Ths project builds many 1Mha landscape level timber production scenarios based on provided parametres 

Inputs: 
ForestYields - showing forest yields from different forest-forest transitions (0-yielding transitions require a non-zero value, so add a nominal decimal)

Plantation yields - showing yields from plantations, including from forest conversion. 

HabByYears - showing the functional habitat type and age for each true year of a habitat transition.


#FUNCTIONS
#ScenarioFunctions.R 
This contains the function for generating lots of different scenarios from different starting landscapes based on different rulesets. These functions are executed in the GenerateScenarios script


#SCRIPTS - to be run in this order. Note that the R.project should have a folders associates with it called Inputs, Outputs, Scripts, Functions, Data. 

#--------------------------------------
#1. CalculateYields.R 
#--------------------------------------
Output: MasterHabTransitionYields.csv

This code provided a replicable backbone for determining the yields of different habitat transitions. 
It estimates yields likely from harvesting strip-plantated forest. 
It also estimates yields from staggered harvest of plantations - e.g. where 1/30 of plantations are established in yr1, or yr2 ... to yr30. 

The output is a MasterHabTransitionYields.csv that feeds into the LandscapeParametres.R script, and enables the construction of a wide set of scenarios. 

#--------------------------------------
#2. LandscapeParametres.R
#--------------------------------------
Inputs - MasterHabTransitionYields.csv

Thereafter this script defines scenario  parametres: 
including
#(1) rules for habitat transitions are permitted
#(2) reads in yields for different habitat transitions 
#(3) defines the starting lanscape composition 
#all scenarios are 1Mha landscape level scenarios developed for malaysian borneo 

#--------------------------------------
#3. Generate2CompartmentScenarios.R
#--------------------------------------
Output: TwoCompartmentScenarios.rds"
This generates all two compartment scenarios for meeting production targets. Two-compartment scenarios 
are defined as in the traditional sparing-sharing paradigm, to represent one harvested and one zero-yielding managment type

#--------------------------------------
#4. GenerateScenarios.R
#--------------------------------------
Inputs: TwoCompartmentScenarios.rds
Source scripts: LandscapeParametres.R, ScenarioFunctions.R
Outputs: MasterAllScenarios.rds

Using functions from ScenarioFunctions and Parametres defined in LandscapeParametres.R, this code uses a brute-force approach (alike to Cerullo et al. 2023; Biological Conservation) to generate a wide-range of multi-compartment 1Mha landcape level scenarios. It then joins these to the 2-compartment scenarios built in the code above - so be sure to run that script first. 

#--------------------------------------
#5. AddTemporalDelayToScenarios.R 
#--------------------------------------
Inputs: HabByYears.csv, MasterAllScenarios.rds

Since our scenarios assume staggered harvests, e.g. 1/30th of total plantation is converted each year, we need to capture the habitat that is present prior to conversion, as this is important for calculating bird, dung beetle, and megatree outcomes. This script adds delays prior to harvests for each scenario. This script adds this temporal delay to scenario and outputs the scenarios with time delays as both 
#1. MasterAllScenarios_withHarvestDelays.rds
#2. csvs, where each csv is a scenario set. This is because we improve memory allocation by processing one scenario set at a time in the R. Environement. csvs are saved in a folder called: Outputs/ScenariosWithDelaysCSVS
