% try to model complete data per participant with different cues for
% pre-post and both cued conditions
% as for now, use simple lienar model only.

%% start with a clean environment
clc
clear
close all

%% directories
cd .. % get to the parent folder, out of the analysis folder
rootdir = cd;
cd([rootdir '/data/4images/matFiles'])

%% select whether to fit pre- or post-cued trials
PrePost_select = 2;

%% select the right folder with all pre-processed data and load it
files = dir('*.mat');

idCount = 1;

for file = files'
    
    cd([rootdir '/data/4images/matFiles'])
    mat_file = file.name;
    load(mat_file);
    
    
    %% we are only intersted in pre-cued, one-image trials here
    pleasure = pleasure(imageCue<5 & prePostCue==PrePost_select);
    targetPleasure = targetPleasure(imageCue<5 & prePostCue==PrePost_select);
    distractorPleasure1 = distractor1Pleasure(imageCue<5 & prePostCue==PrePost_select);
    distractorPleasure2 = distractor2Pleasure(imageCue<5 & prePostCue==PrePost_select);
    distractorPleasure3 = distractor3Pleasure(imageCue<5 & prePostCue==PrePost_select);
    upperLeftPleasure = upperLeftPleasure(imageCue<5 & prePostCue==PrePost_select);
    upperRightPleasure = upperRightPleasure(imageCue<5 & prePostCue==PrePost_select);
    lowerLeftPleasure = lowerLeftPleasure(imageCue<5 & prePostCue==PrePost_select);
    lowerRightPleasure = lowerRightPleasure(imageCue<5 & prePostCue==PrePost_select);
    
    nTrials = length(pleasure);
    
    for itter = 1:nTrials
        %% now we leave one trial out for computation of error
        trainPleasure = pleasure;
        trainTarget = targetPleasure;
        trainDistractor1 = distractorPleasure1;
        trainDistractor2 = distractorPleasure2;
        trainDistractor3 = distractorPleasure3;
        trainPleasure_ul = upperLeftPleasure;
        trainPleasure_ur = upperRightPleasure;
        trainPleasure_ll = lowerLeftPleasure;
        trainPleasure_lr = upperRightPleasure;
        
        % set the left out trial to NaN
        trainPleasure(itter) = NaN;
        trainTarget(itter) = NaN;
        trainDistractor1(itter) = NaN;
        trainDistractor2(itter) = NaN;
        trainDistractor3(itter) = NaN;
        trainPleasure_ul(itter) = NaN;
        trainPleasure_ur(itter) = NaN;
        trainPleasure_ll(itter) = NaN;
        trainPleasure_lr(itter) = NaN;
        
        testPleasure = pleasure(itter);
        testTarget = targetPleasure(itter);
        testDistractor1 = distractorPleasure1(itter);
        testDistractor2 = distractorPleasure2(itter);
        testDistractor3 = distractorPleasure3(itter);
        testPleasure_ul = upperLeftPleasure(itter);
        testPleasure_ur = upperRightPleasure(itter);
        testPleasure_ll = lowerLeftPleasure(itter);
        testPleasure_lr = lowerRightPleasure(itter);
        
        %% for each trial, we need the right target/distractor input information
        trainDistractors = [trainDistractor1; trainDistractor2; trainDistractor3];
        testDistractors = [testDistractor1; testDistractor2; testDistractor3];
        
        trainPleasures_ordered_by_position = [trainPleasure_ul; trainPleasure_ur; trainPleasure_ll; trainPleasure_lr];
        testPleasures_ordered_by_position = [testPleasure_ul; testPleasure_ur; testPleasure_ll; testPleasure_lr];
        
        trainPleasures_ordered_by_pleasure = sort(trainDistractors);
        testPleasures_ordered_by_pleasure = sort([testDistractor1; testDistractor2; testDistractor3]);
        %% continue with the fitting procedure
        % change working directory to access the model fctns
        cd([rootdir '/analyses'])
        
        % set up cost fctn for each model
        cost_linear = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearModel_4images(parameters, trainTarget, trainDistractors)).^2));
        cost_linear_simple = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearModel_simple_4images(parameters, trainTarget, trainDistractors)).^2));
        
        cost_linear_ordered_by_position = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearModel_ordered_4images(parameters, trainTarget, trainPleasures_ordered_by_position)).^2));
        
        cost_linear_ordered_by_pleasure = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_linearModel_ordered_4images(parameters, trainTarget, trainPleasures_ordered_by_pleasure)).^2));
        
        cost_meanBias = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_meanBias_4images(parameters, trainTarget, trainDistractors)).^2));
        
        cost_highAtt = @(parameters) sqrt(nanmean((trainPleasure - ...
            predict_highPleasureAttenuation(parameters, trainTarget)).^2));
        
        % Set the number of iterations and other options to optimally use fmin...
        options = optimoptions('fmincon', 'maxIter',10e8, 'maxFunEvals', 10e8, 'TolX', 1e-20); % for disgnostics also include: ,'Display','iter',
        
        % constraints
        lowerBounds_simple = [0 0 0];
        upperBounds_simple = [1 1 1];
        lowerBounds_ordered = [0 0 0 0];
        upperBounds_ordered = [1 1 1 1];
        lowerBounds = [0 0 0 -9 -9];
        upperBounds = [1 1 1 9 9];
        lowerBounds_meanBias = [0];
        upperBounds_meanBias = [1];
        lowerBounds_highAtt = [1 -1];
        upperBounds_highAtt = [9 1];
        
        % plausible start values
        startValues_simple = [0.1 0.1 0.1];
        startValues_ordered = [0.1 0.1 0.1 0.1];
        startValues = [0.1 0.1 0.1 0 1];
        startValues_meanBias = [0.5];
        startValues_highAtt = [5 1];
        
        % Call the minimization fn
        parameters_linear(itter,:) = fmincon(cost_linear, startValues,...
            [],[],[],[],lowerBounds,upperBounds,[],options);
        parameters_linear_simple(itter,:) = fmincon(cost_linear_simple, startValues_simple,...
            [],[],[],[],lowerBounds_simple,upperBounds_simple,[],options);
        parameters_linear_ordered_by_position(itter,:) = fmincon(cost_linear_ordered_by_position,...
            startValues_ordered,[],[],[],[],lowerBounds_ordered,upperBounds_ordered,[],options);
        parameters_linear_ordered_by_pleasure(itter,:) = fmincon(cost_linear_ordered_by_pleasure,...
            startValues_ordered,[],[],[],[],lowerBounds_ordered,upperBounds_ordered,[],options);
        parameters_meanBias(itter,:) = fmincon(cost_meanBias, startValues_meanBias,...
            [],[],[],[],lowerBounds_meanBias,upperBounds_meanBias,[],options);
        parameters_highAtt(itter,:) = fmincon(cost_highAtt, startValues_highAtt,...
            [],[],[],[],lowerBounds_highAtt,upperBounds_highAtt,[],options);
        
        % generate predictions based on test pleasure
        predictions_linear = predict_linearModel_4images(parameters_linear(itter,:),...
            testTarget, testDistractors);
        predictions_linear_simple = predict_linearModel_simple_4images(parameters_linear_simple(itter,:),...
            testTarget, testDistractors);
        predictions_linear_ordered_by_position = ...
            predict_linearModel_ordered_4images(parameters_linear_ordered_by_position(itter,:),...
            testTarget, testPleasures_ordered_by_position);
        predictions_linear_ordered_by_pleasure = ...
            predict_linearModel_ordered_4images(parameters_linear_ordered_by_pleasure(itter,:),...
            testTarget, testPleasures_ordered_by_pleasure);
        predictions_meanBias = predict_meanBias_4images(parameters_meanBias(itter,:),...
            testTarget, testDistractors);
        predictions_highAtt = predict_highPleasureAttenuation(parameters_highAtt(itter,:),...
            testTarget);
        
        % r-square can be ignored here - one data point to test is not
        % enough to compute it.
        [~, RMSE_linear(itter)] =...
            rsquare(testPleasure, predictions_linear);
        [~, RMSE_linear_simple(itter)] =...
            rsquare(testPleasure, predictions_linear_simple);
        [~, RMSE_linear_ordered_by_position(itter)] =...
            rsquare(testPleasure, predictions_linear_ordered_by_position);
        [~, RMSE_linear_ordered_by_pleasure(itter)] =...
            rsquare(testPleasure, predictions_linear_ordered_by_pleasure);
        [~, RMSE_meanBias(itter)] =...
            rsquare(testPleasure, predictions_meanBias);
        [~, RMSE_highAtt(itter)] =...
            rsquare(testPleasure, predictions_highAtt);
        
        [~, RMSE_accurate(itter)] = rsquare(testPleasure, testTarget);
        [~, RMSE_averaging(itter)] = rsquare(testPleasure, mean([testTarget testDistractors']));
        
    end
    
    % get summary means per participant
    avg_parameters_linear(idCount,:) = nanmean(parameters_linear,1);
    avg_parameters_linear_simple(idCount,:) = nanmean(parameters_linear_simple,1);
    avg_parameters_linear_ordered_by_position(idCount,:) =...
        nanmean(parameters_linear_ordered_by_position,1);
    avg_parameters_linear_ordered_by_pleasure(idCount,:) =...
        nanmean(parameters_linear_ordered_by_pleasure,1);
    avg_parameters_meanBias(idCount,:) = nanmean(parameters_meanBias,1);
    avg_parameters_highAtt(idCount,:) = nanmean(parameters_highAtt,1);
    
    avg_RMSE_linear(idCount) = nanmean(RMSE_linear);
    avg_RMSE_linear_simple(idCount) = nanmean(RMSE_linear_simple);
    avg_RMSE_linear_ordered_by_position(idCount) = ...
        nanmean(RMSE_linear_ordered_by_position);
    avg_RMSE_linear_ordered_by_pleasure(idCount) = ...
        nanmean(RMSE_linear_ordered_by_pleasure);
    avg_RMSE_meanBias(idCount) = nanmean(RMSE_meanBias);
    avg_RMSE_highAtt(idCount) = nanmean(RMSE_highAtt);
    avg_RMSE_accurate(idCount) = nanmean(RMSE_accurate);
    avg_RMSE_averaging(idCount) = nanmean(RMSE_averaging);
    
    % also compute the SDs to go with it, here
    std_parameters_linear(idCount,:) = nanstd(parameters_linear,1);
    std_parameters_linear_simple(idCount,:) = nanstd(parameters_linear_simple,1);
    std_parameters_linear_ordered_by_position(idCount,:) =...
        nanstd(parameters_linear_ordered_by_position,1);
    std_parameters_linear_ordered_by_pleasure(idCount,:) =...
        nanstd(parameters_linear_ordered_by_pleasure,1);
    std_parameters_meanBias(idCount,:) = nanstd(parameters_meanBias,1);
    std_parameters_highAtt(idCount,:) = nanstd(parameters_highAtt,1);
    
    std_RMSE_linear(idCount) = nanstd(RMSE_linear);
    std_RMSE_linear_simple(idCount) = nanstd(RMSE_linear_simple);
    std_RMSE_linear_ordered_by_position(idCount) =...
        nanstd(RMSE_linear_ordered_by_position);
    std_RMSE_linear_ordered_by_pleasure(idCount) =...
        nanstd(RMSE_linear_ordered_by_pleasure);
    std_RMSE_meanBias(idCount) = nanstd(RMSE_meanBias);
    std_RMSE_highAtt(idCount) = nanstd(RMSE_highAtt);
    std_RMSE_accurate(idCount) = nanstd(RMSE_accurate);
    std_RMSE_averaging(idCount) = nanstd(RMSE_averaging);
    
    idCount = idCount+1;
end

%% plot an RMSE overview
figure(1); clf; hold on; box off;
plot(avg_RMSE_accurate)
plot(avg_RMSE_meanBias)
plot(avg_RMSE_highAtt)
plot(avg_RMSE_linear)
plot(avg_RMSE_linear_simple)
plot(avg_RMSE_linear_ordered_by_position)
plot(avg_RMSE_linear_ordered_by_pleasure)
plot(avg_RMSE_averaging)
legend({'accurate', 'mean bias', 'high attenuation', 'linear', 'linear simplified',...
    'linear position ordered','linear pleasure oredered','averaging'})
xlabel('Participant #')
ylabel('Average RMSE')
axis([0 25 0 4])

%% for the purpose of an easy copy-past to Excel overview table, create a results matrix
% table format (no matter how clumsy) for storage in .mat format
results_table = table(avg_RMSE_accurate', 'VariableNames', {'rmse_faithful'});
results_table.rmse_meanBias = avg_RMSE_meanBias';
results_table.rmse_highAtt = avg_RMSE_highAtt';
results_table.rmse_linear = avg_RMSE_linear';
results_table.rmse_linear_simple = avg_RMSE_linear_simple';
results_table.rmse_ordered_by_position = avg_RMSE_linear_ordered_by_position';
results_table.rmse_ordered_by_pleasure = avg_RMSE_linear_ordered_by_pleasure';
results_table.rmse_averaging = avg_RMSE_averaging';

results_table.parameter_w_meanBias = avg_parameters_meanBias;
results_table.parameter_Pbeau_highAtt = avg_parameters_highAtt(:,1);
results_table.parameter_gain_highAtt = avg_parameters_highAtt(:,2);
results_table.parameter_w1_linear_simple = avg_parameters_linear_simple(:,1);
results_table.parameter_w2_linear_simple = avg_parameters_linear_simple(:,2);
results_table.parameter_w3_linear_simple = avg_parameters_linear_simple(:,3);
results_table.parameter_w1_linear = avg_parameters_linear(:,1);
results_table.parameter_w2_linear = avg_parameters_linear(:,2);
results_table.parameter_w3_linear = avg_parameters_linear(:,3);
results_table.parameter_a_linear = avg_parameters_linear(:,4);
results_table.parameter_b_linear = avg_parameters_linear(:,5);
results_table.parameter_w1_linear_ordered_by_position = avg_parameters_linear_ordered_by_position(:,1);
results_table.parameter_w2_linear_ordered_by_position = avg_parameters_linear_ordered_by_position(:,2);
results_table.parameter_w3_linear_ordered_by_position = avg_parameters_linear_ordered_by_position(:,3);
results_table.parameter_w4_linear_ordered_by_position = avg_parameters_linear_ordered_by_position(:,4);
results_table.parameter_w1_linear_ordered_by_pleasure = avg_parameters_linear_ordered_by_pleasure(:,1);
results_table.parameter_w2_linear_ordered_by_pleasure = avg_parameters_linear_ordered_by_pleasure(:,2);
results_table.parameter_w3_linear_ordered_by_pleasure = avg_parameters_linear_ordered_by_pleasure(:,3);
results_table.parameter_w4_linear_ordered_by_pleasure = avg_parameters_linear_ordered_by_pleasure(:,4);

% also save this result matrix
if PrePost_select==1
    save('loocv_results_precued_onePleasure.mat', 'results_table');
else
    save('loocv_results_postcued_onePleasure', 'results_table');
end