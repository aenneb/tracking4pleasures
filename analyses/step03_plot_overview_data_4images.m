% Give a summary of the data acquired so far. split pre-/post cueing as
% well as one- vs. all-image reports.

clear
close all
%%
scriptDir = pwd;
cd ..
rootDir = pwd;
cd([rootDir '/data/4images/matFiles/'])
subjList = {'ao_12_12_18','ay_11_29_18','cx_14_02_20','csl_02_13_20','ec_11_26_18',...
    'ht_12_04_18','in_12_10_18','jg_12_10_18','jh_12_06_18','jr_12_06_18',...
    'js_11_22_18','js2_11_26_18','jw_02_13_20','jw2_02_13_20','jz_02_13_20',...
    'kb_12_05_18','lg_06_14_18','mm_11_29_18', 'nw_12_13_18', 'ro_02_13_20',...
    'rp_11_28_18','sjl_14_02_20','tl_06_14_18','yc_11_28_18','yd_12_05_18'};

%% read in the data, combine data of all participants

for subj = 1:length(subjList)
    
    participantID = subjList{subj};
    load([participantID '.mat'])
    
    PLEASURE(360*(subj-1)+1:360*(subj)) = pleasure;
    TARGETPLEASURE(360*(subj-1)+1:360*(subj)) = targetPleasure;
    
    DISTRACTORPLEASURE1(360*(subj-1)+1:360*(subj)) = distractor1Pleasure;
    DISTRACTORPLEASURE2(360*(subj-1)+1:360*(subj)) = distractor2Pleasure;
    DISTRACTORPLEASURE3(360*(subj-1)+1:360*(subj)) = distractor3Pleasure;
    
    UL_DISTRACTORPLEASURE(360*(subj-1)+1:360*(subj)) = upperLeftDistractorPleasure;
    UR_DISTRACTORPLEASURE(360*(subj-1)+1:360*(subj)) = upperRightDistractorPleasure;
    LL_DISTRACTORPLEASURE(360*(subj-1)+1:360*(subj)) = lowerLeftDistractorPleasure;
    LR_DISTRACTORPLEASURE(360*(subj-1)+1:360*(subj)) = lowerRightDistractorPleasure;
    
    IMAGECUE(360*(subj-1)+1:360*(subj)) = imageCue;
    PREPOSTCUE(360*(subj-1)+1:360*(subj)) = prePostCue;
end

%% now we can sort the complete data, and plot it
cd(scriptDir)

