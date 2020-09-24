function [predictions] = predict_linearTransformModel_4images(parameters, displayedPleasures)

% predicts combined pleasure ratings as a linear transform of the average
% across all displayed images
a = parameters(1);
b = parameters(2);

predictions = a + b.*(mean(displayedPleasures));

end