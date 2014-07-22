classdef eulerMomentEquations
%Class to propogate the Euler equations of motion.
%
%This class assumes a rigid body rotation where the
%applied torques, body rates, and principal moments
%of inertia are measured with respect to the rigid
%body's principal axes.

  properties
    w
    w_dot
    I
    lastUpdate
  end

  methods
    % Class construction method
    function self = eulerMomentEquations(args)
      if (nargin == 0); args = struct; end

      try
        self.I = args.I;
      catch
        error('Missing "I" argument in %s',mfilename())
      end

      % Check the moment of inertia tensor.
      if (size(self.I,1) ~= 3 | size(self.I,2) ~= 3)
        error('Passed "I" moment of inertia tensor is not a 3x3 matrix in %s',mfilename())
      end

      if (sum(sum(self.I.*eye(3) == self.I)) ~= 9)
        warning(sprintf(['Passed "I" moment of inertia tensor has cross product ' ...
          'values that will not be used in %s'],mfilename()))
      end

      self = self.reset(args);
    end

    function self = reset(self, args)
      if (nargin == 1); args = struct; end

      global t

      try
        self.w = args.w;
      catch
        self.w = bodyRate();
      end

      self.w_dot = bodyRateDot();
      self.lastUpdate = t.now();
    end

    % Propogate the state according to Euler's moment equations.
    % Assume no cross product terms.
    % If no arguments are passed, use global clock to determine
    % elapsed time, last propogated body rate, 0 moment torques.
    function self = propagate(self, args)
      if (nargin == 1); args = struct; end

      global t

      updateTime = t.now();
      try
        % Use the passed dt to propagate out a specific time step.
        dt = args.dt;
      catch
        % propagation step size was not passed, so use the last
        % time updated to estimate this time step.
        dt = updateTime - self.lastUpdate;
      end
      self.lastUpdate = updateTime;

      % Get the previous body rate either passed or the last value stored
      % on this instance.
      try
        br = args.w;
      catch
        br = self.w;
      end

      % Get the moment torques being applied here.
      try
        M = makeVec(args.M);
      catch
        M = [0 0 0]';
      end

      w_dot = bodyRateDot();
      w_dot.w(1) = M(1) / self.I(1,1) - (self.I(3,3) - ...
        self.I(2,2)) * br.w(2) * br.w(3) / self.I(1,1);
      w_dot.w(2) = M(2) / self.I(2,2) - (self.I(1,1) - ...
        self.I(3,3)) * br.w(1) * br.w(3) / self.I(2,2);
      w_dot.w(3) = M(3) / self.I(3,3) - (self.I(2,2) - ...
        self.I(1,1)) * br.w(1) * br.w(2) / self.I(3,3);

      % Update body rate rate on the class.
      self.w_dot = w_dot;

      % Update the body rate state
      w_delta = w_dot * dt;
      w_new = br + w_delta;
      self.w = w_new;
    end

  end
end
