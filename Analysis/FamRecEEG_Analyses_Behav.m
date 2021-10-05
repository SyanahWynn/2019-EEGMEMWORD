%% FamRecEEGpic_BehavAnalysis

%% GENERAL SET-UP
csvdir      = fullfile(curexperiment.datafolder_inputbehav, 'BehavData');
csvdf       = dir(csvdir);
csvfiles    = {csvdf.name};

display(sprintf('\nBEHAVIORAL ANALYSES\n'))

% get the phases of the experiment (because they partly determine filename)
for i=1:length(curexperiment.datasets_names)-1 % skip rest
    phases{i}     = curexperiment.datasets_names{i}(5:end); % phase names
end
clear i

% get the participant numbers
p=1;
for i=1:length(phases):length(csvfiles)
    if length(csvfiles{i})>2
        ppns{p} = csvfiles{i}(1:3);
        p=p+1;
    end
end
clear i
clear p

% to loop or not to loop
loop = true; % loop

%% LOOP OVER PARTICIPANTS OR NOT
curl = '';
% start loop or determine current ppn
if loop
    display('Loop true')
    strt = 1:length(ppns);
else
    display('Loop false')
    strt = f;
end
for p=strt
    cur_ppn = ppns{p};
    fprintf(curl);
    curtxt = sprintf('\nPARTICIPANT %d of %d',p,length(ppns));
    fprintf(curtxt)
    curl = repmat('\b',1,length(curtxt));
    % select files of this participant
    ppnfiles = csvfiles(logical(~cellfun('isempty',strfind(csvfiles,cur_ppn))));    
    for cur_phase=1:length(phases)
        % select the files for this memory phase
        phafile = ppnfiles(logical(~cellfun('isempty',strfind(ppnfiles,phases{cur_phase}))));
        
        %% LOAD FILE
        inputdir = fullfile(csvdir,phafile);
        fid = fopen(inputdir{:},'rt');
        if fid~=-1
            T = textscan(fid, curexperiment.behav.file_format{cur_phase}, 'Delimiter', ',', 'HeaderLines', 21); % skip practice
        else
            error('Cannot open %s\n',inputdir);
        end
        fclose(fid);
        clear inputdir
        clear fid
        
        %% GET THE VARIABLES
        for i=1:length(T)
            evalc(sprintf('ppn.%s = T{i};',curexperiment.behav.vars{cur_phase,i}));
        end
        clear T
        clear i
        clear memfiles
        
        %% RECODE VARIABLES
        % gender
        if ppn.gender{1} == 'f'
            ppn.gender = 1;
        elseif ppn.gender{1} == 'm'
            ppn.gender = 2;
        end
        % ppn
        ppn.ppn = ppn.ppn(1);
        % age
        ppn.age = ppn.age(1);
        % encoding response
        if cur_phase==1
            ppn.enc_resp(strcmp(ppn.enc_resp,'left'))={1}; % pleasant
            ppn.enc_resp(strcmp(ppn.enc_resp,'right'))={2}; % unpleasant
            ppn.enc_resp(strcmp(ppn.enc_resp,''))={9}; % no response
            ppn.enc_resp=cell2mat(ppn.enc_resp);
        end
        % retrieval
        if cur_phase==2
            ppn.ret_resp = ppn.on_resp;
            ppn.ret_RT = ppn.on_RT;
        end
        %% ANALYSES   
        % Encoding/Retrieval No Responses
        if cur_phase==1
            evalc(sprintf('ppn.%s_noresp = sum(ppn.%s_RT(:)==0)',phases{cur_phase}(2:end),phases{cur_phase}(2:end)));
        elseif cur_phase==2
            evalc(sprintf('ppn.%s_noresp = numel(find(ppn.conf_rating==99))',phases{cur_phase}(2:end)));
        end

        % Encoding/Retrieval RTs
        evalc(sprintf('ppn.%s_meanRT = mean(nonzeros(ppn.%s_RT))',phases{cur_phase}(2:end),phases{cur_phase}(2:end)));

        % Retrieval RTs (6 levels of confidence & 4 memory score groups)
        if cur_phase==2
            % confidence levels
            evalc(sprintf('ppn.%s_meanRT_nso = mean(ppn.%s_RT(logical(ppn.conf_rating==11)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % not sure old
            evalc(sprintf('ppn.%s_meanRT_bso = mean(ppn.%s_RT(logical(ppn.conf_rating==12)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % bit sure old
            evalc(sprintf('ppn.%s_meanRT_vso = mean(ppn.%s_RT(logical(ppn.conf_rating==13)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % very sure old
            evalc(sprintf('ppn.%s_meanRT_nsn = mean(ppn.%s_RT(logical(ppn.conf_rating==21)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % not sure new
            evalc(sprintf('ppn.%s_meanRT_bsn = mean(ppn.%s_RT(logical(ppn.conf_rating==22)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % bit sure new
            evalc(sprintf('ppn.%s_meanRT_vsn = mean(ppn.%s_RT(logical(ppn.conf_rating==23)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % very sure new
            % memory score groups
            evalc(sprintf('ppn.%s_meanRT_hit = mean(ppn.%s_RT(logical(ppn.on_acc==11)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % hit
            evalc(sprintf('ppn.%s_meanRT_miss = mean(ppn.%s_RT(logical(ppn.on_acc==12)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % miss
            evalc(sprintf('ppn.%s_meanRT_fa = mean(ppn.%s_RT(logical(ppn.on_acc==21)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % false alarm
            evalc(sprintf('ppn.%s_meanRT_cj = mean(ppn.%s_RT(logical(ppn.on_acc==22)))',phases{cur_phase}(2:end),phases{cur_phase}(2:end))); % correct rejection
        
            % Retrieval counts (6 levels of confidence & 4 memory score groups)
            ppn.count_vso = sum(logical(ppn.conf_rating == 13 & ppn.on_acc == 11)); % very conf hit
            ppn.count_bso = sum(logical(ppn.conf_rating == 12 & ppn.on_acc == 11)); % bit conf hit
            ppn.count_nso = sum(logical(ppn.conf_rating == 11 & ppn.on_acc == 11)); % not conf hit
            ppn.count_nsn = sum(logical(ppn.conf_rating == 21 & ppn.on_acc == 22)); % not conf cr
            ppn.count_bsn = sum(logical(ppn.conf_rating == 22 & ppn.on_acc == 22)); % bit conf cr
            ppn.count_vsn = sum(logical(ppn.conf_rating == 23 & ppn.on_acc == 22)); % very conf cr
            ppn.count_vsm = sum(logical(ppn.conf_rating == 23 & ppn.on_acc == 12)); % very conf miss
            ppn.count_bsm = sum(logical(ppn.conf_rating == 22 & ppn.on_acc == 12)); % bit conf miss
            ppn.count_nsm = sum(logical(ppn.conf_rating == 21 & ppn.on_acc == 12)); % not conf miss

            ppn.count_vs = sum(logical(ppn.conf_rating == 13 | ppn.conf_rating == 23)); % very sure
            ppn.count_bs = sum(logical(ppn.conf_rating == 12 | ppn.conf_rating == 22)); % bit sure
            ppn.count_ns = sum(logical(ppn.conf_rating == 11 | ppn.conf_rating == 21)); % not sure
            
            % new encoding subsequent memory response
            hitrp = 0;
            missrp = 0;
            hitrn = 0;
            missrn = 0;
            ppn.encDm=zeros(curexperiment.Ntrials_enc,1);
            % loop over ret trials
            for i=1:length(ppn.ret_word)
                % loop over enc trials
                for e=1:length(ppn.enc_word)
                    % find match between enc and ret trials
                    if strcmp(ppn.ret_word{i},ppn.enc_word{e})
                        % adjust to no response
                        if ppn.conf_rating(i)==99 || ppn.enc_resp(e)==9
                            ppn.encDm(e)=99;
                        % make Dm responses pleasant
                        elseif ppn.on_acc(i) == 11 && ppn.conf_rating(i) == 13 && ppn.enc_resp(e)==1
                            ppn.encDm(e)=131; % subs hitHC pleasant
                            hitrp=hitrp+1;
                        elseif ppn.on_acc(i) == 11 && (ppn.conf_rating(i) == 12 || ppn.conf_rating(i) == 11) && ppn.enc_resp(e)==1
                            ppn.encDm(e)=121; % subs hitLC pleasant
                            hitrp=hitrp+1;
                        elseif ppn.on_acc(i) == 12 && ppn.enc_resp(e)==1
                            ppn.encDm(e)=111; % subs miss pleasant
                            missrp=missrp+1;
                        % make Dm responses unpleasant
                        elseif ppn.on_acc(i) == 11 && ppn.conf_rating(i) == 13 && ppn.enc_resp(e)==2
                            ppn.encDm(e)=132; % subs hitHC unpleasant
                            hitrn=hitrn+1;
                        elseif ppn.on_acc(i) == 11 && (ppn.conf_rating(i) == 12 || ppn.conf_rating(i) == 11) && ppn.enc_resp(e)==2
                            ppn.encDm(e)=122; % subs hitLC unpleasant
                            hitrn=hitrn+1;
                        elseif ppn.on_acc(i) == 12 && ppn.enc_resp(e)==2
                            ppn.encDm(e)=112; % subs miss unpleasant
                            missrn=missrn+1;
                        end
                    end
                end
            end
            
            % Encoding counts
            ppn.count_SubsHitHC_pos = sum(logical(ppn.encDm == 131));
            ppn.count_SubsHitLC_pos = sum(logical(ppn.encDm == 121));
            ppn.count_SubsMiss_pos = sum(logical(ppn.encDm == 111));
            ppn.count_SubsHitHC_neg = sum(logical(ppn.encDm == 132));
            ppn.count_SubsHitLC_neg = sum(logical(ppn.encDm == 122));
            ppn.count_SubsMiss_neg = sum(logical(ppn.encDm == 112));
            
            % pleasantness & memory performance
            ppn.hit_rate_pleasant = hitrp/(hitrp+missrp);
            ppn.hit_rate_unpleasant = hitrn/(hitrn+missrn);
            
            clear hitrp hitrn missrp missrn
        
            % ROC curve Familiarity/Recollection estimate
            % create scores
            scores = ppn.conf_rating;
            scores(scores==13)= 6; % very sure old
            scores(scores==12)= 5; % bit sure old
            scores(scores==11)= 4; % not sure old
            scores(scores==21)= 3; % not sure new
            scores(scores==22)= 2; % bit sure new
            scores(scores==23)= 1; % very sure new
            scores(scores==99)= []; % no response
            % create labels
            labels = ppn.on_class(logical(ppn.conf_rating~=99)); % get the values with a response
            labels(labels==1)= 1; % old
            labels(labels==2)= 0; % new
            % ROC curve
            [x(:,1),x(:,2)]=perfcurve(labels,scores,1);
            if ~ismember(6,unique(scores))
                display(sprintf('\n%d: no very sure old trials',ppn.ppn(1)))
                x2=x(1:end,:);
                x(2:end+1,:)=x2;
            end
            if ~ismember(5,unique(scores))
                display(sprintf('\n%d: no bit sure old trials',ppn.ppn(1)))
                x2=x(2:end,:);
                x(3:end+1,:)=x2;
            end
            if ~ismember(4,unique(scores))
                display(sprintf('\n%d: no not sure old trials',ppn.ppn(1)))
                x2=x(3:end,:);
                x(4:end+1,:)=x2;
            end
            if ~ismember(3,unique(scores))
                display(sprintf('\n%d: no not sure new trials',ppn.ppn(1)))
                x2=x(4:end,:);
                x(5:end+1,:)=x2;
            end
            if ~ismember(2,unique(scores))
                display(sprintf('\n%d: no bit sure new trials',ppn.ppn(1)))
                x2=x(5:end,:);
                x(6:end+1,:)=x2;
            end
            if ~ismember(1,unique(scores))
                display(sprintf('\n%d: no very sure new trials',ppn.ppn(1)))
                x2=x(6:end,:);
                x(7:end+1,:)=x2;
            end
%             figure;
%             plot(x(:,1),x(:,2));xlim([0 1]);ylim([0 1]);
            x=flipud(x(2:6,:));
            % familiarity and recollection estimate
            
            [ppn.fam ppn.rec] = memorysolve(x);
            
            addpath(genpath('ROC'))
            targf = zeros(1,length(unique(scores))); % frequency matrix for targets
            luref = zeros(1,length(unique(scores))); % frequency matrix for lures
            cnt=1;
            for i=length(unique(scores)):-1:1
                targf(cnt)=sum(logical(scores==i & labels==1));
                luref(cnt)=sum(logical(scores==i & labels==0));
                cnt=cnt+1;
            end
            nBins        = size(targf,2); % number of rating bins
            nConds       = size(targf,1); % number of conditions
            fitStat      = '-LL'; % fit statistic used (maximum likelihood estimation)
            model        = 'dpsd'; % dual-process signal detection (DPSD) model 
            ParNames     = {'Ro' 'F'};
            [x0,LB,UB]   = gen_pars(model,nBins,nConds,ParNames);
            % optional
            subID        = num2str(ppn.ppn);
            groupID      = 'NA';
            condLabels   = {'N/A'};
            modelID      = 'dpsd model 1';
            evalc(sprintf('outpath = ''%s%s_%d'';',curexperiment.scriptdir, curexperiment.name,ppn.ppn'));
            rocData      = roc_solver(targf,luref,model,fitStat,x0,LB,UB, ...
                'groupID',groupID, ...
                'subID',subID, ...
                'condLabels',condLabels, ...
                'modelID',modelID, ... 
                'saveFig',outpath, ...
                'figTimeout',5);
            ppn.hit_rate = rocData.observed_data.accuracy_measures.HR;
            ppn.fa_rate = rocData.observed_data.accuracy_measures.FAR;
            ppn.d_prime = rocData.observed_data.accuracy_measures.Dprime;
            ppn.rec = rocData.dpsd_model.parameters.Ro;
            ppn.fam = rocData.dpsd_model.parameters.F;
            if loop
                if p==1
                    tot_targf = targf;
                    tot_luref = luref;
                else
                    tot_targf = tot_targf+targf;
                    tot_luref = tot_luref+luref;
                end     
            end
            
            clear scores
            clear labels
            clear x
            
            clear targf luref nBins nConds fitStat model ParNames x0 LB UB subID groupID
            clear condLabels modelID outpath roc_solver
        end
    end
    clear cur_phase
    clear phafile

    ppn=rmfield(ppn,{'enc_word','enc_resp','enc_RT','enc_jit','fix_time','encDm',...
    'ret_word','on_class','on_resp','on_RT','on_acc','ret_jit',...
    'ret_resp','ret_RT','conf_resp','conf_RT','conf_rating'});
    curtable=struct2table(ppn);
    if ~loop
        display(sprintf('\n%d',ppn.ppn))
        curtable
    end
    
    if loop
        if p==1
            table_behav = curtable;
            table_roc = rocData;
        else
            table_behav = [table_behav;curtable];
            table_roc = [table_roc;rocData];
        end
    else
        table_behav = curtable;
        table_roc = rocData;
        subjectdata.behavdata=ppn
    end
    clear ppn
    clear cur_ppn
    clear ppnfiles
    clear curtable rocData
end
clear csv*
clear phases
clear p i
clear curl
clear ppns
if exist(outputfile,'file')
   load(outputfile)
end
if loop
    Data.BehavRes= table_behav;
    Data.BehavROC = table_roc;
    
    nBins        = size(tot_targf,2); % number of rating bins
    nConds       = size(tot_targf,1); % number of conditions
    fitStat      = '-LL'; % fit statistic used (maximum likelihood estimation)
    model        = 'dpsd'; % dual-process signal detection (DPSD) model 
    ParNames     = {'Ro' 'F'};
    [x0,LB,UB]   = gen_pars(model,nBins,nConds,ParNames);
    % optional
    subID        = 'all';
    groupID      = 'NA';
    condLabels   = {'NA'};
    modelID      = 'dpsd model 1';
    evalc(sprintf('outpath = ''%s'';',curexperiment.scriptdir));
    rocData      = roc_solver(tot_targf,tot_luref,model,fitStat,x0,LB,UB, ...
        'groupID',groupID, ...
        'subID',subID, ...
        'condLabels',condLabels, ...
        'modelID',modelID, ... 
        'saveFig',outpath, ...
        'figTimeout',5);
    Data.BehavROCtot = rocData;
else
    Data.BehavRes(f,:)= table_behav;
    Data.BehavROC(f,:)= table_roc;
end
clear table_behav
clear targf luref nBins nConds fitStat model ParNames x0 LB UB subID groupID
clear condLabels modelID outpath roc_solver
save(outputfile,'Data')