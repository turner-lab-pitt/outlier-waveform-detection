function [gpCV] = get_gp_CV(ts,gp)
%get_gp_CV.m 7/27/21

    gpISIs = get_gp_ISIs(ts,gp);
    % defaults at sample (div by N-1)
    gpCV = std(gpISIs)/mean(gpISIs);
    
    
end

