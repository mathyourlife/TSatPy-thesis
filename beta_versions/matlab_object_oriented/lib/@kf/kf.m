classdef kf
  properties
    A
    B
    C
    D
    Q_k
    R_k
    K
    P = NaN
    state
    last_update = NaN
  end

  methods
    function self = kf(args)
      if (nargin == 0); args = struct; end

      try
        self.A = args.A;
      catch
        error('Missing "A" argument in %s',mfilename())
      end
      try
        self.B = args.B;
      catch
        error('Missing "B" argument in %s',mfilename())
      end
      try
        self.C = args.C;
      catch
        error('Missing "C" argument in %s',mfilename())
      end
      try
        self.D = args.D;
      catch
        error('Missing "D" argument in %s',mfilename())
      end
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
        self.state = args.state;
      catch
        self.state = state();
      end
    end

    function self = update(self, args)

      global t

      persistent update_args

      if ~isstruct(update_args)
        disp('Creating update_args structure');
        update_args = struct;
      end

      try
        y = args.y;
      catch
        error('Missing "y" argument in %s',mfilename())
      end
      try
        u = args.u;
      catch
        error('Missing "u" argument in %s',mfilename())
      end
      x_est = self.state;
      P = self.P;

      t_now = t.now();

      % The kalman filter has not been called for an update yet
      % Set the last_update time as now so we get an acurate dt
      % measurement when the next update comes in.
      if isnan(self.last_update)
        self.last_update = t_now;
        return;
      end

      % Calculate the actual dt between now and the last kf update
      update_args.dt = t_now - self.last_update;

      self.last_update = t_now;

      A = self.A(update_args);
      B = self.B(update_args);
      C = self.C(update_args);
      D = self.D(update_args);

      if isnan(P)
        P = self.Q_k(update_args);
      end

      % (a priori) Predict the next state and covariance values
      x_est = A * x_est + B * u;  % state
      P = A * P * A' + self.Q_k(update_args);    % covariance

      % Compute Kalman Gain
      K = P * C' * inv(C * P * C' + self.R_k);

      % (a posteriori) Update predictions
      % Calulate the measurement based adjustement
      x_adj = K * (y - (C * x_est + D * u));
      % Combine the predicted state with the measurement adjustment
      x_est = x_est + x_adj;
      % Update the coviance matrix
      P = (eye(2) - K * C) * P;

      self.P = P;
      self.K = K;
      self.state = x_est;
    end
  end
end