function [msg_num, msg_data] = tsat_recv_msg(sock)

global tsat_msg_headers tsat_msg_handlers

msg_data=0;
msg_num=0;

size=pnet(sock,'readpacket',65500,'noblock');
disp(size)
if (size>0) 
    header=pnet(sock,'read',5,'uint8','intel');     % Get the header and message number
    msg_num = header(1);
    handler = tsat_msg_handlers{msg_num};
    disp(header)
		disp(tsat_msg_headers{msg_num})
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
    %msg_data = fakedata(msg_num);
    msg_data = feval(handler,flags,sock);
		disp(msg_data)
else
    %No data in the buffer
end
