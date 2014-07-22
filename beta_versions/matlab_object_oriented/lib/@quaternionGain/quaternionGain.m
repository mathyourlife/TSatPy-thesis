classdef quaternionGain
  % GAIN structure for use with a quaternion class
  % 
  properties
    Kv
    Ks
  end
  
  methods
    % Class construction method
    function self = quaternionGain(args)
      if (nargin == 0); args = struct; end
      
      try
        self.Kv = args.Kv;
      catch
        self.Kv = eye(3);
      end
      
      try
        self.Ks = args.Ks;
      catch
        self.Ks = 1;
      end
      
    end
    
  end
end