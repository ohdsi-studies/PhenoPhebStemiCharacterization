# Install correct versions of HADES packages
# remotes::install_github("ohdsi/CohortGenerator")
# remotes::install_github("ohdsi/CohortDiagnostics")
# remotes::install_github("OHDSI/Strategus")

library(dplyr)
library(CohortGenerator)
library(magrittr)
library(Strategus)

## Cohorts for the study
cohortsToCreate <- createEmptyCohortDefinitionSet()

# Set up WebAPI link
baseUrl <- Sys.getenv("ATLAS_WEBAPI")

### include all cohortIds that you need for your analysis ###
cohortIds <- c(135,1707,1708)

#link to IQVIA ATLAS Web API using your single-sign on credentials
ROhdsiWebApi::authorizeWebApi(baseUrl = baseUrl,
                              authMethod = "ad",
                              webApiUsername = Sys.getenv("NW_USER"),
                              webApiPassword = Sys.getenv("NW_PASS"))


# check we have the cohorts specified
webApiCohorts <- ROhdsiWebApi::getCohortDefinitionsMetaData(baseUrl = baseUrl)
studyCohorts <- webApiCohorts %>%
  dplyr::filter(.data$id %in% cohortIds)

### Cohort Definitions & Negative Control Outcomes
# Fetch the details
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(baseUrl = baseUrl, 
                                                               cohortIds = cohortIds, 
                                                               generateStats = TRUE)

## CohortGenerator Module Settings
CohortGenerator::saveCohortDefinitionSet(cohortDefinitionSet = cohortDefinitionSet,
                                         settingsFileName = "Strategus/inst/settings/CohortsToCreate.csv",
                                         jsonFolder = "Strategus/inst/cohorts",
                                         sqlFolder = "Strategus/inst/sql/sql_server")

write.csv(cohortDefinitionSet, "Strategus/inst/settings/CohortsToCreateDocumentation.csv",row.names = FALSE)

cohortDefinitionSet <- getCohortDefinitionSet(
  settingsFileName = "Strategus/inst/settings/CohortsToCreate.csv",
  jsonFolder = "Strategus/inst/cohorts",
  sqlFolder = "Strategus/inst/sql/sql_server"
)

## Module setup cohort generator
#The following code downloads the settings functions from the `CohortGeneratorModule` which then activates some additional functions we can use for creating the analysis specification. 
#In the analysis specification, we will add the cohort definitions and negative control outcomes to the `sharedResources` section since these elements may be used by any of the HADES modules. 
#To do this, we will use the `createCohortSharedResourceSpecifications` and `createNegativeControlOutcomeCohortSharedResourceSpecifications` functions respectively. In addition, we will use the  `cohortGeneratorModuleSpecifications` function to specify the cohort generation settings.
source("https://raw.githubusercontent.com/OHDSI/CohortGeneratorModule/v0.4.2/SettingsFunctions.R")

# Create the cohort definition shared resource element for the analysis specification
cohortDefinitionShared <- createCohortSharedResourceSpecifications(cohortDefinitionSet)

# Create the module specification
cohortGeneratorModuleSpecifications <- createCohortGeneratorModuleSpecifications(
  incremental = TRUE,
  generateStats = TRUE
)

## CohortDiagnostics Module Settings
#The following code creates the `cohortDiagnosticsModuleSpecifications` to run cohort diagnostics on the cohorts in the study.
source("https://raw.githubusercontent.com/OHDSI/CohortDiagnosticsModule/v0.2.0/SettingsFunctions.R")
library(CohortDiagnostics)
cohortDiagnosticsModuleSpecifications <- createCohortDiagnosticsModuleSpecifications(
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = TRUE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  minCharacterizationMean = 0.0001,
  temporalCovariateSettings = getDefaultCovariateSettings(),
  incremental = FALSE,
  cohortIds = cohortDefinitionSet$cohortId)


# Strategus Analysis Specifications
#Finally, we will use the various shared resources and module specifications to construct the full set of analysis specifications and save it to the file system in JSON format.
analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() %>%
  Strategus::addSharedResources(cohortDefinitionShared) %>%
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) %>%
  Strategus::addModuleSpecifications(cohortDiagnosticsModuleSpecifications) 

ParallelLogger::saveSettingsToJson(analysisSpecifications, file.path("Strategus/inst/analysisSpec.json"))

