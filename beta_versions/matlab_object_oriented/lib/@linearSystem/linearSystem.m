classdef linearSystem
  properties
    A
    B
    C
    D
    x0
    x
    dx
    lastUpdate
    y
    history
    historylen
  end
  
  methods
    function self = linearSystem(args)
      if (nargin == 0); args = struct; end
      
      try
        self.A = args.A;
      catch
        self.A = [0 1; -0.4 -0.2];
      end
      try
        self.B = args.B;
      catch
        self.B = [0; 0.2];
      end
      try
        self.C = args.C;
      catch
        self.C = [1 0; 0 1];
      end
      try
        self.D = args.D;
      catch
        self.D = [0; 0];
      end
      
      % TODO Confirm array sizes
      
      try
        self.x0 = args.x0;
      catch
        self.x0 = [0; 0];
      end
      
      try
        self.x = args.x;
      catch
        self.x = self.x0;
      end
      
      % Initialize the last update time
      self.lastUpdate = now*24*60*60;
    end
    
    function self = init(self)
      self.lastUpdate = now*24*60*60;
      self.x = self.x0
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      % Validate the rows of u match the cols of b and d
      
      try
        u = args.u;
      catch
        u = zeros(size(self.B,2),1);
      end
      
      % Use the system time unless passed a time argument (for simulation)
      try
        dt = args.t - self.lastUpdate;
        self.lastUpdate = args.t;
      catch
        curtime = t.now()
        dt = curtime - self.lastUpdate;
        self.lastUpdate = curtime;
      end
      
      self.dx = self.A * self.x + self.B * u;
      self.x = self.x + self.dx * dt;
      
      self.y = self.C * self.x + self.D * u;
      
      self = self.updateHistory();
    end
    
    function self = updateHistory(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.historylen = args.historylen;
      catch
        self.historylen = 500;
      end
      
      % Update the history
      try
        self.history.y;
      catch
        self.history.y = [];
      end
      if (size(self.history.y,1) >= self.historylen)
        startRow = size(self.history.y,1) - self.historylen + 2;
      else
        startRow = 1;
      end
      self.history.y = [self.history.y(startRow:end,:); now*24*3600 self.y'];
    end
  end
end