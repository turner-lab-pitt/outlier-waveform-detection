function [dur_msec] = get_duration_msec(w,dim,fs,amp_norm)
%get_duration_msec.m 8/3/21
% ref Jia et al. 2019 (p. 1834)
% "Duration was defined by the time between waveform trough and peak."
% "Waveform peak was defined by
% the maximum point of extracellular waveform. Trough was
% defined by the minimum point."
% following Fig. 2 illustration: positive duration if max after min
% (for example, conventional spike followed by AHP)
% 9/4/21 adding amp norm option

if amp_norm
    dur_msec = (get_duration_samples(w,dim)/fs)*1000/get_amplitude(w,dim);
else
    dur_msec = (get_duration_samples(w,dim)/fs)*1000;
end
    
    
end

