function [ipsn] = ipSnip(sn,upfac)
% ipSnip.m 8/22/21
% interpolates 1 snip

assert(isvector(sn),'this function currently only accepts vectors');

x = 1:numel(sn);
xq = 1:1/upfac:numel(sn);
ipsn = interp1(x,sn,xq,'spline');  


end %fn