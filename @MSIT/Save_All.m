function Save_All(app)

Send_Log_TTL(app, GetSecs, 'Saving_Data', true, true);

% Try to save everything about the app object
warning('off', 'MATLAB:structOnObject');
disp('Saving app data in... ');
disp(app.FileSettings.OutputPath);
% Do some housekeeping and store things in AppSettings and AppProperties
explicitCuts = {'UIFigure', 'AutoListeners__', 'ttlDevice', 'udpObj', 'TimingFields'};
appstruct = struct(app);
fns = fieldnames(appstruct);
for fni = 1:length(fns)
    if ~any(strcmp(explicitCuts,fns{fni}))
        if ~(contains(fns{fni}, 'Label') || contains(fns{fni}, 'GridLayout') || contains(fns{fni}, 'Button'))
            if isprop(appstruct.(fns{fni}), 'Value')
                AppSettings.(fns{fni}) = appstruct.(fns{fni}).Value;
            elseif isprop(appstruct.(fns{fni}), 'Text')
                AppSettings.(fns{fni}) = appstruct.(fns{fni}).Text;
            else
                AppProperties.(fns{fni}) = appstruct.(fns{fni});
            end
        end
    end
end

% Store FinishedTrials, TaskSettings and TTLlog separately, along with all settings and
% properties.
FinishedTrials = app.FinishedTrials;
TaskSettings = app.TaskSettings;
TTLlog = app.TTLlog;
AppProperties = rmfield(AppProperties, {'FinishedTrials', 'TaskSettings', 'TTLlog'});

save(app.FileSettings.OutputPath, 'FinishedTrials', 'TTLlog', 'TaskSettings', 'AppProperties', 'AppSettings', '-v7.3');

Send_Log_TTL(app, GetSecs, 'Data_Saved', true, true);

disp('Done!');