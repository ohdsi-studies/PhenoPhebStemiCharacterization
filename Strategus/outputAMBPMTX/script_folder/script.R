analysisSpecificationsFileName <- '/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/script_folder/analysisSpecifications.rds'
executionSettingsFileName <- '/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/script_folder/executionSettings.rds'
keyringSettingsFileName <- '/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/script_folder/keyringSettings.rds'
moduleToTargetNamesFileName <- '/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/script_folder/moduleTargetNames.rds'
dependenciesFileName <- '/home/mbrand2/PhenoPheb_STEMI_Characterization_new/Strategus/output/script_folder/dependencies.rds'
execResultsUpload <- 'FALSE'
library(targets)
analysisSpecificationsLoad <- readRDS(analysisSpecificationsFileName)
moduleToTargetNames <- readRDS(moduleToTargetNamesFileName)
dependencies <- readRDS(dependenciesFileName)
targets::tar_option_set(packages = c("Strategus", "keyring"), 
    imports = c("Strategus", "keyring"))
targetList <- list(targets::tar_target(analysisSpecifications, 
    readRDS(analysisSpecificationsFileName)), targets::tar_target(executionSettings, 
    readRDS(executionSettingsFileName)), targets::tar_target(keyringSettings, 
    readRDS(keyringSettingsFileName)))
for (i in 1:length(analysisSpecificationsLoad$moduleSpecifications)) {
    moduleSpecification <- analysisSpecificationsLoad$moduleSpecifications[[i]]
    targetName <- sprintf("%s_%d", moduleSpecification$module, 
        i)
    dependencyModules <- dependencies[dependencies$module == 
        moduleSpecification$module, ]$dependsOn
    dependencyTargetNames <- moduleToTargetNames[moduleToTargetNames$module %in% 
        dependencyModules, ]$targetName
    targetList[[length(targetList) + 1]] <- targets::tar_target_raw(targetName, 
        substitute(Strategus:::runModule(analysisSpecifications, 
            keyringSettings, i, executionSettings), env = list(i = i)), 
        deps = c("analysisSpecifications", "keyringSettings", 
            "executionSettings", dependencyTargetNames))
    if (execResultsUpload) {
        resultsTargetName <- paste0(targetName, "_results_upload")
        targetList[[length(targetList) + 1]] <- targets::tar_target_raw(resultsTargetName, 
            substitute(Strategus:::runResultsUpload(analysisSpecifications, 
                keyringSettings, i, executionSettings), env = list(i = i)), 
            deps = c("analysisSpecifications", "keyringSettings", 
                "executionSettings", targetName))
    }
}
targetList
