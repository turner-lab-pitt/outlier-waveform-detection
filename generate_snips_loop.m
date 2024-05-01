% generate_snips_loop.m
% 4/14/24
% the initial several sections specify settings that may 
% need to be adjusted depending on preferences

%%
clear all;
close all;
clc;
warning('on','all')

%% 
subj = 'G';    
mptp = 'Pre';

%% area
Area = 'GPi';

%% script paths: assumes the present script is in current working dir
% associated scripts in folders just below
basepath = pwd;
vars_to_load = {'Recordings'};
scriptdirs = {'helper_functions';
			'snip_processing';
			'feature_functions'};
scriptpaths = fullfile(basepath,scriptdirs);
addpath(scriptpaths{:}) 

%% data paths: assumes that the input data
% folder is in the current working dir
datadir = ['GPi_input_data'];
dataprepath = fullfile(basepath,datadir);
addpath(dataprepath)  
listdir = ['GPi_datalists'];
listprepath = fullfile(basepath,listdir);
addpath(listprepath) 
listfile = ['DataList',subj,mptp,'.mat'];
listpath = fullfile(listprepath,listfile); 
fprintf('loading %s\n',listpath);   
load(listpath,'datalist');
contprepath = fullfile(dataprepath,subj,mptp,'hpcont_data');
sortprepath = fullfile(dataprepath,subj,mptp,'spike_data');

%% figure writing prefs
writeFigs = true;  % writes figures with aligned snips (can take some time)
figdir = fullfile('snip_figures',subj,mptp);
figprepath = fullfile(basepath,figdir);
if writeFigs; mkdir(figprepath); end

%% data writing prefs
writeData = true;
writedir = fullfile('snip_output',subj,mptp);
writeprepath = fullfile(basepath,writedir);
if writeData; mkdir(writeprepath); end
writefile = 'snipdata.mat';

vars_to_save = {'subj';'mptp';'fnstr';'fn';'Area';...
    'offsets';'offsets_shifted';'load_ok';'ts_ok';'dists';'ct_sn_gp_pol';'search_dir';'fs';...
    'offsets_search';'ctr_offset';...
    'snips_gp';'samps_gp';'snips_ex';'samps_ex';'datalist'};

%% choose median or mean for summary over snips
fnstr = 'median';  
switch fnstr
    case 'median'
        fn = @(x,d) median(x,d);
    case 'mean'
        fn = @(x,d) mean(x,d);
    otherwise
        error('unrecognized function string')
end %sw

%%
offsets = containers.Map;
offsets('VLa') = [-11 50]; 
offsets_shifted = containers.Map;
offsets_shifted('VLa') = offsets('VLa') - 12;  
offsets('VLp') = offsets('VLa');
offsets_shifted('VLp')= offsets_shifted('VLa');
offsets('GPi') = [-11 50];   
offsets_shifted('GPi') = offsets('GPi') - 12; 
offsets('GPe') = [-11 50]; 
offsets_shifted('GPe') = offsets('GPe') - 12; 
offsets('M1-S') = [-11 50];   
offsets_shifted('M1-S') = offsets('M1-S') - 12; 
offsets('M1-G') = [-11 50];   
offsets_shifted('M1-G') = offsets('M1-G') - 12; 

% search window for the extremum relative to median extremum 
max_ex_dev_msec = 0.20;  % this should ultimately turn into 5 samples
expected_max_dev = 5;
% for interpolation
upfac = 4;

%%
sortstrs = containers.Map({false,true},{'manual','automated'});
sclr = [0.8 0.8 0.8];
slw = 0.3; % default 0.5
mclr = 'b';
mlw = 0.6;
iclr = [75 48 72]/256;
ilw = mlw;
fig_dims = [404-100 247-100 560*2 420+60];
tisz = 11;
ymin = -0.3; ymax = 0.3; 

%%
nU = size(datalist,1);

%% pre-allocate
load_ok = false(nU,1);
ts_ok = load_ok;
snips_ok = ts_ok;
dists = cell(nU,1);
ct_sn_gp_pol = nan(nU,1);
search_dir = nan(nU,1);  
fs = nan(nU,1);
snips_gp = cell(nU,1);
samps_gp = cell(nU,1);
snips_ex = cell(nU,1);
samps_ex = cell(nU,1);
ctr_offset = nan(nU,1); 
offsets_search = nan(nU,2);

