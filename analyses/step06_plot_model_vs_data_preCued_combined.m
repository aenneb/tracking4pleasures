% After we have fit and evaluated all the models, let's check on the fit by
% plotting the best model's predictions against the data

%%
clear
close all

%% we load results from the model fitting from the current folder
%  !!! Make sure that this is PRE or POST cued based on which trials we
%  plot
load loocv_results_precued_combinedPleasure
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
    
    % for the combined trials, it's easier to select trials if we have a
    % variable that reflects the average pleasure of the images displayed
    avg_shown = mean([targetPleasure; distractor1Pleasure; distractor2Pleasure;...
        distractor3Pleasure]);
    
    % select the appropriate trials
    % and let's again condense this a little because otherwise the
    % visualization is horrid
    for target = 1:9
        trial_select = imageCue==5 & prePostCue==1 & avg_shown>=target & avg_shown<(target+1);
        if sum(trial_select)>0
            observed(idCount,target) = nanmean(pleasure(trial_select));
            
            % for combined pleasure trials,the linear transformation model
            % is best
            model_parameters = results_table{idCount,18:19};
            
            trial_predictions = model_parameters(1) + model_parameters(2).*avg_shown(trial_select);
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
