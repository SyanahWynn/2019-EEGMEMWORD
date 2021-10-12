%% FamRecEEG_ERP_Analyses
% Do within subject ERP analyses on the FN400 and Parietal Old/New components

% loop through the datasets
for d=1:length(curexperiment.datasets)-1 % exclude Rest EEG
    for l=1:curexperiment.levels
        
        %% ERP ANALYSES
        % Select trials based upon condition
        cfg = [];
        % define the current dataset
        evalc(sprintf('curdat = curexperiment.data%d.l%d',d,l));
        for t=1:length(fieldnames(curdat))
            % define the current condition
            evalc(sprintf('curcond = curexperiment.data%d.l%d.condition%d',d,l,t));
            % find the trails corresponding to the current condition
            cfg.trials             = find(ismember(curexperiment.datasets(d).trialinfo(:,1),curcond)); 
            if length(cfg.trials) >= 1 % only include if there are more than 1 trials in the condition
                % Data per condition
                data_org = ft_preprocessing(cfg, curexperiment.datasets(d));
                % ERP analysis per condition
                %cfg.channel            = 'EEG';     
                cfg.channel            = 'all'; %include VEOG & HEOG
                data_ERP(t)           = ft_timelockanalysis(cfg,curexperiment.datasets(d));
                % perform baseline correction
                cfg.baseline           = curexperiment.baselinewindow;
                data_ERP_norm(t)      = ft_timelockbaseline(cfg,data_ERP(t));
                % substract the ERP from the original data (for the induced power)
                for i=1:length(data_org.trial)
                    data_org.trial{1,i}=data_org.trial{1,i}-data_ERP_norm(t).avg;
                end
                % save the data
                data_cond              = data_ERP_norm(t);
                evalc(sprintf('save([curexperiment.analysis_loc filesep subjectdata.subjectnr curexperiment.dataset_name{d} curexperiment.data%dl%d_name{t} ''_ERP''],''data_cond'')',d,l));
                clear data_cond
                data_org.cfg.previous      = [];
                data_cond              = data_org;
                data_cond.cfg.previous = []; % clear previous
                evalc(sprintf('save([curexperiment.analysis_loc filesep subjectdata.subjectnr curexperiment.dataset_name{d} curexperiment.data%dl%d_name{t} ''_IRP''],''data_cond'')',d,l));
                clear data_org
            end   
        end  
        
        %% EVOKED POWER
        % define the frequencies of interest
        freq_names = fieldnames(curexperiment.freq_interest);
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
            for i=1:length(data_ERP_norm)
                display(sprintf('\nCurrent evoked power analysis:'))
                display(eval(sprintf('curexperiment.data%dl%d_name{i}(2:end)\n',d,l)))
                if not(isempty(data_ERP_norm(i).avg))
                    evalc(sprintf('data_freq_%s(i) = ft_freqanalysis(cfg, data_ERP_norm(i));',freq_names{fr}));
                end
            end
        end
        
        %% SAVE DATA
        for fr=1:length(fieldnames(curexperiment.freq_interest))
            evalc(sprintf('data_freq = data_freq_%s;',freq_names{fr}));
            for i=1:length(data_freq)
                if not(isempty(data_freq(i).powspctrm))
                    data_cond = data_freq(i);
                    evalc(sprintf('save([curexperiment.analysis_loc filesep subjectdata.subjectnr curexperiment.dataset_name{d} curexperiment.data%dl%d_name{i} ''_Evoked_TF''],''data_cond'')',d,l));
                end
            end
        end

        clear data_freq_norm
        clear data_ERP*
        clear curdat
        clear curcond
        clear t
        clear data_freq*
        clear data_cond
        clear data_set
        clear fr
        clear t
    end
end

clear d
clear l
