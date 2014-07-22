classdef derivative
  % DERIVATIVE class
  % 
  properties
    rate
    lastValue
    dt
    lastUpdate
  end
  
  methods
    % Class construction method
    function self = derivative(args)
      if (nargin == 0); args = struct; end
      
      self.lastValue = 0;
      
      try
        self.rate = makeVec(args.init);
      catch
        self.rate = 0;
      end
      
      global t
      self.lastUpdate = t.now();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        value = args.value;
      catch
        error('Missing "value" argument in %s',mfilename())
      end
      
      global t
      
      n = t.now();
      self.dt = n - self.lastUpdate;
      
      self.rate = ( value - self.lastValue ) / self.dt;
      self.lastValue = value;
      self.lastUpdate = n;
    end
    
    function self = reset(self)
      global t
      
      self.rate = 0;
      self.lastValue = 0;
      self.lastUpdate = t.now();
    end
  end
end