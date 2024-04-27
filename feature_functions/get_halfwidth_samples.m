function [hw] = get_halfwidth_samples(w,dim)  
%get_halfwidth.m 8/22/21
% 9/23/21 important update: 
% bound search for rising/falling points
% to avoid issues found with some triphasics
% see old_get_halfwidth_samples for former approach
% which was based on allen institute code
%https://github.com/AllenInstitute/ecephys_spike_sorting/blob/master/ecephys_spike_sorting/modules/mean_waveforms/waveform_metrics.py

assert(isvector(w),'this function currently only accepts vectors');

[ex,I,T] = extreme(w,dim);
assert(T~=0,'this function is undefined for flat lines')
assert(I > 1 && I < numel(w),'this function is undefined when the extremum is in the 1st or final position')

wf = T*w; % will flip if negative extremum type (trough largest)
exf = T*ex;

thresh = exf*0.5;

wPreRaw = wf(1:I-1);
wPostRaw = wf(I+1:end); % their code starts at I but should not make a difference since they are looking for points below thresh (though they do not need the 2nd part of the assert)

% for wPre
% look for regions > 0
% first point after last < 0 point
preStart = max(find(wPreRaw < 0))+1;
if isempty(preStart); preStart = 1; end
postEnd = min(find(wPostRaw < 0))-1;
if isempty(postEnd); postEnd = length(postEnd); end


wPre = wPreRaw(preStart:end);
wPost = wPostRaw(1:postEnd);

%this is how it was defined in the reference code
preI = min(find(wPre > thresh))+preStart-1; % first ix to cross 0.5 point -- keep in mind implications for double trough/peak situations

postI =  min(find(wPost < thresh))+I;  % first ix to fall below 0.5 point -- again, consider implications for double trough/peak situations

hw = postI-preI;


end %fn

% with reference to https://github.com/AllenInstitute/ecephys_spike_sorting/blob/master/ecephys_spike_sorting/modules/mean_waveforms/waveform_metrics.py