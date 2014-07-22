classdef controllerPID
%CONTROLLER PID class
%
%PID control algorithm
%Controller assumes use of the state class
%containing a quaternion class to describe the 
%attitude and the body rate class to describe
%angular rates. Base integral and derivative
%classes are used to allow for variable time 
%step usage where time between updates effects
%the magnitude of the derivative and integral
%values.
  properties
    desired_state
    state
    state_error
    M
    Kp
    Ki
    Kd
    integral
    derivative
  end
  
  methods
    % Class construction method
    function self = controllerPID(args)
      if (nargin == 0); args = struct; end
      
      K = struct;
      K.Kq = 0;
      K.Kw = zeros(3);
      self.Kp = K;
      self.Ki = K;
      self.Kd = K;
      self = self.reset();
    end
    
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.desired_state = state();
      self.state = state();
      self.state_error = state();
      self.M = [0 0 0]';
      self.integral = integral();
      self.derivative = derivative();
      
      self = self.setGain(args);
    end
    
    function self = setGain(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.Kp.Kq = args.Kp.Kq;
      catch
      end
      
      try
        self.Kp.Kw = args.Kp.Kw;
      catch
      end
      
      try
        self.Ki.Kq = args.Ki.Kq;
      catch
      end
      
      try
        self.Ki.Kw = args.Ki.Kw;
      catch
      end
      
      try
        self.Kd.Kq = args.Kd.Kq;
      catch
      end
      
      try
        self.Kd.Kw = args.Kd.Kw;
      catch
      end
      
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.desired_state = args.desired_state;
      catch
      end
      
      try
        self.state = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      err_state = state();
      
      args = struct;
      args.q = self.desired_state.q;
      args.q_hat = self.state.q;
      err_state.q = quaternionError(args);
      
      % $\omega = 2 q^* \otimes \dot{q}$
      q_control_effort = self.state.q * self.desired_state.q.conj;
      q_w = 2 * quaternion() * q_control_effort;
      
      err_state.w = self.desired_state.w - self.state.w;
      val = [q_w.vector; err_state.w.w];
      
      args = struct; args.value = val;
      self.integral = self.integral.update(args);
      self.derivative = self.derivative.update(args);
      
      M = struct;
      M.Kp.Kq = self.Kp.Kq * val(1:3);
      M.Kp.Kw = self.Kp.Kw * val(4:6);
      
      M.Ki.Kq = self.Ki.Kq * self.integral.sum(1:3);
      M.Ki.Kw = self.Ki.Kw * self.integral.sum(4:6);
      
      M.Kd.Kq = self.Kd.Kq * self.derivative.rate(1:3);
      M.Kd.Kw = self.Kd.Kw * self.derivative.rate(4:6);
      
      M.total = M.Kp.Kq + M.Kp.Kw + M.Ki.Kq + M.Ki.Kw + M.Kd.Kq + M.Kd.Kw;
      
      self.state_error = err_state;
      self.M = M;
    end
  end
end