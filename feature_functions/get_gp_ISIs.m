function [gpISIs] = get_gp_ISIs(ts,gp)
%get_gp_ISIs.m 7/27/21

    gpmask = get_gp_mask(gp,ts);
    lblmask = bwlabel(gpmask);
    isi_cell = arrayfun(@(x) diff(ts(lblmask == x)),[1:max(lblmask)]','UniformOutput',false);
    gpISIs = cell2mat(isi_cell);

end

