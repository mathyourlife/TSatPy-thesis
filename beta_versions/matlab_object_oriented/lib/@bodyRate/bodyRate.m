classdef bodyRate
  properties
    w
  end
  
  methods
    function self = bodyRate(args)
      if (nargin == 0); args = struct; end
      
      try
        self.w = makeVec(args.w);
      catch
        self.w = [0 0 0]';
      end
    end
    
    function wx = wx(self)
      wx = [   0   -self.w(3)  self.w(2); ...
         self.w(3)   0    -self.w(1); ...
        -self.w(2)  self.w(1)    0];
    end
    
    % Determine if the two body rate are equivalent
    % Equivalent body rates have equivalent vector
    function b = eq(w1, w2)
      b = (sum(w1.w == w2.w) == 3);
    end
    
    function str = str(self)
      str = sprintf('<%+0.5f %+0.5f %+0.5f>',self.w(1),self.w(2),self.w(3));
    end
  end
end