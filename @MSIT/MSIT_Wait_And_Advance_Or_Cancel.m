function MSIT_Wait_And_Advance_Or_Cancel(app, StartTime, WaitTime, Process)

% Process:
% 'justwait' is just waiting, no keyboard check
% 'escape' is to just check for the escape key
% 'advance' is to wait indefinitely while checking for Advance Key or Escape Key
% 'blockstart' is to wait indefinitely while checking for Subject Keypress or Escape
% Key

% Only check the relevant keys, makes it faster!

switch Process
    case 'justwait'
        WaitSecs(WaitTime - (GetSecs-StartTime));
        RestrictKeysForKbCheck([]);

    case 'escape'
        RestrictKeysForKbCheck(app.TaskSettings.EscapeCode);
        while (GetSecs - StartTime) < WaitTime
            [keyDown, keyTime] = KbCheck;
            if keyDown 
                % Send a TTL first
                Send_Log_TTL(app, keyTime, 'Escape_Key_Pressed', false, true);
                disp('Escape key detected!');
                app.ExitFlag = true;
                
                RestrictKeysForKbCheck([]);
                return;
            end
        end
        RestrictKeysForKbCheck([]);

    case 'advance'
        % First wait for all keys to be released
        KbWait([],1);
        RestrictKeysForKbCheck([app.TaskSettings.EscapeCode, app.TaskSettings.AdvanceCode]);
        while true
            [keyDown,keyTime,keyCode] = KbCheck;
            if keyDown
                keyCodes = find(keyCode);
                % Check for escape key
                if any(keyCodes == app.TaskSettings.EscapeCode)
                    Send_Log_TTL(app, keyTime, 'Escape_Key_Pressed', false, true);
                    disp('Escape key detected!');
                    app.ExitFlag = true;
                % Check for block advance key
                elseif any(keyCodes == app.TaskSettings.AdvanceCode)
                    Send_Log_TTL(app, keyTime, 'Block_Advance_Key_Pressed', false, true);
                    disp('Block advance key detected!');
                end

                RestrictKeysForKbCheck([]);
                return;
            end
        end

    case 'blockstart'
        % First wait for all keys to be released
        KbWait([],1);
        RestrictKeysForKbCheck([app.TaskSettings.ResponseCodes, app.TaskSettings.EscapeCode]);
        while true
            [keyDown,keyTime,keyCode] = KbCheck;
            if keyDown
                % Decode what key(s) is(are) down
                keyCodes = find(keyCode);
    
                % Check for escape key
                if any(keyCodes == app.TaskSettings.EscapeCode)
                    Send_Log_TTL(app, keyTime, 'Escape_Key_Pressed', false, true);
                    disp('Escape key detected!');
                    app.ExitFlag = true;
                else
                    Send_Log_TTL(app, keyTime, 'Instructions_Exited', false, true);
                    disp('Block start key detected!');
                end
    
                RestrictKeysForKbCheck([]);
                return;
            end
        end

    otherwise
        error(['Bad Wait and Check command: ''' Process '''']);
end