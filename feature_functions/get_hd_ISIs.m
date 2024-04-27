function [hdISIs] = get_hd_ISIs(ts,Evts)
%get_hd_ISIs
% assumes hds only drawn from gp

    % inclusive, then exclusive bound
    mask = @(d,l,u) d>=l & d<u; 

    ts_mask_cell = arrayfun(@(st,ed) mask(reshape(ts,1,[]),st,ed),...
        Evts.starttime, Evts.cue_onset,'UniformOutput',false);
    isi_cell = cellfun(@(x) diff(ts(x)),ts_mask_cell,'UniformOutput',false);
    
    hdISIs = cell2mat(isi_cell);

end

