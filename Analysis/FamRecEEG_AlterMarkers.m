%% FamRecEEG ALTER MARKERS
% Checks whether enc_start, enc_stop, ret_start and ret_Stop markers are in
% the data. When this is not the case it adds them to it. Also it makes
% another column which contains the original markers.

% VARIABLES
StartMarkerEnc      = curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Start Encoding')==1)...
                      );
EndMarkerEnc        = curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'End Encoding')==1)...
                      );
StartMarkerRet      = curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Start Retrieval')==1)...
                      );
EndMarkerRet        = curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'End Retrieval')==1)...
                      );
StimOnsetMarkerEnc  = curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Stimulus Onset')==1)...
                      ); 
StimOnsetMarkerRet  = [curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Stimulus Onset Old')==1)...
                      )
                      curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Stimulus Onset New')==1)...
                      )];
EyesOpenMarker      = [curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Eyes Open BefEnc')==1)...
                      )
                      curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Eyes Open AftEnc')==1)...
                      )
                      curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Eyes Open AftRet')==1)...
                      )]; 
EyesClosedMarker     = [curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Eyes Closed BefEnc')==1)...
                      )
                      curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Eyes Closed AftEnc')==1)...
                      )
                      curexperiment.original_markers(...
                      find(strcmp({curexperiment.original_markers.description}, 'Eyes Closed AftRet')==1)...
                      )]; 
SubsRec             = 23;
SubsFam             = [21, 22];
SubsMiss            = [24, 25, 26];
Rec                 = 511;
Fam                 = 512;
Miss                = 513;
FA                  = 573;
CRREC               = 571;
CRFAM               = 572;

% add a column for the original EEG markers
tmp=cell(size(data_markers.event)); [data_markers.event(:).original_marker] =deal(tmp{:});
clear tmp
i=1;
while i < length(data_markers.event)+1
   % exclude all non-marker rows
   if isequal(cellstr(data_markers.event(i).type),cellstr(curexperiment.eventtype)) == 0
      % delete non-marker row
       data_markers.event(i) = [];
   else
       % add a column with the original markers
        data_markers.event(i).original_marker = data_markers.event(i).value - curexperiment.marker_offset;
       % go to the next row
        i = i +1;         
   end
end
clear i

% check if all markers are there
StartEnc        = 0;
StopEnc         = 0;
StartRet        = 0;
StopRet         = 0;
for i=1:length(data_markers.event)  
    % check if data contains begin and end encoding and retrieval markers
    if data_markers.event(i).original_marker == StartMarkerEnc.original_marker
        StartEnc    = StartEnc +1;
    elseif data_markers.event(i).original_marker == EndMarkerEnc.original_marker
        StopEnc     = StopEnc +1;
    elseif data_markers.event(i).original_marker == StartMarkerRet.original_marker
        StartRet    = StartRet +1;
    elseif data_markers.event(i).original_marker == EndMarkerRet.original_marker
        StopRet     = StopRet +1;
    end
end
clear i
e = 0;
if StartEnc ~= StartMarkerEnc.count
    % the start marker is missing
    fprintf(2,['ERROR Start Enc' char(10)])
    e = e+1;
    for i=1:length(data_markers.event) 
        % determine the first stimulus onset
        if data_markers.event(i).original_marker == StimOnsetMarkerEnc.original_marker
            % add an arteficial start encoding marker before the first stimulus
            data_markers.event(i-1).original_marker = StartMarkerEnc.original_marker;
            break
        end
    end
    display(sprintf('\nERROR Start Enc Solved\n'))
end
if StopEnc ~= EndMarkerEnc.count
    fprintf(2,['ERROR Stop Enc' char(10)])
    e = e+1;
end
if StartRet ~= StartMarkerRet.count
    fprintf(2,['ERROR Start Ret' char(10)])
    e = e+1;
    for i=1:length(data_markers.event) 
        % determine the first stimulus onset
        if (data_markers.event(i).original_marker == StimOnsetMarkerRet(1).original_marker) || (data_markers.event(i).original_marker == StimOnsetMarkerRet(2).original_marker)
            % add an arteficial start encoding marker before the first stimulus
            data_markers.event(i-1).original_marker = StartMarkerRet.original_marker;
            break
        end
    end
    display(sprintf('\nERROR Start Ret Solved\n'))
