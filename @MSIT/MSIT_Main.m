function MSIT_Main(app)

% Reset exit flag
app.ExitFlag = false;

% Lock in and initialize the output files
Setup_MSIT(app, 'inputs_outputs');

% Lock in and log some Task Settings
app.TaskSettings.ResponseTime = app.ResponseTime_EditField.Value;
app.TaskSettings.IntroTextSize = app.IntroTextSize_EditField.Value;
app.TaskSettings.TextSize = app.TextSize_EditField.Value;

% Initialize the TTLs and send the start train
Setup_Parallel_TTL(app, 'initialize');

% Get the number of blocks to run
app.TaskSettings.BlockAmt = 0;
app.TaskSettings.BlocksToDo = [];
for blocki = 1:4
    if app.(['Block_' num2str(blocki) '_CheckBox']).Value
        app.TaskSettings.BlockAmt = 1 + app.TaskSettings.BlockAmt;
        app.TaskSettings.BlocksToDo = [app.TaskSettings.BlocksToDo, blocki];
    end
end
if app.TaskSettings.BlockAmt == 0
    error('No blocks selected. Please select at least one block to run.');
end

% Open Psychtoolbox window.
try
    Display_Controls(app, 'initialize');
catch err
    Display_Controls(app, 'close');
    rethrow(err);
end

