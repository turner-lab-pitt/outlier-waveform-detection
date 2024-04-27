function [gpFR] = get_gp_fr(ts,gp)
%get_gp_fr.m

    dur = sum(diff(cell2mat(gp),1,2));
    gpmask = get_gp_mask(gp,ts);
    nSpk = nnz(gpmask);
    gpFR = nSpk/dur;

end

