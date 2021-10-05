%% FamRecEEG_TrialCount
% count the trialtypes

% load the data
if exist(outputfile,'file')
   load(outputfile)
end

% loop through the datasets
for d=1:length(curexperiment.datasets)-1
    % get all possible markers
    evalc(sprintf('markers = cell2mat(table2cell(struct2table(curexperiment.data%d.l%d)));',d,curexperiment.levels));
    % count the markers
    for i=1:length(markers)
      evalc(sprintf('count(i) = sum(%s.trialinfo==markers(i))',curexperiment.datasets_names{d}));
    end
    evalc(sprintf('fldnms = fieldnames(curexperiment.data%d.l%d);',d,curexperiment.levels));
    % link count to conditions
    for i=1:length(fldnms)
        evalc(sprintf('conmarkers = curexperiment.data%d.l%d.%s;',d,curexperiment.levels,fldnms{i}));
        concount(i) = sum(count(ismember(markers,conmarkers)));
    end
    % wrapping up
    evalc(sprintf('connames = char(curexperiment.data%dl%d_name);',d,curexperiment.levels));
    count_tab = array2table(concount,'VariableNames',cellstr(connames(:,5:end)))
    evalc(sprintf('Data.EEGEncRetCountpost.%s(f,:) = count_tab;',curexperiment.dataset_name{d}(2:end)));
    
    clear markers count fldnms conmarkers connames concount count_tab
end

save(outputfile,'Data')