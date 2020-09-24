% The terms target and distractor are meaningless in this script
% AND NEED TO BE REPLACED 
% But Aenne is lazy and copied code from one-image analyses
% in any case, this is equivalent to simply encoding the positions of
% images where target = upper left image; distractor 1 = upper right;
% distractor 2 = lower left; distractor 3 = lower right

%%
clear
close all
cd .. % get to the parent folder, out of the analysis folder
rootdir = cd;
cd([rootdir '/data/4images/matFiles'])

%% choose whether to look at pre or postcued trials
PrePost_select = 1;

%% load data
files = dir('*.mat');

idCount = 1;

for file = files'
    
    cd([rootdir '/data/4images/matFiles'])
    mat_file = file.name;
    load(mat_file);
    
    
    %% we are only intersted in pre/post-cued, both-image trials here
    pleasure = pleasure(imageCue==5 & prePostCue==PrePost_select);
    targetPleasure = targetPleasure(imageCue==5 & prePostCue==PrePost_select);
    distractorPleasure1 = distractor1Pleasure(imageCue==5 & prePostCue==PrePost_select);
    distractorPleasure2 = distractor2Pleasure(imageCue==5 & prePostCue==PrePost_select);
    distractorPleasure3 = distractor3Pleasure(imageCue==5 & prePostCue==PrePost_select);
    
    nTrials = length(pleasure);
    
    for itter = 1:nTrials
        %% now we leave one trial out for computation of error
        trainPleasure = pleasure;
        trainTarget = targetPleasure;
        trainDistractor1 = distractorPleasure1;
        trainDistractor2 = distractorPleasure2;
        trainDistractor3 = distractorPleasure3;
        
        % set the left out trial to NaN
        trainPleasure(itter) = NaN;
        trainTarget(itter) = NaN;
        trainDistractor1(itter) = NaN;
        trainDistractor2(itter) = NaN;
        trainDistractor3(itter) = NaN;
        
        testPleasure = pleasure(itter);
        testTarget = targetPleasure(itter);
        testDistractor1 = distractorPleasure1(itter);
        testDistractor2 = distractorPleasure2(itter);
        testDistractor3 = distractorPleasure3(itter);
        
        trainDistractors = [trainDistractor1; trainDistractor2; trainDistractor3];
        testDistractors = [testDistractor1; testDistractor2; testDistractor3];
        
        trainAvgShown = nanmean([trainTarget; trainDistractor1; trainDistractor2; trainDistractor3]);
        testAvgShown = mean([testTarget; testDistractor1; testDistractor2; testDistractor3]);
        
        %% for each trial, we need the right target/distractor input information
        cd([rootdir '/analyses/'])
        
        cost_linear = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearModel_simple_4images(parameters, trainTarget, trainDistractors)).^2));
        cost_full_linear = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearModel_4images(parameters, trainTarget, trainDistractors)).^2));
        cost_sortedWeights = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_sortedWeights_4images(parameters, trainTarget, trainDistractors)).^2));
        
        cost_linTrans = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearTransformModel_4images(parameters, [trainTarget; trainDistractors])).^2));
        
        % looks like high-pleasure attenuation is a thing in combined
        % pleasure ratings, too
        cost_highAtt = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_highPleasureAttenuation(parameters, trainAvgShown)).^2));
        
        % Set the number of iterations and other options to optimally use fmin...
        options = optimoptions('fmincon', 'maxIter',10e8, 'maxFunEvals', 10e8, 'TolX', 1e-20); % for disgnostics also include: ,'Display','iter',
        
        % constraints
        lowerBounds = [0 0 0];
        upperBounds = [1 1 1];
        lowerBounds_full = [0 0 0 -9 -9];
        upperBounds_full = [1 1 1 9 9];
        lowerBounds_linTrans = [-9 -9];
        upperBounds_linTrans = [9 9];
        lowerBounds_highAtt = [1 -1];
        upperBounds_highAtt = [9 1];
        
        % set up start values
        startValues = [0.25 0.25 0.25];
        startValues_full = [0.25 0.25 0.25 0 1];
        startValues_linTrans = [0 1];
        startValues_highAtt = [5 1];
        
        % Call the minimization fn, fit, predict, evaluate
        parameters_linear(itter,:) = fmincon(cost_linear, startValues,[],[],[],[],lowerBounds,upperBounds,[],options);
        predictions_linear = predict_linearModel_simple_4images(parameters_linear(itter,:), testTarget, testDistractors);
        [rSquare_linear(itter) RMSE_linear(itter)] = rsquare(testPleasure, predictions_linear);
        
        parameters_full_linear(itter,:) = fmincon(cost_full_linear, startValues_full,[],[],[],[],lowerBounds_full,upperBounds_full,[],options);
        predictions_full_linear = predict_linearModel_4images(parameters_full_linear(itter,:), testTarget, testDistractors);
        [rSquare_linear_full(itter) RMSE_linear_full(itter)] = rsquare(testPleasure, predictions_full_linear);

        parameters_sortedWeights(itter,:) = fmincon(cost_sortedWeights, startValues,[],[],[],[],lowerBounds,upperBounds,[],options);
        predictions_sortedWeights = predict_sortedWeights_4images(parameters_sortedWeights(itter,:), testTarget, testDistractors);
        [rSquare_sortedWeights(itter) RMSE_sortedWeights(itter)] = rsquare(testPleasure, predictions_sortedWeights);
        
        parameters_linTrans(itter,:) = fmincon(cost_linTrans, startValues_linTrans,[],[],[],[],lowerBounds_linTrans,upperBounds_linTrans,[],options);
        predictions_linTrans = predict_linearTransformModel_4images(parameters_linTrans(itter,:), [testTarget; testDistractors]);
        [rSquare_linTrans(itter) RMSE_linTrans(itter)] = rsquare(testPleasure, predictions_linTrans);
        
        parameters_highAtt(itter,:) = fmincon(cost_highAtt, startValues_highAtt,[],[],[],[],lowerBounds_highAtt,upperBounds_highAtt,[],options);
        predictions_highAtt = predict_highPleasureAttenuation(parameters_highAtt(itter,:), testAvgShown);
        [rSquare_highAtt(itter) RMSE_highAtt(itter)] = rsquare(testPleasure, predictions_highAtt);
        
        RMSE_averaging(itter) = sqrt(nanmean((testPleasure - mean([testTarget testDistractors'])).^2));
        
    end
    
    % get summary means and SDs per participant
    avg_parameters_linear(idCount,:) = nanmean(parameters_linear,1);
    avg_parameters_full_linear(idCount,:) = nanmean(parameters_full_linear,1);
    avg_parameters_sortedWeights(idCount,:) = nanmean(parameters_sortedWeights,1);
    avg_parameters_linTrans(idCount,:) = nanmean(parameters_linTrans,1);
    avg_parameters_highAtt(idCount,:) = nanmean(parameters_highAtt,1);
    
    avg_RMSE_linear(idCount) = nanmean(RMSE_linear);
    avg_RMSE_linear_full(idCount) = nanmean(RMSE_linear_full);
    avg_RMSE_sortedWeights(idCount) = nanmean(RMSE_sortedWeights);
    avg_RMSE_linTrans(idCount) = nanmean(RMSE_linTrans);
    avg_RMSE_highAtt(idCount) = nanmean(RMSE_highAtt);
    avg_RMSE_averaging(idCount) = nanmean(RMSE_averaging);
    %
    %     std_parameters_linear(idCount,:) = nanstd(parameters_linear,1);
    std_RMSE_linear(idCount) = nanstd(RMSE_linear);
    std_RMSE_linear_full(idCount) = nanstd(RMSE_linear_full);
    std_RMSE_sortedWeights(idCount) = nanstd(RMSE_sortedWeights);
    std_RMSE_linTrans(idCount) = nanstd(RMSE_linTrans);
    std_RMSE_highAtt(idCount) = nanstd(RMSE_highAtt);
    std_RMSE_averaging(idCount) = nanstd(RMSE_averaging);
    %
    idCount = idCount+1;
end

% %% plot an RMSE overview
% figure(1); clf; hold on; box off;
% plot(avg_RMSE_linear)
% plot(avg_RMSE_linear_full)
% plot(avg_RMSE_sortedWeights)
% plot(avg_RMSE_linTrans)
% plot(avg_RMSE_averaging)
% legend({'linear (by position simplified)', 'linear (by position)',...
%     'linear (by baseline pleasure)', 'linear transformation', 'averaging'})
% xlabel('Participant #')
% ylabel('Average RMSE')

%% for the purpose of an easy copy-past to Excel overview table, create a results matrix
% table format (no matter how clumsy) for storage in .mat format
results_table = table(avg_RMSE_averaging', 'VariableNames', {'rmse_averaging'});
results_table.rmse_linear = avg_RMSE_linear';
results_table.rmse_linear_full = avg_RMSE_linear_full';
results_table.rmse_linear_sorted_by_pleasure = avg_RMSE_sortedWeights';
results_table.rmse_linear_transformation = avg_RMSE_linTrans';
results_table.rmse_highAttenuation = avg_RMSE_highAtt';

results_table.parameter_w1_linear = avg_parameters_linear(:,1);
results_table.parameter_w2_linear = avg_parameters_linear(:,2);
results_table.parameter_w3_linear = avg_parameters_linear(:,3);
results_table.parameter_w1_linear_sorted_by_pleasure = avg_parameters_sortedWeights(:,1);
results_table.parameter_w2_linear_sorted_by_pleasure = avg_parameters_sortedWeights(:,2);
results_table.parameter_w3_linear_sorted_by_pleasure = avg_parameters_sortedWeights(:,3);
results_table.parameter_w1_linear_full = avg_parameters_full_linear(:,1);
results_table.parameter_w2_linear_full = avg_parameters_full_linear(:,2);
results_table.parameter_w3_linear_full = avg_parameters_full_linear(:,3);
results_table.parameter_a_linear_full = avg_parameters_full_linear(:,4);
results_table.parameter_b_linear_full = avg_parameters_full_linear(:,5);
results_table.parameter_a_linear_transformation = avg_parameters_linTrans(:,1);
results_table.parameter_b_linear_transformation = avg_parameters_linTrans(:,2);
results_table.parameter_Pbeau_highAttenuation = avg_parameters_highAtt(:,1);
results_table.parameter_gain_highAttenuation = avg_parameters_highAtt(:,2);

% also save this result matrix
if PrePost_select==1
    save('loocv_results_precued_combinedPleasure.mat', 'results_table');
else
    save('loocv_results_postcued_combinedPleasure', 'results_table');
end
