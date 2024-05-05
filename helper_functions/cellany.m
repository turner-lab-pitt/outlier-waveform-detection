function [a] = cellany(c)
%cellany.m

a = cell2mat(cellfun(@(x) any(x),c,'UniformOutput',false));

end