%%
for u = 1:nU
	fprintf('%d of %d\n',u,nU); 
    sortfile = datalist.sortfile{u};
    sortpath = fullfile(sortprepath,sortfile);
    fprintf('loading %s\n',sortpath)
	load(sortpath,'S');
    snips_ok(u) = isfield(S.units,'snips'); 
    fs(u) = extractFS(S); 
    gpmask = get_gp_mask(S.units.gp,S.units.ts);
    dt = fs(u)^-1;
    contfile = datalist.contfile{u};
    contpath = fullfile(contprepath,contfile);
    fprintf('loading %s\n',contpath)
	load(contpath,'hp_cont');
    data = hp_cont;
	sorterflag = datalist.sorterflag(u);
    offsets_samp = offsets(Area); 
    offsets_ex = offsets_shifted(Area); 
    ts = S.units.ts;
    assert(~any(round(ts/dt) > numel(data)),'ts values too high')
    ts_ok(u) = true;
    [snips_orig,samps_orig] = create_snips(ts,data,fs(u),offsets_samp);
    tsGP = ts(gpmask); 
    [snips_gp{u},samps_gp{u}] = create_snips(tsGP,data,fs(u),offsets_samp);
    [ex,I,ct_sn_gp_pol(u)] = extreme(fn(snips_gp{u},1),2);
    max_dev_samp = ceil((max_ex_dev_msec*.001)/dt);
    assert(max_dev_samp == expected_max_dev,'unexpected max dev samp')
    switch sorterflag
        case 0 % offline sorter (manual)
            tc_ix = abs(offsets_samp(1)) + 1;  
            search_dir(u) = sign(I-tc_ix);
            assert(search_dir(u)~=0,'handling of 0 search direction is not yet defined')
            ctr_offset(u) = I-tc_ix;           
            offsets_search(u,:) = sort(max((abs(ctr_offset(u)) + [-max_dev_samp, max_dev_samp]),0)*sign(ctr_offset(u)));  
            [snips_search,samps_search] = create_snips(tsGP,data,fs(u),offsets_search(u,:));
            dists{u} = get_tc_ex_dist(snips_search,(-offsets_search(u,1))+1,ct_sn_gp_pol(u));
            ti1 = 'TC aligned';               
        case 1
            start_ix = abs(offsets_samp(1)) + 1;  
            ctr_offset(u) = I-start_ix;  
            offsets_search(u,:) = ctr_offset(u) + [-max_dev_samp, max_dev_samp];
            [snips_search,samps_search] = create_snips(tsGP,data,fs(u),offsets_search(u,:));
            dists{u} = get_start_ex_dist(snips_search,(-offsets_search(u,1))+1,ct_sn_gp_pol(u));   
            ti1 = 'Original auto-sorting alignment';               
    end %sw
    [snips_ex{u},samp_ex{u}] = create_snips(tsGP+(dists{u}*dt),data,fs(u),offsets_ex);
    fig_offsets = [offsets_samp; offsets_ex];
    fig_snips = {snips_gp{u};snips_ex{u}};
    fig_ti = {ti1;['extremum aligned (max abs shift diff ',num2str(max_dev_samp) ' samples)', ' + interpolation']};  
    iFlag = [false;true];
    if writeFigs
        figure('Position',fig_dims);
        nF = numel(fig_snips);
        tl = tiledlayout(1,nF,'Padding', 'compact', 'TileSpacing', 'compact');
        titlestr = ['snip ',fnstr, ' (gp only): ', escUscore(sortfile), ' (',mptp,'/',Area,')'];
        tl.Title.String = titlestr;
        tl.Title.FontSize = tisz;
        for f = 1:nF
            nexttile
            of = fig_offsets(f,:);
            sn = fig_snips{f}; 
            x = (of(1)):(of(end)); 
            plot(x,sn,'Color',sclr,'LineWidth',slw)
            hold on;
            ct = fn(sn,1);
            pm = plot(x,ct,'Color',mclr,'LineWidth',mlw);    
            if iFlag(f)
                xq = x(1):1/upfac:x(end); % matlab does similar end-anchoring in their interpolation example
                % so note this implies that length(xq) =
                % length(x)*upfac-(upfac-1)
                vq = interp1(x,ct,xq,'spline');  
                hold on;
                plot(xq,vq,'Color',iclr,'LineWidth',ilw)
            end
            ylabel('V')
            xlabel('Samples (0 = alignment point)')
            xlim([min(x),max(x)])
            ylim([ymin,ymax]); % new 8/10/21
            title(fig_ti{f})
            legend(pm,['SNR = ', num2str(getWaveSNR(sn,1))],'Box','off');
         end % f
         %confirmed all sort entries numeric in recordings table
         tifName = strrep(sortfile,'.mat','.tif');
         tifpath = fullfile(figprepath,tifName);
         saveas(gcf,tifpath)  
         close all;
    end %if
end %u
% dist information 
mndists = cell2mat(cellfun(@(x) mean(x),dists,'UniformOutput',false));
%%
fprintf('note there were %d false entries for load_ok\n',nnz(~load_ok));
%%
% %% saving
if writeData
   writepath = fullfile(writeprepath,writefile);
   save(writepath,vars_to_save{:},'-v7.3')
end

