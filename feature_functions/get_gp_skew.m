function [gpSkew] = get_gp_skew(ts,gp)
%get_gp_skew.m 7/27/21

    gpISIs = get_gp_ISIs(ts,gp);
    % 0 flag for the bias correction
    gpSkew = skewness(gpISIs,0);
    
end

