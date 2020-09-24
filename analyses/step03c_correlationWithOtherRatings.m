% relate the pleasure ratings to the "normative" beauty ratings obtained in
% a previous stuyd, Brielmann & Pelli (2019)
%% start with a clean environment
clc
clear
close all

%% directories
cd .. % get to the parent folder, out of the analysis folder
rootdir = cd;
cd([rootdir '/data/4images/matFiles'])

%% load data
files = dir('*.mat');

idCount = 1;

for file = files'
    
    mat_file = file.name;
    load(mat_file);
    
    % we calculate correlations between baseline pleasure ratings and the beauty
    % rating for that image per participant
    
    r_beauty(idCount) = corr(imInfo.beauty, baselinePleasure', 'rows', 'complete');
    r_valence(idCount) = corr(imInfo.valence, baselinePleasure', 'rows', 'complete');
    
    BEAUTY(idCount,:) = baselinePleasure;
    
    idCount = idCount+1;
end

%% summary
mean(r_beauty)
min(r_beauty)
max(r_beauty)

mean(r_valence)
min(r_valence)
max(r_valence)

%% plot
figure(1); clf; hold on; box off; axis square;
plot(nanmean(BEAUTY), imInfo.valence', 'o')
plot([1 9], [1 7], '--k')
xlabel('Beauty')
ylabel('Valence')

diff = nanmean(BEAUTY) - imInfo.valence';
[~, ind] = max(diff);
imInfo.imageName(ind)
imInfo.valence(ind)
nanmean(BEAUTY(:,ind))
%%

for subj = 1:idCount-1
    figure(subj+1);clf; hold on; box off; axis square;
    plot(BEAUTY(subj,:), imInfo.valence', 'o')
    plot([1 9], [1 7], '--k')
    xlabel('Beauty')
    ylabel('Valence')
end