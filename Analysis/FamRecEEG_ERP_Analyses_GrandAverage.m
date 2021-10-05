%% FamRecEEG_ERP_Analyses_GrandAverage

% loop over subject group
for g=1:curexperiment.subject_groups
    % find the files in the analyses folder
    matdir      = fullfile(curexperiment.analysis_loc, sprintf('*ERP*'));
    matdf       = dir(matdir);
    matfiles    = {matdf.name};
    clear matdir
      
    % loop over datasets
    for d=1:length(curexperiment.datasets_names)-1 % exclude Rest EEG
        % find the files from the current dataset
        matfiles    = {matdf.name};
        matfiles    = matfiles(find(~cellfun('isempty',strfind(matfiles,curexperiment.dataset_name{d}))));
        matfiles    = matfiles(find(cellfun('isempty',strfind(matfiles,'GrandAverage'))));
        
        for l=1:curexperiment.levels
            % define the current dataset
            evalc(sprintf('curdat = curexperiment.data%d.l%d',d,l));
            % loop over conditions
            for c=1:length(fieldnames(curdat))
                % create an array to hold the inputfiles for the different conditions
                evalc(sprintf('curmatfiles = matfiles(find(~cellfun(''isempty'',strfind(matfiles,strcat(curexperiment.data%dl%d_name{c},''_'')))));',d,l));
                for cf=1:length(curmatfiles)
                    inputfiles(c,cf) = fullfile(curexperiment.analysis_loc, curmatfiles(cf));
                end
            end

            clear c
            clear curdat
            clear curfiles
            clear cf

            evalc(sprintf('curconname = curexperiment.data%dl%d_name',d,l));
            curconname = strrep(curconname,'_','');
            cfg = [];
            cfg.keepindividual = 'no';
            % calculate the grand average per condition
            for i=1:size(inputfiles,1)
                cfg.inputfile = inputfiles(i, ~cellfun('isempty',inputfiles(i,:)));
                display(sprintf('\nERP analysis %s\n',curconname{i}));
                GrandAverage_ERP(i) = ft_timelockgrandaverage(cfg);
            end

            clear inputfiles
            clear i

            % save the data
            for i=1:length(GrandAverage_ERP)
                data_cond = GrandAverage_ERP(i);
                data_cond.cfg.previous = []; % clear previous
                display(sprintf('\nSaving %s\n',curconname{i}));
                evalc(sprintf('save([curexperiment.analysis_loc filesep curexperiment.dataset_name{d} curexperiment.data%dl%d_name{i} ''_ERP_GrandAverage''],''data_cond'')',d,l));
            end

            clear data_cond
            clear i

            clear GrandAverage_ERP
            clear curconname
        end
    end
end
        
clear curmatfiles
clear d
clear g
clear i
clear matdf
