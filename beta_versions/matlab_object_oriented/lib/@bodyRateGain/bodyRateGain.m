classdef bodyRateGain
  % GAIN structure for use with a quaternion class
  % 
  properties
    K
  end
  
  methods
    % Class construction method
    function self = bodyRateGain(args)
      if (nargin == 0); args = struct; end
      
      try
        self.K = args.K;
      catch
        self.K = eye(3);
      end
      
    end
    
    % Calculate the product of the gain matrix and a bodyRate.
    function br = mtimes(self,w)
      
      w = self.K * w.w;
      
      args = struct;
      args.w = w;
      br = bodyRate(args);
    end
  end
end