function handle_ControlLoop()
%HANDLE_CONTROLLOOP Summary of this function goes here
%   Detailed explanation goes here

%Check that get sensor flag is set.

global tsat_msg_waits tsat_timer_state tsat_msg_handlers tsat_msg_headers
global tsat_data_fcn_call tsat_msg_waits tsat_timer_state tsat_data_fcn_call
        
msg_num=0;
msg_data=0;

%Check buffer for data
TSsock=evalin('base','TSsock');
handles=evalin('base','TSatMC_handles');

size=pnet(TSsock,'readpacket',65500,'noblock');
%[size, header] = fakeheaders();

if size<=0

    %if no data
    %  # waits ++
    if tsat_timer_state{63} ~= 0
        tsat_msg_waits{63}{1} = tsat_msg_waits{63}{1} + 1;
    end
    %  If the timer has exceeded the specified wait time, 
    if tsat_msg_waits{63}{1} > tsat_msg_waits{63}{2}

        TSsock=evalin('base','TSsock');

        tsat_send_msg(20,{uint8(0)},TSsock)
        set(handles.display_info,'String', ...
            'ERROR WAITING TOO LONG FOR CONTROL SENSOR SCAN')

        %Set # of waits to 0
        tsat_msg_waits{63}{1}=0;

        %Set max # waits before lost packet assumed
        tsat_msg_waits{63}{2}=10;

        %Turn on appropriate timer
        tsat_timer_state{63}=1;

        %Set flag for which function handles the call back 
        tsat_data_fcn_call{63} = 1;

    end

    %  exit function
    return;
else
    %if data exists
    %  get message number
    
    % Get the header and message number
    header=pnet(TSsock,'read',5,'uint8','intel');     
    msg_num = header(1);

    %  Reset the number of waits for the received message
    %    #waits = 0
    tsat_msg_waits{msg_num}{1} = 0;
    tsat_msg_waits{msg_num}{2} = 0;
    
    %    Get message handler
    handler = tsat_msg_handlers{msg_num};
    
    % Look for errors
    if (isequal(handler,@handle_NULL))  % Check if message is registered
        reply=sprintf('Message %d received but not registered for receipt\n',char(msg_num));
        disp(reply);
        return;
    end
    if (header(3)~=tsat_msg_headers{msg_num}(3) | ...  % Check for correct payload length
        header(4)~=tsat_msg_headers{msg_num}(4))
        reply=sprintf('Message %d received but with incorrect payload size\n',char(msg_num));
        disp(reply);
        return; 
    end 
    
    % Get message flags and invoke handler
    flags = 0;
    feval(@control_pid,flags);
    %msg_data = feval(handler,flags,sock);

    % Append data to buffer text log
    fid = fopen('buffer.txt','a');
    fprintf(fid,'%5d', msg_num);
    fprintf(fid,'%10.2f', msg_data);
    fprintf(fid,'\n');
    fclose(fid);
end