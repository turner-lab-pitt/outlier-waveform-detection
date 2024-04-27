function [ptszd] = get_pt_sz_diff(w,dim,amp_norm)
%get_pt_sz_diff.m
% an attempt to adjust PT ratio from Jia et al. 
% so as to make linear across + and -

	if amp_norm
		ptszd = (abs(max(w,[],dim)) - abs(min(w,[],dim)))/get_amplitude(w,dim);
	else
		ptszd = abs(max(w,[],dim)) - abs(min(w,[],dim));
	end

end
