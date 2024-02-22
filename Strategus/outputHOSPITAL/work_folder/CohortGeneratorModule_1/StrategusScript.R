unlockKeyring <- 
function (keyringName) 
{
    keyringLocked <- keyring::keyring_is_locked(keyring = keyringName)
    if (keyringLocked) {
        x <- Sys.getenv("STRATEGUS_KEYRING_PASSWORD")
        if (length(x) == 0 || x == "") {
            stop(paste0("STRATEGUS_KEYRING_PASSWORD NOT FOUND. STRATEGUS_KEYRING_PASSWORD must be set using Sys.setenv(STRATEGUS_KEYRING_PASSWORD = \"<your password>\") to unlock the keyring: ", 
                keyringName))
        }
        keyring::keyring_unlock(keyring = keyringName, password = Sys.getenv("STRATEGUS_KEYRING_PASSWORD"))
    }
    return(keyringLocked)
}
retrieveConnectionDetails <- 
function (connectionDetailsReference, keyringName = NULL) 
{
    keyringList <- keyring::keyring_list()
    errorMessages <- checkmate::makeAssertCollection()
    checkmate::assertCharacter(connectionDetailsReference, len = 1, 
        add = errorMessages)
    checkmate::assertLogical(x = (is.null(keyringName) || keyringName %in% 
        keyringList$keyring), add = errorMessages)
    checkmate::reportAssertions(collection = errorMessages)
    if (!connectionDetailsReference %in% keyring::key_list(keyring = keyringName)$service) {
        stop("Connection details with connectionDetailsReference = \"", 
            connectionDetailsReference, "\" were not found in your keyring. Please check that you have used the Strategus storeConnectionDetails function to save your connection details with this connectionDetailsReference name.")
    }
    keyringLocked <- unlockKeyring(keyringName = keyringName)
    connectionDetails <- keyring::key_get(connectionDetailsReference, 
        keyring = keyringName)
    connectionDetails <- ParallelLogger::convertJsonToSettings(connectionDetails)
    connectionDetailsConstructedFromKeyring <- list()
    for (i in 1:length(connectionDetails)) {
        if (isFALSE(is.na(connectionDetails[[i]]))) {
            connectionDetailsConstructedFromKeyring[names(connectionDetails)[i]] <- connectionDetails[[i]]
        }
    }
    connectionDetails <- do.call(DatabaseConnector::createConnectionDetails, 
        connectionDetailsConstructedFromKeyring)
    if (keyringLocked) {
        keyring::keyring_lock(keyring = keyringName)
    }
    return(connectionDetails)
}
source("Main.R")
jobContext <- readRDS("/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/work_folder/CohortGeneratorModule_1/jobContext.rds")
keyringName <- jobContext$keyringSettings$keyringName
keyringLocked <- unlockKeyring(keyringName = keyringName)
ParallelLogger::addDefaultFileLogger(file.path(jobContext$moduleExecutionSettings$resultsSubFolder, "log.txt"))
ParallelLogger::addDefaultErrorReportLogger(file.path(jobContext$moduleExecutionSettings$resultsSubFolder, "errorReport.R"))
options(andromedaTempFolder = file.path(jobContext$moduleExecutionSettings$workFolder, "andromedaTemp"))
options(sqlRenderTempEmulationSchema = jobContext$moduleExecutionSettings$tempEmulationSchema)
options(databaseConnectorIntegerAsNumeric = jobContext$moduleExecutionSettings$integerAsNumeric)
options(databaseConnectorInteger64AsNumeric = jobContext$moduleExecutionSettings$integer64AsNumeric)
if (Sys.getenv("FORCE_RENV_USE", "") == "TRUE") {
    renv::use(lockfile = "renv.lock")
}
if (TRUE) {
    connectionDetails <- retrieveConnectionDetails(connectionDetailsReference = jobContext$moduleExecutionSettings$connectionDetailsReference, keyringName = keyringName)
    jobContext$moduleExecutionSettings$connectionDetails <- connectionDetails
} else {
    resultsConnectionDetails <- retrieveConnectionDetails(connectionDetailsReference = jobContext$moduleExecutionSettings$resultsConnectionDetailsReference, keyringName = keyringName)
    jobContext$moduleExecutionSettings$resultsConnectionDetails <- resultsConnectionDetails
}
if (keyringLocked) {
    keyring::keyring_lock(keyring = keyringName)
}
execute(jobContext)
ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE)
ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE)
writeLines("done", "/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/results_folder/CohortGeneratorModule_1/done")
