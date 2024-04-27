function [waveSNR] = getWaveSNR(snips,dim)
%getSNR.m  8/8/21
% dim = 1 means snippets down rows
% ref: Suner et al. 2005

if dim == 2; sn = snips'; else; sn = snips; end

mn = mean(sn,1);
amp = get_amplitude(mn,2);

nS = size(sn,1);
res = sn - repmat(mn,nS,1);

% note using default of n-1 normalization for std
waveSNR = amp/(2*std(res,0,'all'));  
%old versions of Matlab: can't use 'all', reshape res into a vector first 


end

