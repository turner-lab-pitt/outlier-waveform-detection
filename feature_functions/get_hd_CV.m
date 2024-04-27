function [hdCV] = get_hd_CV(ts,Evts)
%get_hd_CV.m 7/27/21
% note this will return nan if hdISIs is empty

    hdISIs = get_hd_ISIs(ts,Evts);

    % defaults at sample (div by N-1) 
    hdCV = std(hdISIs)/mean(hdISIs);    

end

