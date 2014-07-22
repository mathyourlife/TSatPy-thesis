classdef time
  % TIME class
  % 
  properties
    speed
    starttime
  end
  
  methods
    % Class construction method
    function self = time(args)
      if (nargin == 0); args = struct; end
      
      try
        self.speed = args.speed;
      catch
        self.speed = 1;
      end
      
      self.starttime = self.now();
    end
    
    function t_1 = now(self)
      if (self.speed == 1)
        % Return the normal time for a speed of 1
        t_1 = datenummx(clock) * 86400; % 24*60*60
      else
        % Return the adjusted time for a speed <> 1
        n = datenummx(clock) * 86400; % 24*60*60
        t_1 = self.starttime + self.speed * (n - self.starttime);
      end
    end
    
    function t_1 = elapsed(self,args)
      if (nargin == 1); args = struct; end
      
      t_1 = self.now() - self.starttime;
    end
    
    function self = restart(self,args)
      if (nargin == 1); args = struct; end
      
      self.starttime = datenummx(clock) * 86400; % 24*60*60
    end
    
  end
end