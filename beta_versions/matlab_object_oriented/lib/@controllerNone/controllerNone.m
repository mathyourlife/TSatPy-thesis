classdef controllerNone
  % None CONTROLLER class
  % 
  % Empty controller class for a disable controller
  properties
    state
    M
  end
  
  methods
    % Class construction method
    function self = controllerNone()
      self = self.reset();
    end
    
    function self = reset(self)
      self.M = [0 0 0]';
      self.state = state();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.state = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      % Empty update function
      self.M = [0 0 0]';
    end
  end
end