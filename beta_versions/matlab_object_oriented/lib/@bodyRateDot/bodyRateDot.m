classdef bodyRateDot < bodyRate
  properties
    w
  end
  
  methods
    function self = bodyRateDot(args)
      if (nargin == 0); args = struct; end
      
      try
        self.w = makeVec(args.w);
      catch
        self.w = [0 0 0]';
      end
    end
    
    function str = str(self)
      str = sprintf('<%+0.5f %+0.5f %+0.5f>',self.w(1),self.w(2),self.w(3));
    end
  end
end