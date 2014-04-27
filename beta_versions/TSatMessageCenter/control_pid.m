function control_pid( flag )
%CONTROL_PID Summary of this function goes here
%   Detailed explanation goes here

    persistent error_sum last_error last_timestamp
    if flag == 1;
        error_sum=0;
        last_error=0;
        last_timestamp=now;
        FilterMovingAverage(0,1)
        Plot_Realtime(1,1)
        return;
    end

    TSsock=evalin('base','TSsock');
    handles=evalin('base','TSatMC_handles');
    
    %Get sensor data
    msg_data = feval(@handle_RawData,0,TSsock);
    if size(msg_data,2)<12
        return;
    end

    if get(handles.chkRealtime,'Value')
        if get(handles.radioCSS,'Value')
            [ css_mag, css_theta ] = conv_css_to_theta( ...
                [msg_data(2); msg_data(3); msg_data(4); ...
                 msg_data(5); msg_data(6); msg_data(7) ] );
            Plot_Realtime(css_theta,0)
        end
        if get(handles.radioNutationX,'Value')
            Plot_Realtime(msg_data(8),0)
        end
        if get(handles.radioNutationY,'Value')
            Plot_Realtime(msg_data(10),0)
        end
        if get(handles.radioSpinAccel,'Value')
            Plot_Realtime((msg_data(9)-msg_data(11))/2,0)
        end
        if get(handles.radioGyro,'Value')
            Plot_Realtime(msg_data(12),0)
        end
        
    end

    %Filter option
    %Moving average
    if get(handles.chkMovingAverage,'Value')
        display('Filtering Sensors')
        msg_data = FilterMovingAverage(msg_data,0);
    end
    
    omega = conv_gyro_to_omega(msg_data(12));  %rpm
    set(handles.measured_omega,'String',[num2str(round(omega*10)/10) ' rpm'])
    
    %Get Desired RPM
    desired_rpm = str2num(get(handles.desired_rpm,'String'));
    
    %Calculate error
    PID_error = desired_rpm - omega;
    
    %Get PID gains from GUI
    pid_gains(1) = str2num(get(handles.pid_p,'String'));
    pid_gains(2) = str2num(get(handles.pid_i,'String'));
    pid_gains(3) = str2num(get(handles.pid_d,'String'));

    %Proportional
    pid_p = pid_gains(1) * PID_error;
    
    %Integral
    error_sum = error_sum + PID_error;
    pid_i = pid_gains(2) * error_sum;

    %Derivative
    slope = (PID_error - last_error)/(now - last_timestamp);
    pid_d = slope * pid_gains(3);
    
    control_signal = pid_p + pid_i + pid_d;
    
    send_control_signal(control_signal)
    
    %Record values for next call
    last_error = PID_error;
    last_timestamp = now;