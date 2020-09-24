% read in the data from pleasure integration experiment
% add information about baseline beauty, valence and arousal of the images
% using .xls files based on previous code that used xlsread
% UPDATE Feb 2020: switch to readtable

%% set up the environment - clear it, close old windows and find the current folder
clear
close all
cd .. % get to the parent folder, out of the analysis folder
rootdir = cd;

%% First, the names of the files that we want to read in need to be specified,
% i.e. all the parts of the .xls file that are not _main.xls or _single.xls
subjList = {'ao_12_12_18','ay_11_29_18','cx_14_02_20','csl_02_13_20','ec_11_26_18',...
    'ht_12_04_18','in_12_10_18','jg_12_10_18','jh_12_06_18','jr_12_06_18',...
    'js_11_22_18','js2_11_26_18','jw_02_13_20','jw2_02_13_20','jz_02_13_20',...
    'kb_12_05_18','lg_06_14_18','mm_11_29_18', 'nw_12_13_18', 'ro_02_13_20',...
    'rp_11_28_18','sjl_14_02_20','tl_06_14_18','yc_11_28_18','yd_12_05_18'};

%% read in the data
% We do this in a for-loop, reading one participants' data at a time
for subj = 1:length(subjList)
    
    clearvars -except subj subjList rootdir
    close all
    cd([rootdir '/data/4images/']) % since we save the files in a different folder, switch back to data folder each time we loop
    
    participantID = subjList{subj};
    fileName = [participantID '_main.xls'];
    rawData = readtable(fileName); %read xls
    
    % give obvious names to the numerical data
    prePostCue = rawData.pre_or_post_cue'; % 1 = pre; 2 = post
    imageCue = rawData.which_image_cued'; % value from 1-4 = target image position
    pleasure = rawData.pelasure'; % rating
    rt = rawData.rt'; %RT is always last column, but partially we did not record original key press, so column number varies
    
    % get all image names for 
    targetImage = rawData.image_1;
    distractorImage1 = rawData.image_2;
    distractorImage2 = rawData.image_3;
    distractorImage3 = rawData.image_4;
    
    % encode the position of each image. For presentation purposes, the
    % first (target) image was placed at the image cue position, the other
    % distractor images filled up the remaining positions 1-4 in order
    targetPosition = imageCue';
    targetPosition(imageCue==5) = 1; %default positioning for all-image trials
    distractor1Position(1:length(targetPosition)) = 2;
    distractor1Position(targetPosition>1) = 1;
    distractor2Position(1:length(targetPosition)) = 3;
    distractor2Position(targetPosition>2) = 2;
    distractor3Position(1:length(targetPosition)) = 4;
    distractor3Position(targetPosition>3) = 3;
    
    %% now "attach" baseline info, most importantly image indices to facilitate 
    % attaching the correct baseline ratings
    load baselineImageInformation
    
    for ii = 1:length(pleasure)
        
        targetImageInd(ii) = imInfo.imageInd(find(strcmp(imInfo.imageName, targetImage(ii))));
        distr1ImageInd(ii) = imInfo.imageInd(find(strcmp(imInfo.imageName, distractorImage1(ii))));
        distr2ImageInd(ii) = imInfo.imageInd(find(strcmp(imInfo.imageName, distractorImage2(ii))));
        distr3ImageInd(ii) = imInfo.imageInd(find(strcmp(imInfo.imageName, distractorImage3(ii))));
        
        targetImageBeauty(ii) = imInfo.beauty(find(strcmp(imInfo.imageName, targetImage(ii))));
        distr1ImageBeauty(ii) = imInfo.beauty(find(strcmp(imInfo.imageName, distractorImage1(ii))));
        distr2ImageBeauty(ii) = imInfo.beauty(find(strcmp(imInfo.imageName, distractorImage2(ii))));
        distr3ImageBeauty(ii) = imInfo.beauty(find(strcmp(imInfo.imageName, distractorImage3(ii))));
        
    end
    
    %% optional: exclude trials with extremely low and extremely high RTs
