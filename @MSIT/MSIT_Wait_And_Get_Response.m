function MSIT_Wait_And_Get_Response(app, StartTime, WaitTime)

% Wait for time, full checking and logging for the task response. Separate
% function here so that it can be as fast as possible.
%
% Escape key is not checked during this time for faster timing.

n = app.TaskSettings.CurrentTrial;

% Only check the relevant keys, makes it faster!
RestrictKeysForKbCheck(app.TaskSettings.ResponseCodes);

while ((GetSecs - StartTime) < WaitTime)
    [keyDown,keyTime,keyCode,keyDelta] = KbCheck;
    % Does the key match any of our desired keys? Check real fast
    if keyDown
        % Send the TTL first
        Send_Log_TTL(app, keyTime, 'Response_Key_Pressed', false, true);
        
        % Decode what key(s) is(are) down (1, 2 and/or 3)
        keyIdx = find(keyCode(app.TaskSettings.ResponseCodes));
        
        % Log the key identity(ies) and timing uncertainty
        % If there was somehow a key tie, append and log them all
        app.TrialStruct.Trials(n).ResponseKey = str2num(erase(num2str(keyIdx),' '));
        app.TrialStruct.Trials(n).ResponseUncertainty = keyDelta;
        
        % Determine accuracy. Only count if they depressed just the
        % correct key first.
        app.TrialStruct.Trials(n).ResponseAccuracy = (app.TrialStruct.Trials(n).ResponseKey == app.TrialStruct.Trials(n).Correct);

        % Store the reaction time also
        app.TrialStruct.Trials(n).ReactionTime = keyTime-StartTime;

        % Report the result
        if app.TrialStruct.Trials(n).ResponseAccuracy
            accuracystr = 'Correct';
        else
            accuracystr = 'Incorrect';
        end
        disp([accuracystr ' response recorded: ' num2str(app.TrialStruct.Trials(n).ResponseKey) ' (' num2str(app.TrialStruct.Trials(n).Correct) '), reaction time: ' num2str(app.TrialStruct.Trials(n).ReactionTime) 's.']);

        RestrictKeysForKbCheck([]);
        return;
    end
end
RestrictKeysForKbCheck([]);