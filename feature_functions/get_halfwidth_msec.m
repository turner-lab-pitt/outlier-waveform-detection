function [hw] = get_halfwidth_msec(w,dim,fs,amp_norm)
%get_halfwidth_msec.m 8/3/21
% 9/4/21 adding amp-norm option
if amp_norm
    hw = ((get_halfwidth_samples(w,dim)/fs)*1000)/get_amplitude(w,dim);
else
    hw = (get_halfwidth_samples(w,dim)/fs)*1000;
end
    
end

