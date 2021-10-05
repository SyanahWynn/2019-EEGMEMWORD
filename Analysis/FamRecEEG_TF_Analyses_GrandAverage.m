%% FamRecEEG_TF_Analyses_GrandAverage
% Grand average time-frequency representation

% Load in the data per subject group
for g=1:curexperiment.subject_groups
    % find the files in the analyses folder
    TFdir      = fullfile(curexperiment.analysis_loc, sprintf('*TF*'));
    TFdf       = dir(TFdir);
    TFfiles    = {TFdf.name};
    TFfiles    = TFfiles(find(cellfun('isempty',strfind(TFfiles,'GrandAverage'))));

    % set the names of the frequency ranges of interest
    freq_names = fieldnames(curexperiment.freq_interest);
    
    % loop over the datasets
    for d=1:length(curexperiment.datasets_names) 
        % locate current dataset files
        display(sprintf('\n%s\n', curexperiment.dataset_name{d}(2:end)))
        TFfiles_dat = TFfiles(find(~cellfun('isempty',strfind(TFfiles,curexperiment.dataset_name{d}))));
        % loop over all levels of processing
        for l=1:curexperiment.levels
            if ~(l==2 && d==3) % skip level two for rest
                % locate current level files
                evalc(sprintf('curlevnames = curexperiment.data%dl%d_name',d,l));
                display(sprintf('\n%s\n',curexperiment.level_name{l}(2:end)))
                TFfiles_lev =[];
                for i=1:length(curlevnames)
                    TFfiles_lev = [TFfiles_lev TFfiles_dat(find(~cellfun('isempty',strfind(TFfiles_dat,strcat(curlevnames{i},'_')))))];
                end
                for fr=1:length(fieldnames(curexperiment.freq_interest)) % loop over the frequency ranges of interest
                    TFfiles_freq = TFfiles_lev;
                    for po=1:length(curexperiment.curpow)
                        TFfiles_pow = TFfiles_freq(find(~cellfun('isempty',strfind(TFfiles_freq,curexperiment.curpow{po}))));
                        if ~isempty(TFfiles_pow)
                            %% TRIAL SELECTION
                            % Select trials based upon condition
                            % define the current dataset
                            evalc(sprintf('curdat = curexperiment.data%d.l%d',d,l));
                            % loop over conditions
                            for c=1:length(fieldnames(curdat))
                                % create an array to hold the inputfiles for the different conditions
                                evalc(sprintf('curmatfiles = TFfiles_pow(find(~cellfun(''isempty'',strfind(TFfiles_pow,curexperiment.data%dl%d_name{c}))));',d,l));
                                for cf=1:length(curmatfiles)
                                    inputfiles(c,cf) = fullfile(curexperiment.analysis_loc, curmatfiles(cf));
                                end
                            end
                            clear c
                            clear curdat
                            clear curfiles
                            clear cf
                            clear curmatfiles     

                            %% CALCULATE GRAND AVERAGE
                            evalc(sprintf('curconname = curexperiment.data%dl%d_name',d,l));
                            cfg = [];
                            cfg.keepindividual = 'yes';
                            % calculate the grand average
                            for i=1:size(inputfiles,1)
                                cfg.inputfile = inputfiles(i, ~cellfun('isempty',inputfiles(i,:)));
                                display(sprintf('\nMaking grand average %s %s power\n',curconname{i}(2:end),curexperiment.curpow{po}(2:end)));
                                GrandAverage_TF(i) = ft_freqgrandaverage(cfg);
                            end
                            clear inputfiles
                            clear i

                            %% SAVE DATA
                            for i=1:length(GrandAverage_TF)
                                data_cond = GrandAverage_TF(i);
                                data_cond.cfg.previous = []; % clear previous
                                display(sprintf('\nSaving %s %s\n',curconname{i}(2:end),curexperiment.curpow{po}(2:end)));
                                evalc(sprintf('save([curexperiment.analysis_loc filesep curexperiment.dataset_name{d} curexperiment.data%dl%d_name{i} curexperiment.curpow{po} ''_TF_GrandAverage''],''data_cond'')',d,l));
                            end

                            clear data_cond
                            clear i
                            clear curconname
                            clear GrandAverage_TF
                        end
                    end
                    clear TFfiles_pow
                end
                clear TFfiles_freq
            end
        end
        clear TFfiles_lev
    end
    clear TFfiles_dat
end
clear TFdir
clear TFdf
clear TFfiles
clear g
clear d
clear l
clear fr
clear po
clear freqnames
