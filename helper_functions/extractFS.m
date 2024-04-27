function [fs] = extractFS(T)
%extractFS.m 7/25/21

contIx = strcmp(cellstr(T.Tanksummary.ChanName),'Conx');
fs = T.Tanksummary.ChanFS(contIx);    

end

