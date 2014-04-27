function [msgnum, msg_data] = tsat_recv_msg(sock)

global tsat_msg_headers tsat_msg_handlers tsat_msg_flags tsat_msg_watch tsat_msg_waits

msg_data=zeros(1,15);
msgnum=0;

size=pnet(sock,'readpacket',65500,'noblock');
tsat_msg_waits(tsat_msg_watch) = tsat_msg_waits(tsat_msg_watch)+1;

display('***********Checking size of returned buffer')
if (size>0) 
    
display('***********Buffer size > 0')
    header=pnet(sock,'read',5,'uint8','intel');     % Get the header and message number
    msgnum = header(1);
    handler = tsat_msg_handlers{msgnum};
   
    % Look for errors
display('***********Checking errors in message')
    if (isequal(handler,@handle_NULL))  % Check if message is registered
        reply=sprintf('Message %d received but not registered for receipt\n',char(msgnum));
        disp(reply);
        return;
    end
    if (header(3)~=tsat_msg_headers{msgnum}(3) | ...  % Check for correct payload length
        header(4)~=tsat_msg_headers{msgnum}(4))
        reply=sprintf('Message %d received but with incorrect payload size\n',char(msgnum));
        disp(reply);
        return; 
    end 
    
    % Get message flags and invoke handler
    flags = header(2);
    display('***********Invoking handler')
    %returned =feval(handler,flags,sock);
    msg_data = feval(handler,flags,sock);

end
