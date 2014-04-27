function sock=tsat_init(port,tsat_addr)

global tsat_msg_headers tsat_msg_handlers tsat_msg_flags tsat_msg_waits
global tsat_timer tsat_polling_timer tsat_control_timer tsat_timer_state 
global MAXMSG tsat_data_fcn_call

addpath(genpath(pwd));

MAXMSG = 256;    % Maximum number of messages (arbitrary!)

bsize = 1;       % Size of byte (single char)
dsize = 8;       % Size of double
vsize = 32767;   % Flag for variably-sized messages

sock=pnet('udpsocket',port);              % Open socket on recognized port for listening
if sock==-1
    disp('ERROR: Unable to open UDP socket')
end
pnet(sock,'udpconnect',tsat_addr,port);   % All outgoing connections will be to tsat_addr

% Null out all the arrays
for i=1:MAXMSG
    tsat_msg_headers{i}    = [];
    tsat_msg_handlers{i}   = @handle_NULL;
    tsat_msg_flags(i)      = 0;
    tsat_msg_waits{i}{1}   = 0;
    tsat_msg_waits{i}{2}   = 0;
    tsat_data_fcn_call{i}  = 0;
    tsat_timer_state{i}    = 0;
end

Msgs = {      {2,  @handle_ackMesg, bsize}, ...            % Set run Mode (send 0 to shutdown)
              {4,  @handle_NULL, bsize}, ...            % Set run Mode (send 0 to shutdown)
              {18, @handle_NULL, 4*dsize}, ...          % Set Fan speed data (double npts,vector wpts,vector forcepts)
              {19, @handle_NULL, bsize}, ...            % Set sensor log record mode
              {20, @handle_NULL, bsize}, ...            % Request raw sensor readings from vehicle
              {22, @handle_endDataMesg, bsize},  ...    % Receive end of sensor log transfer
              {23, @handle_NULL, dsize}, ...            % Request sensor log data
              {33, @handle_NULL, dsize}, ...            % Set data storage sample rate
              {63, @handle_RawData, 15*dsize}, ...      % Receive raw sensor readings from vehicle
              {64, @handle_RawData, 16*dsize}, ...      % Receive raw sensor readings from sensor log
              {65, @handle_RawData, dsize}, ...         % Receive sensor log size
              {104,  @handle_ackMesg, bsize}, ...       % Acknowledge run mode
              {118,  @handle_ackMesg, bsize}, ...       % Acknowledge fan speed
              {119,  @handle_ackMesg, bsize}, ...       % Acknowledge sensor log record mode
              {133,  @handle_ackMesg, bsize} ...        % Acknowledge set data storage rate
             
              };

for i=1:size(Msgs,2)
    tsat_register_msg(Msgs{i}{1},0,Msgs{i}{3},Msgs{i}{2});
end

reply=sprintf('Tablesat communications initialized on port %d\n',port);
disp(reply);

% Set up check message timer.
delete(timerfind);
tsat_timer = timer;
set(tsat_timer,'executionMode','fixedRate')
set(tsat_timer,'TimerFcn','tsat_check_msg')
set(tsat_timer,'Period',0.05)

tsat_polling_timer = timer;
set(tsat_polling_timer,'executionMode','fixedRate')
set(tsat_polling_timer,'TimerFcn','handle_SensorPoll')
set(tsat_polling_timer,'Period',2.0)

tsat_control_timer = timer;
set(tsat_control_timer,'executionMode','fixedRate')
set(tsat_control_timer,'TimerFcn','handle_ControlLoop')
set(tsat_control_timer,'Period',1/40)
