function [hdFR] = get_hd_fr(ts,Evts)
%get_hd_fr.m

hdur = sum(Evts.cue_onset - Evts.starttime,1);

% inclusive, then exclusive bound
mask = @(d,l,u) d>=l & d<u; 

ts_mask = sum(cell2mat(arrayfun(@(st,ed) mask(reshape(ts,1,[]),st,ed),...
    Evts.starttime, Evts.cue_onset,'UniformOutput',false)),1);

hdFR = nnz(ts_mask)/hdur;

end

