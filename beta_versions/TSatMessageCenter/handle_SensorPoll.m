function handle_SensorPoll()
%HANDLE_SENSORPOLL Summary of this function goes here
%   Detailed explanation goes here

    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call
    
    TSsock=evalin('base','TSsock');
    TSatMC_handles=evalin('base','TSatMC_handles');

    tsat_send_msg(20,{uint8(0)},TSsock)
    set(TSatMC_handles.display_info,'String','SENDING REQUEST FOR SENSOR SCAN')

    %Set # of waits to 0
    tsat_msg_waits{63}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{63}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{63}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{63} = 1;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end
