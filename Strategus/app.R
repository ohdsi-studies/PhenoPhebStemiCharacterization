#remotes::install_github("drttrousers/OhdsiShinyModules")

library(dplyr)
library(ShinyAppBuilder)
library(markdown)

##=========== START OF INPUTS ==========

connectionDetailsReference <- CDR
outputLocation <- outputFolder

##=========== END OF INPUTS ==========
##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
# specify the connection to the results database
sqliteDbPath <- file.path(paste0(outputFolder,"/app/",connectionDetailsReference, ".sqlite"))
resultsDatabaseSchema <- "main"
resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sqlite", 
  server = sqliteDbPath
)

# Specify about module ---------------------------------------------------------
aboutModule <- createDefaultAboutConfig()

# Specify cohort generator module ----------------------------------------------
cohortGeneratorModule <- createDefaultCohortGeneratorConfig()

# Specify cohort diagnostics module --------------------------------------------
cohortDiagnosticsModule <- createDefaultCohortDiagnosticsConfig()

# Combine module specifications ------------------------------------------------
shinyAppConfig <- initializeModuleConfig() %>%
  addModuleConfig(aboutModule) %>%
  addModuleConfig(cohortGeneratorModule) %>%
  addModuleConfig(cohortDiagnosticsModule) 

# Launch shiny app -----------------------------------------------------
connectionHandler <- ResultModelManager::ConnectionHandler$new(resultsDatabaseConnectionDetails)

ShinyAppBuilder::createShinyApp(
  config = shinyAppConfig, 
  connection = connectionHandler,
  resultDatabaseSettings = createDefaultResultDatabaseSettings()
)
