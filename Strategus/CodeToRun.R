# Package synchronization, run once and not again
# install.packages("keyring")
# remotes::install_github("ohdsi/ShinyAppBuilder")
# remotes::install_github("ohdsi/OhdsiShinyModules")
# remotes::install_github("ohdsi/ResultModelManager")
# remotes::install_github("ohdsi/CohortGenerator")
# remotes::install_github("ohdsi/CohortDiagnostics")
# remotes::install_github("OHDSI/Strategus")

## User input variables
CDR <- "OPEN_CLAIMS"                                          # reference for connection details
workSchema <- Sys.getenv("STUDY_REFERENCE_USA_OPENCLAIMS")                           # Database location to write results during modules
tempEmulationSchema <- Sys.getenv("STUDY_REFERENCE_USA_OPENCLAIMS")                 # Emulation schema for snowflake, oracle etc. NOT NEEDED ON OTHER DBMS
resultsSchema <- workSchema                              # Database location to write results for storage on completion
cdmDatabaseSchema <- Sys.getenv("PA_USA_OPENCLAIMS_SCHEMA")  # Database location for the CDM
cohortTableName <- "STEMI_v2"
outputFolder <- file.path(paste0(getwd(),"/Strategus/output"))

# If first time using strategus execution, these variables are essential
Sys.setenv(INSTANTIATED_MODULES_FOLDER="~/StrategusModulesHome") # directory for Strategus modules to be installed
Sys.setenv(STRATEGUS_KEYRING_PASSWORD="empace")                  # Password for keyring used to store details, if already set do not re-set
  
# Create connection details in usual manner
connectionDetails <- DatabaseConnector::createConnectionDetails(
  "snowflake",
  user = Sys.getenv("NW_SNOWFLAKE_USER"),
  password = Sys.getenv("NW_SNOWFLAKE_PASSWORD"),
  connectionString = paste0(Sys.getenv("OMOP_PA_SERVER"), Sys.getenv("MEDIUM_USA_OPENCLAIMS"),"&CLIENT_SESSION_KEEP_ALIVE=true")
  )

#######################
## END OF USER INPUT ##
# NOTE line 42 and 43 #
#######################
# Store connection details on Keyring
Strategus::storeConnectionDetails(connectionDetails = connectionDetails,
                                  connectionDetailsReference = CDR)

# Check emulation schema options are set 
# (may not work, may need to copy this line into the top of Main.R in each module)
options(sqlRenderTempEmulationSchema = tempEmulationSchema)

## Creating an execution settings object
executionSettings <- Strategus::createCdmExecutionSettings(
  connectionDetailsReference = CDR,
  workDatabaseSchema = workSchema,
  resultsDatabaseSchema = workSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputFolder, "work_folder"),
  resultsFolder = file.path(outputFolder, "results_folder"),
  minCellCount = 5,
  tempEmulationSchema = tempEmulationSchema
)

#Write out the execution settings to the file system to capture this information.
ParallelLogger::saveSettingsToJson(
  object = executionSettings, "Strategus/inst/empaceExecutionSettings.json")

#For this study, we will use analysis specifications created elsewhere, and the execution settings we created earlier:
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "Strategus/inst/analysisSpec.json"
)
executionSettings <- ParallelLogger::loadSettingsFromJson(
  fileName = "Strategus/inst/empaceExecutionSettings.json"
)

#execute the study
Strategus::execute(analysisSpecifications = analysisSpecifications,
                   executionSettings = executionSettings,
                   executionScriptFolder = file.path(outputFolder, "script_folder"))

#Step 1. create app folder in outputFolder
#If trouble running resuls_compile, please delete the NOT NULL from the source_concept_id in Home/ R/ Workbench/x86.....gnu_library/ 4.2/ CohortDiagnostics/ sql/ sql_server/ createResultsDataModel.sql
source("Results_compile.R")

if(launchShiny){
  source("app.R")
}

