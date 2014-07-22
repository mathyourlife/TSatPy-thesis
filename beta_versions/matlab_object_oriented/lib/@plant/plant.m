classdef plant < handle
%PLANT - class simulates the dynamics of a rotating rigid body
%
%This class combines the code for attitude and
%body rate dynamics for full state modelling
%and propagation.

  properties
    state
    pos
    vel
  end
  
  methods
    % Class construction method
    function self = plant(args)
      if (nargin == 0); args = struct; end
      
      self.reset(args);
    end
    
    function reset(self, args)
      if (nargin == 1); args = struct; end
      
      self.pos = quaternionDynamics(args);
      self.vel = eulerMomentEquations(args);
      self.state = state(args);
    end
    
    function set_state(self, args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      self.state = s;
      self.vel.w = s.w;
      self.pos.q = s.q;
      
    end
    
    function propagate(self, args)
      if (nargin == 1); args = struct; end
      
      % Get the moment torques being applied here.
      try
        M = args.M;
      catch
        M = [0 0 0]';
      end
      
      prop_vel_args = struct;
      prop_vel_args.M = M;
      self.vel = self.vel.propagate(prop_vel_args);
      
      new_state_args = struct;
      new_state_args.w = self.vel.w;
      
      pos_args = struct;
      pos_args.w = self.vel.w;
      
      self.pos.propagate(pos_args);
      new_state_args.q = self.pos.q;
      new_state_args.w = pos_args.w;
      
      self.state = state(new_state_args);
    end
    
    function sm = jacobian(self)
      sm = stateMatrix();
      
      args = struct;
      args.s = self.state;
      args.I = self.vel.I;
      
      sm = sm.jacobian(args);
      
    end
  end
end