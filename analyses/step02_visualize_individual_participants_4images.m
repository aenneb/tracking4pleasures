% I am not quite sure yet what the best way of looking at the 4-image data
% will be. Use the first bit of data to explore the visualization options
% and get a sense for the data structure
clear
close all
%% set up the working directories
cd ..
rootDir = pwd;
cd([rootDir '/data/4images/matFiles/'])
subjList = {'ao_12_12_18','ay_11_29_18','cx_14_02_20','csl_02_13_20','ec_11_26_18',...
    'ht_12_04_18','in_12_10_18','jg_12_10_18','jh_12_06_18','jr_12_06_18',...
    'js_11_22_18','js2_11_26_18','jw_02_13_20','jw2_02_13_20','jz_02_13_20',...
    'kb_12_05_18','lg_06_14_18','mm_11_29_18', 'nw_12_13_18', 'ro_02_13_20',...
    'rp_11_28_18','sjl_14_02_20','tl_06_14_18','yc_11_28_18','yd_12_05_18'};

%% load the data
for subj = 1:length(subjList)
    
    participantID = subjList{subj};
    load([participantID '.mat'])
    
    %% probably the simplest thing we can do is plot pleasure per average distractor pleasure
    % we need to bin those, though, otherwise we run into a lot of points
    % with 0 SD just because there is only 1 datapoint.
    
    figure(subj); clf; hold on;
    set(gcf, 'Position',  [200, 200, 1600, 400])
    
    subplot(1,4,1); hold on; box off;
    title('Means')
    xlabel('Average distractor pleasure')
    ylabel('Average reported pleasure')
    cmap = colormap(jet(9));
    axis([1 9 1 9])
    
    for target = 1:9
        for distr = 1:9
            
            plot(distr+0.5, nanmean(pleasure(targetPleasure==target & ...
                mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure]) &...
                imageCue<5 &...
                prePostCue==1)), '.', 'color', cmap(target,:), 'markersize',20)
            
        end
    end
    
    %% along the same summary statistic lines, I would like to add a plot of the variances
    subplot(1,4,2); hold on; box off;
    title('SDs')
    xlabel('Average distractor pleasure')
    ylabel('SD pleasure ratings')
    cmap = colormap(jet(9));
    axis([1 9 0 4])
    
    for target = 1:9
        for distr = 1:9
            
            % only plot a data point if there are >1 data points
            if length(pleasure(targetPleasure==target & ...
                    mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    imageCue<5 &...
                    prePostCue==1))>1
                plot(distr+0.5, nanstd(pleasure(targetPleasure==target & ...
                    mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    imageCue<5 &...
                    prePostCue==1)), '.', 'color', cmap(target,:), 'markersize',20)
            end
            
        end
    end
    
    %% repeat this plot, simpler, ignoring the target pleasure
    subplot(1,4,3); hold on; box off;
    title('SDs per average distractor pleasure')
    xlabel('Average distractor pleasure')
    ylabel('SD pleasure ratings')
    axis([1 9 0 4])
    
    for distr = 1:9
        for target = 1:9
            % only plot a data point if there are >1 data points
            if length(pleasure(targetPleasure==target & ...
                    mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    imageCue<5 &...
                    prePostCue==1))>1
                SD_per_target(target) = nanstd(pleasure(targetPleasure==target & ...
                    mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    imageCue<5 &...
                    prePostCue==1));
            else
                SD_per_target(target) = NaN;
            end
        end
        plot(distr+0.5, nanmean(SD_per_target), '.', 'markersize',20)
    end
    
    %% another iteration for SDs: average across distractor pleasures, plot per target pleasure
    subplot(1,4,4); hold on; box off;
    title('SDs per target pleasure')
    xlabel('Target pleasure')
    ylabel('SD pleasure ratings')
    axis([1 9 0 4])
    
    for target = 1:9
        for distr = 1:9
        
            % only plot a data point if there are >1 data points
            if length(pleasure(targetPleasure==target & ...
                    mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    imageCue<5 &...
                    prePostCue==1))>1
                SD_per_distr(distr) = nanstd(pleasure(targetPleasure==target & ...
                    mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    distr> mean([distractor1Pleasure; distractor2Pleasure; distractor3Pleasure])<=distr &...
                    imageCue<5 &...
                    prePostCue==1));
            else
                SD_per_distr(distr) = NaN;
            end
            
        end
        plot(target, nanmean(SD_per_distr), '.', 'markersize',20)
    end
    
 %% HEATMAPS   
    %     %% I would also like to see how the different positions might influence
    %     % the target pleasure ratings
    %
    %     for target = 1:9
    %         for distr = 1:9
    %             dist1_pleasure(distr, target) = ...
    %                 nanmean(pleasure(targetPleasure==target &...
    %                 upperLeftDistractorPleasure==distr &...
    %                 imageCue<5 &...
    %                 prePostCue==1));
    %             dist2_pleasure(distr, target) = ...
    %                 nanmean(pleasure(targetPleasure==target &...
    %                 upperRightDistractorPleasure==distr &...
    %                 imageCue<5 &...
    %                 prePostCue==1));
    %             dist3_pleasure(distr, target) = ...
    %                 nanmean(pleasure(targetPleasure==target &...
    %                 lowerLeftDistractorPleasure==distr &...
    %                 imageCue<5 &...
    %                 prePostCue==1));
    %             dist4_pleasure(distr, target) = ...
    %                 nanmean(pleasure(targetPleasure==target &...
    %                 lowerRightDistractorPleasure==distr &...
    %                 imageCue<5 &...
    %                 prePostCue==1));
    %         end
    %     end
    %
    %     lim = [1 9];
    %
    %     figure(2+(subj-1)*3)
    %     subplot(2,2,1)
    %     imagesc(dist1_pleasure, lim)
    %     colorbar
    %     xlabel('Target pleasure')
    %     ylabel('Upper left distractor pleasure')
    %     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    %
    %     subplot(2,2,2)
    %     imagesc(dist2_pleasure, lim)
    %     colorbar
    %     xlabel('Target pleasure')
    %     ylabel('Upper right distractor pleasure')
    %     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    %
    %     subplot(2,2,3)
    %     imagesc(dist3_pleasure, lim)
    %     colorbar
    %     xlabel('Target pleasure')
    %     ylabel('Lower left distractor pleasure')
    %     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    %
    %     subplot(2,2,4)
    %     imagesc(dist4_pleasure, lim)
    %     colorbar
    %     xlabel('Target pleasure')
    %     ylabel('Lower right distractor pleasure')
    %     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    %
    %     %% let's also look at expected vs. actual reported averages
    %     ensembleInd = find(imageCue==5); %marks trials where all 4 images were rated
    %     for ii = 1:sum(imageCue==5)
    %
    %         thisTrial = ensembleInd(ii);
    %         expected(ii) = nanmean([targetPleasure(thisTrial)...
    %             distractor1Pleasure(thisTrial)...
    %             distractor2Pleasure(thisTrial)...
    %             distractor3Pleasure(thisTrial)]);
    %
    %         reported(ii) = pleasure(thisTrial);
    %
    %     end
    %
    %     figure(3+(subj-1)*3); hold on; axis square; box off;
    %     plot(reported, expected, 'o')
    %     plot(1:9, 1:9, ':k')
    %     xlabel('Reported pleasure')
    %     ylabel('Prediction based on single image ratings')
end