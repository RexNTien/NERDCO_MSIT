function MSIT_Run_Trial(app)

% Runs a single trial of the neuropixels version of the MSIT.

n = app.TaskSettings.CurrentTrial;

%% Run first ISI
% If it's the first trial, show a fixation cross and wait.
if n == 1
    FixationStart = MSIT_Show_Text(app, '+', 1);
    Send_Log_TTL(app, FixationStart, 'Fixation_Shown', false, true);
    % Wait out the ISI and check for escape key.
    MSIT_Wait_And_Advance_Or_Cancel(app, FixationStart, app.TrialStruct.Trials(n).ISI, 'escape');
    if app.ExitFlag
        return;
    end
end

%% Check if keys are down before presenting stimulus
% Check if a key is down before moving on to present the stimulus.
RestrictKeysForKbCheck(app.TaskSettings.ResponseCodes);
keyIsDown = KbCheck;
while keyIsDown
    % Show message and wait for release of keys if there is a key being
    % held down, send and log a TTL
    ShowTime = MSIT_Show_Text(app, 'Please release all keys to continue', 0);
    Send_Log_TTL(app, ShowTime, 'Key_Down_Message_Shown', false, true);
    KbWait([], 1);
    % Run the ISI again and send TTL
    FixationStart = MSIT_Show_Text(app, '+', 1);
    Send_Log_TTL(app, FixationStart, 'Fixation_Shown', false, true);
    MSIT_Wait_And_Advance_Or_Cancel(app, FixationStart, app.TrialStruct.Trials(n).ISI, 'escape');
    if app.ExitFlag
        return;
    end
    keyIsDown = KbCheck;
end
RestrictKeysForKbCheck([]);

%% Present stimulus.
StimulusStart = MSIT_Show_Text(app, app.TrialStruct.Trials(n).Stimuli, 1);
% Send a TTL
Send_Log_TTL(app, StimulusStart, 'Stimulus_Shown', false, true);
disp(['Displaying stimulus (' app.TrialStruct.Trials(n).Stimuli ') for trial ' num2str(n) '/' num2str(app.TaskSettings.nTrials) '.']);

%% Get keyboard response
MSIT_Wait_And_Get_Response(app, StimulusStart, app.TaskSettings.ResponseTime);
% Wait out the rest of the ResponseTime while checking for exit key.
MSIT_Wait_And_Advance_Or_Cancel(app, StimulusStart, app.TaskSettings.ResponseTime, 'escape');
if app.ExitFlag
    return;
end

%% Draw fixation cross for the next trial, continue listening for keyboard response
FixationStart = MSIT_Show_Text(app, '+', 1);
Send_Log_TTL(app, FixationStart, 'Fixation_Shown', false, true);
if n == app.TaskSettings.nTrials
    isitime = app.TrialStruct.Trials(n).ISI;
else
    isitime = app.TrialStruct.Trials(n+1).ISI;
end
% If they haven't responded yet, check for late response
exitkeychecktime = 0.05; % Reserve the last x seconds to check for exit key
if app.TrialStruct.Trials(n).ResponseKey == -1
    MSIT_Wait_And_Get_Response(app, StimulusStart, FixationStart-StimulusStart+isitime-exitkeychecktime);
end
% Wait out the rest of the isi checking for exit key
MSIT_Wait_And_Advance_Or_Cancel(app, FixationStart, isitime, 'escape');
if app.ExitFlag
    return;
end