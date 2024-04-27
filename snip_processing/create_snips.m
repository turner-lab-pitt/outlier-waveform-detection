function [snips,samps] = create_snips(ts,data,fs,offsets_samp)
%create_snips.m 7/17/21
% this is the procedure that best matched offline sorter output
% (max abs diff < 1e-5)

    dt = 1/fs;
    samps = round(ts/dt);
    snips_raw = samp2snip_samp(samps,data,offsets_samp);
    snips = round(snips_raw/1000,3);


end

