function [ex,I,T] = extreme(x,dim)
%extreme.m
%T = Type:
%-1 = min
%+1 = max
% 0 = neither (flat)

[V,I] = max(abs(x),[],dim);
ex = x(I);
if any(ex > x)
   T = 1;
elseif any(ex < x)
   T = -1;
else
   T = 0;
end %if
    

end %fn

