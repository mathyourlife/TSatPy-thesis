classdef rigidRotation
  properties
    x
    I
    xDot
    lastUpdate
  end
  
  methods
    function self = rigidRotation(args)
      if (nargin == 0); args = struct; end
      
      try
        self.I = args.I;
      catch
        self.I = eye(3);
      end
      
      try
        self.x = args.x;
      catch
        self.x = state();
      end
      
      self.xDot = state;
    end
    
    function self = update(self)
      %disp(sprintf('Running rigidRotation update'));
      wx = self.x.w.w(1);
      wy = self.x.w.w(2);
      wz = self.x.w.w(3);
      wmatrix = [  0  wz -wy wx;
             -wz   0  wx wy;
            wy -wx   0 wz];
      q_dot = quaternion;
      q_dot.vector = wmatrix * [self.x.q.vector; self.x.q.scalar];
      %q_dot.vector
      q_dot.scalar = -0.5 * sum([wx wy wz]' .* self.x.q.vector);
      %q_dot.scalar
      %q_dot.str
      w_dot = bodyRate;
      w = [(self.I(2,2) - self.I(3,3))/self.I(1,1)*wy*wz;
         (self.I(3,3) - self.I(1,1))/self.I(2,2)*wx*wz;
         (self.I(1,1) - self.I(2,2))/self.I(3,3)*wx*wy];
      w_dot.w = w;
      
      args = struct;
      args.q = q_dot;
      args.w = w_dot;
      self.xDot = state(args);
      
    end

    function str = str(self)
      str = sprintf('q=%s\nw=%s',self.x.q.str,self.x.w.str);
    end
  end
end