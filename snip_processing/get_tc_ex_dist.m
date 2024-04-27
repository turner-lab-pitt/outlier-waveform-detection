function [d] = get_tc_ex_dist(snips,tc_ix,pol)
%get_tc_ex_dist.m  7/30/21
% assuming time on dim 2

    switch pol
        case -1
            [ex,I] = min(snips,[],2); 
        case 1
            [ex,I] = max(snips,[],2);
        otherwise
            error('polarity ~= -1 or +1 not supported')
    end %sw
   
    d = I-tc_ix;

end

