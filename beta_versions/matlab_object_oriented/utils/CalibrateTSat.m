function CalibrateTSat(calibration_step)
% Calibrate the TableSat.
% This should be run on each program startup.
% Calibration routine is to:
%   a) Determine reference values for sensors at steady state.
%   b) Send steady voltage to a spin fan and wait for sensors to reach
%      equilibrium.
%   c) Calculate spin rate and associate with determine change in 
%      global tsat_calib_timer baseline conv sensor_count

    global sensor_count sensor baseline conv noise_var TAM
    global tsat_timer_buffer TShandles
    persistent gyro_last_volt record_pause

    spin_up_voltage = 15;    % What voltage to send to 1 spin fan.
    sample_rate = 40;       % Set the sensor log sample rate.
    error_threshold = 0.005;  % Sets the maximum threshold for the margin of error.

    %Enter Calibration step
    switch calibration_step
        case 0 %Initialize
            disp('Calibration Step 0 - Initializing')
            
            %Stop the check buffer timer
            stop(tsat_timer_buffer)
            
            %Initialize gyro moving average values to high values
            gyro_last_volt = [1 10 100 1000 100000 1000000 10000000];
            
            %Set sample rate.
            SendCommandAndWait(33,sample_rate,133);

            record_pause = 5;
            CalibrateTSat(1)
            
        case 1 %Setup sensor recording for steady state calibration.
            disp('Calibration Step 1 - Collecting resting state')

            set(TShandles.display_info,'String', ...
                'Calibration Step 1 - Collecting resting state')

            % Start recording.
            SendCommandAndWait(19,1,119);
            
            pause(record_pause)
            CalibrateTSat(2)

        case 2 %Analyze steady state sensor data.
            disp('Calibration Step 2 - Analyzing resting state')
            
            set(TShandles.display_info,'String', ...
                'Calibration Step 2 - Analyzing resting state')

            % Stop sensor data collection.
            SendCommandAndWait(19,0,119);

            %Retreive the sensor log from TSat.
            RetrieveSensorLog();
            [data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
            assignin('base','resting_data',data);
            
            %Calculate the margin of error for the voltage means for
            %the gyro and accelerometers.  If the margin of error is
            %more than 0.005 V with a 95% confidence interval, repeat
            %calibration step 1 with a longer timer interval.
            max_margin_of_error = -1;
            for n=3:16
                if std(data(1:end,n))/sqrt(size(data,1))*1.96 > max_margin_of_error
                    max_margin_of_error = std(data(1:end,n))/sqrt(size(data,1))*1.96;
                    max_sensor = n;
                end
            end
            if max_margin_of_error>error_threshold
                % Estimated number of samples required to stay in margin of error
                est_size=(1.96*std(data(1:end,max_sensor))/error_threshold)^2;

                % Calculate the required sampling time.
                record_pause=record_pause*est_size/size(data,1)*1.1;

                reply = sprintf('Sensor %s has too much noise. Repeating steady state analysis for %d seconds.',...
                    SensorName(max_sensor-2),round(record_pause));
                set(TShandles.display_info,'String', reply)
                disp(reply)

                CalibrateTSat(1)
                return;
            end
            
            % Set the mean recorded values of the sensors during
            % steady state measurement to their baseline values except for
            % magnetometer which get a baseline during spin analysis.
            % Sensor data starts at column 3 column 1 is interative value
            % column 2 is a timestamp.
            j=3;   
            for i=1:sensor_count.css
                % baseline css voltage established during spin analysis
                noise_var.css(i)=var(data(1:end,j));    % css measurement variance
                j=j+1;
            end
            for i=1:sensor_count.accel.nut+sensor_count.accel.rot
                % Special situation - accelerometers 1 and 3 detect centripital
                % acceleration while accelerometers 2 and 4 detect nutation
                switch i
                    case 1
                        baseline.accel.nut(1)=mean(data(1:end,j));  % baseline accel voltage
                        noise_var.accel.nut(1)=var(data(1:end,j));  % accel measurement variance
                    case 2
                        baseline.accel.rot(1)=mean(data(1:end,j));  % baseline accel voltage
                        noise_var.accel.rot(1)=var(data(1:end,j));  % accel measurement variance
                    case 3
                        baseline.accel.nut(2)=mean(data(1:end,j));  % baseline accel voltage
                        noise_var.accel.nut(2)=var(data(1:end,j));  % accel measurement variance
                    case 4
                        baseline.accel.rot(2)=mean(data(1:end,j));  % baseline accel voltage
                        noise_var.accel.rot(2)=var(data(1:end,j));  % accel measurement variance
                end
                j=j+1;
            end
            for i=1:sensor_count.gyro
                baseline.gyro(i)=mean(data(1:end,j));   % baseline gyro voltage
                noise_var.gyro(i)=var(data(1:end,j));   % gyro measurement variance
                j=j+1;
            end
            for i=1:sensor_count.mag
                % Magnetometer baseline values established during spin.
                noise_var.mag(i)=var(data(1:end,j));    % magnetometer measurement variance
                j=j+1;
            end

            %Calibration step 2 complete moving on to step 3.
            CalibrateTSat(3)
            return;
        
        case 3 %Setup sensor recording for spin up
            disp('Calibration Step 3 - Spin up')
            
            set(TShandles.display_info,'String', ...
                'Calibration Step 3 - Spin up')
            
            % Set voltage to spin up fan.
            SendCommandAndWait(18, [spin_up_voltage,0,0,0],118);

            %Set slower sample rate.
            SendCommandAndWait(33,round(sample_rate/10),133);

            % Start recording.
            SendCommandAndWait(19,1,119);

            CalibrateTSat(4)
            
            return;
            
        case 4

            set(TShandles.display_info,'String', ...
                'Calibration Step 4 - Spinning up to steady speed')
            
            % Check every 4 seconds
            % Request sensor data.
            SendCommandAndWait(20,0,63);
            
            %Calculate slope of the last five gyro readings.
            x=zeros(1,size(gyro_last_volt,2));
            for n=1:size(gyro_last_volt,2)
                x(n) = n;  %populate x vector for polyfit size of gyro recordings
            end
            p=polyfit(x,gyro_last_volt,1);
            reply = sprintf('Calibration Step 4 - Spinning up (%0.3f)',abs(p(1)));
            disp(reply)
            if abs(p(1)) <= 0.003
                % Stop recording.
                SendCommandAndWait(19,0,119);
                % Retrieve sensor log
                RetrieveSensorLog();
                [data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
                assignin('base','spin_data',data);

                %Gyro shows an acceleration approaching zero over the last 
                %4 seconds. Stop the timer and move to analysis.
                CalibrateTSat(5)
                return;
            else
                %Bump values for moving average.
                for n=1:size(gyro_last_volt,2)-1
                    gyro_last_volt(n) = gyro_last_volt(n+1);
                end
                gyro_last_volt(size(gyro_last_volt,2))=sensor.gyro;
                
                %Pause for x seconds and then recheck acceleration.
                pause(4)
                CalibrateTSat(4)
            end
            
            
        case 5
            disp('Calibration Step 5 - Recording spin data')
            
            set(TShandles.display_info,'String', ...
                'Calibration Step 5 - Recording spin data')
            
            %Set sample rate.
            SendCommandAndWait(33,sample_rate,133);

            % Start recording.
            SendCommandAndWait(19,1,119);

            % Use the determined sensor pause to set record spin data duration.
            pause(record_pause)
            CalibrateTSat(6)

        case 6
            disp('Calibration Step 6 - Analyze spin data')
            
            set(TShandles.display_info,'String', ...
                'Calibration Step 6 - Analyze spin data')
            
            % Stop recording.
            SendCommandAndWait(19,0,119);

            % Zero actuators.
            SendCommandAndWait(4,2,104);
            
            % Retrieve sensor log
            RetrieveSensorLog();
            [data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
            assignin('base','steady_spin_data',data);
            
            % Complete FFT on TAM to determine spin rate.
            Y=fft(data(1:end,16));
            Y(1)=[];
            n=length(Y);
            power = abs(Y(1:floor(n/2))).^2;
            nyquist = 1/2;
            freq = (1:n/2)/(n/2)*nyquist;

            index=find(power==max(power));
            rpm = freq(index)*sample_rate*60;
            spin_rate = rpm *2*pi()/60;
            
            reply = sprintf('Steady state spin measured at %0.4f rad/sec',spin_rate);
            disp(reply)
            
            set(TShandles.display_info,'String', reply)
            
            % Calculate the increased in spin rate from 0 at steady state to 
            % the value calculated in the fft of the TAM as a function of the
            % change in voltage on each sensor.
            %    Note:  These values for CSS and Mag sensors are not useful.
            %
            j=3;   
            for i=1:sensor_count.css
                baseline.css(i)=mean(data(1:end,j));  % baseline css voltage
                j=j+1;
            end
            for i=1:sensor_count.accel.nut+sensor_count.accel.rot
                % Conversion factor for Voltage change to Spin Rate  (Units rad/s / delta volt)

                % Special situation - accelerometers 1 and 3 detect centripital
                % acceleration while accelerometers 2 and 4 detect nutation
                switch i
                    case 2
                        conv.accel.rot(1) = spin_rate / (mean(data(1:end,j))-baseline.accel.rot(1));
                    case 4
                        conv.accel.rot(2) = spin_rate / (mean(data(1:end,j))-baseline.accel.rot(2));
                    otherwise

                end
                j=j+1;
            end
            for i=1:sensor_count.gyro
                % Conversion factor for Voltage change to Spin Rate  (Units rad/s / delta volt)
                conv.gyro(i) = spin_rate / (mean(data(1:end,j))-baseline.gyro(i));
                j=j+1;
            end
            % Establish baseline values for the magnetometer
            for i=1:sensor_count.mag
                baseline.mag(i)=mean(data(1:end,j));    % baseline magnetometer voltage
                j=j+1;
            end

            %Reset the sensor log rate
            SendCommandAndWait(33,str2num(get(TShandles.sensorrate,'String')),133);
            
            set(TShandles.display_info,'String', ...
                'Calibration Complete')

            %Start up check buffer timer
            start(tsat_timer_buffer)

        otherwise

    end
        
    

