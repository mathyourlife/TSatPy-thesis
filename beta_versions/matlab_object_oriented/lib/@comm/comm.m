classdef comm
  properties
    msgs
    headers
    msgSize
    socket
    msgData
  end

  methods
    function self = comm(args)
      if (nargin == 0); args = struct; end
      self.msgSize.bsize = 1;    % Size of a bit messages
      self.msgSize.dsize = 8;    % Size of a double messages
      self.msgSize.vsize = 32767;  % Size of a large varible messages

      self = self.init_messages();
    end

    function self = init_conn(self,args)
      if (nargin == 1); args = struct; end

    end

    function self = init_messages(self,args)
      if (nargin == 1); args = struct; end

      self.msgs{  2} = {self.msgSize.bsize, 'ReadAckMesg', 'Set run mode'};     % 0 to shutdown
      self.msgs{  4} = {self.msgSize.bsize, 'NULL', 'Set run mode'};            % 0 to shutdown
      self.msgs{ 18} = {4*self.msgSize.dsize, 'NULL', 'Set fan speed'};          % 4 doubles
      self.msgs{ 19} = {self.msgSize.bsize, 'NULL', 'Set log record mode'};
      self.msgs{ 20} = {self.msgSize.bsize, 'NULL', 'Request sensor reading'};
      self.msgs{ 22} = {self.msgSize.bsize, 'endDataMesg', 'End of sensor log'};
      self.msgs{ 23} = {self.msgSize.dsize, 'NULL', 'Request sensor log data'};
      self.msgs{ 33} = {self.msgSize.dsize, 'NULL', 'Set log sample rate'};
      self.msgs{ 63} = {15*self.msgSize.dsize, 'ReadRawData', 'Sensor readings'};
      self.msgs{ 64} = {16*self.msgSize.dsize, 'ReadRawData', 'Sensor log entry'};
      self.msgs{ 65} = {self.msgSize.dsize, 'ReadRawData', 'Sensor log size'};
      self.msgs{104} = {self.msgSize.bsize, 'ReadAckMesg', 'Ack run mode'};
      self.msgs{118} = {self.msgSize.bsize, 'ReadAckMesg', 'Ack fan volt'};
      self.msgs{119} = {self.msgSize.bsize, 'ReadAckMesg', 'Ack sensor log run mode'};
      self.msgs{133} = {self.msgSize.bsize, 'ReadAckMesg', 'ACK log sample rate'};

      for i=1:size(self.msgs,2)
        if (isempty(self.msgs{i}))
          continue;
        end
        args = struct; args.msgNum = i;
        self.headers{i} = self.makeHeader(args);
      end
    end

    function header = makeHeader(self,args)
      if (nargin == 1); args = struct; end

      try
        msgNum = args.msgNum;
      catch
        error('Missing "msgNum" argument in %s',mfilename())
      end

      msgData = self.msgs{msgNum};
      msgSize = msgData{1};

      header = [uint8(msgNum),...
        uint8(0),uint8(floor(msgSize/256)),...
        uint8(mod(msgSize,256)),uint8(0)];
    end

    function self = send_msg(self,args)
      if (nargin == 1); args = struct; end

      try
        msg = self.msgs.msg;
      catch
        error('Missing "msg" argument in %s',mfilename())
      end
      try
        data = args.msgs.data;
      catch
        error('Missing "data" argument in %s',mfilename())
      end

      header = self.headers(msg);

      if (length(header)==5)
        try
          pnet(self.socket,'write',header,'intel');
        catch
          disp('ERROR: Lost connection to TSat')
        end

        if (isstruct(data))  % flatten structures into cell array
          data=struct2cell(data);
        end
        for i=1:length(data)  % loop through cells
          if (length(data{i})>0)
            if (size(data{i},1)>1)
              try
                pnet(self.socket,'write',data{i}','intel');
              catch
                disp('ERROR: Lost connection to TSat')
              end
            else
              try
                pnet(self.socket,'write',data{i},'intel');
              catch
                disp('ERROR: Lost connection to TSat')
              end
            end
          end
        end
        try
          pnet(self.socket,'writepacket');
        catch
          disp('ERROR: Lost connection to TSat')
        end
      else
        display(sprintf('Incorrect sized header'));
      end

    end

    function self = check_msg(self,args)
      if (nargin == 1); args = struct; end

      msgNum=0;
      msgData=0;

      display('===============================')
      display('Checking for messages')
      display('===============================')

      % The program is communicating with TSat.
      try
        msgSize=pnet(self.socket,'readpacket',65500,'noblock');
      catch
        disp('Error: Communicating with TSat.')
        msgSize=0;
      end

      if msgSize<=0
        %No data exists in the buffer.  Exit the function.
        return;
      else
        %Data exists in the buffer.

        % Get the header and message number
        if tsat.socket ~= -1
          data_header=pnet(tsat.socket,'read',5,'uint8','intel');
        end
        msgNum = header(1);

        % Update the timestamp that the message was recieved.
%        tsat.msg.recieved{msgNum} = t.now();

        % Display the returned message if need extra returned detail.
%        if (tsat.debug)
%          reply = sprintf('Received message %d at time %d',msgNum,tsat.msg.recieved{msgNum});
%          disp(reply)
%        end

        % Check if the data returned is the expected size for the message.
        msg_header = self.headers{msgNum};
        if (data_header(3)~=msg_header(3) | data_header(4)~=msg_header(4))
          reply=sprintf('Message %d received but with incorrect payload size',char(msgNum));
          disp(reply);
          return;
        end

        % Get message flags and invoke handler
        flags = data_header(2);

        % Handle the returned data.
        if (self.socket~=-1)
          switch msg_header.val
            case 'ReadAckMesg'
              theMesg=pnet(tsat.socket,'read',1,'char','intel');
              msgData = ceil(theMesg);
            case 'ReadRawData'
              msgData=pnet(tsat.socket,'read',20,'double','intel');
            case 'endDataMesg'
              msgData=pnet(tsat.socket,'read',15,'double','intel');
            case 'NULL'
              msgData=1;
            otherwise
              reply = sprintf('I do not know how to handle message #%d.',msgNum);
              disp(reply)
              return;
          end
        else
          reply = sprintf('CRITICAL ERROR: Lost socket connection');
          disp(reply)
          return;
        end

        disp('==========Data Returned===========')
        msgData
        self.msgData{msgNum} = msgData;

        % Launch any function triggers attached to this returned message
        launchFunctionTriggers(tsat.triggers,'msgreturn',msgNum);

        % Send message data to the appropriate location.
        %handle_msgData(msgNum,msgData)

        % Append data to buffer text log
        msg = sprintf('%5d %10.2f',msgNum,msgData);
        args = struct;
        args.log = 'buffer';
        args.msg = msg;
        self.logMessage(args);
      end
    end

    function logMessage(self,args)
      if (nargin == 1); args = struct; end

      try
        logName = args.log;
      catch
        logName = 'tsat';
      end

      try
        msg = args.msg;
      catch
        return;
      end

      if (isnumeric(msg))
        msg = num2str(msg);
      end

      fid = fopen([logName '.log'],'a');
      fprintf(fid,'%5s ', datestr(t.now()));
      fprintf(fid,'%s', msg);
      fprintf(fid,'\n');
      fclose(fid);
    end
  end
end