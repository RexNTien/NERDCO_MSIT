function FixationStart = MSIT_Run_Trial(app, lastFixationStart)

% Runs a single trial of the neuropixels version of the MSIT.

n = app.TaskSettings.CurrentTrial;
FixationStart = NaN;

%% Run ISI
% If it's the first trial, show a fixation cross. Otherwise there will
% already be a fixation cross up from the end of the previous trial
if n == 1
    lastFixationStart = MSIT_Show_Text(app, '+', 1);
    Send_Log_TTL(app, lastFixationStart, 'Fixation_Shown', false, true);
end

% Wait out the ISI and check for escape key.
MSIT_Wait_And_Advance_Or_Cancel(app, lastFixationStart, app.TrialStruct.Trials(n).ISI, 'escape');
if app.ExitFlag
    return;
end

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
    lastFixationStart = MSIT_Show_Text(app, '+', 1);
    Send_Log_TTL(app, lastFixationStart, 'Fixation_Shown', false, true);
    MSIT_Wait_And_Advance_Or_Cancel(app, lastFixationStart, app.TrialStruct.Trials(n).ISI, 'escape');
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
% If we got a response, wait out the rest of the ResponseTime while
% checking for exit key. If no response, report it
if app.TrialStruct.Trials(n).ResponseKey == -1
    disp('Response time exceeded, no response recorded.');
else
    MSIT_Wait_And_Advance_Or_Cancel(app, StimulusStart, app.TaskSettings.ResponseTime, 'escape');
    if app.ExitFlag
        return;
    end
end

%% Draw fixation cross for the next trial
FixationStart = MSIT_Show_Text(app, '+', 1);
Send_Log_TTL(app, FixationStart, 'Fixation_Shown', false, true);

% If it's the last trial, let it run out its ISI
if n == app.TaskSettings.nTrials
    MSIT_Wait_And_Advance_Or_Cancel(app, FixationStart, app.TrialStruct.Trials(n).ISI, 'justwait');
end