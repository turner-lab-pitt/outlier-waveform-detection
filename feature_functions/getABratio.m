function [ABratio] = getABratio(w,dim)
%getABratio.m
% adapted from cell explorer
% (not matched exactly b/c they 
% set trough cutoff point with a 
% constant applied to a filtered waveform)
% see also Nathan Insel's paper
%https://doi.org/10.1093/cercor/bhu062

if dim == 1
    w = w';
end

I = minind(w,2);

if I == 1
    peakA = w(:,I);
else
    peakA = max(w(:,1:I-1),[],2);
end

if I == size(w,2)
    peakB = w(:,I);
else
    peakB = max(w(:,I+1:end),[],2);
end

ABratio = (peakB-peakA)./(peakA+peakB);


end

