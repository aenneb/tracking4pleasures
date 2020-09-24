% For combined trials, the linear transformation model is the best fit and it seems
% that there are 2 distinct groups of participants, based on the data
% Explore that hypothesis properly with k-means cluster analyses 

%%
clear
close all

%% we load results from the model fitting from the current folder
load loocv_results_precued_combinedPleasure
% extract what we need
precued_parameters = results_table{:,18:19};

load loocv_results_postcued_combinedPleasure
postcued_parameters = results_table{:,18:19};

%% Run the cluster analysis for up to 5 clusters
% Do not use the standard distance matrix, here, because it produces
% unstable results. Sample correlations showed no such variablity in the
% results
sumd_pre = zeros(2,5);
sumd_post = zeros(2,5);

for k = 1:5
   [tmp_idx_pre(k,:), C, sumd_pre(k,1:k)] = ...
       kmeans(precued_parameters,k,'MaxIter',10e43,'Distance','correlation');
   [tmp_idx_post(k,:), C, sumd_post(k,1:k)] = ...
       kmeans(postcued_parameters,k,'MaxIter',10e43,'Distance','correlation');
end
sumd_pre(sumd_pre==0)=NaN;
sumd_post(sumd_post==0)=NaN;
sumSq_pre = nansum(sumd_pre.^2);
sumSq_post = nansum(sumd_post.^2);
%% evaluate number of clusters based on sumd
figure(1)
subplot(1,2,1)
plot(sumSq_pre)
subplot(1,2,2)
plot(sumSq_post)

%% As I thought based on visual inspection, there are 2 clusters each
% look at the centroids and the equivalence of the assignment of
% participants to each cluster in pre- and postcued trials
[idx_pre, C_pre] = ...
       kmeans(precued_parameters,2,'MaxIter',10e4,'Distance','correlation');
[idx_post, C_post] = ...
       kmeans(postcued_parameters,2,'MaxIter',10e4,'Distance','correlation');

% look at the consistency of cluster assignment and at which participants
% do change clusters
sum(idx_pre==idx_post)
find(idx_pre~=idx_post)

n_cluster1_pre = sum(idx_pre==1)
n_cluster1_post = sum(idx_post==1)
%% Because the Centroids are not that well interpretable, look at the average
%  parameter values for each cluster
mean(precued_parameters(idx_pre==1,:))
mean(postcued_parameters(idx_post==1,:))

mean(precued_parameters(idx_pre==2,:))
mean(postcued_parameters(idx_post==2,:))