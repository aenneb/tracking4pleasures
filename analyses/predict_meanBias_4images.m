function [predictions] = predict_meanBias_4images(parameters, targetPleasure, distractorPleasures)

% predicts ratings based on the target pleasure as well as a presumed bias
% towards the mean pleasure across all images
% in this case, do not allow for additional distortions

weight = parameters;

overallMeans = nanmean([targetPleasure; distractorPleasures]);

predictions = (1-weight).*targetPleasure + weight.*overallMeans;


end