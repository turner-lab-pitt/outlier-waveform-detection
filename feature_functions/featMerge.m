function [mFeat,featSets,nameSets,rowSets,icF] = featMerge(feats,datalist)

% fname will be like this form: 
%'I_170623_5'
datalist.date = vertcellflat(regexp(datalist.sortfile,'\d{6,6}','match'));
subtbl = datalist(:,{'date','chans','sorts','zcode'});
[uF,iaF,icF] = unique(subtbl,'first');  % note matlab treats nan's as distinct
[uL,iaL,icL] = unique(subtbl,'last');   
c_ix = find(iaF ~= iaL);
dups = uF(c_ix,:);
dupflag = ismember(icF,c_ix); % will be aligned with rows in the unit indices space
flagged_ris = find(dupflag);    
nQ = size(uF,1);
mFeat = cell2mat(arrayfun(@(x) mean(feats(icF == x,:),1),...
    [1:nQ]','UniformOutput',false));   
featSets = arrayfun(@(x) feats(icF == x,:), [1:nQ]','UniformOutput',false);
% so this was for grouping unit indices
nameSets = arrayfun(@(x) subtbl(icF == x,:), [1:nQ]','UniformOutput',false);
rowSets = arrayfun(@(x) find(icF == x), [1:nQ]','UniformOutput',false);

end %