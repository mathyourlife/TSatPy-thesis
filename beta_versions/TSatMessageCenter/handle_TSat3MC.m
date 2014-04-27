function msg_data = handle_TSat3MC(flag, msg_num, handler)
%HANDLE_UPDATE_SENSORS Summary of this function goes here
%   Detailed explanation goes here

    global tsat_msg_waits tsat_timer_state tsat_data_fcn_call
    msg_data = 0;
    
    % Zero out message receipt prior to function call so it can be
    % reinitialized if necessary.
    tsat_msg_waits{msg_num}{1} = 0;
    tsat_msg_waits{msg_num}{2}=0;
    tsat_data_fcn_call{msg_num}=0;
    tsat_timer_state{msg_num}=0;

    switch flag
        case 1  %Update sensor display
            msg_data = UpdateSensorDisplay(handler);
        case 2  %Print acknowledgment of new voltages
            msg_data = AcknowledgeNewVoltage();
        case 3  %Print acknowledgment of run mode to shut off actuators
            msg_data = AcknowledgeNoActuators();
        case 4  %Print acknowledgment of program shutdown
            msg_data = AcknowledgeShutdown();
        case 5  %Acknowledge sensor log rate change
            msg_data = AcknowledgeLogRate();
        case 6  %Acknowledge start/stop of sensor log
            msg_data = AcknowledgeStartStopLog();
        case 7  %Retrieve sensor log data
            msg_data = ReadSensorLog(handler);
        case 8  %Retrieved sensor log size
            msg_data = ReadLogSize(handler);
        otherwise

    end

