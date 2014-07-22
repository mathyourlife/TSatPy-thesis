classdef integral
  % Discrete integral class
  % 
  properties
    sum      % Running sum of the integrated value
    dt      % Seconds between the updates
    lastUpdate  % Timestamp of the last update
  end
  
  methods
    % Class construction method
    function self = integral(args)
      if (nargin == 0); args = struct; end
      
      % Default initial value to zero if not passed.
      try
        self.sum = args.init;
      catch
        self.sum = 0;
      end
      
      % Access global clock and set the last updated time to now.
      global t
      self.lastUpdate = t.now();
    end
    
    % Update the integrator.
    % Add (value * dt) to the running sum.
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        value = args.value;
      catch
        error('Missing "value" argument in %s',mfilename())
      end
      
      % Access the global clock and determine the number of 
      % seconds since the last update.
      global t
      n = t.now();
      self.dt = n - self.lastUpdate;
      
      % Increment to the running sum and update the last time.
      self.sum = self.sum + (self.dt * value);
      self.lastUpdate = n;
    end
    
    % Reset the discrete integral.  Set the running sum to zero 
    % and set the last updated time to the current global clock.
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      global t
      self.sum = 0;
      self.lastUpdate = t.now();
    end
  end
end