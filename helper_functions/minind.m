function [I] = minind(x,dim)
%minind.m 8/3/21
% for when it is useful to not have to have I be the 2nd output

[v,I] = min(x,[],dim);

end