function msg_data = UpdateSensorDisplay(handler)

    TSatMC_handles=evalin('base','TSatMC_handles');
    TSsock=evalin('base','TSsock');

    msg_data = feval(handler,0,TSsock);
    %msg_data = fakedata(63);

    data_list=['Timestamp: ' num2str(msg_data(1)) char(10)];
    data_list=[data_list char(10)];
    data_list=[data_list 'CSS1:    ' num2str(msg_data(2)) ' V' char(10)];
    data_list=[data_list 'CSS2:    ' num2str(msg_data(3)) ' V' char(10)];
    data_list=[data_list 'CSS3:    ' num2str(msg_data(4)) ' V' char(10)];
    data_list=[data_list 'CSS4:    ' num2str(msg_data(5)) ' V' char(10)];
    data_list=[data_list 'CSS5:    ' num2str(msg_data(6)) ' V' char(10)];
    data_list=[data_list 'CSS6:    ' num2str(msg_data(7)) ' V' char(10)];
    data_list=[data_list char(10)];
    data_list=[data_list 'Accel1Y:    ' num2str(msg_data(8)) ' V' char(10)];
    data_list=[data_list 'Accel1X:    ' num2str(msg_data(9)) ' V' char(10)];
    data_list=[data_list 'Accel2Y:    ' num2str(msg_data(10)) ' V' char(10)];
    data_list=[data_list 'Accel2X:    ' num2str(msg_data(11)) ' V' char(10)];
    data_list=[data_list char(10)];
    data_list=[data_list 'Gyro:    ' num2str(msg_data(12)) ' V' char(10)];
    data_list=[data_list char(10)];
    data_list=[data_list 'MagX:    ' num2str(msg_data(13)) ' V' char(10)];
    data_list=[data_list 'MagY:    ' num2str(msg_data(14)) ' V' char(10)];
    data_list=[data_list 'MagZ:    ' num2str(msg_data(15)) ' V' char(10)];
    
    %TableSat Angle Calculations
    data_list=[data_list char(10)];
    data_list=[data_list 'Theta' char(10)];
    
    %Calculate CSS angle
    [css_mag, css_theta]=conv_css_to_theta([msg_data(2) msg_data(3) ...
        msg_data(4) msg_data(5) msg_data(6) msg_data(7)]');

    data_list=[data_list 'CSS:    ' ...
        num2str(round(css_theta *180/pi()*10)/10) ' deg' char(10)];

    %Calculate TAM angle
    [tam_theta, tam_mag] = conv_tam_to_theta([msg_data(13) msg_data(14) ...
        msg_data(15)]');
    
    data_list=[data_list 'TAM:    ' ...
        num2str(round(tam_theta *180/pi()*10)/10) ' deg' char(10)];

    %Combine Tam and CSS angle measurements
    if tam_theta<90 && css_theta>270
        css_theta=css_theta-360;
    elseif css_theta<90 && tam_theta>270
        tam_theta=tam_theta-360;
    end
    tsat_theta = (css_theta+tam_theta)/2;
    if tsat_theta<0
        tsat_theta = tsat_theta+360;
    end
    data_list=[data_list 'TSat:    ' num2str(round(tsat_theta*180/pi()*10)/10) ' deg' char(10)];
    
    %TableSat Angular Velocity Calculations
    data_list=[data_list char(10)];
    data_list=[data_list 'Omega' char(10)];

    %Calculate Accelerometer readings.
    [accel_x, accel_y, accel_z] = conv_accel_to_omega([msg_data(8) ...
        msg_data(9) msg_data(10) msg_data(11)]');
    
    data_list=[data_list 'Accel x:    ' ...
        num2str(round(accel_x*10)/10) ' rpm' char(10)];
    data_list=[data_list 'Accel y:    ' ...
        num2str(round(accel_y*10)/10) ' rpm' char(10)];
    data_list=[data_list 'Accel z:    ' ...
        num2str(round(accel_z*10)/10) ' rpm' char(10)];
    
     %Calculate gyro angular rate
    gyro_rpm=conv_gyro_to_omega(msg_data(12));
    
    data_list=[data_list 'Gyro z:      ' ...
        num2str(round(gyro_rpm*10)/10) ' rpm' char(10)];

    %Combine Accel and Gyro for angular rate
    tsat_omega = (accel_z+gyro_rpm)/2;
    data_list=[data_list 'TSat z:      ' num2str(round(tsat_omega*10)/10) ' rpm' char(10)];
    
    set(TSatMC_handles.sensordata,'String',data_list)
    set(TSatMC_handles.display_info,'String', ...
        'REQUESTED SENSOR DATA HAS BEEN RETURNED')

function msg_data = AcknowledgeNewVoltage()
    
    TSatMC_handles=evalin('base','TSatMC_handles');
    set(TSatMC_handles.display_info,'String', ...
        'ACKNOWLEDGE - NEW VOLTAGE SETTING')
    msg_data = 1;

function msg_data = AcknowledgeNoActuators()
    
    TSatMC_handles=evalin('base','TSatMC_handles');
    set(TSatMC_handles.display_info,'String', ...
        'ACKNOWLEDGE - ACTUATOR SHUT OFF')
    msg_data = 1;

function msg_data = AcknowledgeShutdown()
    
    TSatMC_handles=evalin('base','TSatMC_handles');
    set(TSatMC_handles.display_info,'String', ...
        'TSAT SHUTDOWN - NO COMMUNICATION')
    msg_data = 1;

function msg_data = AcknowledgeLogRate()
    
    TSatMC_handles=evalin('base','TSatMC_handles');
    set(TSatMC_handles.display_info,'String', ...
        'ACKNOWLEDGE - SENSOR LOG RATE UPDATE')
    msg_data = 1;

function msg_data = AcknowledgeStartStopLog()
    
    TSatMC_handles=evalin('base','TSatMC_handles');
    set(TSatMC_handles.display_info,'String', ...
        'ACKNOWLEDGE - START/STOP SENSOR LOG')
    msg_data = 1;

function msg_data = ReadSensorLog(handler)

    global tsat_msg_waits tsat_timer_state tsat_data_fcn_call

    TSatMC_handles=evalin('base','TSatMC_handles');
    TSsock=evalin('base','TSsock');
    log_entry=evalin('base','log_entry');
    log_size=evalin('base','log_size');
    
    msg_data = feval(handler,0,TSsock);
    %msg_data = fakedata(64);

    if msg_data(1) ~= log_entry
        reply=sprintf('Expecting log entry %d and received log entry %d instead.', ...
            log_entry,msg_data(1));
        disp(reply);
        
        %Reset timer entry
        tsat_msg_waits{64}{1}=0;
        tsat_msg_waits{64}{2}=10;
        tsat_data_fcn_call{64}=7;
        tsat_timer_state{64}=1;

        %Resend message for log entry
        reply=sprintf('Resending message for log entry %d.', log_entry);
        disp(reply);

        tsat_send_msg(23,{[log_entry]},TSsock);
    end

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

    if log_entry >= log_size
        %Completed log read
        tsat_msg_waits{64}{1} = 0;
        tsat_msg_waits{64}{2}=0;
        tsat_data_fcn_call{64}=0;
        tsat_timer_state{64}=0;

        set(TSatMC_handles.display_info,'String', ...
            'SENSOR LOG: END OF FILE REACHED')

        [data, result]= readtext('sensor_log.txt', ' ', '','','numeric')
        plot_sensors(data(1:end,2:end));

        msg_data = 1;
    else
        %Log not completed
        
        %Reset timers
        assignin('base','log_entry',log_entry+1);

        tsat_msg_waits{64}{1} = 0;
        tsat_msg_waits{64}{2}=10;
        tsat_data_fcn_call{64}=7;
        tsat_timer_state{64}=1;

        %Send message for next log entry
        tsat_send_msg(23,{[log_entry+1]},TSsock);
        
        set(TSatMC_handles.display_info,'String', ...
            'READING SENSOR DATA FROM LOG')
    end

function msg_data = ReadLogSize(handler)

    global tsat_msg_waits tsat_timer_state tsat_data_fcn_call
    
    TSsock=evalin('base','TSsock');
    msg_data = feval(handler,0,TSsock);
    
    %Send log size to base workspace for reference.
    assignin('base','log_size',msg_data);
    
    %Send request for first log entry.
    assignin('base','log_entry',1);
    
    %Set timer entry
    tsat_msg_waits{64}{1}=0;
    tsat_msg_waits{64}{2}=10;
    tsat_data_fcn_call{64}=7;
    tsat_timer_state{64}=1;

    %Send message for first log entry
    tsat_send_msg(23,{[1]},TSsock);