for cue = 1:2 % First, we do pre-cues, the post-cues
%     for target = 1:9
%         for distr = 1:9
%             dist1_pleasure(distr, target) = ...
%                 nanmean(PLEASURE(TARGETPLEASURE==target &...
%                 DISTRACTORPLEASURE1==distr &...
%                 IMAGECUE<5 &...
%                 PREPOSTCUE==cue));
%             dist2_pleasure(distr, target) = ...
%                 nanmean(PLEASURE(TARGETPLEASURE==target &...
%                 DISTRACTORPLEASURE2==distr &...
%                 IMAGECUE<5 &...
%                 PREPOSTCUE==cue));
%             dist3_pleasure(distr, target) = ...
%                 nanmean(PLEASURE(TARGETPLEASURE==target &...
%                 DISTRACTORPLEASURE3==distr &...
%                 IMAGECUE<5 &...
%                 PREPOSTCUE==cue));
%         end
%     end
%     
%     lim = [1 9];
%     
%     figure(cue)
%     subplot(1,3,1)
%     imagesc(dist1_pleasure, lim)
%     colorbar
%     xlabel('Target pleasure')
%     ylabel('Distractor 1 pleasure')
%     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
%     
%     subplot(1,3,2)
%     imagesc(dist2_pleasure, lim)
%     colorbar
%     xlabel('Target pleasure')
%     ylabel('Distractor 2 pleasure')
%     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
%     
%     subplot(1,3,3)
%     imagesc(dist3_pleasure, lim)
%     colorbar
%     xlabel('Target pleasure')
%     ylabel('Distractor 3 pleasure')
%     set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    
%% instead of an arbitrary numbering, look at distractor effects per position
    for target = 1:9
        for distr = 1:9
            dist1_pleasure(distr, target) = ...
                nanmean(PLEASURE(TARGETPLEASURE==target &...
                UL_DISTRACTORPLEASURE==distr &...
                IMAGECUE<5 &...
                PREPOSTCUE==cue));
            dist2_pleasure(distr, target) = ...
                nanmean(PLEASURE(TARGETPLEASURE==target &...
                UR_DISTRACTORPLEASURE==distr &...
                IMAGECUE<5 &...
                PREPOSTCUE==cue));
            dist3_pleasure(distr, target) = ...
                nanmean(PLEASURE(TARGETPLEASURE==target &...
                LL_DISTRACTORPLEASURE==distr &...
                IMAGECUE<5 &...
                PREPOSTCUE==cue));
            dist4_pleasure(distr, target) = ...
                nanmean(PLEASURE(TARGETPLEASURE==target &...
                LR_DISTRACTORPLEASURE==distr &...
                IMAGECUE<5 &...
                PREPOSTCUE==cue));
        end
    end
    
    lim = [1 9];
    
    figure(cue)
    subplot(2,2,1)
    imagesc(dist1_pleasure, lim)
    colorbar
    xlabel('Target pleasure')
    ylabel('Upper left distractor pleasure')
    set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    
    subplot(2,2,2)
    imagesc(dist2_pleasure, lim)
    colorbar
    xlabel('Target pleasure')
    ylabel('Upper right distractor pleasure')
    set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    
    subplot(2,2,3)
    imagesc(dist3_pleasure, lim)
    colorbar
    xlabel('Target pleasure')
    ylabel('Lower left distractor pleasure')
    set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    
    subplot(2,2,4)
    imagesc(dist4_pleasure, lim)
    colorbar
    xlabel('Target pleasure')
    ylabel('Lower right distractor pleasure')
    set(gca, 'xtick', 1:2:9, 'ytick', 1:2:9)
    
    r_target_rating = corr(TARGETPLEASURE(IMAGECUE<5 & PREPOSTCUE==cue)',...
        PLEASURE(IMAGECUE<5 & PREPOSTCUE==cue)', 'rows', 'pairwise')
    
    %% let's also look at expected vs. actual reported averages
    ensembleInd = find(IMAGECUE==5 & PREPOSTCUE==cue);
    for ii = 1:sum(IMAGECUE==5 & PREPOSTCUE==cue)
        
        thisTrial = ensembleInd(ii);
        expected(ii) = nanmean([TARGETPLEASURE(thisTrial)...
            DISTRACTORPLEASURE1(thisTrial)...
            DISTRACTORPLEASURE2(thisTrial)...
            DISTRACTORPLEASURE3(thisTrial)]);
        
        min_pleasure(ii) = min([TARGETPLEASURE(thisTrial)...
            DISTRACTORPLEASURE1(thisTrial)...
            DISTRACTORPLEASURE2(thisTrial)...
            DISTRACTORPLEASURE3(thisTrial)]);
        
        reported(ii) = PLEASURE(thisTrial);
        image1(ii) = TARGETPLEASURE(thisTrial);
        image2(ii) = DISTRACTORPLEASURE1(thisTrial);
        image3(ii) = DISTRACTORPLEASURE2(thisTrial);
        image4(ii) = DISTRACTORPLEASURE3(thisTrial);
        
    end
    
    [r2 rmse] = rsquare(reported,expected);
    
    figure(cue+2); hold on; axis square; box off;
    scatter(reported, expected, 'jitter', 'on')
    plot(1:9, 1:9, ':k')
    text(2,8, ['r^2 = ' num2str(round(r2,2))], 'Fontsize', 14)
    ylabel('Predicted rating (arithmetic average)')
    xlabel('Combined rating (raw data)')
    
    % let's try a 5d scatterplot for this data
    % where the size of the data point is the observed rating
    % x- and y-axes and z-axes are the pleasure of images 1,2,3
    % color is the pleasure of the last displayed image
    cmap = colormap(parula(9));
    figure(cue+4);
    scatter3(image1, image2, image3, reported.*10, cmap(image4))
    

end