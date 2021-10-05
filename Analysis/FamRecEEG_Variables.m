%% FamRecEEG VARIABLES

% location of the EEG data
if strcmp(curpc,'CURRENT_DEVICE')
    curexperiment.datafolder_input  = 'LOCATION_OF_RAW_EEG_DATA'; 
end
% location of the behavioral data
if strcmp(curpc,'CURRENT_DEVICE')
    curexperiment.datafolder_inputbehav  = 'LOCATION_OF_RAW_BEHAVIORAL_FILES';
end
% extension of the EEG files
curexperiment.extension             = '*.bdf'; 
% number of trials
curexperiment.Ntrials_ret             = 900; 
curexperiment.Ntrials_enc             = 450; 
%the value you need to substract from the MATLAB markers to get the original EEG markers
curexperiment.marker_offset         = 64512;
% sampling frequency
curexperiment.fs                    = 1024;
% location of outputfiles
if strcmp(curpc,'CURRENT_DEVICE')
    curexperiment.datafolder_output = 'LOCATION_OF_OUTPUTFILES';
end
% location of analyses
curexperiment.analysis_loc = fullfile(curexperiment.datafolder_output, sprintf('%s_Analyses',curexperiment.name));
if ~exist(curexperiment.analysis_loc, 'dir')
    mkdir(curexperiment.analysis_loc);
end
% epoch event type
curexperiment.eventtype             = 'STATUS';
% pre- and post stimulus time
curexperiment.prestim1              = 1.5; % add .5 more for data padding
curexperiment.poststim1             = 2.5; % add .5 more for data padding
curexperiment.prestim2              = 1.5; % add .5 more for data padding
curexperiment.poststim2             = 2.5; % add .5 more for data padding
curexperiment.prestim3              = 0;
curexperiment.poststim3             = 60;
% original markers
description                         = {'Start Rest EEG', 'Stop Rest EEG', ...
                                    'Eyes Open BefEnc', 'Eyes Closed BefEnc', 'Eyes Open AftEnc', 'Eyes Closed AftEnc', 'Eyes Open AftRet', 'Eyes Closed AftRet', ...
                                    'Start Practice Trial', ...
                                    'Start Encoding', 'Stimulus Onset', 'Fixation Onset', 'End Encoding', ...
                                    'Response Pleasant', 'Response Unpleasant', 'Response None', ... 
                                    'Rest onset', 'Rest offset', ...
                                    'Start Retrieval', 'Stimulus Onset Old', 'Stimulus Onset New', 'Fixation Onset', 'End Retrieval',...
                                    'Response Old', 'Response New', 'Response None', ...
                                    'Confidence Onset', 'Response Confidence 1', 'Response Confidence 2', 'Response Confidence 3', 'Response Confidence None'};
original_marker                     = {1,9,...
                                      2,3,4,5,6,7,...
                                      99,...
                                      10,20,40,13,...
                                      33,35,38,...
                                      90,91,...
                                      50,53,55,80,93,...
                                      63,65,68,...
                                      70,73,75,77,78};
count_without_practice              = {3, 3, ...
                                      2,2,2,2,2,2, ...
                                      2,...
                                      1,450,450,1,...
                                      [],[],[],...
                                      3,3,...
                                      1,450,450,450,1,...
                                      [],[],[],...
                                      [],[],[],[],[]};
curexperiment.original_markers      = struct('description', description, 'original_marker', original_marker, 'count', count_without_practice);
clear original_marker
clear count_without_practice
clear description
curexperiment.markers.enc           = 20; % stimulus onset markers
curexperiment.markers.ret           = [53,55]; % stimulus onset markers
% conditions
curexperiment.data1.l1.condition1   = [23,21,22];  curexperiment.data1l1_name{1}   = '_SubsHit';
curexperiment.data1.l1.condition2   = [24,25,26];  curexperiment.data1l1_name{2}   = '_SubsMiss';

curexperiment.data1.l2.condition1   = 23;          curexperiment.data1l2_name{1}   = '_EncSubsHitHC';% encoding, subsequent recollection
curexperiment.data1.l2.condition2   = [21,22];     curexperiment.data1l2_name{2}   = '_EncSubsHitLC';% encoding, subsequent familiarity
curexperiment.data1.l2.condition3   = [24,25,26];  curexperiment.data1l2_name{3}   = '_EncSubsMiss';% encoding, miss

curexperiment.data2.l2.condition1   = 511;         curexperiment.data2l2_name{1}   = '_RetHitHC';% retrieval, recollection
curexperiment.data2.l2.condition2   = 512;         curexperiment.data2l2_name{2}   = '_RetHitLC';% retrieval, familiarity
curexperiment.data2.l2.condition3   = 513;         curexperiment.data2l2_name{3}   = '_RetMiss';% retrieval, miss
curexperiment.data2.l2.condition4   = 571;         curexperiment.data2l2_name{4}   = '_RetCRHC';% retrieval, sure new
curexperiment.data2.l2.condition5   = 572;         curexperiment.data2l2_name{5}   = '_RetCRLC';% retrieval, not/bit sure new
curexperiment.data2.l2.condition6   = 573;         curexperiment.data2l2_name{6}   = '_RetFA';% retrieval, false alarm

curexperiment.data2.l1.condition1   = [511,512];   curexperiment.data2l1_name{1}   = '_Hit';
curexperiment.data2.l1.condition2   = 513;         curexperiment.data2l1_name{2}   = '_Miss';
curexperiment.data2.l1.condition3   = [571,572];   curexperiment.data2l1_name{3}   = '_CR';
curexperiment.data2.l1.condition4   = 573;         curexperiment.data2l1_name{4}   = '_FA';

