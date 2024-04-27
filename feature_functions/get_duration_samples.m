function [dur_samp] = get_duration_samples(w,dim)
%get_duration_samples.m 8/3/21
% ref Jia et al. 2019 (p. 1834)
% "Duration was defined by the time between waveform trough and peak."
% "Waveform peak was defined by
% the maximum point of extracellular waveform. Trough was
% defined by the minimum point."
% following Fig. 2 illustration: positive duration if max after min
% (for example, conventional spike followed by AHP)

dur_samp = maxind(w,dim) - minind(w,dim);

end

