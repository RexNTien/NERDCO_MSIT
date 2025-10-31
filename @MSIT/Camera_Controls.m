function Camera_Controls(app, Process)

% [Process = 'start'] is to start cameras
% [Process = 'stop'] is to stop cameras

% Checks if cameras are enabled first
% Different commands for different MATLAB versions

if app.Camera_CheckBox.Value
    
    if contains(version(),'R2022')
        switch Process
            case 'start'
                disp('Starting cameras...');
                % Create camera udpObj and set UDPnull
                portIDloc = 8866;
                portIDrem = 8844;
                app.udpObj = udp('169.254.164.86','RemotePort',portIDrem,'LocalPort',portIDloc); %#ok
                set(app.udpObj,'EnablePortSharing','on','Terminator','')
                try
                    fopen(app.udpObj);
                catch ME
                    disp('---- UDP Fail ----')
                    getReport(ME)
                    return
                end
                app.UDPnull = 0;
    
                % Test the camera connection
                fprintf(app.udpObj,num2str(22)); % send a message
                %             pause(1);
                tic
                while ~app.udpObj.BytesAvailable() && app.UDPnull == 0
                    if toc > 5
                        app.UDPnull = 1;
                        break
                    end
                end
                if app.udpObj.BytesAvailable()
                    diskTest = fscanf(app.udpObj); % receive a message
                    if strcmp(diskTest,'cancel')
                        disp('---- Not Enough Space on Laptop Hard Drive ----')
                        return
                    end
                    disp(diskTest)
                    %         disp(TbSize)
                end
                % Start camera recording
                fprintf(app.udpObj,'start'); % send a message
                pause(1);
                fprintf(app.udpObj,'pause'); % send a message
                WaitSecs(.1)
                fprintf(app.udpObj,'start'); % send a message
                app.CamsRunning = true;
                disp('Cameras started with 0.1 second pause.');
    
            case 'stop'
                if app.CamsRunning
                    disp('Stopping cameras...');
                    fprintf(app.udpObj,'pause'); % send a message
                    WaitSecs(1)
                    fprintf(app.udpObj,'start'); % send a message
                    WaitSecs(1)
                    % stopping cameras
                    fprintf(app.udpObj,'stop'); % send a message
                    % pause(1);
                    % fprintf(app.udpObj,'stop'); % send a message
                    fclose(app.udpObj);
                    delete(app.udpObj);
                    clear app.udpObj
                    disp('Cameras stopped with 1 second pause.');
                    app.CamsRunning = false;
                else
                    disp('Cameras were not running - did not stop them.')
                end
    
            otherwise
                error(['Bad Camera Controls command: ''' Process '''']);
        end
    
    else
        switch Process
            case 'start'
                disp('Starting cameras...');
                % Create camera udpObj and set UDPnull
                portIDloc = 8866;
                portIDrem = 8844;
                remoteIP = "169.254.164.86";
                % app.udpObj = udp('169.254.164.86','RemotePort',portIDrem,'LocalPort',portIDloc); %#ok
                % set(app.udpObj,'EnablePortSharing','on','Terminator','')
                app.udpObj = udpport("byte", 'LocalPort', portIDloc, 'EnablePortSharing', true);
                configureTerminator(app.udpObj,"LF");
                % try
                %     fopen(app.udpObj);
                % catch ME
                %     disp('---- UDP Fail ----')
                %     getReport(ME)
                %     return
                % end
                app.UDPnull = 0;
    
                % Test the camera connection
                % fprintf(app.udpObj,num2str(22)); % send a message
                writeline(app.udpObj, num2str(22), remoteIP, portIDrem);
                %             pause(1);
                tic
                % while ~app.udpObj.BytesAvailable() && app.UDPnull == 0
                while app.udpObj.NumBytesAvailable == 0
                    if toc > 5
                        app.UDPnull = 1;
                        break
                    end
                end
                if app.udpObj.NumBytesAvailable > 0
                    diskTest = readline(app.udpObj); % receive a message
                    if strcmp(diskTest,'cancel')
                        disp('---- Not Enough Space on Laptop Hard Drive ----')
                        return
                    end
                    disp(diskTest)
                    %         disp(TbSize)
                end
                % Start camera recording
                % fprintf(app.udpObj,'start'); % send a message
                writeline(app.udpObj, "start", remoteIP, portIDrem);
                pause(1);
                % fprintf(app.udpObj,'pause'); % send a message
                writeline(app.udpObj, "pause", remoteIP, portIDrem);
                WaitSecs(.1)
                % fprintf(app.udpObj,'start'); % send a message
                writeline(app.udpObj, "start", remoteIP, portIDrem);
                disp('Cameras started with 0.1 second pause.');
                app.CamsRunning = true;
    
            case 'stop'
                if app.CamsRunning
                    disp('Stopping cameras...');
                    portIDrem = 8844;
                    remoteIP = "169.254.164.86";
                    % fprintf(app.udpObj,'pause'); % send a message
                    writeline(app.udpObj, "pause", remoteIP, portIDrem);
                    WaitSecs(1)
                    % fprintf(app.udpObj,'start'); % send a message
                    writeline(app.udpObj, "start", remoteIP, portIDrem);
                    WaitSecs(1)
                    % stopping cameras
                    % fprintf(app.udpObj,'stop'); % send a message
                    writeline(app.udpObj, "stop", remoteIP, portIDrem);
                    % pause(1);
                    % fprintf(app.udpObj,'stop'); % send a message
                    % fclose(app.udpObj);
                    delete(app.udpObj);
                    clear app.udpObj
                    disp('Cameras stopped with 1 second pause.');
                    app.CamsRunning = false;
                else
                    disp('Cameras were not running - did not stop them.')
                end
    
            otherwise
                error(['Bad Camera Controls command: ''' Process '''']);
        end
    end

else
    disp('Cameras not enabled.');
end