% Let us check in on some simple descriptives about the one- and combined
% pleasure trials
% get accuracy, variance, etc., per participant

%% start with a clean environment
clc
clear
close all

%% directories
cd .. % get to the parent folder, out of the analysis folder
rootdir = cd;
cd([rootdir '/data/4images/matFiles'])

%% select the right folder with all pre-processed data and load it
files = dir('*.mat');

idCount = 1;

% loop though all participants
for file = files'
    
    cd([rootdir '/data/4images/matFiles'])
    mat_file = file.name;
    load(mat_file);
    
    % For oneImage trials, get the mean "error" pre and post cued
    for target = 1:9
        diff_rate_baseline_precued(idCount,target) = ...
            nanmean(pleasure(prePostCue==1 & imageCue<5 & targetPleasure==target)...
            - targetPleasure(prePostCue==1 & imageCue<5 & targetPleasure==target));
        diff_rate_baseline_postcued(idCount,target) = ...
            nanmean(pleasure(prePostCue==2 & imageCue<5 & targetPleasure==target)...
            - targetPleasure(prePostCue==2 & imageCue<5 & targetPleasure==target));
        
        % also get sd per target pleasure
        
        sd_oneImageRating_precued(idCount, target) = ...
            std(pleasure(prePostCue==1 & imageCue<5 & targetPleasure==target));
        sd_oneImageRating_postcued(idCount, target) = ...
            std(pleasure(prePostCue==2 & imageCue<5 & targetPleasure==target));
    end
    
    % for both-image trials, things are a bit more complex
    % we take all possible occurring expected means and loop through those
    % to make the data a bit more digestible, chose a bin-size of 1
    % all measures NaN if that particular mean did not occur for that
    % participant
    pleasure_allImagesShown =...
        [targetPleasure; distractor1Pleasure; distractor2Pleasure; distractor3Pleasure];
    avgShown = mean(pleasure_allImagesShown);
    
    for target_avg = 1:9
        
        trials_precued = prePostCue==1 & imageCue==5 & ...
            mean(pleasure_allImagesShown) >= target_avg &...
            (target_avg+1) > mean(pleasure_allImagesShown);
        trials_postcued = prePostCue==2 & imageCue==5 & ...
            mean(pleasure_allImagesShown) >= target_avg &...
            (target_avg+1) > mean(pleasure_allImagesShown);
        
        % let us look at the average difference here only.
        % Do not use absolute difference but simple average
        avg_diff_rate_avgShown_precued(idCount, target_avg) = ...
            mean(pleasure(trials_precued) - avgShown(trials_precued));
        avg_diff_rate_avgShown_postcued(idCount, target_avg) = ...
            mean(pleasure(trials_postcued) - avgShown(trials_postcued));
        
        if sum(trials_precued)>1
            sd_rate_avgShown_precued(idCount, target_avg) = ...
                std(pleasure(trials_precued));
        else
            sd_rate_avgShown_precued(idCount, target_avg) = NaN;
        end
        
        if sum(trials_postcued)>1
            sd_rate_avgShown_postcued(idCount, target_avg) = ...
                std(pleasure(trials_postcued));
        else
            sd_rate_avgShown_postcued(idCount, target_avg) = NaN;
        end
        
    end
    
    idCount = idCount+1;
end

%% get averages per participant, where appropriate
avg_diff_precued_oneImage = nanmean(diff_rate_baseline_precued,2);
avg_diff_postcued_oneImage = nanmean(diff_rate_baseline_postcued,2);

avg_diff_precued_combined = nanmean(avg_diff_rate_avgShown_precued,2);
avg_diff_postcued_combined = nanmean(avg_diff_rate_avgShown_postcued,2);

avg_sd_precued_oneImage = nanmean(sd_oneImageRating_precued,2);
avg_sd_postcued_oneImage = nanmean(sd_oneImageRating_postcued,2);

avg_sd_precued_combined = nanmean(sd_rate_avgShown_precued,2);
avg_sd_postcued_combined = nanmean(sd_rate_avgShown_postcued,2);

%% plot the relation between mean errors
figure(1); clf;

subplot(2,2,1); hold on; axis square; box off;
plot(avg_diff_precued_oneImage, avg_diff_postcued_oneImage, 'o')
xlabel('Average Error Precued One-image'); ylabel('Average Error Postcued One-image');
title('One-image ratings')
plot(-4:4, -4:4, '--')
plot([0 0], [-4 4], ':')
plot([-4 4], [0 0], ':')
% test whether there is a difference
[H,P,CI,STATS] = ttest(avg_diff_precued_oneImage, avg_diff_postcued_oneImage);
MD = nanmean(avg_diff_precued_oneImage - avg_diff_postcued_oneImage);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end

