function [hdSkew] = get_hd_skew(ts,Evts)
%get_hd_skew.m 7/27/21
% note this will return nan if hdISIs is empty

    hdISIs = get_hd_ISIs(ts,Evts);
    % defaults at sample (div by N-1)
    hdSkew = skewness(hdISIs,0);

end

