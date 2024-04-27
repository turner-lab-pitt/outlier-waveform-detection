function [hdmb] = get_hd_mburst(ts,Evts)
%get_hd_mburst.m 8/24/21
% assumes hds only drawn from gp

    % inclusive, then exclusive bound
    mask = @(d,l,u) d>=l & d<u;     
    ts_mask_cell = arrayfun(@(st,ed) mask(reshape(ts,1,[]),st,ed),...
        Evts.starttime, Evts.cue_onset,'UniformOutput',false);
    isi_cell = cellfun(@(x) diff(ts(x)),ts_mask_cell,'UniformOutput',false);
    short_isi_lbls = cellfun(@(x) bwlabel(x < 0.006), isi_cell,'UniformOutput',false);
    nSpkInB = sum(cell2mat(cellfun(@(x) nnz(x)+max(x), short_isi_lbls,'UniformOutput',false)));
    ts_mask = sum(cell2mat(ts_mask_cell),1);
    nSpk = nnz(ts_mask);
    hdmb = nSpkInB/nSpk; 
    assert(hdmb >= 0 && hdmb <= 1,'problem with invalid burst ratio')

end

