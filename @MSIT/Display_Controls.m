function Display_Controls(app, Process)

% Function to setup presentation of experiment.

% [Process = 'find_screens'] finds the available screens and populates
% dropdown menu
% [Process = 'initialize'] opens the first window

switch Process
    case 'find_screens'
        % Populate the screen drop-down menu, default to Screen 01
        screens = Screen('Screens');
        switch size(screens,2)
            case 2
                app.ScreenUsedNum.Items = {'Screen 01';'Across Both'};
            case 3
                app.ScreenUsedNum.Items = {'Screen 01';'Screen 02';'Across Both'};
            case 4
                app.ScreenUsedNum.Items = {'Screen 01';'Screen 02';'Screen 03';'Across All'};
            otherwise
                app.ScreenUsedNum.Items = {'Screen 01'};
        end

    case 'initialize'
        % Purge old HID entries and PTB functions.
        clear('KbWait','PsychHID','KbCheck','Screen');
        Screen('Preference', 'SkipSyncTests', 0);
        Screen('Preference', 'Verbosity', 2);

        disp('Initiailizing Pyschtoolbox display.');
        % Setup screen parameters.
        % If no specified screen parameters, get current screen resolution and set 
        % as default.
        switch app.ScreenUsedNum.Value
            case "Screen 01"
                if size(app.ScreenUsedNum.Items,2) > 1
                    ChosenScreen = 2;
                else
                    ChosenScreen = 1;
                end
            case "Screen 02"
                ChosenScreen = 3;
            case "Screen 03"
                ChosenScreen = 4;
            otherwise
                ChosenScreen = 1;
        end
        screens = Screen('Screens');
        ScreenNum = screens(ChosenScreen);
        % PredefinedSize = any(strcmp('Rect',fieldnames(app.TrialStruct)));
        % if PredefinedSize == 0
        CurrentScreen = Screen('Resolution', ScreenNum);
        app.TaskSettings.xRes = CurrentScreen.width;
        app.TaskSettings.yRes = CurrentScreen.height;
        app.TaskSettings.Rect = [0 0 app.TaskSettings.xRes app.TaskSettings.yRes];
        app.TaskSettings.Clrdepth = CurrentScreen.pixelSize;
        % end
        
        % Add additional information.
        % If not already defined, add in basic colors.
        app.TaskSettings.Black = [0 0 0];
        app.TaskSettings.White = [255 255 255];
        
        % Open initial window.
        app.TaskSettings.MainWindow = Screen('OpenWindow',ScreenNum, ...
                                         app.TaskSettings.Black, ...
                                         app.TaskSettings.Rect, ...
                                         app.TaskSettings.Clrdepth);
        HideCursor();

    case 'close'
        ShowCursor();
        Screen('CloseAll');
        sca;

    otherwise
        error(['Bad Display Controls command: ''' Process '''']);
end