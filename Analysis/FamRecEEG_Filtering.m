%% FamRecEEG_Filtering

% load RestEEG interval data
load(fullfile(subjectdata.subjectdir, strcat(subjectdata.subjectnr,'_Raw_RestAlterMarkersInt.mat')));

% loop over the datasets
for d=1:length(curexperiment.datasets)
    % resample if neccesary
    if curexperiment.datasets(d).fsample ~=1024
        cfg.resamplefs = 1024;
        data_resample = ft_resampledata(cfg, curexperiment.datasets(d));
        cfg = [];
        eval(sprintf('clear %s', curexperiment.datasets_names{d}));
        eval(sprintf('%s = ft_preprocessing(cfg,data_resample)',curexperiment.datasets_names{d}));
        % update the datasets
        evalc(curexperiment.define_datasets);
    end
    cfg             = [];
    cfg.bpfilter    = 'yes';
    cfg.bpfreq      = [curexperiment.bp_lowfreq curexperiment.bp_highfreq];
    % filter the data
    data_filter     = ft_preprocessing(cfg, curexperiment.datasets(d));
    cfg             = [];
    if d==3 % restEEG  
        % determine the shortest interval between markers
        intrvl = 999; % a numer much larger than the expected interval between rest markers
        for i=1:length(interval)
            if intrvl > interval(i)
                intrvl = interval(i);
            end 
        end
        % limit the time of interest to 5 seconds after the marker and 5 seconds
        % before the new marker
        cfg.toilim                  = [5 intrvl-5];
        data_filter                 = ft_redefinetrial(cfg,data_filter);
        % cut the data into 2 sec segments
        cfg                         = [];
        cfg.length                  = 2; % length of epochs in seconds
    else
        evalc(sprintf('cfg.toilim = [-curexperiment.prestim%d+.5 curexperiment.poststim%d-.5];', d,d));
    end
    data_filter                     = ft_redefinetrial(cfg,data_filter);
        
    % save the filtered data
    evalc(sprintf('%s = data_filter', curexperiment.datasets_names{d}));
    if d==3 % RestEEG data
        evalc(sprintf('%s = rmfield(%s,''hdr'')', curexperiment.datasets_names{d},curexperiment.datasets_names{d}));
    end
    save([subjectdata.subjectdir filesep subjectdata.subjectnr curexperiment.dataset_name{d} '_Filtered.mat'], curexperiment.datasets_names{d});
    clear data_filter
end

% update the datasets
evalc(curexperiment.define_datasets);