end
if StopRet ~= EndMarkerRet.count
    fprintf(2,['ERROR Stop Ret' char(10)])
    e = e+1;
end
if e == 0
    display(sprintf('\nAll Encoding and Retrieval markers present\n'))
end
clear e

%% ENCODING 
% load in the behavioral data (encoding)
data_behav_enc = xlsread(fullfile(curexperiment.datafolder_inputbehav, 'MarkersEncRet.xlsx'));

% replace NaN with zero
data_behav_enc(isnan(data_behav_enc)) = 0; 

% set up variables to check the data (encoding)
enc_subs_recollection              = 0;
enc_subs_familiarity               = 0;
enc_subs_miss                      = 0;

% loop through encoding data, find the right subject, count the number of trials
b = 0; % use b as an end marker for the replacement below
for i=1:length(data_behav_enc)
    % find the right subject
    if data_behav_enc(i,1) == str2double(subjectdata.subjectnr)
        b = i;
        % determine susequent memory performance
        if ismember(data_behav_enc(i,3), SubsRec)
            enc_subs_recollection = enc_subs_recollection+1;
        elseif ismember(data_behav_enc(i,3), SubsFam)
            enc_subs_familiarity = enc_subs_familiarity+1;
        elseif ismember(data_behav_enc(i,3), SubsMiss)
            enc_subs_miss = enc_subs_miss+1;
        end
    end
end
clear i

% set up variables to check the data (encoding)
enc_subs_recollection              = 0;
enc_subs_familiarity               = 0;
enc_subs_miss                      = 0;

% give a new marker value based on type of trial. This is done backwards to
% correct for missing trials at the beginning.
r = 0;
for i=length(data_markers.event):-1:1
    % start one before the end of encoding
    if data_markers.event(i).original_marker == EndMarkerEnc.original_marker
        r = 1;
    end
    % replace the original EEG marker with the new behav_enc marker
    if r == 1 && (ismember(data_markers.event(i).original_marker,StimOnsetMarkerEnc.original_marker))
        if data_behav_enc(b,3) ~= 28 % skip the no response trials
            data_markers.event(i).original_marker = data_behav_enc(b,3);
        end
        b=b-1;
        % determine susequent memory performance
        if ismember(data_markers.event(i).original_marker, SubsRec)
            enc_subs_recollection = enc_subs_recollection+1;
        elseif ismember(data_markers.event(i).original_marker, SubsFam)
            enc_subs_familiarity = enc_subs_familiarity+1;
        elseif ismember(data_markers.event(i).original_marker, SubsMiss)
            enc_subs_miss = enc_subs_miss+1;
        end
    end
    % stop one after the start of encoding
    if data_markers.event(i).original_marker == StartMarkerEnc.original_marker
        r = 0;
    end
end

display(sprintf('\nENCODING\n'))
display(sprintf('\n%d baseline subsequent recollection trials',enc_subs_recollection))
display(sprintf('\n%d baseline subsequent familiarity trials',enc_subs_familiarity))
display(sprintf('\n%d baseline subsequent miss trials\n',enc_subs_miss))
display(sprintf('\n%d encoding trials in total\n', ...
    enc_subs_recollection+enc_subs_familiarity+enc_subs_miss))

clear i
clear r
clear b
clear enc_stim_new
clear SubsFam
clear SubsMiss
clear SubsRec

%% RETRIEVAL
% load in the behavioral data (retrieval)
data_behav_ret = xlsread(fullfile(curexperiment.datafolder_inputbehav, 'CombinedEncRet.xlsx'));

% set up variables to check the data (retrieval)
recollection                   = 0;
familiarity                    = 0;
miss                           = 0;
false_alarm                    = 0;
correct_rejection_rec          = 0;
correct_rejection_fam          = 0;

