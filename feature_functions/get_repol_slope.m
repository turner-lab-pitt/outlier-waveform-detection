function [rps] = get_repol_slope(w,dx_msec,fs,amp_norm)
%get_repol_slope.m 8/23/21
% an adaptation of the repolarization slope from
% the Jia et al. paper
%https://github.com/AllenInstitute/ecephys_spike_sorting/blob/master/ecephys_spike_sorting/modules/mean_waveforms/waveform_metrics.py
% 9/1/21 adding a normalization option


assert(isvector(w),'only vectors are currently supported for this function');

wsz = size(w);
dim = maxind(wsz,2);
nS = wsz(dim); 
[ex,I,T] = extreme(w,dim);

assert(I < nS,'this function is undefined when the extremum is in the final position')

dt = 1/fs;
dx_samp = ceil((dx_msec/1000)*fs);

Ts = ([0:1:nS-1]*dt)*1000;

% this inversion for positive is done in ref code
% so slope signs should be similar
wf = -w*T;

reg_ix = [I:1:(I + dx_samp - 1)];
nR = numel(reg_ix);

assert(max(reg_ix) <= nS, 'slope window exceeds waveform length');


% voltage over millseconds (Jia does over seconds)
y = reshape(wf(reg_ix),nR,1);
X = [ones(nR,1), Ts(reg_ix)'];
b = regress(y,X);

if amp_norm
    rps = b(2)/get_amplitude(w,maxind(size(w),2));
else
    rps = b(2);
end

end %fn






