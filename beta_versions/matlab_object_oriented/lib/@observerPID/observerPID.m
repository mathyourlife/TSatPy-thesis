classdef observerPID
  % PID OBSERVER correction class
  % 
  properties
    Kp
    Ki
    Kd
    I
    D
    state
    q_adj_p
    q_adj_i
    q_adj_d
  end
  
  methods
    % Class construction method
    function self = observerPID(args)
      if (nargin == 0); args = struct; end
      
      self = self.reset();
    end
    
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.Kp.Kq = quaternionGain();
      self.Ki.Kq = quaternionGain();
      self.Kd.Kq = quaternionGain();
      self.I = quaternionIntegral();
      self.D = quaternionDerivative();
      self.state = state();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      % Proportional adjustment
      self.q_adj_p = self.Kp.Kq * s.q;
      
      % Integral adjustment
      args = struct; args.value = s.q;
      self.I = self.I.update(args);
      args = struct;
      args.vector = self.I.vector.sum;
      args.scalar = self.I.scalar.sum;
      q_i = quaternion(args);
      self.q_adj_i = self.Ki.Kq * q_i;  
      
      % Derivative adjustment
      args = struct; args.value = s.q;
      self.D = self.D.update(args);
      args = struct;
      args.vector = self.D.vector.rate;
      args.scalar = self.D.scalar.rate;
      q_d = quaternion(args);
      self.q_adj_d = self.Kd.Kq * q_d;
      
      q_adj = self.q_adj_p + self.q_adj_i + self.q_adj_d;
      q_adj.normalize();
      args = struct; args.q = q_adj;
      s = state(args);
      
      self.state = s;
    end
  end
end