subplot(2,2,2); hold on; axis square; box off;
plot(avg_diff_precued_combined, avg_diff_postcued_combined, 'o')
xlabel('Average Error Precued Combined'); ylabel('Average Error Postcued Combined');
title('Combined ratings')
plot(-4:4, -4:4, '--')
plot([0 0], [-4 4], ':')
plot([-4 4], [0 0], ':')
[H,P,CI,STATS] = ttest(avg_diff_precued_combined, avg_diff_postcued_combined);
MD = nanmean(avg_diff_precued_combined - avg_diff_postcued_combined);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end

subplot(2,2,3); hold on; axis square; box off;
plot(avg_diff_precued_oneImage, avg_diff_precued_combined, 'o')
xlabel('Average Error Precued One-image'); ylabel('Average Error Precued Combined');
title('Precued')
plot(-4:4, -4:4, '--')
plot([0 0], [-4 4], ':')
plot([-4 4], [0 0], ':')
[H,P,CI,STATS] = ttest(avg_diff_precued_oneImage, avg_diff_precued_combined);
MD = nanmean(avg_diff_precued_oneImage - avg_diff_precued_combined);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end

subplot(2,2,4); hold on; axis square; box off;
plot(avg_diff_postcued_oneImage, avg_diff_postcued_combined, 'o')
xlabel('Average Error Postcued One-image'); ylabel('Average Error Postcued Combined');
title('Postcued')
plot(-4:4, -4:4, '--')
plot([0 0], [-4 4], ':')
plot([-4 4], [0 0], ':')
[H,P,CI,STATS] = ttest(avg_diff_postcued_oneImage, avg_diff_postcued_combined);
MD = nanmean(avg_diff_postcued_oneImage - avg_diff_postcued_combined);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end

% Quantify the relation with correlations
[r_err_prePost_one, p] = corr(avg_diff_precued_oneImage, avg_diff_postcued_oneImage)
[r_err_prePost_combined, p] = corr(avg_diff_precued_combined, avg_diff_postcued_combined)

[r_err_oneCombined_pre, p] = corr(avg_diff_precued_oneImage, avg_diff_precued_combined)
[r_err_oneCombined_post, p] = corr(avg_diff_postcued_oneImage, avg_diff_postcued_combined)

% Some averages
avg_err_pre_one = nanmean(avg_diff_precued_oneImage)
avg_err_post_one = nanmean(avg_diff_postcued_oneImage)
%%
avg_err_pre_comb = nanmean(avg_diff_precued_combined)
avg_err_post_comb = nanmean(avg_diff_postcued_combined)

%% similarly, plot the relation between SDs
figure(2); clf;

subplot(2,2,1); hold on; axis square; box off;
scatter(avg_sd_precued_oneImage, avg_sd_postcued_oneImage, 'o','jitter','on')
xlabel('Average SD Precued One-image'); ylabel('Average SD Postcued One-image');
title('One-image ratings')
plot(0:3, 0:3, '--')
% test whether there is a difference
[H,P,CI,STATS] = ttest(avg_sd_precued_oneImage, avg_sd_postcued_oneImage);
MD = nanmean(avg_sd_precued_oneImage - avg_sd_postcued_oneImage);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end
axis([0 3.5 0 3.5])

subplot(2,2,2); hold on; axis square; box off;
plot(avg_sd_precued_combined, avg_sd_postcued_combined, 'o')
xlabel('Average SD Precued Combined'); ylabel('Average SD Postcued Combined');
title('Combined ratings')
plot(0:3, 0:3, '--')
[H,P,CI,STATS] = ttest(avg_sd_precued_combined, avg_sd_postcued_combined);
MD = nanmean(avg_sd_precued_combined - avg_sd_postcued_combined);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end
axis([0 3.5 0 3.5])

subplot(2,2,3); hold on; axis square; box off;
plot(avg_sd_precued_oneImage, avg_sd_precued_combined, 'o')
xlabel('Average SD Precued One-image'); ylabel('Average SD Precued Combined');
title('Precued')
plot(0:3, 0:3, '--')
[H,P,CI,STATS] = ttest(avg_sd_precued_oneImage, avg_sd_precued_combined);
MD = nanmean(avg_sd_precued_oneImage - avg_sd_precued_combined);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end
axis([0 3.5 0 3.5])

subplot(2,2,4); hold on; axis square; box off;
plot(avg_sd_postcued_oneImage, avg_sd_postcued_combined, 'o')
xlabel('Average SD Postcued One-image'); ylabel('Average SD Postcued Combined');
title('Postcued')
plot(0:3, 0:3, '--')
[H,P,CI,STATS] = ttest(avg_sd_postcued_oneImage, avg_sd_postcued_combined);
MD = nanmean(avg_sd_postcued_oneImage - avg_sd_postcued_combined);
if P < .05
    text(.5, 2.75, ['MD = ' num2str(round(MD,2)) ', p = ' num2str(round(P,3))])