% loop through retrieval data, find the right subject, count the number of trials,
% and give a new value based on type of trial.
b = 0;
curr_col = length(data_behav_ret(1,:))+1;
for i=1:length(data_behav_ret)
    % find the right subject
    if data_behav_ret(i,1) == str2double(subjectdata.subjectnr)
        b = i;       
        % OLD
        % old, old, very sure, enc response
        if data_behav_ret(i,9) == 11 && data_behav_ret(i,12) == 13 && data_behav_ret(i,16) > 0
            recollection = recollection+1;
            data_behav_ret(i,curr_col) = Rec;
        % old, not/bit sure, enc response
        elseif data_behav_ret(i,9) == 11 && (data_behav_ret(i,12) == 11 || data_behav_ret(i,12) == 12)  && data_behav_ret(i,16) > 0 
            familiarity = familiarity+1;
            data_behav_ret(i,curr_col) = Fam;
        % old, new, very/not/bit sure, enc response
        elseif data_behav_ret(i,9) == 12 && (data_behav_ret(i,12) == 21 || data_behav_ret(i,12) == 22 || data_behav_ret(i,12) == 23) && data_behav_ret(i,16) > 0
            miss = miss+1;
            data_behav_ret(i,curr_col) = Miss;
        % NEW
        % new, old, very/bit/not sure
        elseif data_behav_ret(i,9) == 21 && (data_behav_ret(i,12) == 11 || data_behav_ret(i,12) == 12 || data_behav_ret(i,12) == 13)
            false_alarm = false_alarm+1;
            data_behav_ret(i,curr_col) = FA;
        % new, new, very sure
        elseif data_behav_ret(i,9) == 22 && data_behav_ret(i,12) == 23
            correct_rejection_rec = correct_rejection_rec+1;
            data_behav_ret(i,curr_col) = CRREC;
        % new, new, not/bit sure
        elseif data_behav_ret(i,9) == 22 && (data_behav_ret(i,12) == 21 || data_behav_ret(i,12) == 22)
            correct_rejection_fam = correct_rejection_fam+1;
            data_behav_ret(i,curr_col) = CRFAM;
        end
    end
end
clear i
clear curr_cell

% set up variables to check the data (retrieval)
recollection                   = 0;
familiarity                    = 0;
miss                           = 0;
false_alarm                    = 0;
correct_rejection_rec          = 0;
correct_rejection_fam          = 0;

% replace the original EEG markers with the new behav_ret markers.
r = 0;
b = b - curexperiment.Ntrials_ret+1;
for i=1:length(data_markers.event)  
    % stop one before the last retrieval trial
    if data_markers.event(i).original_marker == EndMarkerRet.original_marker
        r = 0; 
    end
    % replace the original EEG marker with the new behav_ret marker
    if r == 1 && (ismember(data_markers.event(i).original_marker,StimOnsetMarkerRet(1).original_marker) || ismember(data_markers.event(i).original_marker,StimOnsetMarkerRet(2).original_marker))
        data_markers.event(i).original_marker = data_behav_ret(b,length(data_behav_ret(1,:)));
        b = b+1;
        % determine memory performance
        if ismember(data_markers.event(i).original_marker, Rec)
            recollection = recollection+1;
        elseif ismember(data_markers.event(i).original_marker, Fam)
            familiarity = familiarity+1;
        elseif ismember(data_markers.event(i).original_marker, Miss)
            miss = miss+1;
        elseif ismember(data_markers.event(i).original_marker, FA)
            false_alarm = false_alarm+1;
        elseif ismember(data_markers.event(i).original_marker, CRREC)
            correct_rejection_rec = correct_rejection_rec+1;
        elseif ismember(data_markers.event(i).original_marker, CRFAM)
            correct_rejection_fam = correct_rejection_fam+1;
        end
    end
    % begin one after the first retrieval trial
    if data_markers.event(i).original_marker == StartMarkerRet.original_marker
        r = 1;
    end
end
clear r
clear b
clear i
clear CRFAM
clear CRREC
clear FA
clear Fam
clear Miss
clear Rec

