function Audio_Controls(app, Process)

% [Process = 'setup'] finds mics and sets up gui for mic selection
% [Process = 'start'] starts the audio
% [Process = 'stop'] stops and saves the audio if it's running

switch Process
    case 'setup'
        if app.Microphone_CheckBox.Value
            InitializePsychSound;
            
            % Poll the audio devices on the system
            devices = PsychPortAudio('GetDevices');
        
            % Filter for microphones
            microphones = devices(1);
            miccount = 0;
            for devi = 1:length(devices)
                if devices(devi).NrInputChannels > 0
                    if contains(devices(devi).DeviceName, 'Microphone') && contains(devices(devi).HostAudioAPIName, 'WASAPI') % Prefer WASAPI for performance
                        miccount = miccount+1;
                        microphones(miccount) = devices(devi);
                    end
                end
            end
        
            % Throw error if no microphones detected
            if miccount == 0
                error('Audio recording was enabled but no microphones were detected.');
            end
        
            % If the dropdown hasn't been enabled yet
            if strcmp(app.MicrophoneChoice.Enable, "off")
                % Enable the microphones dropdown, populate it
                app.MicrophoneChoice_Label.Enable = "on";
                app.MicrophoneChoice.Enable = "on";
                app.MicrophoneChoice.Items = {microphones.DeviceName};
                app.MicrophoneChoice.Value = app.MicrophoneChoice.Items{1};
            end
        
            % Set the microphone in app properties
            app.MicrophoneDevice = [];
            for mici = 1:length(microphones)
                if strcmp(microphones(mici).DeviceName, app.MicrophoneChoice.Value)
                    app.MicrophoneDevice = microphones(mici);
                end
            end
            if isempty(app.MicrophoneDevice)
                error('Could not find selected microphone on the system devices.');
            end
        
        else
            % Disable the dropdown
            app.MicrophoneChoice_Label.Enable = "off";
            app.MicrophoneChoice.Enable = "off";
            app.MicrophoneChoice.Items = {'...'};
            app.MicrophoneChoice.Value = app.MicrophoneChoice.Items{1};
        end
        
        app.MicrophoneHandle = NaN;

    case 'start'
        if app.Microphone_CheckBox.Value
            disp('Starting audio capture...');
            app.MicrophoneHandle = PsychPortAudio('Open', app.MicrophoneDevice.DeviceIndex, 2, [], [], 1);
%             if app.MicrophoneHandle == 0
%                 error('Invalid audio device handle generated when starting PsychPortAudio');
%             end
            PsychPortAudio('GetAudioData', app.MicrophoneHandle, 600); % Preallocate 10 minutes of recording
            audioStartTime = PsychPortAudio('Start', app.MicrophoneHandle, 0, 0, 1);
            % Send a TTL
            Send_Log_TTL(app, audioStartTime, 'Audio_Recording_Started', false, false);
            s = PsychPortAudio('GetStatus', app.MicrophoneHandle);
            freq = s.SampleRate;
            disp(['Audio recording started on ' app.MicrophoneDevice.DeviceName ' at ' num2str(freq) ' Hz.']);
        else
            disp('Audio recording disabled, did not start.');
        end

    case 'stop'
        if app.Microphone_CheckBox.Value
            % Check if the audio is running
            if ~isnan(app.MicrophoneHandle)
                s = PsychPortAudio('GetStatus', app.MicrophoneHandle);
                if s.Active == 1 && s.State == 2
                    disp('Stopping audio...');
                    [~,~,~,audioStopTime] = PsychPortAudio('Stop', app.MicrophoneHandle, [], 1);
                    % Send a TTL
                    Send_Log_TTL(app, audioStopTime, 'Audio_Recording_Stopped', false, true);
                    audiodata = PsychPortAudio('GetAudioData', app.MicrophoneHandle);
                    audioblockfile = append(app.FileSettings.OutputStub, '_Block', num2str(app.TaskSettings.CurrentBlock,'%0.2i'), '.wav');
                    psychwavwrite(transpose(audiodata), s.SampleRate, 16, audioblockfile);
                    disp(append('Audio stopped, saved in ', audioblockfile));
                    PsychPortAudio('Close', app.MicrophoneHandle);
                    app.MicrophoneHandle = NaN;
                end
            else
                disp('Could not find microphone handle to stop audio!');
            end
        else
            disp('Audio recording disabled, nothing to stop.');
        end

    otherwise
        error(['Bad Audio Controls command: ''' Process '''']);
end