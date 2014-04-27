function CalibrateTSat(calibration_step)

    global tsat_calib_timer
    persistent gyro_last_volt
    handles=evalin('base','TSatMC_handles');

    spin_up_voltage = 5;
    sample_rate = 40;

    %Enter Calibration step
    switch calibration_step
        case 0 %Initialize
            display('Calibration Step 0 - Initializing')
            
            %Establish Calibration timer
            tsat_calib_timer = timer;
            set(tsat_calib_timer,'executionMode','singleShot')
            set(tsat_calib_timer,'StartDelay',5)
            set(tsat_calib_timer,'TimerFcn','CalibrateTSat(2)')
            start(tsat_calib_timer)
            
            %Initialize gyro moving average values to high values
            gyro_last_volt = [1 10 100 1000 100000];

            %Set and confirm sample rate.
            [msg_num, msg_data] = SendCommandAndWait(33,sample_rate,133);

            CalibrateTSat(1)
            
        case 1 %Setup sensor recording for steady state calibration.
            display('Calibration Step 1 - Collecting resting state')

            set(handles.display_info,'String', ...
                'Calibration Step 1 - Collecting resting state')

            %Set and confirm start recording.
            [msg_num, msg_data] = SendCommandAndWait(19,1,119);

        case 2 %Analyze steady state sensor data.
            display('Calibration Step 2 - Analyzing resting state')
            
            %Stop the calibration timer.
            stop(tsat_calib_timer);
            
            set(handles.display_info,'String', ...
                'Calibration Step 2 - Analyzing resting state')

            %Set and confirm end sensor collection.
            [msg_num, msg_data] = SendCommandAndWait(19,0,119);

            %Retreive the sensor log from TSat.
            data = RetrieveSensorLog();
            
            %Check variation are within tolerances for acurate baselines
            %for the accelerometers and gyro.
            margin_of_error = zeros(1,16);
            for n=9:13
                %Calculate the margin of error for the voltage means for
                %the gyro and accelerometers.  If the margin of error is
                %more than 0.005 V with a 95% confidence interval, repeat
                %calibration step 1 with a longer timer interval.
                margin_of_error(n)=std(data(1:end,n))/sqrt(size(data,1))*1.96;
                if margin_of_error(n)>0.005
                    reply = sprintf('Sensor #%d has too much noise. Repeating calibration step 1',n);
                    set(handles.display_info,'String', reply)
                    
                    %Add 3 seconds to sensor recording time.
                    display('Repeating Calibration step 1 with longer period')
                    old_timer=get(tsat_calib_timer,'StartDelay');
                    tsat_calib_timer = timer;
                    set(tsat_calib_timer,'executionMode','singleShot')
                    set(tsat_calib_timer,'StartDelay',old_timer+3)
                    set(tsat_calib_timer,'TimerFcn','CalibrateTSat(2)')
                    start(tsat_calib_timer)
                    
                    CalibrateTSat(1)
                    return;
                end
            end
            
            %Find means for each sensor reading.
            baseline.accel(1) = mean(data(1:end,9));
            baseline.accel(2) = mean(data(1:end,10));
            baseline.accel(3) = mean(data(1:end,11));
            baseline.accel(4) = mean(data(1:end,12));
            baseline.gyro = mean(data(1:end,13));

            assignin('base','baseline',baseline);
            
            %Calibration step 2 complete moving on to step 3.
            CalibrateTSat(3)
            return;
        
        case 3 %Setup sensor recording for spin up
            display('Calibration Step 3 - Spin up')
            
            set(handles.display_info,'String', ...
                'Calibration Step 3 - Spin up')
            
            %Set voltage to spin up fan either clockwise or counter
            %clockwise.
            [msg_num, msg_data] = SendCommandAndWait(18, ...
                [spin_up_voltage,0,0,0],118);

            %Start timer to check for acceleration.
            set(tsat_calib_timer,'executionMode','fixedRate')
            set(tsat_calib_timer,'Period',4)
            set(tsat_calib_timer,'TimerFcn','CalibrateTSat(4)')
            start(tsat_calib_timer)
            return;
            
        case 4
            display('Calibration Step 4 - Spinning up to steady speed')

            set(handles.display_info,'String', ...
                'Calibration Step 4 - Spinning up to steady speed')
            
            %Check every 4 seconds
            %Request sensor data and wait.
            [msg_num, msg_data] = SendCommandAndWait(20,0,63);
            
            %Calculate slope of the last five gyro readings.
            x=zeros(1,size(gyro_last_volt,2));
            for n=1:size(gyro_last_volt,2)
                x(n) = n;  %populate x vector for polyfit size of gyro recordings
            end
            p=polyfit(x,gyro_last_volt,1);
            if abs(p(1)) < 0.005
                %Gyro shows an acceleration approaching zero over the last 
                %4 seconds. Stop the timer and move to analysis.
                
                %Stop the timer and move on to the next calibration step.
                stop(tsat_calib_timer)
                CalibrateTSat(5)
                return;
            else
                %Bump values for moving average.
                for n=1:size(gyro_last_volt,2)-1
                    gyro_last_volt(n) = gyro_last_volt(n+1);
                end
                gyro_last_volt(size(gyro_last_volt,2))=msg_data(12);
            end
            
        case 5
            display('Calibration Step 5 - Recording spin data')
            
            set(handles.display_info,'String', ...
                'Calibration Step 5 - Recording spin data')
            
            %Set and confirm start recording.
            [msg_num, msg_data] = SendCommandAndWait(19,1,119);

            
            %If timer is on, then turn off
            if strcmp(get(tsat_calib_timer,'Running'),'on')
                stop(tsat_calib_timer);
            end
            tsat_calib_timer = timer;
            set(tsat_calib_timer,'executionMode','singleShot')
            set(tsat_calib_timer,'StartDelay',10)
            set(tsat_calib_timer,'TimerFcn','CalibrateTSat(6)')
            start(tsat_calib_timer)

        case 6
            display('Calibration Step 6 - Analyze spin data')
            
            set(handles.display_info,'String', ...
                'Calibration Step 6 - Analyze spin data')
            
            %Set and confirm stop recording.
            [msg_num, msg_data] = SendCommandAndWait(19,0,119);

            %Send and confirm zeroed actuators.
            [msg_num, msg_data] = SendCommandAndWait(4,2,104);
            
            %Retrieve sensor log
            data = RetrieveSensorLog();
            
            %Determine spin rate from TAM z
            Y=fft(data(1:end,16));
            Y(1)=[];
            n=length(Y);
            power = abs(Y(1:floor(n/2))).^2;
            nyquist = 1/2;
            freq = (1:n/2)/(n/2)*nyquist;

            index=find(power==max(power));
            rpm = freq(index)*sample_rate*60;
            
            %Calculate and store sensor reading to rpm conversion
            baseline=evalin('base','baseline');
            conv.sensor_to_rpm.gyro = rpm / (mean(data(1:end,13)) - baseline.gyro);
            conv.sensor_to_rpm.accel(1) = rpm / (mean(data(1:end,9)) - baseline.accel(1));
            conv.sensor_to_rpm.accel(2) = rpm / (mean(data(1:end,10)) - baseline.accel(2));
            conv.sensor_to_rpm.accel(3) = rpm / (mean(data(1:end,11)) - baseline.accel(3));
            conv.sensor_to_rpm.accel(4) = rpm / (mean(data(1:end,12)) - baseline.accel(4));
            
            assignin('base','conv',conv)
            
            %Get max and min values for TAM
            
            set(handles.display_info,'String', ...
                'Calibration Complete')
        otherwise

    end


