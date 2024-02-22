Thread: Main
Message:  
Level:  FATAL
Time:  2024-02-07 15:14:13

Stack trace:
12: h(simpleError(msg, call))
11: .handleSimpleError(function (condition) 
{
    if (is(condition, "error")) {
 
10: CohortConstruction.R#342: stop()
9: value[[3]](cond)
8: tryCatchOne(expr, names, parentenv, handlers[[1]])
7: tryCatchList(expr, classes, parentenv, handlers)
6: CohortConstruction.R#328: tryCatch(expr = {
    startTime <- lubridate::now(
5: FUN(X[[i]], ...)
4: lapply(x, fun, ...)
3: CohortConstruction.R#165: ParallelLogger::clusterApply(cluster, cohortsToGe
2: CohortGenerator::generateCohortSet(connection = connection, cohortDefinitio
1: execute(jobContext)

R version:
R version 4.2.1 (2022-06-23)

Platform:
x86_64-pc-linux-gnu

Attached base packages:
- stats
- graphics
- grDevices
- datasets
- utils
- methods
- base

Other attached packages:
- RSQLite (2.3.0)
- SqlRender (1.15.2)
- ParallelLogger (3.1.0)
- keyring (1.3.1)
- CohortGenerator (0.8.0)
- R6 (2.5.1)
- DatabaseConnector (6.2.3)


