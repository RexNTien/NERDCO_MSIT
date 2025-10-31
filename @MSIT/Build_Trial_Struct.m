function Build_Trial_Struct(app)
%{
This function is used to import trial data
Created by MSIT research team
Modified by NERD CO team
%}

% Builds the trial struct independently for each "block"

% Open file.
filepath = app.FileSettings.(['BlockFile_' num2str(app.TaskSettings.CurrentBlock)]);

fid = fopen(filepath);
% Read in column names. (As of 12/10, there are 11.)
headers = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s', 1, 'Delimiter', ',');
headers = [headers{1:numel(headers)}];

% Read in the rest of the rows. Assumes the following format:
raw_trials = textscan(fid, '%d %d %d %d %s %d %f %f %f %f %f %f %f', 'Delimiter', ',', ...,
                      'HeaderLines', 1);

% Place trials in struct.
% Find number of trials.
nTrials = numel(raw_trials{1});
% Create empty structure.
app.TrialStruct = struct();
%
% Iteratively build trial fields containing the seven columns of information.
for n=1:nTrials
    for m=1:7 % numel(headers) % Ignoring stim fields
        app.TrialStruct.Trials(n).(headers{m}) = raw_trials{m}(n);
    end

    % De-cell the stimuli
    app.TrialStruct.Trials(n).Stimuli = app.TrialStruct.Trials(n).Stimuli{:};
end

% Add in additional fields, populate them with -1
[app.TrialStruct.Trials.ResponseKey] = deal(-1);
[app.TrialStruct.Trials.ResponseAccuracy] = deal(-1);
[app.TrialStruct.Trials.ResponseUncertainty] = deal(-1);
[app.TrialStruct.Trials.ReactionTime] = deal(-1);

% Get the block start time
app.TrialStruct.StartTime = GetSecs;