function data = RetrieveSensorLog()
    %Delete the current sensor log text file
    delete 'sensor_log.txt'
    pause(0.1)

    %Retrieve log size
    [msg_num, msg_data] = SendCommandAndWait(23,0,65);
    log_size = msg_data;
    reply=sprintf('Retrieving %d log entries.',log_size);
    display(reply)

    for i=1:log_size
        [msg_num, msg_data] = SendCommandAndWait(23,i,64);

        data_list='';
        for n=1:length(msg_data)
            if n==1
                data_list = [num2str(msg_data(n))];
            else
                data_list = [data_list ' ' num2str(msg_data(n))];
            end
        end

        fid = fopen('sensor_log.txt','a');
        fprintf(fid,data_list);
        fprintf(fid,'\n');
        fclose(fid);
    end
    [data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
        
    
    
function [msg_num, msg_data] = SendCommandAndWait(send_msg_num, ...
    send_data, wait_msg_num)
    
    msg_data = 0;
    TSsock=evalin('base','TSsock');

    %Send command to TSat
    switch send_msg_num
        case 19
            if send_data == 1
                tsat_send_msg(19,{uint8(1)},TSsock)
            else
                tsat_send_msg(19,{uint8(0)},TSsock)
            end
        case 20
            tsat_send_msg(20,{uint8(0)},TSsock)
        case 4
            switch send_data
                case 0
                    tsat_send_msg(4,{uint8(0)},TSsock)
                case 1
                    tsat_send_msg(4,{uint8(1)},TSsock)
                case 2
                    tsat_send_msg(4,{uint8(2)},TSsock)
            end
        otherwise
            tsat_send_msg(send_msg_num,{send_data},TSsock)
    end
    
    msg_num=0;
    received=0;
    attempts=0;
    while (msg_num==0 || received==0)
        pause(0.05)
        attempts = attempts+1;
        [msg_num, msg_data] = tsat_recv_msg(TSsock);
        if msg_num == wait_msg_num
            received=1;
        end
        %If ten attemtps fail, resend sample rate confirmation.
        if attempts >= 10
            %Send command to TSat
            switch send_msg_num
                case 19
                    if send_data == 1
                        tsat_send_msg(19,{uint8(1)},TSsock)
                    else
                        tsat_send_msg(19,{uint8(0)},TSsock)
                    end
                case 20
                    tsat_send_msg(20,{uint8(0)},TSsock)
                case 4
                    switch send_data
                        case 0
                            tsat_send_msg(4,{uint8(0)},TSsock)
                        case 1
                            tsat_send_msg(4,{uint8(1)},TSsock)
                        case 2
                            tsat_send_msg(4,{uint8(2)},TSsock)
                    end
                otherwise
                    tsat_send_msg(send_msg_num,{send_data},TSsock)
            end
            attempts = 0;
        end
    end

