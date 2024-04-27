% compute_features_loop.m
% 12/23/23
% assumes that generate_snips_loop 
% has already been run
% computes several features, beyond those used for clustering

%%
clear all;
close all;
clc;
warning('on','all')
%% 
subj = 'G';    
mptp = 'Pre';
%%
Area = 'GPi';
fnstr = 'median'; % mean or median

%% paths
basepath = pwd;
scriptdirs = {'helper_functions';
			'snip_processing';
			'feature_functions'};
scriptpaths = fullfile(basepath,scriptdirs);
addpath(scriptpaths{:}) 

snipfile = 'snipdata.mat';
snipdir = fullfile('snip_output',subj,mptp);
snipprepath = fullfile(basepath,snipdir);
snippath = fullfile(snipprepath,snipfile);

datadir = 'GPi_input_data';
dataprepath = fullfile(basepath,datadir);
addpath(dataprepath)  
listfile = ['DataList',subj,mptp,'.mat'];
listpath = fullfile(dataprepath,listfile); 
fprintf('loading %s\n',listpath);   
load(listpath,'datalist');
sortprepath = fullfile(dataprepath,subj,mptp,'spike_data');


%% mean or median 
switch fnstr
    case 'median'
        fn = @(x,d) median(x,d);
    case 'mean'
        fn = @(x,d) mean(x,d);
    otherwise
        error('unrecognized function string')
end %sw
%%
iFlag = true; % use interpolation
upfac = 4;

%% writing prefs
writeData = true;
writedir = fullfile('feat_output',subj,mptp);
writeprepath = fullfile(basepath,writedir);
writefile = 'featdata.mat';

vars_to_save = {'subj','mptp','Area',...
    'offsets','offsets_shifted','load_ok','ts_ok','dists','ct_sn_gp_pol','fs',...
    'snips_gp','samps_gp','snips_ex','samps_ex','feat',...
    'featStrs','sncts','datalist'};
	
%%
fprintf('loading %s\n',snippath)
load(snippath)

%%
nU = size(datalist,1);
add_nan = false(nU,1);
sncts = cell(nU,1);


%%
for u  = 1:nU
	fprintf('%d of %d\n',u,nU); 
    if ~ts_ok(u)
        warning('invalid ts data for this unit; populating with empty entries');
        add_nan(u) = true;
        continue;
    end
	snips = snips_ex{u}; % aligned on extremum
	ctraw = fn(snips,1);
	if iFlag %snct = "snip central tendency" (mean or median)
		snct = ipSnip(ctraw,upfac);
        Fs = fs(u)*upfac; 
    else 
		snct = ctraw;
        Fs = fs(u); 
    end
	sncts{u} = snct;	
    % fill in feat struct: n indicates normalization by spike amplitude
    % starting with waveform features:
    feat.dur(u,1) = get_duration_msec(snct,2,Fs,false);	
    feat.dur(u,1) = get_duration_msec(snct,2,Fs,false);
    feat.durn(u,1) = get_duration_msec(snct,2,Fs,true);
    feat.adur(u,1) = abs(feat.dur(u,1)); % helpful if don't want polarity to influence (especially for cases where PT diff close to 0)
    feat.adurn(u,1) = abs(feat.durn(u,1));
	feat.amp(u,1) = get_amplitude(snct,2);	
	feat.pol(u,1) = ct_sn_gp_pol(u); 
	feat.ABratio(u,1) = getABratio(snct,2);
    feat.waveSNR(u,1) = getWaveSNR(snips_ex{u},1); % note this will use mean regardless of ct fn
	feat.ptszd(u,1) = get_pt_sz_diff(snct,2,false);
	feat.ptszdn(u,1) = get_pt_sz_diff(snct,2,true);
    feat.hw(u,1) = get_halfwidth_msec(snct,2,Fs,false);
    feat.hwn(u,1) = get_halfwidth_msec(snct,2,Fs,true);	
    feat.rcvs(u,1) = get_recov_slope(snct,0.3,Fs,false);  
    feat.rcvsn(u,1) = get_recov_slope(snct,0.3,Fs,true);	
	feat.rpsn(u,1) = get_repol_slope(snct,0.3,Fs,true);
    sortfile = datalist.sortfile{u};
    sortpath = fullfile(sortprepath,sortfile);
    fprintf('loading %s\n',sortpath)
	load(sortpath,'S');	
    gp = S.units.gp;
    ts = S.units.ts;
    Evts = S.Evts;	
	% firing rate features
    % gp = all good period; hd = hold periods
	feat.gpFR(u,1) = get_gp_fr(ts,gp); 
	feat.hdFR(u,1) = get_hd_fr(ts,Evts);
	feat.gpCV(u,1) = get_gp_CV(ts,gp);
	feat.hdCV(u,1) = get_hd_CV(ts,Evts);
	feat.gpSkew(u,1) = get_gp_skew(ts,gp);
	feat.hdSkew(u,1) = get_hd_skew(ts,Evts);
	feat.gpmb(u,1) = get_gp_mburst(ts,gp);
	feat.hdmb(u,1) = get_hd_mburst(ts,Evts);
	feat.sorterflag(u,1) = double(datalist.sorterflag(u));
end %u

%%
for i = find(add_nan)
   feat = feat_add_nan(feat,i); 
end


%% store this map with the output for reference

featStrs = containers.Map();

featStrs('dur') = 'signed duration (ms)';
featStrs('durn') = 'normalized signed duration';
featStrs('adur') = 'absolute duration (ms)';
featStrs('adurn') = 'normalized absolute duration';
featStrs('amp') = 'amplitude';
featStrs('pol') = 'polarity';
featStrs('ABratio') = 'normalized post-pre peak difference';
featStrs('waveSNR') = 'SNR';
featStrs('ptszd') = 'PT size difference';
featStrs('ptszdn') = 'normalized PT size difference';
featStrs('hw') = 'waveform half-width (ms)';
featStrs('hwn') = 'normalized waveform half-width';
featStrs('rcvs') = 'recovery slope (V/ms)';
featStrs('rps') = 'repolarization slope (V/ms)';
featStrs('rcvsn') = 'normalized recovery slope';
featStrs('rpsn') = 'normalized repolarization slope';
featStrs('gpFR') = 'firing rate (all good period)';
featStrs('hdFR') = 'firing rate (hold period)';
featStrs('gpCV') = 'ISI CV (all good period)';
featStrs('hdCV') = 'ISI CV (hold period)';
featStrs('gpSkew') = 'ISI skew (all good period)';
featStrs('hdSkew') = 'ISI skew (hold period)';
featStrs('gpmb') = 'Mizuseki burst index (all good period)';
featStrs('hdmb') = 'Mizuseki burst index (hold period)';
featStrs('sorterflag') = 'sort method (0 = manual, 1 = automated)';

%% saving
if writeData
   writepath = fullfile(writeprepath,writefile);
   mkdir(writeprepath)
   fprintf('writing %s\n',writepath);
   save(writepath,vars_to_save{:},'-v7.3')
end
%%
function feat = feat_add_nan(feat,u)
    flds = fieldnames(feat); % this will not work if row 1
    for f = 1:numel(flds)
        feat.(flds{f})(u,1) = nan;
    end
end

