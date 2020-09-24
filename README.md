# tracking4pleasures
Experiment materials, code, data, and supporting files for a follow-up study on Brielmann &amp; Pelli (2020).
Materials and methods follow the one of this previous study but extends the protocol from 2 to 4 images.



Reference:
Brielmann, A. A., & Pelli, D. G. (under review). the pelasure of multiple images. Attention, Perception, & Psychophysics

## Folder structure

### analyses
Contains all .m analysis files used to obtain the results reported in the main article

### csv_data
Sadly slightly mis-named - contains the .txt raw data files for researchers without access to matlab

### data
Contains the complete data of all participants in .mat format for convenience. Analyses are based on these data files (except for step 01 which extracts the data from csv or xls files)

### results
Detailed results for all LOOCV analyses. Each .mat table contains the RMSE and parameter values of the best fit for each model and each participant. Column names indicate content of that column, each row is one participant (in alphabetical file name order).

## Additional files
baselineImageInformation.mat contains average ratings, file names, etc. for all 36 OASIS images used in the main experiment