end
axis([0 3.5 0 3.5])

% Quantify the relation with correlations
[r_sd_prePost_one, p] = corr(avg_sd_precued_oneImage, avg_sd_postcued_oneImage)
[r_sd_prePost_combined, p] = corr(avg_sd_precued_combined, avg_sd_postcued_combined)

[r_sd_oneCombined_pre, p] = corr(avg_sd_precued_oneImage, avg_sd_precued_combined)
[r_sd_oneCombined_post, p] = corr(avg_sd_postcued_oneImage, avg_sd_postcued_combined)

% Some averages
avg_sd_pre_one = nanmean(avg_sd_precued_oneImage)
avg_sd_post_one = nanmean(avg_sd_postcued_oneImage)
%
avg_sd_pre_comb = nanmean(avg_sd_precued_combined)
avg_sd_post_comb = nanmean(avg_sd_postcued_combined)

%% plot error per target pleasure

% We need different averaging for these plots
avg_error_precued_oneImage = nanmean(diff_rate_baseline_precued);
avg_error_postcued_oneImage = nanmean(diff_rate_baseline_postcued);
se_error_precued_oneImage = nanstd(diff_rate_baseline_precued) ./ sqrt(9);
se_error_postcued_oneImage = nanstd(diff_rate_baseline_postcued) ./ sqrt(9);

avg_error_precued_combined = nanmean(avg_diff_rate_avgShown_precued);
avg_error_postcued_combined = nanmean(avg_diff_rate_avgShown_postcued);
se_error_precued_combined = nanstd(avg_diff_rate_avgShown_precued) ./ sqrt(9);
se_error_postcued_combined = nanstd(avg_diff_rate_avgShown_postcued) ./ sqrt(9);

figure(3); clf;

subplot(2,2,1); hold on; box off;
errorbar(1:9, avg_error_precued_oneImage, se_error_precued_oneImage);
axis([.5 9.5 -3 3])
xlabel('Target pleasure'); ylabel('Error');
title('Precued one-image')

subplot(2,2,2); hold on; box off;
errorbar(1:9, avg_error_postcued_oneImage, se_error_postcued_oneImage);
axis([.5 9.5 -3 3])
xlabel('Target pleasure'); ylabel('Error');
title('Postcued one-image')

subplot(2,2,3); hold on; box off;
errorbar(1:9, avg_error_precued_combined, se_error_precued_combined);
axis([.5 9.5 -3 3])
xlabel('Target pleasure'); ylabel('Error');
title('Precued combined')

subplot(2,2,4); hold on; box off;
errorbar(1:9, avg_error_postcued_combined, se_error_postcued_combined);
axis([.5 9.5 -3 3])
xlabel('Target pleasure'); ylabel('Error');
title('Postcued combined')

%% plot change in SD per target pleasure
% We see here the SAME patterns as for the 2-image case where SDs are
% pretty stable across target pleasures for one-image ratings and follow
% and inverted U-shape for combined pleasure ratings!

% We need different averaging for these plots
avg_sd_precued_oneImage = nanmean(sd_oneImageRating_precued);
avg_sd_postcued_oneImage = nanmean(sd_oneImageRating_postcued);
se_sd_precued_oneImage = nanstd(sd_oneImageRating_precued) ./ sqrt(9);
se_sd_postcued_oneImage = nanstd(sd_oneImageRating_postcued) ./ sqrt(9);

avg_sd_precued_combined = nanmean(sd_rate_avgShown_precued);
avg_sd_postcued_combined = nanmean(sd_rate_avgShown_postcued);
se_sd_precued_combined = nanstd(sd_rate_avgShown_precued) ./ sqrt(9);
se_sd_postcued_combined = nanstd(sd_rate_avgShown_postcued) ./ sqrt(9);

figure(4); clf;

subplot(2,2,1); hold on; box off;
errorbar(1:9, avg_sd_precued_oneImage, se_sd_precued_oneImage);
axis([.5 9.5 0 2.5])
xlabel('Target pleasure'); ylabel('SD');
title('Precued one-image')

subplot(2,2,2); hold on; box off;
errorbar(1:9, avg_sd_postcued_oneImage, se_sd_postcued_oneImage);
axis([.5 9.5 0 2.5])
xlabel('Target pleasure'); ylabel('SD');
title('Postcued one-image')

subplot(2,2,3); hold on; box off;
errorbar(1:9, avg_sd_precued_combined, se_sd_precued_combined);
axis([.5 9.5 0 2.5])
xlabel('Target pleasure'); ylabel('SD');
title('Precued combined')

subplot(2,2,4); hold on; box off;
errorbar(1:9, avg_sd_postcued_combined, se_sd_postcued_combined);
axis([.5 9.5 0 2.5])
xlabel('Target pleasure'); ylabel('SD');
title('Postcued combined')
