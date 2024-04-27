function [gpmask] = get_gp_mask(gp,ts)
%updating 8/23/21
% to accommodate multiple gps
% and assume cell array
% gp = good period

assert(~any(cellany(cellisnan(gp))),'expected gp with no nan entries');

% this assumes a specific layout
gp_rs = cell2mat(gp)';
% this means row 1 is for start times
% row 2 is for end times
% columns for the different segments

gpmask = any(ts >= gp_rs(1,:) & ts <=  gp_rs(2,:),2);

end

