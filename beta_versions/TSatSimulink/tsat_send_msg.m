function tsat_send_msg(msgnum,data,sock)

global tsat_msg_headers tsat_msg_handlers tsat_msg_flags

if (length(tsat_msg_headers{msgnum})==5)
    pnet(sock,'write',tsat_msg_headers{msgnum},'intel');
    if (isstruct(data))  % flatten structures into cell array
        data=struct2cell(data);
    end
    for i=1:length(data)  % loop through cells
        if (length(data{i})>0)
            if (size(data{i},1)>1)
              pnet(sock,'write',data{i}','intel');
            else
              pnet(sock,'write',data{i},'intel');
          end
        end
    end
    pnet(sock,'writepacket');
else
    reply=sprintf('Message %d has not been registered\n',msgnum);
    disp(reply);
end


