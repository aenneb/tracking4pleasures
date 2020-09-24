function [predictions] = predict_linearModel_ordered_4images(parameters, targetPleasure, allPleasures)

% predicts ratings based on a linear function of a weighted average of target and
% distractor pelasure
% here, we take into consideration each distractor pleasure, weighted by
% its position on the screen
% This means that we input all baseline pleasures per image position and
% give them a 'baseline' weight according to position. On top of that, the
% target baseline receives an extra weight.

weights = parameters;

predictions = (1-sum(weights))*targetPleasure...
    + (1-sum(weights(2:4)))*allPleasures(1,:)...
    + (1-sum(weights([1 3:4])))*allPleasures(2,:)...
    + (1-sum(weights([1:2 4])))*allPleasures(3,:)...
    + (1-sum(weights(1:3)))*allPleasures(3,:);

end