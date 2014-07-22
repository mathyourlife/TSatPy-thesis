classdef ekf < handle
  properties
    Q_k
    R_k

    A_sm
    A
    B
    C
    D

    P
    K

    plant
    state_adj
    state
  end

  methods
    function self = ekf(args)
      if (nargin == 0); args = struct; end

      try
        self.Q_k = args.Q_k;
      catch
        error('Missing "Q_k" argument in %s',mfilename())
      end

      try
        self.R_k = args.R_k;
      catch
        error('Missing "R_k" argument in %s',mfilename())
      end

      try
        self.P = args.P;
      catch
        self.P = zeros(7);
      end

      try
        self.B = args.B;
      catch
        self.B = zeros(7);
      end
      try
        self.C = args.C;
      catch
        self.C = eye(7);
      end
      try
        self.D = args.D;
      catch
        self.D = zeros(7);
      end

      try
        I = args.I;
      catch
        error('Missing "I" argument in %s',mfilename())
      end
      plant_args = struct; plant_args.I = I;
      self.plant = plant(args);

      try
        self.state = args.state;
      catch
        args.state = state();
        self.state = args.state;
      end
      plant_args = struct; plant_args.state = self.state;
      self.plant.set_state(args);

      self.A_sm = stateMatrix();
    end

    function update(self,args)
      if (nargin == 1); args = struct; end

      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end

      try
        u = args.u;
      catch
        u = zeros(7, 1);
      end

      self.plant.propagate();

      % Adjust the plant quaternion to account for the quaternion
      % situation where <qv, qs> is the same as <-qv, -qs>
      % If the plant estimate and measured attitude have
      % opposite signs, use the quternion error to calculate
      % the corresponding quaternion with matching signs.
      q_err = s.q.conj * self.plant.state.q;
      if q_err.scalar < 0
        q_err = -q_err;
        self.plant.state.q = s.q * q_err;
      end


      args = struct; args.I = self.plant.vel.I; args.state = self.plant.state;
      self.A_sm.jacobian(args);


      y = s.matrix();
      state_est = self.plant.state.matrix();
      A = self.A_sm.matrix();
      self.P = A * self.P * A' + self.Q_k;    % covariance
      self.K = self.P * self.C' * inv(self.C * self.P * self.C' + self.R_k);

      err = y - (self.C * state_est + self.D * u);
      % Calulate the measurement based adjustement
      x_adj = self.K * err;
      % Combine the predicted state with the measurement adjustment
      state_est = state_est + x_adj;
      % Update the coviance matrix
      self.P = (eye(7) - self.K * self.C) * self.P;

      args = struct;
      args.state = matrixToState(state_est);
      args.state.q.normalize();
      self.plant.set_state(args);

      self.state_adj = matrixToState(x_adj);
      self.state = args.state;
    end

    function str = str(self)
      str = sprintf('%s',self.state.str);
    end
  end
end