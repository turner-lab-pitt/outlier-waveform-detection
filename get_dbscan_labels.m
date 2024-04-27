% get_dbscan_labels.m

%%
clear all;
close all;
clc;
warning('on','all')

%% 
subj_list = {'G','I'};    
mptp = 'Post';
Area = 'GPi';


%% other paths
basepath = pwd;
scriptdirs = {'helper_functions';
			'snip_processing';
			'feature_functions'};
scriptpaths = fullfile(basepath,scriptdirs);
addpath(scriptpaths{:})
featdirs = cell(numel(subj_list),1);
for f = 1:numel(subj_list)
    featdirs{f} = fullfile('feat_output',subj_list{f},mptp);
end %f
featfile = 'featdata.mat';	
featprepaths = fullfile(basepath,featdirs);
addpath(featprepaths{:})
datadir = 'GPi_input_data';
dataprepath = fullfile(basepath,datadir);
addpath(dataprepath)  

%% set to true to combine features
% across sessions for multi-session units
mergeSessions = true;

%%
plotFigs = true;
plotEpsFind = true;
writetbl = false;
writeData = false;
%% writing
writedir = fullfile('dbscan_output',mptp);
writeprepath = fullfile(basepath,writedir);
writefile = 'dbscan_data.mat';
mkdir(writeprepath)

%% features
ftFlds = {'hw','ptszdn','ABratio'};
nF = numel(ftFlds);

%%  processing for feats for each subject
% (there may be more than 1)
nS = numel(subj_list);
ftDataZCell = cell(nS,1);
uiSetsCell = cell(nS,1);
sColCell = cell(nS,1);
nO = nan(nS,1);  %number of observations after merge
snctSetsCell = cell(nS,1);
nameSetsCell = cell(nS,1);
rowSetsCell = cell(nS,1);

