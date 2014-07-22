classdef quaternionDynamics < handle
% QUATERNION  DYNAMICS class
%
  properties
    q
    q_dot
    w = NaN
    lastUpdate
  end
  
  methods
    % Class construction method
    function self = quaternionDynamics(args)
      if (nargin == 0); args = struct; end
      
      global t
      
      try
        self.q = args.q;
      catch
        self.q = quaternion();
      end
      
      args = struct; args.vector = [0 0 0]'; args.scalar = 0;
      self.q_dot = quaternion(args);
      self.lastUpdate = t.now();
    end
    
    function propagate(self, args)
      if (nargin == 1); args = struct; end
      
      global t
      
      t_now = t.now();
      try
        % Use the passed dt to propagate out a specific time step.
        dt = args.dt;
      catch
        % propagation step size was not passed, so use the last
        % time updated to estimate this time step.
        dt = t_now - self.lastUpdate;
      end
      self.lastUpdate = t_now;
      
      if dt <= 0
        % Timestamp hasn't increased, so skip update
        return
      end
      
      try
        w = args.w;
      catch
        error('Missing "w" argument in %s',mfilename())
      end
      
      q_org = self.q.copy();
      
      if isnan(self.w)
        % If this is the first update, assume the body rate has
        % been consistent throughout the dt
        self.q = propagate_quaternion(self.q, w, w, dt);
      else
        % Propagate the quaternion state using a linear
        % approimation in the body rate between the
        % last and current values.
        self.q = propagate_quaternion(self.q, self.w, w, dt);
      end
      
      % Scale back to a per sec unit for continuity
      q_dot = self.q - q_org;
      q_dot.vector = q_dot.vector / dt;
      q_dot.scalar = q_dot.scalar / dt;
      self.q_dot = q_dot;
    end
    
  end
end