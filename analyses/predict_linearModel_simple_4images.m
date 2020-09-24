function [predictions] = predict_linearModel_simple_4images(parameters, targetPleasure, distractorPleasures)

% predicts ratings based on a linear function of a weighted average of target and
% distractor pelasure
% special case: no compression or amplification

weights = parameters;

predictions = (1-sum(weights))*targetPleasure...
    + (1-sum(weights(2:3)))*distractorPleasures(1,:)...
    + (1-sum(weights([1 3])))*distractorPleasures(2,:)...
    + (1-sum(weights(1:2)))*distractorPleasures(3,:);


end