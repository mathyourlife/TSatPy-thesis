function sock=tsat_init(port,tsat_addr)

global tsat_msg_headers tsat_msg_handlers tsat_msg_flags tsat_msg_waits

MAXMSG = 256;  % Maximum number of messages (arbitrary!)

bsize = 1;          % Size of byte (single char)
dsize = 8;          % Size of double
vsize = 32767;   % Flag for variably-sized messages

sock=pnet('udpsocket',port);                  % Open socket on recognized port for listening
pnet(sock,'udpconnect',tsat_addr,port);   % All outgoing connections will be to tsat_addr

% Null out all the arrays

for i=1:MAXMSG
    tsat_msg_headers{i}  = [];
    tsat_msg_handlers{i} = @handle_NULL;
    tsat_msg_flags(i)      = 0;
    tsat_msg_waits(i)     = 0;
end

Msgs = { {     2,  @handle_ackMesg,bsize},  ...        % Receive Acknowledgements 
              {4,  @handle_NULL,bsize}, ...            % Set run Mode (send 0 to shutdown)
              {18, @handle_NULL,4*dsize}, ...          % Set Fan speed data (double npts,vector wpts,vector forcepts)
              {19, @handle_NULL,bsize}, ...
              {20, @handle_NULL, bsize}, ...           % Request raw sensor readings from vehicle
              {21, @handle_NULL, bsize}, ...           % Request to send recorded data
              {22, @handle_endDataMesg, bsize},  ... 
              {33, @handle_NULL, dsize}, ...           % Set data storage sample rate
              {63, @handle_RawData,15*dsize}, ...      %  Receive raw sensor readings from vehicle
              {64, @handle_RawData,16*dsize}, ...
             
              };
 

%  Report success

for i=1:size(Msgs,2)
    tsat_register_msg(Msgs{i}{1},0,Msgs{i}{3},Msgs{i}{2});
end

reply=sprintf('Tablesat communications initialized on port %d\n',port);
disp(reply);

