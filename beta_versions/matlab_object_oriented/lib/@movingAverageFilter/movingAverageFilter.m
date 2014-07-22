classdef movingAverageFilter
  properties
    state
    hist
    avgLen
  end
  
  methods
    function self = movingAverageFilter(args)
      if (nargin == 0); args = struct; end
      
      try
        self.avgLen = args.avgLen;
      catch
        self.avgLen = 5;
      end
      
      args = struct; args.historylen = self.avgLen;
      self.hist = hist(args);
      self.state = state();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      args = struct;
      args.var = 'state';
      args.value = s;
      self.hist = self.hist.log(args);
      
      args = struct;
      if (size(self.hist.logs.state,1) == 1)
        args.vector = self.hist.logs.state(:,2:4);
        args.scalar = self.hist.logs.state(:,5);
      else
        args.vector = mean(self.hist.logs.state(:,2:4));
        args.scalar = mean(self.hist.logs.state(:,5));
      end
      q = quaternion(args);
      
      args = struct;
      if (size(self.hist.logs.state,1) == 1)
        args.w = self.hist.logs.state(:,6:8);
      else
        args.w = mean(self.hist.logs.state(:,6:8));
      end
      w = bodyRate(args);
      args = struct;
      args.q = q;
      args.w = w;
      self.state = state(args);
    end
    
    function str = str(self)
      str = 'Moving average filter instance';
    end
  end
end