% Run the blocks
for nn = 1:app.TaskSettings.BlockAmt

    % Get the actual block number, e.g. if user somehow only put block 2
    % without block 1 checked.
    app.TaskSettings.CurrentBlock = app.TaskSettings.BlocksToDo(nn);
    blockStr = append('Block', num2str(app.TaskSettings.CurrentBlock,'%0.2i'));

    % Wait for experimenter to press key to begin.
    disp(['Ready to begin Block ' blockStr ' (block ' num2str(nn) '/' num2str(app.TaskSettings.BlockAmt) ...
        ' for this session). Press ''' app.TaskSettings.AdvanceKey ''' key to advance.']);
    if app.Camera_CheckBox.Value
        disp('BUT FIRST ARM THE CAMERAS!');
    end
    MSIT_Wait_And_Advance_Or_Cancel(app, 0, 0, 'advance');
    if app.ExitFlag
        break;
    end

    disp('');
    disp(['Beginning Block ' blockStr ' (block ' num2str(nn) '/' num2str(app.TaskSettings.BlockAmt) ' for this session).']);

    % Send a TTL to have more good-aligning TTLs
    Send_Log_TTL(app, GetSecs, 'Initializing_Block', true, true);

    % Start the audio
    Audio_Controls(app, 'start');

    % Start the cameras
    Camera_Controls(app, 'start');

    % Reset trial counter
    app.TaskSettings.CurrentTrial = 0;

    % Setup experiment environment. Creates TrialStruct in app
    Build_Trial_Struct(app);

    if nn == 1
        % Write initial instructions.
        ShowTime = MSIT_Show_Text(app, ['We are beginning the numbers task.\n\n', ...
            'You will see sets of 3 numbers appear on the\n', ...
            'screen. These will change every ' num2str(app.ResponseTime_EditField.Value) ' seconds.\n\n', ...
            'Your job is to press the button indicating which\n', ...
            'number is different from the other two.\n\n', ...
            'On all trials, report only the target number,\n', ...
            'regardless of its position.\n\n', ...
            'For all trials, answer as fast as possible without\n', ...
            'losing accuracy.\n\n', ...
            'Press any key to begin.'], 0);
        % Send a TTL
        Send_Log_TTL(app, ShowTime, 'Initial_Instructions_Shown', false, false);
    else
        % Write subject keypress instructions to begin the next block
        ShowTime = MSIT_Show_Text(app, 'Press any key to begin the next block.', 0);
        % Send a TTL
        Send_Log_TTL(app, ShowTime, 'Next_Block_Instructions_Shown', false, false);
    end
    
    % Wait for any key to be pressed by the subject
    WaitSecs(1); % Don't let them do it right away by accident
    % Wait for a subject key press
    MSIT_Wait_And_Advance_Or_Cancel(app, 0, 0, 'blockstart');
    if app.ExitFlag
        break;
    end

    % Initialize save of FinishedTrials
    app.FinishedTrials.(blockStr).Output = app.TrialStruct;

    % Trials Block.
    app.TaskSettings.nTrials = numel(app.TrialStruct.Trials);
    app.TaskSettings.CurrentTrial = 1;
    lastFixationStart = NaN;
    while app.TaskSettings.CurrentTrial <= app.TaskSettings.nTrials
        
        % Run a trial.
        lastFixationStart = MSIT_Run_Trial(app, lastFixationStart);

        % Stash things in FinishedTrials
        app.FinishedTrials.(blockStr).Output.Trials(app.TaskSettings.CurrentTrial) = app.TrialStruct.Trials(app.TaskSettings.CurrentTrial);

        % Print out to Trials live log
        fprintf(app.FileSettings.Trials_live_log_ID, '%i %i %i %i %s %i %i %i %i %f %f\n', ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).Trial, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).Condition, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).Conflict, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).Stimulation, ...
            string(app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).Stimuli), ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).Correct, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).ISI, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).ResponseKey, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).ResponseAccuracy, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).ResponseUncertainty, ...
            app.TrialStruct.Trials(app.TaskSettings.CurrentTrial).ReactionTime);

        % Send a regular good TTL
        Send_Log_TTL(app, GetSecs, 'Trial_Data_Stored', true, true);

        if app.ExitFlag
            % Trim the FinishedTrials to contain only those that weren't
            % exited.
            app.FinishedTrials.(blockStr).Output.Trials = app.FinishedTrials.(blockStr).Output.Trials(1:app.TaskSettings.CurrentTrial);
            break;
        end
        
        % Increment trial counter
        app.TaskSettings.CurrentTrial = app.TaskSettings.CurrentTrial + 1;
    end

    % Show Block End Text
    if app.ExitFlag
        disp('');
        disp(['Exiting Block ' num2str(app.TaskSettings.CurrentBlock) ' (run ' num2str(nn) ' out of ' num2str(app.TaskSettings.BlockAmt) ' for this session) and quitting (escape was pressed).']);
    else
        disp('');
        disp(['Finished Block ' num2str(app.TaskSettings.CurrentBlock) ' (run ' num2str(nn) ' out of ' num2str(app.TaskSettings.BlockAmt) ' for this session).']);
        if nn < app.TaskSettings.BlockAmt
            ShowTime = MSIT_Show_Text(app, ['Block ' num2str(nn) ' out of ' num2str(app.TaskSettings.BlockAmt) ' completed!\n\nPlease wait...'], 0);
            Send_Log_TTL(app, ShowTime, 'Block_End_Text_Shown', false, true);
        end
    end
    
    % Write out missed trials / accuracy.
    disp(['Block ran for ' num2str(GetSecs-app.TrialStruct.StartTime) ' seconds.']);
    app.FinishedTrials.(blockStr).NumTrialsPresented = numel(app.FinishedTrials.(blockStr).Output.Trials);
    app.FinishedTrials.(blockStr).MissedTrials = sum([app.TrialStruct.Trials.ResponseKey]==-1);
    app.FinishedTrials.(blockStr).Accuracy = mean([app.TrialStruct.Trials.ResponseAccuracy]==1);
    disp(['Presented trials: ', num2str(app.FinishedTrials.(blockStr).NumTrialsPresented)]);
    disp(['Missed trials: ', num2str(app.FinishedTrials.(blockStr).MissedTrials)]);
    disp(['Accuracy: ', num2str(app.FinishedTrials.(blockStr).Accuracy)]);
    disp('');

    % Stop the cameras
    Camera_Controls(app, 'stop');

    % Stop and save the audio
    Audio_Controls(app, 'stop');
    
    % Exit if exit key pressed
    if app.ExitFlag
        break;
    end
end

% Exit text
if app.ExitFlag
    ShowTime = MSIT_Show_Text(app, 'Saving and exiting...', 0);
else
    ShowTime = MSIT_Show_Text(app, 'Thank you!', 1);
end

% Send a TTL and save everything!
Save_All(app);

% Close the live logs
fclose(app.FileSettings.TTL_live_log_ID);
fclose(app.FileSettings.Trials_live_log_ID);

% Wait a bit if it's fast
WaitSecs(2-(GetSecs-ShowTime));
% Close screens.
Display_Controls(app, 'close');