display(sprintf('\nRETRIEVAL\n'))
display(sprintf('\n%d recollection trials',recollection))
display(sprintf('\n%d familiarity trials',familiarity))
display(sprintf('\n%d miss trials\n',miss))
display(sprintf('\n%d very confident correct rejection trials',correct_rejection_rec))
display(sprintf('\n%d not/bit confident correct rejection trials',correct_rejection_fam))
display(sprintf('\n%d false alarm trials\n',false_alarm))
display(sprintf('\n%d retrieval trials in total\n',...
    recollection+familiarity+miss+correct_rejection_rec+correct_rejection_fam+false_alarm))

%% REST

% set up variables to check the data (encoding)
eyes_open              = 0;
eyes_closed            = 0;
r=1;
s=1;
% loop through data, count the number of trials
for i=1:length(data_markers.event) 
    % adjust EEG markers for the first two participants
    if strcmp(subjectdata.subjectnr,'101') || strcmp(subjectdata.subjectnr,'102')
        if data_markers.event(i).original_marker == 3 && i<10 % 3 was the old marker used in the first 2 subjects
           data_markers.event(i).original_marker = EyesOpenMarker(1).original_marker;
        elseif data_markers.event(i).original_marker == 3 && (i>1350 && i<1400)  % 3 was the old marker used in the first 2 subjects
           data_markers.event(i).original_marker = EyesOpenMarker(2).original_marker;
        elseif data_markers.event(i).original_marker == 3 && i>5800  % 3 was the old marker used in the first 2 subjects
           data_markers.event(i).original_marker = EyesOpenMarker(3).original_marker;
        elseif data_markers.event(i).original_marker == 5 && i<10 % 5 was the other old marker used in the first 2 subjects
            data_markers.event(i).original_marker = EyesClosedMarker(1).original_marker;
        elseif data_markers.event(i).original_marker == 5 && (i>1350 && i<1400) % 5 was the other old marker used in the first 2 subjects
            data_markers.event(i).original_marker = EyesClosedMarker(2).original_marker;
        elseif data_markers.event(i).original_marker == 5 && i>5800 % 5 was the other old marker used in the first 2 subjects
            data_markers.event(i).original_marker = EyesClosedMarker(3).original_marker;
        end
    end
    % determine the amount of trials
    if data_markers.event(i).original_marker == EyesOpenMarker(1).original_marker || ...
       data_markers.event(i).original_marker == EyesOpenMarker(2).original_marker || ...
       data_markers.event(i).original_marker == EyesOpenMarker(3).original_marker
       eyes_open = eyes_open+1;
       restMarkers(r) = data_markers.event(i).original_marker;
       r=r+1;
       % determine the sample of the marker
       samples(s) = data_markers.event(i).sample;
       if (eyes_open > 1 || eyes_closed > 1) && samples(s)-samples(s-1)<40*fs % skip marker if there is less than 40 seconds between markers
           data_markers.event(i).original_marker = 0;
           samples = samples(1:s-1);
           s=s-1;
       end
       s=s+1;
    elseif data_markers.event(i).original_marker == EyesClosedMarker(1).original_marker || ...
       data_markers.event(i).original_marker == EyesClosedMarker(2).original_marker || ...
       data_markers.event(i).original_marker == EyesClosedMarker(3).original_marker
       eyes_closed = eyes_closed+1;
       restMarkers(r) = data_markers.event(i).original_marker;
       r=r+1;
       % determine the sample of the marker
       samples(s) = data_markers.event(i).sample;
       if ((eyes_open>1 || eyes_closed>1) || (eyes_open>0 && eyes_closed>0)) && samples(s)-samples(s-1)<40*fs % skip marker if there is less than 40 seconds between markers
           data_markers.event(i).original_marker = 0;
           samples(s-1) =[];
           s=s-1;
       end
       s=s+1; 
    end
    
end
clear i

% transform the samples into timepoints in sec
timepoints = samples./fs;
% look at the interval between triggers
intvl = 1;
for i=1:length(timepoints)-1
    interval(intvl) = timepoints(i+1)-timepoints(i);
    intvl = intvl+1;
