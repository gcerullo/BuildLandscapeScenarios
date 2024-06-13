# BuildLandscapeScenarios
Ths project generates many different scenarios. Make sure you define the parametres in the LandscapeParametres folder and that you also check over descriptions of what functions are doing in the 
scenarioFunctions script. 


Builds many 1Mha landscape level timber production scenarios based on provided parametres 



#FUNCTIONS
#ScenarioFunctions.R 
This contains the function for generating lots of different scenarios from different starting landscapes based on different rulesets. These functions are executed in the GenerateScenarios script



#SCRIPTS 

#LandscapeParametres.R
Inputs - needs csv definining the yields associated with different habitat transitions. 
Thereafter this script defines scenario  parametres: 
including
#(1) rules for habitat transitions are permitted
#(2) reads in yields for different habitat transitions 
#(3) defines the starting lanscape composition 
#all scenarios are 1Mha landscape level scenarios developed for malaysian borneo 

#Generate2CompartmentScenarios.R
This generates two-compartment scenarios for meeting production targets from different starting landscapes 


#GenerateScenarios.R
Using functions from ScenarioFunctions and Parametres defined in LandscapeParametres.R, this code uses a brute-force approach (alike to Cerullo et al. 2023; Biological Conservation) to generate a wide-range of multi-compartment 1Mha landcape level scenarios. It then joins these to the 2-compartment scenarios built in the code above - so be sure to run that script first. 
