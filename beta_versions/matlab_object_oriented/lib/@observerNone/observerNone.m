classdef observerNone
  % None OBSERVER correction class
  % 
  % Empty observer class for a disable observer
  properties
    state
  end
  
  methods
    % Class construction method
    function self = observerNone(args)
      if (nargin == 0); args = struct; end
      
      self = self.reset();
    end
    
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.state = state();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.state = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
    end
    
  end
end