Characterization of acute ST elevation myocardial infarction (STEMI) patients
=================

<img src="https://img.shields.io/badge/Study%20Status-Started-blue.svg" alt="Study Status: Started"> 

* Analytics use case(s): Clinical Application
* Study type: Characterization
* Tags: Acute STEMI, Myocardial infarction
* Study lead:  Milou Brand, Atif Adam, and Mirza Khan
* Study lead forums tag: [[mbrand]](https://forums.ohdsi.org/u/[mbrand])
* Study start date: [01] [03], [2024]
* Study end date: -
* Protocol: [[protocol here]](https://github.com/milou-brand/PhenoPheb_STEMI_Characterization/tree/master/Protocol)
* Publications: -
* Results explorer: -

**Decription**: Given the acuity and “need for speed” in treating acute STEMI cases, accurate and scalable generalizable identification, characterization, and current incidence of STEMI in multi-country real-world data has many benefits. For example, informing on resource allocation, campaigns to improve heart attack recognition, cardiovascular health, and risk factor modification, etc. This comprehensive study aims to understand STEMI patients’ characteristics and identify the incidence rates across multiple real-world data datasets.    

The idea is to publish this study in OHDSI symposiums as well as other cardiology journals.

### To run this analytical package
Please see "Instructions and tips.PPTX" for more information on how-to run the package and tips for frequently encountered problems. 

This package uses the OHDSI Strategus framework for execution. Once you have started the project, you should have a Strategus home directory, housing the strategus modules.
The reason for this is the way strategus runs, each module runs within its own project/working directory. This centralises the packages each module uses, and means your overall system library has no actual bearing on the project because of the way the processes are run.

### To Execute
Enter the CodeToRun.R file, review the variables for completion, lines 1-34. 

Source the file and wait. Execution time is dependent on Database speed. 

Package installation and updates may require user input to fully upgrade the environment.

If Keyring:: or secretservice errors occur, first please ensure that:
  Run in a terminal the following before installing keyring 
  (may be different depending on linux flavour)
  for reference [Keyring Secret handling](https://r-lib.github.io/keyring/index.html#linux):
  
```
sudo yum install libsodium libsodium-devel 
sudo yum install libsecret libsecret-devel
sudo chmod 777 /home/idies/.config 
```

