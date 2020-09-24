function [predictions] = predict_sortedWeights_4images(parameters, targetPleasure, distractorPleasures)

% predicts ratings based on a linear function of the weighted baseline
% image pleausres.
% Here, we weigh the images according to their relative pleasure values,
% i.e., weights get applied in an ordinal fashion.

weights = parameters;

sorted_pleasures = sort([targetPleasure; distractorPleasures]);

predictions = (1-sum(weights))*sorted_pleasures(1,:)...
    + (1-sum(weights(2:3)))*sorted_pleasures(2,:)...
    + (1-sum(weights([1 3])))*sorted_pleasures(3,:)...
    + (1-sum(weights(1:2)))*sorted_pleasures(4,:);


end