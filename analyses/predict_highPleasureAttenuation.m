function [predictions] = predict_highPleasureAttenuation(parameters, targetPleasure)

% predicts ratings based on a linear function of a weighted average of target and
% distractor pelasure
% here, predicted averaged pleasure is more extreme than the actual average

P_beau=parameters(1);
gain = parameters(2);

for trial = 1:length(targetPleasure)
    
   if targetPleasure(trial)<P_beau
       predictions(trial) = targetPleasure(trial);
   else
       predictions(trial) = P_beau + gain.*(targetPleasure(trial)-P_beau);
   end
    
end

end