%     pleasure(rt<0.1) = NaN;
%     pleasure(rt>2) = NaN;
    
    %% now load and convert the single-image ratings
    fileName = [participantID '_single.xls'];
    [numericalData_single,textData_single,~] = xlsread(fileName);
    
    image = textData_single(2:end,1); %do not include first row, this is merely the header in the .xls file
    
    singleImPleasure = numericalData_single(:,1);
    singleImRT = numericalData_single(:,3);
    
    %% optional: exclude trials with extremely low and extremely high RTs
    %     singleImPleasure(singleImRT<0.1) = NaN;
    %     singleImPleasure(singleImRT>2) = NaN;
    
    %% get indices for baseline image ratings
    for ii = 1:length(singleImPleasure)
        imageInd_single(ii) = imInfo.imageInd(find(strcmp(imInfo.imageName, image(ii))));
    end
    
    % now, what I really want is the pleasure per image number
    for ii = 1:length(imageInd_single)
        if ~isempty(singleImPleasure(imageInd_single==ii))
            baselinePleasure(ii) = singleImPleasure(imageInd_single==ii);
        else
            baselinePleasure(ii) = NaN;
        end
        
    end
    
    % get target vs. distractor pleasure immediately here
    for trial = 1:length(pleasure)
        
        targetInd(trial) = targetImageInd(trial);
        targetPleasure(trial) = baselinePleasure(targetInd(trial));
        
        distractor1Ind(trial) = distr1ImageInd(trial);
        distractor1Pleasure(trial) = baselinePleasure(distractor1Ind(trial));
        distractor2Ind(trial) = distr2ImageInd(trial);
        distractor2Pleasure(trial) = baselinePleasure(distractor2Ind(trial));
        distractor3Ind(trial) = distr3ImageInd(trial);
        distractor3Pleasure(trial) = baselinePleasure(distractor3Ind(trial));
    end
    
    % also encode the pleasure for each image per position on the screen
    upperLeftPleasure(targetPosition==1) = targetPleasure(targetPosition==1);
    upperLeftPleasure(distractor1Position==1) = distractor1Pleasure(distractor1Position==1);
    upperLeftPleasure(distractor2Position==1) = distractor2Pleasure(distractor2Position==1);
    upperLeftPleasure(distractor3Position==1) = distractor3Pleasure(distractor3Position==1);
    
    upperRightPleasure(targetPosition==2) = targetPleasure(targetPosition==2);
    upperRightPleasure(distractor1Position==2) = distractor1Pleasure(distractor1Position==2);
    upperRightPleasure(distractor2Position==2) = distractor2Pleasure(distractor2Position==2);
    upperRightPleasure(distractor3Position==2) = distractor3Pleasure(distractor3Position==2);
    
    lowerLeftPleasure(targetPosition==3) = targetPleasure(targetPosition==3);
    lowerLeftPleasure(distractor1Position==3) = distractor1Pleasure(distractor1Position==3);
    lowerLeftPleasure(distractor2Position==3) = distractor2Pleasure(distractor2Position==3);
    lowerLeftPleasure(distractor3Position==3) = distractor3Pleasure(distractor3Position==3);
    
    lowerRightPleasure(targetPosition==4) = targetPleasure(targetPosition==4);
    lowerRightPleasure(distractor1Position==4) = distractor1Pleasure(distractor1Position==4);
    lowerRightPleasure(distractor2Position==4) = distractor2Pleasure(distractor2Position==4);
    lowerRightPleasure(distractor3Position==4) = distractor3Pleasure(distractor3Position==4);
    
    % and then I also want distractor pleasures encoded for each position,
    % such that its value = NaN if the target is at that position
    upperLeftDistractorPleasure = upperLeftPleasure;
    upperLeftDistractorPleasure(targetPosition==1) = NaN;
    
    upperRightDistractorPleasure = upperRightPleasure;
    upperRightDistractorPleasure(targetPosition==2) = NaN;
    
    lowerLeftDistractorPleasure = lowerLeftPleasure;
    lowerLeftDistractorPleasure(targetPosition==3) = NaN;
    
    lowerRightDistractorPleasure = lowerRightPleasure;
    lowerRightDistractorPleasure(targetPosition==4) = NaN;
    
    %% save it all
    cd([pwd '/matFiles/'])
    
    save([participantID '.mat'],'pleasure','rt','prePostCue','imageCue','imInfo',...
        'targetImageInd', 'targetPleasure', 'distractor1Ind', 'distractor1Pleasure',...
        'distractor2Ind', 'distractor2Pleasure', 'distractor3Ind', 'distractor3Pleasure',...
        'baselinePleasure', 'targetPosition', 'distractor1Position',...
        'distractor2Position', 'distractor3Position', 'upperLeftPleasure',...
        'upperRightPleasure', 'lowerLeftPleasure', 'lowerRightPleasure',...
        'upperLeftDistractorPleasure', 'upperRightDistractorPleasure',...
        'lowerLeftDistractorPleasure', 'lowerRightDistractorPleasure')
    
end