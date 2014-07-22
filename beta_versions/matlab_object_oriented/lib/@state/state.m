classdef state
  properties
    q
    w
  end
  
  methods
    function self = state(args)
      if (nargin == 0); args = struct; end
      
      try
        self.q = args.q;
      catch
        self.q = quaternion();
      end
      try
        self.w = args.w;
      catch
        self.w = bodyRate();
      end
    end
    
    function self = stimes(self, b)
      if isa(b,'double')
        self.q = q * b;
        self.w = w * b;
      end
    end
    
    function sm = jacobian(self, args)
      if (nargin == 1); args = struct; end
      
      try
        I = args.I;
      catch
        error('Missing "I" argument in %s',mfilename())
      end
      
      sm = stateMatrix();
      
      q = quaternion();
      q.vector = self.w.w;
      
      sm.qq.vv = q.x();
      sm.qq.vs = q.vector;
      sm.qq.sv = -q.vector';
      
      sm.ww = zeros(3, 3);
      I_1 = (I(3, 3) - I(2, 2)) / I(1, 1);
      I_2 = (I(1, 1) - I(3, 3)) / I(2, 2);
      I_3 = (I(2, 2) - I(1, 1)) / I(3, 3);
      sm.ww(1, 2) = self.w.w(3) * I_1;
      sm.ww(1, 3) = self.w.w(2) * I_1;
      sm.ww(2, 1) = self.w.w(3) * I_2;
      sm.ww(2, 3) = self.w.w(1) * I_2;
      sm.ww(3, 1) = self.w.w(2) * I_3;
      sm.ww(3, 2) = self.w.w(1) * I_3;
    end
    
    function state_matrix = matrix(self)
      state_matrix = [self.q.vector; self.q.scalar; self.w.w];
    end
    
    function str = str(self)
      str = sprintf('q=%s\nw=%s',self.q.str,self.w.str);
    end
  end
end