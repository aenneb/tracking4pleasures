# tracking4pleasures
Experiment materials, code, data, and supporting files for a follow-up study on [Brielmann &amp; Pelli (2020)](https://link.springer.com/article/10.3758/s13423-019-01695-6).
Materials and methods follow the one of this previous study but extends the protocol from 2 to 4 images.



Reference:
Brielmann, A. A., & Pelli, D. G. (2021). [The pleasure of multiple images](https://link.springer.com/article/10.3758/s13414-020-02175-z). Attention, Perception, & Psychophysics, 83(3), 1179-1188.

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