curexperiment.data3.l1.condition1   = [2,3];       curexperiment.data3l1_name{1}   = '_RestPreEnc';% rest, pre-encoding
curexperiment.data3.l1.condition2   = [4,5];       curexperiment.data3l1_name{2}   = '_RestPostEnc';% rest post-encoding
curexperiment.data3.l1.condition3   = [6,7];       curexperiment.data3l1_name{3}   = '_RestPostRet';% rest post-retrieval

% levels of processing
curexperiment.levels                = length(fieldnames(curexperiment.data1));
curexperiment.level_name{1}         = '_MemoryGlobal';
curexperiment.level_name{2}         = '_MemorySpecific';
curexperiment.level_name{3}         = '_MemoryConfLevels';

% online reference / implicit reference (non-recorded)
curexperiment.extelec.impref        = 'CSM';
% desired new/offline reference(s)
curexperiment.extelec.newref1       = 'EXG5';
curexperiment.extelec.newref2       = 'EXG6';
% EOG electrodes
curexperiment.extelec.heog_l        = 'EXG1'; %left HEOG electrode
curexperiment.extelec.heog_r        = 'EXG2'; %right HEOG electrode
curexperiment.extelec.veog_t        = 'EXG3'; %top VEOG electrode
curexperiment.extelec.veog_b        = 'EXG4'; %bottom VEOG electrode
% number of EEG electrodes
curexperiment.Nelectrodes           = 32;
% electrode layout
% http://www.fieldtriptoolbox.org/example/biosemi/
cfg.layout = 'biosemi32.lay';
% https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=2ahUKEwiL3bqLtvXnAhXtRt8KHcBICr0QFjAAegQIBRAC&url=https%3A%2F%2Fwww.biosemi.com%2Fdownload%2FCap_coords_all.xls&usg=AOvVaw2tlSmP5-v-N4dG2YQqd5x7
curexperiment.elecs.elecpos = [
-27	83	-3
-36	76	24
-71	51	-3
-48	59	44
-33	33	74
-78	30	27
-87	0	-3
-63	0	61
-33	-33	74
-78	-30	27
-71	-51	-3
-48	-59	44
0	-63	61
-36	-76	24
-27	-83	-3
0	-87	-3
27	-83	-3
36	-76	24
48	-59	44
71	-51	-3
78	-30	27
33	-33	74
63	0	61
87	0	-3
78	30	27
33	33	74
48	59	44
71	51	-3
36	76	24
27	83	-3
0	63	61
0	0	88];
curexperiment.elecs.channelpos = curexperiment.elecs.elecpos;
curexperiment.elecs.label={
    'Fp1'
'AF3'
'F7'
'F3'
'FC1'
'FC5'
'T7'
'C3'
'CP1'
'CP5'
'P7'
'P3'
'Pz'
'PO3'
'O1'
'Oz'
'O2'
'PO4'
'P4'
'P8'
'CP6'
'CP2'
'C4'
'T8'
'FC6'
'FC2'
'F4'
'F8'
'AF4'
'Fp2'
'Fz'
'Cz'};
% number of external electrodes
curexperiment.Nextelectrodes        = 8;
% filtering
curexperiment.bp_lowfreq            = .5;
curexperiment.bp_highfreq           = 30; 
% dataset names
curexperiment.datasets_names        = {'data_enc', 'data_ret', 'data_rest'};
curexperiment.define_datasets       = 'curexperiment.datasets = [data_enc, data_ret, data_rest]';
curexperiment.dataset_name{1}       = '_EncData';
curexperiment.dataset_name{2}       = '_RetData';
curexperiment.dataset_name{3}       = '_RestData';
% list of analyses to be done
curexperiment.analyses              = {'erp', 'pow','plt','con'};
curexperiment.Nanalyses.erp         = 15; % amount of outputfiles
curexperiment.Nanalyses.ep          = 15; % amount of outputfiles
curexperiment.Nanalyses.ip          = 15; % amount of outputfiles
curexperiment.Nanalyses.tp          = 18; % amount of outputfiles
curexperiment.Nanalyses.plt         = 75; % amount of outputfiles
% channels to plot
curexperiment.channelgroups         = 2;
curexperiment.plotchannels          = {'F3','Fz','F4','P3','Pz','P4'};
curexperiment.plotchannels_Frontal  = {'F3','Fz','F4'};
curexperiment.plotchannels_Parietal = {'P3','Pz','P4'};
curexperiment.plotcolors            = 'brgkymrgbkymrgbkymrgbkym';
% power analyses
curexperiment.freq_interest.low     = 2:.333:30; %1:2:29; % frequencies of interest
curexperiment.timwin.low            = 0.5; % length of timewindow for the low frequencies
curexperiment.baselinewindow        = [-.2 0]; % baseline window
curexperiment.baselinetype          = 'db'; % baseline window
curexperiment.curpow                = {'_Total','_Evoked','_Induced'}; % set the current power type of interest
% subject groups
curexperiment.subject_groups        = 1;
curexperiment.Nsubs                 = 28;
curexperiment.Nses                   = 1;
curexperiment.behav.file_format     = {'%f%s%f%s%f%s%f%f','%f%s%f%s%f%f%s%f%f%s%f%f%f'}; % file format of phase input files
curexperiment.behav.vars            = [{'ppn','gender','age','enc_word','enc_jit','enc_resp','enc_RT','fix_time','','','','',''};...
                                      {'ppn','gender','age','ret_word','ret_jit','on_class','on_resp','on_RT','on_acc','conf_resp','conf_RT','conf_rating','fix_time'}];
curexperiment.behav.ext             = '.csv'; %extension of inputfiles
curexperiment.behav.hand            = [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2]; %1 = right, 2 = left