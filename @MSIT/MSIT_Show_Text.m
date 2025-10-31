function ShowTime = MSIT_Show_Text(app, text, isMain)

% Show some text. If isMain (stimulus), use the main font size, if not use the intro
% font size.

Screen('TextFont', app.TaskSettings.MainWindow, app.TaskSettings.Font);
if isMain == 1
    Screen('TextSize', app.TaskSettings.MainWindow, app.TaskSettings.TextSize);
    DrawFormattedText(app.TaskSettings.MainWindow, text, 'center', 'center',...
        [255 255 255], 60);
else
    Screen('TextSize', app.TaskSettings.MainWindow, app.TaskSettings.IntroTextSize);
    DrawFormattedText(app.TaskSettings.MainWindow, text, 'center', 'center',...
        [255 255 255], 60, [], [], 1.2);
end

ShowTime = Screen('Flip', app.TaskSettings.MainWindow);