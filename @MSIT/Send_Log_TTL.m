function Send_Log_TTL(app, TTLTime, EventTxt, GoodAlign, WaitAfter)

%{
Function to send and log the TTL
%}

% Send the TTL, with a try-catch to avoid crashing due to TTL collision.
if app.TaskSettings.TTLused
    try
        parPulse(app.ttlDevice,2,1,255,app.TTLlog.TTLLength,1);
        TTLSent = true;
    catch exception
        if strcmp(exception.message, 'Asynchronously issued trigger pulse still not finished (trigger mode).')
            disp('TTL collision - pulse not sent!');
            TTLSent = false;
        else
            rethrow(exception);
        end
    end
else
    TTLSent = false;
end

% Get more timestamps
TimeStamp = datetime("now","Format","dd-MMM-uuuu HH:mm:ss.SSS");
TimeFromStart = TTLTime - app.TTLlog.StartTime;

% Advance the table row number
app.TTLlog.NextrowNum = app.TTLlog.NextrowNum + 1;

% Log this TTL in the app data
app.TTLlog.TTLtable(app.TTLlog.NextrowNum,:) = ...
    {EventTxt, TTLTime, TimeStamp, TimeFromStart, app.TaskSettings.currentBlock, app.TaskSettings.currentTrial, app.TaskSettings.TTLused, GoodAlign, TTLSent};

% Log this TTL in the live TTL log
fprintf(app.FileSettings.TTL_live_log_ID, '%s %f %f %i %i %i %i %i\n', EventTxt, TTLTime, TimeFromStart, app.TaskSettings.currentBlock, app.TaskSettings.currentTrial, app.TaskSettings.TTLused, GoodAlign, TTLSent);

if WaitAfter
    WaitSecs(0.0025);
end