function [size, header] = fakeheaders()

switch floor(rand()*20)
    case 0
        size = 6;
        header = [22 0 0 1];
    case 1
        size = 6;
        header = [63 0 0 120];
    case 2
        size = 6;
        header = [64 0 0 128];
    case 3
        size = 6;
        header = [104 0 0 1];
    case 4
        size = 6;
        header = [118 0 0 1];
    case 5
        size = 6;
        header = [119 0 0 1];
    case 6
        size = 6;
        header = [133 0 0 1];
    case 7
        size = 6;
        header = [64 0 0 128];
    case 8
        size = 6;
        header = [64 0 0 128];
    case 9
        size = 6;
        header = [64 0 0 128];
    case 10
        size = 6;
        header = [64 0 0 128];
    case 11
        size = 6;
        header = [64 0 0 128];
    otherwise
        size = 0;
        header = [0 0 0 0];
end

%              {22, @handle_endDataMesg, bsize},  ...    % Receive end of sensor log transfer
%              {63, @handle_RawData, 15*dsize}, ...      % Receive raw sensor readings from vehicle
%              {64, @handle_RawData, 16*dsize}, ...      % Receive raw sensor readings from sensor log
%              {104,  @handle_ackMesg, bsize}, ...       % Acknowledge run mode
%              {118,  @handle_ackMesg, bsize}, ...       % Acknowledge fan speed
%              {119,  @handle_ackMesg, bsize}, ...       % Acknowledge sensor log record mode
%              {133,  @handle_ackMesg, bsize} ...        % Acknowledge set data storage rate             