%% loop
for s = 1:nS
    subj = subj_list{s}; 
    listfile = ['DataList',subj,mptp,'.mat'];
    listpath = fullfile(dataprepath,listfile); 
    load(listpath,'datalist');
    fprintf('loading %s\n',listpath);   
    featpath = fullfile(featprepaths{s},featfile);
    fprintf('loading %s\n',featpath)
    M{s} = load(featpath);
    feat = M{s}.feat;
    nOR = size(feat.(ftFlds{1}),1);
    ftDataRaw = nan(nOR,nF);
    snctsRaw = M{s}.sncts;
    datalist.date = vertcellflat(regexp(datalist.sortfile,'\d{6,6}','match'));
    subtbl = datalist(:,{'date','chans','sorts','zcode'});
    nameSetsRaw = arrayfun(@(x) subtbl(x,:), [1:height(subtbl)]','UniformOutput',false);
    rowSetsRaw = [1:height(datalist)]';
    for f = 1:nF
        ftDataRaw(:,f) = feat.(ftFlds{f});    
    end %f
    if mergeSessions
        % ftData are merged as means, ftSets in cells but orig data, not means
        [ftDataNan,ftSetsNan,nameSetsNan,rowSetsNan,icF] = featMerge(ftDataRaw,datalist); %uses mean now
        snctSetsNan = arrayfun(@(x) snctsRaw(icF == x,:), [1:nunique(icF)]','UniformOutput',false);
    else
        ftDataNan = ftDataRaw;
        snctSetsNan = snctsRaw;
        nameSetsNan = nameSetsRaw;
        rowSetsNan = rowSetsRaw;
    end %if
    % clear out nan
    ix_nan = any(isnan(ftDataNan),2);  %this means 1 nan in merge set sufficient to eliminate
    ftData = ftDataNan(~ix_nan,:);
    snctSets = snctSetsNan(~ix_nan);
    nameSets = nameSetsNan(~ix_nan);
    rowSets = rowSetsNan(~ix_nan);

    % standardize with Z
    ftDataZ = zscore(ftData,0,1);
    nO(s) = size(ftDataZ,1);

    % normalize with median and IQR:
    % ultimately used this for dbscan
    ftDataN = normalize(ftData,1,'medianiqr');

    ftDataZCell{s} = ftDataZ;
    ftDataCell{s} = ftData;
    sColCell{s} = ones(nO(s),1)*s; 
    snctSetsCell{s} = snctSets;
    ftDataNCell{s} = ftDataN;
    nameSetsCell{s} = nameSets;
    rowSetsCell{s} = rowSets;

end %s

ftDataAll = vertcellflat(ftDataCell);
ftDataZAll =  vertcellflat(ftDataZCell);
snctSetsAll = vertcellflat(snctSetsCell);
nameSetsAll = vertcellflat(nameSetsCell);
rowSetsAll = vertcellflat(rowSetsCell);

sCol = cell2mat(sColCell);
nOA = size(ftDataZAll,1);

ftDataNAll = vertcellflat(ftDataNCell);

%% to set epsilon parameter for dbscan
k = 5; %<== if k = 5, Wnumber of point neighbors = 4
assert(nOA >= k,'too few units to perform dbscan')
[Idx,D] =  knnsearch(ftDataNAll,ftDataNAll,'K',k);
distk = D(:,k);
sdist = sort(distk);
cvec = [1:nOA]';
p1 = [cvec(1),sdist(1)];
x1 = p1(1); y1 = p1(2);
p2 = [cvec(end),sdist(end)];
x2 = p2(1); y2 = p2(2);
% this is based on a rule described by matlab documentation
x = [x1;x2]; y = [y1;y2];
pf = polyfit(x,y,1);
slope = pf(1);
pslope = -1*(1/slope);
b = -1;
c = pf(2);
a = slope;
dToLine = nan(nOA,1);
for i = 1:nOA
   x0 = cvec(i);
   y0 = sdist(i);
   dToLine(i) = abs(a*x0 + b*y0 + c)/sqrt(a^2 + b^2);
end
[maxD,maxI] = max(dToLine);

epsilon = sdist(maxI);

if plotEpsFind
    plot(cvec,sdist);
    hold on;
    plot([p1(1);p2(1)],[p1(2);p2(2)])
    plot(cvec(maxI),sdist(maxI),'+')
    tstr = sprintf('epsilon = %0.2f',epsilon);
    title(tstr)
    %close all;
end %if

%% run dbscan
minpts = 4;
dmetric = 'euclidean'; 
[idx,corepts] = dbscan(ftDataNAll,epsilon,minpts,'Distance',dmetric);

ix_out = idx < 0;
ix_b = idx > 0 & corepts < 1;
ix_c = ~ix_out & ~ix_b;

%%
if plotFigs
    figure
    sc = gobjects(3,1);
    sc(1) = scatter(ftDataNAll(ix_out,1),ftDataNAll(ix_out,2),40,ftDataNAll(ix_out,3),'filled');
    hold on;
    sc(2) = scatter(ftDataNAll(ix_b,1),ftDataNAll(ix_b,2),40,ftDataNAll(ix_b,3),'+');
    sc(3) = scatter(ftDataNAll(ix_c,1),ftDataNAll(ix_c,2),40,ftDataNAll(ix_c,3),'o');
    cb = colorbar;
    cb.Limits = [-6 3];
    cb.Label.String = M{end}.featStrs(ftFlds{3});
    ax = gca;
    ax.XLim = [-2 5];
    ax.YLim = [-4 14];
    xlabel(M{end}.featStrs(ftFlds{1}));
    ylabel(M{end}.featStrs(ftFlds{2}));
    title(join({subj_list{:},Area,mptp,':','filled = outlier, + = border, data normed with med&iqr'}),' ')
    saveas(gcf,fullfile(writeprepath,[subj_list{:},Area,mptp,'_scatterplot.tif']))
    %close all;
end %if    
%
%% table
nOut = nnz(ix_out); pOut = nnz(ix_out)/nOA;
nB = nnz(ix_b); pB = nnz(ix_b)/nOA;
nC = nnz(ix_c); pC = nnz(ix_c)/nOA;
arr = [{'outlier';'border';'core'},num2cell([nOut,pOut;nB,pB;nC,pC])];
tbl = array2table(arr,'VariableNames',{'type','count','percent'});
if writetbl
    writepath = fullfile(writeprepath,[subj_list{:},Area,mptp,'_counts.xlsx']);
    fprintf('writing %s\n',writepath)
    writetable(tbl,writepath)
end


%%
vars_to_save = {'sCol','ix_out','ix_b','ix_c',...
    'idx','corepts','epsilon','minpts','dmetric',...
    'subj_list','mptp','Area','k','snctSetsCell',...
    'ftDataNCell','nameSetsCell','rowSetsCell',...
    'snctSetsAll','ftDataNAll','nameSetsAll',...
    'rowSetsAll'};

if writeData
    writepath = fullfile(writeprepath,[subj_list{:},Area,mptp,'_labels.mat']);
    fprintf('writing %s\n',writepath)
    save(writepath,vars_to_save{:},'-v7.3')
end

%%













