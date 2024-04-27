function [snips] = samp2snip(samp,data,offsets_samp)
%samp2snip_samp.m  7/8/21
% 8/29/21 updating to allow left zero padding 
% in rare event that there is not enough data pre samp

    % horizontal
     data = reshape(data,1,[]);
    if samp(1) + offsets_samp(1) > 0        
        snips = cell2mat(arrayfun(@(x) data(x+offsets_samp(1):x+offsets_samp(2)),samp,'UniformOutput',false));
    else
        padsize = abs(samp(1) + offsets_samp(1)) + 1;
        warning('zero padding of %u necessary for early spike',padsize)
        zdata = [zeros(1,padsize) data];
        shiftsamp = samp + padsize;
        snips = cell2mat(arrayfun(@(x) zdata(x+offsets_samp(1):x+offsets_samp(2)),shiftsamp,'UniformOutput',false));
    end
end

