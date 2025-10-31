function Setup_Parallel_TTL(app, Process)

% [Process = 'toggle'] toggles the TTL on/off
% [Process = 'initialize'] initializes the TTL and sends initial train

switch Process
    case 'toggle'
        % Turn on the TTL and fields
        if app.TTL_CheckBox.Value
            % Ensure the mex file is on the path
            addpath(genpath(fullfile(pwd,'ParallelPortFiles')));
            % Activate the GUI fields
            app.ParallelAddress_Label.Enable = "on";
            app.ParallelAddress_EditField.Enable = "on";
            app.TTLLength_Label.Enable = "on";
            app.TTLLength_EditField.Enable = "on";
            if isempty(app.ParallelAddress_EditField.Value)
                % adding defult value only if the field is empty!
                app.ParallelAddress_EditField.Value = "4FE8"; % NOTE - GET THIS VALUE FROM YOUR SYSTEM HARDWARE INFORMATION
            end
            app.TaskSettings.TTLused = true;

        % Turn off the TTL and fields
        else
            app.ParallelAddress_Label.Enable = "off";
            app.ParallelAddress_EditField.Enable = "off";
            app.TTLLength_Label.Enable = "off";
            app.TTLLength_EditField.Enable = "off";            
            app.TaskSettings.TTLused = false;
        end
        
    case 'initialize'
        disp('Initializing TTLs.');

        % Set up the parallel card
        if app.TTL_CheckBox.Value
            app.TaskSettings.TTLused = true;
            % Set the TTL Length
            app.TTLlog.TTLLength = app.TTLLength_EditField.Value/1000;
            % Initiate
            app.ttlDevice = hex2dec(app.ParallelAddress_EditField.Value);
            parPulse(app.ttlDevice);
            % Set all data lines to 0
            parPulse(app.ttlDevice,0,0,255,0);
        else
            disp('Note - TTLs not enabled. Just logging timestamps and not sending real TTLs.');
        end

        app.TTLlog.StartTime = GetSecs;
        
        % Send a train of 5 TTL pulses to indicate the start
        WaitSecs(0.005);
        for traini = 1:5
            Send_Log_TTL(app, GetSecs, ['TTL_Start_Train_' num2str(traini,'%0.2i')], true, false);
            WaitSecs(0.005);
        end
        disp('TTL initial pulse train sent.');

    otherwise
        error(['Bad Parallel TTL Setup command: ''' Process '''']);
end