function [d] = get_start_ex_dist(snips,start_ix,pol)
%get_start_ex_dist.m  8/28/21
% assuming time on dim 2
% currently identical to get_tc_ex_dist

    switch pol
        case -1
            [ex,I] = min(snips,[],2); 
        case 1
            [ex,I] = max(snips,[],2);
        otherwise
            error('polarity ~= -1 or +1 not supported')
    end %sw
   
    d = I-start_ix;

end

