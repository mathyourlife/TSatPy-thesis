function send_control_signal( control_signal )
%SEND_CONTROL_SIGNAL Summary of this function goes here
%   Detailed explanation goes here

    TSsock=evalin('base','TSsock');
    handles=evalin('base','TSatMC_handles');
    
    rotation = sign(control_signal);
    
    %Check control signal against fan's operating range (9.5 to 15 V).
    control_mag = abs(control_signal);
    if control_mag >= 14
        fan1=14;
        fan2=0;
    elseif control_mag >=10
        fan1=control_mag;
        fan2=0;
    elseif control_mag >= 7.5
        fan1=10;
        fan2=0;
    elseif control_mag >= 4
        fan1=14;
        fan2=10;
    elseif control_mag >= 0.05
        fan1=10+control_mag;
        fan2=10;
    else
        fan1=10;
        fan2=10;
    end
    
    %Convert desired fan voltage to sent voltage
    fan1_send_signal = fan1*0.4 + 0.1522;
    fan2_send_signal = fan2*0.4 + 0.1522;
    
    artificial_input = (2*sin(3*rem(now*24*60,1)*60)+12)*0.4+0.1522;
    if rotation == -1
        tsat_send_msg(18,{[fan2_send_signal, 0, ...
            fan1_send_signal, 0]},TSsock);
        set(handles.control_fan_3,'String',num2str(fan1))
        set(handles.control_fan_1,'String',num2str(fan2))
    else
        tsat_send_msg(18,{[fan1_send_signal, 0, ...
            fan2_send_signal, 0]},TSsock);
        set(handles.control_fan_1,'String',num2str(fan1))
        set(handles.control_fan_3,'String',num2str(fan2))
    end