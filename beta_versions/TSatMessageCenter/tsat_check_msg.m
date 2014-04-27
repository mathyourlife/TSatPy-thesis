function tsat_check_msg()

global tsat_msg_waits tsat_timer_state tsat_msg_handlers tsat_msg_headers
global MAXMSG tsat_timer tsat_data_fcn_call

msg_num=0;
msg_data=0;

%Check buffer for data
TSsock=evalin('base','TSsock');

size=pnet(TSsock,'readpacket',65500,'noblock');
%[size, header] = fakeheaders();

if size<=0
    %if no data
    %  # waits ++
    for i=1:MAXMSG
        if tsat_timer_state{i} ~= 0
            tsat_msg_waits{i}{1} = tsat_msg_waits{i}{1} + 1;
        end
        %  If the timer has exceeded the specified wait time, 
        if tsat_msg_waits{i}{1} > tsat_msg_waits{i}{2}
            switch i
                case 64
                    %Special Case for log entry return.  If the timer expires,
                    %reset the timer and resend request for data.
                    log_entry=evalin('base','log_entry');

                    reply=sprintf('Waiting too long for log entry %d', ...
                        log_entry);
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
                case 65
                    %Special Case for log size return.  If the timer 
                    %expires, reset the timer and resend request for data.
                    disp('Waiting too long for the log size.');

                    %Reset timer entry
                    tsat_msg_waits{65}{1}=0;
                    tsat_msg_waits{65}{2}=10;
                    tsat_data_fcn_call{65}=7;
                    tsat_timer_state{65}=1;

                    %Resend message for log size
                    disp('Resending message for log size');

                    tsat_send_msg(23,{[0]},TSsock);
                otherwise
                    tsat_msg_waits{i}{1} = 0;
                    tsat_timer_state{i}=0;
                    TSatMC_handles=evalin('base','TSatMC_handles');
                    set(TSatMC_handles.display_info,'String', ...
                        'ERROR WAITING TOO LONG FOR SENSOR DATA SCAN')
            end
        end
    end

    %  Reset timer if no timer states are set
    active_timers = 0;
    for i=1:MAXMSG
        if tsat_timer_state{i}==1
            active_timers = active_timers + 1;
        end
    end
    display(['active timers ' num2str(active_timers)])
    if active_timers == 0
        stop(tsat_timer);
    end

    %  exit function
    return;
else
    %if data exists
    %  get message number
    
    % Get the header and message number
    header=pnet(TSsock,'read',5,'uint8','intel');     
    msg_num = header(1)

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
    flags = header(2);
    msg_data = feval(@handle_TSat3MC,tsat_data_fcn_call{msg_num},msg_num,handler);
    %msg_data = feval(handler,flags,sock);

    % Append data to buffer text log
    fid = fopen('buffer.txt','a');
    fprintf(fid,'%5d', msg_num);
    fprintf(fid,'%10.2f', msg_data);
    fprintf(fid,'\n');
    fclose(fid);
end