function [in] = cellisnan(c)
%cellisnan.m

in = cellfun(@(x) isnan(x),c,'UniformOutput',false);

end