end

clear samples
clear timepoints
clear intvl
clear s

display(sprintf('\nREST\n'))
display(sprintf('\n%d eyes open trials',eyes_open))
display(sprintf('\n%d eyes closed trials',eyes_closed))
display(sprintf('\n%d rest trials in total\n', ...
    eyes_open+eyes_closed))

%% WRAPPING UP
% replace the marker values with the original markers
r = 0;
for i=1:length(data_markers.event)  
    % skip practice trials
    if data_markers.event(i).original_marker == StartMarkerEnc.original_marker
        r = 1;
    elseif data_markers.event(i).original_marker == EndMarkerEnc.original_marker
        r = 0;
    elseif data_markers.event(i).original_marker == StartMarkerRet.original_marker
        r = 1;
    elseif data_markers.event(i).original_marker == EndMarkerEnc.original_marker
        r = 0;    
    % restEEG
    elseif data_markers.event(i).original_marker == EyesOpenMarker(1).original_marker || ...
       data_markers.event(i).original_marker == EyesOpenMarker(2).original_marker || ...
       data_markers.event(i).original_marker == EyesOpenMarker(3).original_marker  
         r =1;
    elseif data_markers.event(i).original_marker == EyesClosedMarker(1).original_marker || ...
         data_markers.event(i).original_marker == EyesClosedMarker(2).original_marker || ...
         data_markers.event(i).original_marker == EyesClosedMarker(3).original_marker  
         r =1;
    end
    if r == 1
        data_markers.event(i).value = data_markers.event(i).original_marker;
    end
end
clear r
clear i
% remove the 'original_marker field'
data_markers.event = rmfield(data_markers.event,'original_marker');
% create an event file
event = data_markers.event;
% create a list of new marker values
ret_stim_new = unique(data_behav_ret(:,length(data_behav_ret(1,:))));
enc_stim_new = unique(data_behav_enc(:,length(data_behav_enc(1,:))));
rest_stim_new = unique(restMarkers);

% save the data with altered markers
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_RawData_AlterMarkers.mat'],'data_markers'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_AlterMarkers_Events.mat'],'event'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_EncAlterMarkers.mat'],'enc_stim_new'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_RetAlterMarkers.mat'],'ret_stim_new'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_RestAlterMarkers.mat'],'rest_stim_new');
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_RestAlterMarkersInt.mat'],'interval');

% save info on the preprocessing trials
if exist(outputfile,'file')
   load(outputfile)
end

Data.headers_ret  = cellstr(['recollection           '; 'familiarity            '; 'miss                   '; ...
                            'false_alarm            '; 'correct_rejection_rec  '; 'correct_rejection_fam  '])';
Data.headers_enc  = cellstr(['recollection           '; 'familiarity            '; 'miss                   '])';
Data.headers_rest = cellstr(['eyes_open              '; 'eyes_closed            '])';

Data.pre_data_ret(f,:) = [recollection familiarity miss ...
    false_alarm correct_rejection_rec correct_rejection_fam];
Data.pre_data_enc(f,:) = [enc_subs_recollection enc_subs_familiarity enc_subs_miss];
Data.pre_data_rest(f,:) = [eyes_open eyes_closed];

save(outputfile,'Data')



clear StartEnc
clear StopEnc
clear StartRet
clear StopRet
clear data_markers
clear data_behav_ret
clear data_behav_enc
clear subs_recollection  
clear subs_familiarity              
clear subs_miss           
clear enc_subs_familiarity
clear enc_subs_miss
clear enc_subs_recollection
clear recollection            
clear familiarity             
clear miss                                    
clear false_alarm                     
clear correct_rejection_rec           
clear correct_rejection_fam  
clear eyes_closed
clear eyes_open
clear Data
clear EndMarkerEnc
clear EndMarkerRet
clear EyesClosedMarker
clear EyesOpenMarker
clear StartMarkerEnc
clear StartMarkerRet
clear StimOnsetMarkerEnc
clear StimOnsetMarkerRet


