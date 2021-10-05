%% FamRecEEG_ArtifactRejection
% manually remove artifacts not caused by eye movements

% load in events
load(fullfile(subjectdata.subjectdir, strcat(subjectdata.subjectnr,'_Raw_AlterMarkers_Events.mat')));
curevents = [23,21,22,24,25,26,40,511,512,513,573,571,572,80,70]; %fixation, stimulus, cue and confidence onset
event_arti = [];
for i=1:length(event)
    if ismember(event(i).value, curevents)
        event_arti = [event_arti event(i)];
    end
end

% needed for the check if there is already artifact data
artidir     = fullfile(subjectdata.subjectdir, '*Artifacts*');
artidf      = dir(artidir);
artifiles   = {artidf.name};

% loop over the datasets
for d=1:length(curexperiment.datasets)
    curexperiment.datasets(d).cfg.previous = []; % clear previous
    cfg = [];
    % check if there is already artifact data
    if ismember(strcat(subjectdata.subjectnr, curexperiment.dataset_name{d}(1:end-4), '_ArtifactsFin.mat'),artifiles)
        load(fullfile(subjectdata.subjectdir, strcat(subjectdata.subjectnr, curexperiment.dataset_name{d}(1:end-4), '_ArtifactsFin.mat')));
        cfg.artfctdef.visual.artifact = artifacts;
    elseif ismember(strcat(subjectdata.subjectnr, curexperiment.dataset_name{d}(1:end-4), '_Artifacts.mat'),artifiles)
        load(fullfile(subjectdata.subjectdir, strcat(subjectdata.subjectnr, curexperiment.dataset_name{d}(1:end-4), '_Artifacts.mat')));
        cfg.artfctdef.visual.artifact = artifacts;
    end
    % select the additional artifacts
    cfg.viewmode        = 'vertical';
    cfg.channel         = 'EEG';
    cfg.renderer        = 'painters';
    %cfg.ploteventlabels = 'colorvalue';
    if d~=3 % display the rest EEG per trial, encoding and retrieval continuous
        cfg.continuous      = 'yes';
        cfg.blocksize       = 15;
        cfg.event           = event_arti;
        cfg.ploteventlabels = 'colorvalue';
    end
    display(sprintf('\nSUBJECT: %s', subjectdata.subjectnr));
    display(sprintf('DATASET: %s\n', curexperiment.dataset_name{d}(2:end)));
    % show the data to select the artifacts
    cfg                     = ft_databrowser(cfg,curexperiment.datasets(d));
    artifacts               = cfg.artfctdef.visual.artifact;
    % reject the artifacts
    cfg.artfctdef.reject        = 'complete';
    cleandata                   = ft_rejectartifact(cfg,curexperiment.datasets(d));
    % save the artifact data
    evalc(sprintf('%s = cleandata', curexperiment.datasets_names{d}));
    save([subjectdata.subjectdir filesep subjectdata.subjectnr curexperiment.dataset_name{d} '_ArtiRemovedFin.mat'], curexperiment.datasets_names{d});
    save([subjectdata.subjectdir filesep subjectdata.subjectnr curexperiment.dataset_name{d}(1:end-4) '_ArtifactsFin.mat'],'artifacts');
    save([curexperiment.datafolder_input filesep subjectdata.subjectnr curexperiment.dataset_name{d}(1:end-4) '_ArtifactsFin_' date '.mat'],'artifacts');
    clear artifacts
    clear cleandata
end
% update the datasets
evalc(curexperiment.define_datasets);