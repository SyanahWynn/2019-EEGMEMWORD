%% FamRecEEG_Rereferencing
% rereference the EEG data

% loop through the datasets
for d=1:length(curexperiment.datasets)
    cfg             = [];
    cfg.reref       = 'yes';  
    cfg.channel     = 'all';
    cfg.refchannel  = {curexperiment.extelec.newref1, curexperiment.extelec.newref2}; % the average of these channels is used as the new reference
    cfg.implicitref = curexperiment.extelec.impref;            % the implicit (non-recorded) reference channel is added to the data representation
    % rereference the data
    data_reref      = ft_preprocessing(cfg,curexperiment.datasets(d));
    % save the rereferenced data
    evalc(sprintf('%s = data_reref', curexperiment.datasets_names{d}));
    save([subjectdata.subjectdir filesep subjectdata.subjectnr curexperiment.dataset_name{d} '_Rereferenced.mat'], curexperiment.datasets_names{d});
    clear data_reref
end
% update the datasets
evalc(curexperiment.define_datasets);