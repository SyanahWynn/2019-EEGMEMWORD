%% FamRecEEG_TF_Analyses
% Do within subject time-frequency analyses

% determine subject frequency data
TFdir      = fullfile(curexperiment.analysis_loc, sprintf('%s*TF.mat*',subjectdata.subjectnr));
TFdf       = dir(TFdir);
TFfiles    = {TFdf.name};

% set the names of the frequency ranges of interest
freq_names = fieldnames(curexperiment.freq_interest);

% loop over the datasets
for d=1:length(curexperiment.datasets)-1 % skip rest
    % locate current dataset files
    display(sprintf('\n%s\n', curexperiment.dataset_name{d}(2:end)))
    TFfiles_dat = TFfiles(find(~cellfun('isempty',strfind(TFfiles,curexperiment.dataset_name{d}))));
    % loop over all levels of processing
    for l=1:curexperiment.levels
        % locate current level files
        evalc(sprintf('curlevnames = curexperiment.data%dl%d_name',d,l));
        display(sprintf('\n%s %s\n',subjectdata.subjectnr,curexperiment.level_name{l}(2:end)))
        TFfiles_lev =[];
        for i=1:length(curlevnames)
            TFfiles_lev = [TFfiles_lev TFfiles_dat(find(~cellfun('isempty',strfind(TFfiles_dat,strcat(curlevnames{i},'_')))))];
        end
        %% TRIAL SELECTION
        % Select trials based upon condition
        cfg = [];
        %define the current dataset
        evalc(sprintf('curdat = curexperiment.data%d.l%d',d,l));
        for t=1:length(fieldnames(curdat))
            % define the current condition
            evalc(sprintf('curcond = curexperiment.data%d.l%d.condition%d',d,l,t));
            % find the trails corresponding to the current condition
            cfg.trials = find(ismember(curexperiment.datasets(d).trialinfo(:,1),curcond)); 
            if length(cfg.trials) >= 1
                data(t) = ft_selectdata(cfg,curexperiment.datasets(d));
            end
            if l==2 % FamRec analyses
                evalc(sprintf('post_data_%s(f,t) = length(cfg.trials);',curexperiment.datasets_names{d}(6:end)));
            end
        end

        clear curdat
        clear curcond
        clear t

        %% TOTAL POWER
        % loop over them and do freq analyses
        for fr=1:length(fieldnames(curexperiment.freq_interest))         
            % frequency analyses per condition
            cfg              = [];
            cfg.output       = 'pow';
            cfg.channel      = 'EEG';
            cfg.method       = 'mtmconvol';
            cfg.taper        = 'hanning';
            cfg.foi          = getfield(curexperiment.freq_interest, freq_names{fr}); 
            cfg.t_ftimwin    = ones(length(cfg.foi)).*getfield(curexperiment.timwin, freq_names{fr});
            evalc(sprintf('cfg.toi = -curexperiment.prestim%d+.5:.05:curexperiment.poststim%d-.5;',d,d));
            for i=1:length(data)
                display(sprintf('\nCurrent frequency analysis:'))
                display(eval(sprintf('curexperiment.data%dl%d_name{i}(2:end)\n',d,l)))
                if not(isempty(data(i).trialinfo))
                    evalc(sprintf('data_freq_%s(i) = ft_freqanalysis(cfg, data(i));',freq_names{fr}));
                end
            end
        end

        clear data
        clear i
        clear fr

        %% SAVE DATA TOTAL POWER
        for fr=1:length(fieldnames(curexperiment.freq_interest))
            evalc(sprintf('data_freq = data_freq_%s;',freq_names{fr}));
            for i=1:length(data_freq)
                if not(isempty(data_freq(i).powspctrm))
                    data_cond = data_freq(i);
                    evalc(sprintf('save([curexperiment.analysis_loc filesep subjectdata.subjectnr curexperiment.dataset_name{d} curexperiment.data%dl%d_name{i} ''_Total_TF''],''data_cond'')',d,l));
                end
            end
        end
        clear data_cond
        
        %% LOAD DATA EVOKED POWER       
        for fr=1:length(fieldnames(curexperiment.freq_interest)) % loop over the frequency ranges of interest
            % locate current frequency range files
            TFfiles_freq = TFfiles_lev;
            curpow = {'_Total','_Evoked','_Induced'}; % set the current power type of interest
            for po=2:2 % only evoked power is needed, total is there already, and we are going to make induced
                %% LOAD DATA 
                display(sprintf('\nCurrent power type: %s power\n',curpow{po}(2:end)))
                for i=1:length(curlevnames) % loop over the conditions and get the data if available
                    evalc(sprintf('curdatname = curexperiment.data%dl%d_name{i}',d,l));
                    if exist(fullfile(curexperiment.analysis_loc, strcat(subjectdata.subjectnr,curexperiment.dataset_name{d},curdatname,curpow{po}, '_TF.mat')),'file')
                        display(sprintf('\nLoading %s Evoked Power\n', curdatname(2:end)))
                        load(fullfile(curexperiment.analysis_loc, strcat(subjectdata.subjectnr,curexperiment.dataset_name{d},curdatname,curpow{po}, '_TF.mat')));
                        data_freq_evok(i) = data_cond;
                    elseif exist('data_freq','var') && ~exist(fullfile(curexperiment.analysis_loc, strcat(subjectdata.subjectnr,curexperiment.dataset_name{d},curdatname,curpow{po}, '_TF.mat')),'file')
                        display(sprintf('\nUnable to load %s\n', curdatname(2:end)))
                        % copy data from previous entry and then clear the stuct
                        data_freq_evok(i) = data_freq_evok(i-1);
                        data_freq_evok(i) = structfun(@(x) [], data_freq_evok(i), 'UniformOutput', false);
                    else
                        display(sprintf('\nUnable to load %s\n', curdatname(2:end)))
                    end
                end
                clear data_cond
            end
        end
        
        %% CALCULATE THE INDUCED POWER
        % With the ERP substracted data
        
        % frequency analyses per condition
        cfg              = [];
        cfg.output       = 'pow';
        cfg.channel      = 'all';
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'hanning';
        cfg.foi          = getfield(curexperiment.freq_interest, freq_names{fr}); 
        cfg.t_ftimwin    = ones(length(cfg.foi)).*getfield(curexperiment.timwin, freq_names{fr});
        evalc(sprintf('cfg.toi = -curexperiment.prestim%d+.5:.05:curexperiment.poststim%d-.5;',d,d));
        for i=1:length(curlevnames)
            evalc(sprintf('curdatname = curexperiment.data%dl%d_name{i}',d,l));
            display(sprintf('\nCurrent INDUCED frequency analysis:'))
            display(eval(sprintf('curexperiment.data%dl%d_name{i}(2:end)\n',d,l)))
            % load data
            if exist(fullfile(curexperiment.analysis_loc, strcat(subjectdata.subjectnr,curexperiment.dataset_name{d},curdatname, '_IRP.mat')),'file')
               load(fullfile(curexperiment.analysis_loc, strcat(subjectdata.subjectnr,curexperiment.dataset_name{d},curdatname, '_IRP.mat')))
               data_freq_ind(i) = ft_freqanalysis(cfg, data_cond);
               clear data_cond
            end
        end              
        
        %% SAVE DATA INDUCED POWER
        display('\nSaving induced power data\n')
        for fr=1:length(fieldnames(curexperiment.freq_interest))
            data_freq = data_freq_ind;
            for i=1:length(data_freq)
                if not(isempty(data_freq(i).powspctrm))
                    data_cond = data_freq(i);
                    evalc(sprintf('save([curexperiment.analysis_loc filesep subjectdata.subjectnr curexperiment.dataset_name{d} curexperiment.data%dl%d_name{i} ''_Induced_TF''],''data_cond'')',d,l));
                end
            end
        end
        clear data_cond
        clear i
        clear data_freq*
        
    end   
    % save trial data
    load(outputfile)
    evalc(sprintf('Data.post_data%s(f,:) = post_data%s(f,:);', curexperiment.dataset_name{d}(1:end-4), curexperiment.datasets_names{d}(5:end)));
    %Data.post_data(f,:) = post_data(f,:);
    save(outputfile,'Data')
    
    clear post_data*
    clear Data
end

clear d
clear matfiles
clear matdf
