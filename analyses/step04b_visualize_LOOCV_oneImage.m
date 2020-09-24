% Let us take a look at the results from the LOOCV results for one-image
% ratings.
% plot the goodness of fit as well as the predicted rating patterns

%% start with a clean environment
clc
clear
close all

%% load the results
load loocv_results_precued_onePleasure

%% first, let's calculate means + SEs for RMSEs
n = size(results_table,1);

avg_faithful = mean(results_table.rmse_faithful);
avg_meanBias = mean(results_table.rmse_meanBias);
avg_linear = mean(results_table.rmse_linear);
avg_linear_simple = mean(results_table.rmse_linear_simple);
avg_ordered_pos = mean(results_table.rmse_ordered_by_position);
avg_ordered_pleas = mean(results_table.rmse_ordered_by_pleasure);
means = [avg_faithful avg_meanBias avg_linear avg_linear_simple avg_ordered_pos avg_ordered_pleas];

se_faithful = std(results_table.rmse_faithful)/sqrt(n);
se_meanBias = std(results_table.rmse_meanBias)/sqrt(n);
se_linear = std(results_table.rmse_linear)/sqrt(n);
se_linear_simple = std(results_table.rmse_linear_simple)/sqrt(n);
se_ordered_pos = std(results_table.rmse_ordered_by_position)/sqrt(n);
se_ordered_pleas = std(results_table.rmse_ordered_by_pleasure)/sqrt(n);
ses = [se_faithful se_meanBias se_linear se_linear_simple se_ordered_pos se_ordered_pleas];

% let's plot that
figure(1);clf; hold on; box off;
errorbar(1:6, means, ses, 'o');
axis([.5 6.5 0 3]);
set(gca, 'xtick', 1:6, 'fontsize',12)
xticklabels({'faithful','mean bias',...
    'linear','simplified linear',...
    'ordered by position','ordered by beasline pleasure'})
xtickangle(45)
ylabel('Mean RMSE')

%% plot model predictions based on the average parameter values
avg_parameters_meanBias = mean(results_table{:,8});
avg_parameters_linear_simple = mean(results_table{:,9:11});
avg_parameters_linear = mean(results_table{:,12:16});
avg_parameters_linear_ordered_by_position = mean(results_table{:,17:20});
avg_parameters_linear_ordered_by_pleasure = mean(results_table{:,21:24});

ratings = 1:9;

for image1 = ratings
    for image2 = ratings
        for image3 = ratings
            for image4 = ratings
                
                pred_meanBias(image1,image2,image3,image4) = ...
                    predict_meanBias_4images(avg_parameters_meanBias,...
                    image1, [image2; image3; image4]);
                pred_linear_simple(image1,image2,image3,image4) = ...
                    predict_linearModel_simple_4images(avg_parameters_linear_simple, ...
                    image1, [image2; image3; image4]);
                pred_linear(image1,image2,image3,image4) = ...
                    predict_linearModel_4images(avg_parameters_linear, ...
                    image1, [image2; image3; image4]);
                
                ordered_distractors = sort([image2; image3; image4]);
                pred_linear_ordered_by_pleasure(image1,image2,image3,image4) = ...
                    predict_linearModel_ordered_4images(avg_parameters_linear_ordered_by_pleasure, ...
                    image1, ordered_distractors);
                
            end
        end
    end
end

%% now we have to extract means from the above complete predictions for all possible cases
for target = ratings
    for distractor = ratings
        
        pred_faithful(distractor, target) = target;
        pred_averaging(distractor, target) = mean([distractor target]);
        
        avg_pred_meanBias(distractor, target) = ...
            squeeze(mean(pred_meanBias(target,distractor,:)));
        avg_pred_linear_simple(distractor, target) = ...
            squeeze(mean(pred_linear_simple(target,distractor,:)));
        avg_pred_linear(distractor, target) = ...
            squeeze(mean(pred_linear(target,distractor,:)));
        avg_pred_linear_ordered_by_pleasure(distractor, target) = ...
            squeeze(mean(pred_linear_ordered_by_pleasure(target,distractor,:)));
        
    end
end

%% now plot the predictions (we only have to do this per target position for
% the linear model that assumes an impact of the image positions

lim = [1 9]; % set a common scale 1-9 for comparable plots across models

figure(1); clf;
subplot(2,3,1)
imagesc(pred_faithful, lim)
colorbar
xlabel('Target pleasure')
ylabel('Distractor pleasure')
set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
title('Predictions faithful model')

subplot(2,3,2)
imagesc(avg_pred_meanBias, lim)
colorbar
xlabel('Target pleasure')
ylabel('Distractor pleasure')
set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
title('Predictions best fit mean bias model')

subplot(2,3,3)
imagesc(avg_pred_linear_simple, lim)
colorbar
xlabel('Target pleasure')
ylabel('Distractor pleasure')
set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
title('Predictions best fit simplified linear model')

subplot(2,3,4)
imagesc(avg_pred_linear, lim)
colorbar
xlabel('Target pleasure')
ylabel('Distractor pleasure')
set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
title('Predictions best fit linear model')

subplot(2,3,5)
imagesc(avg_pred_linear_ordered_by_pleasure, lim)
colorbar
xlabel('Target pleasure')
ylabel('Distractor pleasure')
set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
title('Predictions best fit linear model ordered by baseline pleasure')

subplot(2,3,6)
imagesc(pred_averaging, lim)
colorbar
xlabel('Target pleasure')
ylabel('Distractor pleasure')
set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
title('Predictions averaging model')

%% Maybe the easiest, best thing to do is just a predictions vs data plot (per participant)
