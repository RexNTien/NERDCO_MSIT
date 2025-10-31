function Setup_MSIT(app, Process)

% [Process = 'initialize'] sets initial parameters and prepares the app to
% run
% [Process = 'OutputFileLoc'] lets the user pick output file location
% [Process = 'BlockXFileButton'] lets the user pick the .csv file for each 
% block to run
% [Process = 'inputs_outputs'] locks in the keypress settings and builds
% outputs

switch Process
    case 'initialize'
        if app.TTL_CheckBox.Value
            if ~exist(fullfile(pwd,'BlockFiles'), 'dir')
                error('Looks like we''re in the wrong directory!');
            end
        end

        % Set default / starting values for the app
        app.ScreenUsedNum.Value = "Screen 01";

        % Set the font
        app.TaskSettings.Font = 'Arial';
        
        % Necessary if app was exited previously with keypress
        app.ExitFlag = false;

        % Assume the cameras are stopped
        app.CamsRunning = false;
        
        % Set starting values
        app.TaskSettings.TTLused = false;
        app.TaskSettings.BlockAmt = 0;
        app.TaskSettings.BlocksToDo = [];
        app.TaskSettings.currentBlock = 0;
        app.TaskSettings.currentTrial = 0;
        
        % Set up default files
        defaultSaveLoc = fullfile('C:\Users\', getenv('USERNAME'), 'Documents', 'PatientData');
        app.File_Location_Display.Text = defaultSaveLoc;
        app.FileSettings.OutputLoc = defaultSaveLoc;
        
        prefix = '';
        if app.ShortBlockDemo_CheckBox.Value == 1
            prefix = 'short_';
        end
        
        for blocki = 1:4
            thisblockfile = [prefix 'mg106_msit_block_' num2str(blocki,'%0.2i') '.csv'];
            fullBlock = fullfile(pwd, 'BlockFiles', thisblockfile);
            app.(['Block_' num2str(blocki) '_FileName']).Text = thisblockfile;
            app.FileSettings.(['BlockFile_' num2str(blocki)]) = fullBlock;
        end

    case 'OutputFileLoc'
        OutputLoc = uigetdir(pwd);
        app.File_Location_Display.Text = OutputLoc;
        app.FileSettings.OutputLoc = OutputLoc;

    case 'Block1FileButton'
        [CSVfile, fileLoc] = uigetfile('.csv');
        FileUsed = fullfile(fileLoc,CSVfile);
        app.Block_1_FileName.Text = CSVfile;
        app.FileSettings.BlockFile_1 = FileUsed;

    case 'Block2FileButton'
        [CSVfile, fileLoc] = uigetfile('.csv');
        FileUsed = fullfile(fileLoc,CSVfile);
        app.Block_2_FileName.Text = CSVfile;
        app.FileSettings.BlockFile_2 = FileUsed;

    case 'Block3FileButton'
        [CSVfile, fileLoc] = uigetfile('.csv');
        FileUsed = fullfile(fileLoc,CSVfile);
        app.Block_3_FileName.Text = CSVfile;
        app.FileSettings.BlockFile_3 = FileUsed;

    case 'Block4FileButton'
        [CSVfile, fileLoc] = uigetfile('.csv');
        FileUsed = fullfile(fileLoc,CSVfile);
        app.Block_4_FileName.Text = CSVfile;
        app.FileSettings.BlockFile_4 = FileUsed;
    
    case 'inputs_outputs'
        % Set the save filename as the patient, then date, then time
        Pid = app.Patient_ID_EditField.Value;
        CurrentDate = datetime('now','Format','uuuu-MM-dd');
        CurrentTimeHour = datetime('now','Format','HH');
        CurrentTimeMin = datetime('now','Format','mm');
        CurrentTimeSec = datetime('now','Format','ss');
        app.FileSettings.FileName = append(Pid,'_',string(CurrentDate),'_',string(CurrentTimeHour),'H_',string(CurrentTimeMin),'m_',string(CurrentTimeSec),'s','.mat');
        app.FileSettings.FileStub = append(Pid,'_',string(CurrentDate),'_',string(CurrentTimeHour),'H_',string(CurrentTimeMin),'m_',string(CurrentTimeSec),'s');
        % Setting output filename
        app.FileSettings.OutputPath = fullfile(app.FileSettings.OutputLoc, Pid, app.FileSettings.FileName);
        app.FileSettings.OutputStub = fullfile(app.FileSettings.OutputLoc, Pid, app.FileSettings.FileStub);
        
        % Make the directory if it doesn't exist
        if ~exist(fullfile(app.FileSettings.OutputLoc, Pid), 'dir')
            mkdir(fullfile(app.FileSettings.OutputLoc, Pid));
        end

        % Create the TTL Table
        app.TTLlog.NextrowNum = 0;
        app.TTLlog.TTLtable = table( ...
            'Size', [1,9], ...
            'VariableTypes',["string", "double", "datetime", "double", "double", "double", "logical", "logical", "logical"],...
            'VariableNames',["Event", "TTLTime", "TimeStamp", "TimeFromStart", "BlockNum", "TrialNum", "TTLEnabled", "GoodForAlignment", "TTLActuallySent"]);
        
        % Create the TTL live log and write the headers
        TTL_live_log_name = append(Pid,'_',string(CurrentDate),'_',string(CurrentTimeHour),'H_',string(CurrentTimeMin),'m_',string(CurrentTimeSec),'s', '_TTL_log.txt');
        app.FileSettings.TTL_live_log_path = fullfile(app.FileSettings.OutputLoc, Pid, TTL_live_log_name);
        app.FileSettings.TTL_live_log_ID = fopen(app.FileSettings.TTL_live_log_path, 'w');
        fprintf(app.FileSettings.TTL_live_log_ID, '%s %s %s %s %s %s %s %s\n', "Event", "TTLTime", "TimeFromStart", "BlockNum", "TrialNum", "TTLEnabled", "GoodForAlignment", "TTLActuallySent");
        
        % Create the Trials live log and write the headers
        Trials_live_log_name = append(Pid,'_',string(CurrentDate),'_',string(CurrentTimeHour),'H_',string(CurrentTimeMin),'m_',string(CurrentTimeSec),'s', '_Trial_log.txt');
        app.FileSettings.Trials_live_log_path = fullfile(app.FileSettings.OutputLoc, Pid, Trials_live_log_name);
        app.FileSettings.Trials_live_log_ID = fopen(app.FileSettings.Trials_live_log_path, 'w');
        fprintf(app.FileSettings.Trials_live_log_ID, '%s %s %s %s %s %s %s %s %s %s %s\n', "Trial", "Condition", "Conflict", "Stimulation", "Stimuli", "Correct", "ISI", "ResponseKey", "ResponseAccuracy", "ResponseUncertainty", "ReactionTime");

        % Define keypresses.
        app.TaskSettings.ResponseCodes = [0 0 0];
        app.TaskSettings.ResponseKeys(1) = app.LeftKey.Value;   % Corresponds to 1-key.
        app.TaskSettings.ResponseKeys(2) = app.MiddleKey.Value;   % Corresponds to 2-key.
        app.TaskSettings.ResponseKeys(3) = app.RightKey.Value;   % Corresponds to 3-key.
        for keyi = 1:3
            app.TaskSettings.ResponseCodes(keyi) = KbName(app.TaskSettings.ResponseKeys(keyi));
        end
        % Get keymatchVector for ultrafast key match identification
        app.TaskSettings.KeymatchVector = false(1,256);
        app.TaskSettings.KeymatchVector(app.TaskSettings.ResponseCodes) = true;

        % Define escape and block advance keys
        app.TaskSettings.EscapeKey = app.QuitKey.Value;
        app.TaskSettings.EscapeCode = KbName(app.TaskSettings.EscapeKey);
        app.TaskSettings.AdvanceKey = app.AdvanceKey.Value;
        app.TaskSettings.AdvanceCode = KbName(app.TaskSettings.AdvanceKey);

        % Release keyCode restrictions
        RestrictKeysForKbCheck([]);

    otherwise
        error(['Bad Setup command: ''' Process '''']);
end