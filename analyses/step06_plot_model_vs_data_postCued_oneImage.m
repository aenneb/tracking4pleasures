% After we have fit and evaluated all the models, let's check on the fit by
% plotting the best model's predictions against the data

%%
clear
close all

%% we load results from the model fitting from the current folder
%  !!! Make sure that this is PRE or POST cued based on which trials we
%  plot
load loocv_results_postcued_onePleasure
% the relevant parameters for one-image trials are the ones for
% faithful (no parameters) for one-image precued
% high attenuation for one-image postcued
% full linear model for all combined-pleasure trials

%%
cd .. % get to the parent folder, out of the analysis folder
rootdir = cd;
cd([rootdir '/data/4images/matFiles'])

%% load data
files = dir('*.mat');

idCount = 1;

for file = files'
    
    cd([rootdir '/data/4images/matFiles'])
    mat_file = file.name;
    load(mat_file);
    
    % for generating predictions, we need to get back to the analysis
    % folder
    cd([rootdir '/analyses'])
    % select the appropriate trials
    % and let's again condense this a little because otherwise the
    % visualization is horrid
    for target = 1:9
        if sum(imageCue<5 & prePostCue==2 & targetPleasure==target)>0
            observed(idCount,target) = nanmean(pleasure(imageCue<5 &...
                prePostCue==2 & targetPleasure==target));
            
            % for one-image postcued, predictions come from the high
            % attenuation model
            P_beau = results_table.parameter_Pbeau_highAtt(idCount);
            gain = results_table.parameter_gain_highAtt(idCount);
            trial_predictions = predict_highPleasureAttenuation([P_beau gain],...
                targetPleasure(imageCue<5 & prePostCue==2 & targetPleasure==target));
            predicted(idCount,target) = nanmean(trial_predictions);
        else
            observed(idCount,target) = NaN;
            predicted(idCount,target) = NaN;
        end
    end
        
        idCount = idCount+1;
    end
    
    %% Plot data vs. predictions
    figure(1); clf; hold on; box off; axis square;
    scatter(observed(:), predicted(:), 'o', 'jitter', 'on')
    plot(1:9, 1:9, '-k')
    axis([1 9 1 9])
    xlabel('Data'); ylabel('Model'); title('Average rating per target pleasure');
