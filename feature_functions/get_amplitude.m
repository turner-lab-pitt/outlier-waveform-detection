function [amp] = get_amplitude(w,dim)
%get_amplitude.m 8/3/21
% ref Jia et al. 2019  (p. 1834)
% "Waveform peak was defined by
% the maximum point of extracellular waveform. Trough was
% defined by the minimum point. Amplitude was defined by the
% absolute difference between peak and trough."

amp = abs(max(w,[],dim) - min(w,[],dim));

end

