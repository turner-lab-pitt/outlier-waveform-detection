function [gpmb] = get_gp_mburst(ts,gp)
%get_gp_mburst.m
% 8/23/21
% ref: Cell Explorer and https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3718552/

gpmask = get_gp_mask(gp,ts);
lblmask = bwlabel(gpmask);
isi_cell = arrayfun(@(x) diff(ts(lblmask == x)),[1:max(lblmask)]','UniformOutput',false);
short_isi_lbls = cellfun(@(x) bwlabel(x < 0.006), isi_cell,'UniformOutput',false);
nSpkInB = sum(cell2mat(cellfun(@(x) nnz(x)+max(x), short_isi_lbls,'UniformOutput',false)));
nSpk = nnz(gpmask);

gpmb = nSpkInB/nSpk;

assert(gpmb >= 0 && gpmb <= 1,'problem with invalid burst ratio')

end %fn
% "A burst index was defined as the ratio of spikes in bursts to all spikes. 
% Inclusion of a spike in a burst event required a spike with an interspike interval (ISI) 
% less than 6 ms occurred either before or after the spike."
