function [rcvs] = get_recov_slope(w,dx_msec,fs,amp_norm)
%get_recov_slope.m
% an adaptation of the recovery slope from
% the Jia et al. paper
%https://github.com/AllenInstitute/ecephys_spike_sorting/blob/master/ecephys_spike_sorting/modules/mean_waveforms/waveform_metrics.py
% 8/31/21 updating so searches for max at 
% region dx_msec before end, so doesn't overrun
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

% 8/31/21 updating so enough room for slope
wPost = wf(I+1:end-dx_samp);
% their code does not use 
% +1 but should make no practical difference
% since looking for max and this is already
% confirmed to be global min
assert(~isempty(wPost),'there are not enough samples post-extremum to compute the recovery slope');

% look for max in what remains after the trough (forced to be trough if peak)
pkI = maxind(wPost,dim) + I;

reg_ix = [pkI:1:(pkI + dx_samp - 1)];
nR = numel(reg_ix);


% voltage over millseconds (Jia does over seconds)
y = reshape(wf(reg_ix),nR,1);
X = [ones(nR,1), Ts(reg_ix)'];
b = regress(y,X);

% new 9/1/21
if amp_norm
    rcvs = b(2)/get_amplitude(w,maxind(size(w),2));
else
    rcvs = b(2);
end


end

% from matlab docs:
% b = regress(y,X) returns a vector b of coefficient estimates for a multiple linear regression of the responses in vector y on the predictors in matrix X. To compute coefficient estimates for a model with a constant term (intercept), include a column of ones in the matrix X.