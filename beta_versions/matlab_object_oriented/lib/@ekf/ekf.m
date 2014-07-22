classdef ekf < handle
  properties
    Q_k
    R_k
    
    A
    B
    C
    D
    
    P
    K
    
    x_adj
    x_hat
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
      
      if (~all(size(self.R_k) == size(self.Q_k)))
        error('Size of "R_k" and "Q_k" arguments do not agree in %s',mfilename())
      end
      
      try
        self.P = args.P;
      catch
        self.P = zeros(size(self.R_k));
      end
      
      try
        self.A = args.A;
      catch
        self.A = eye(size(self.R_k));
      end
      try
        self.B = args.B;
      catch
        self.B = ones(size(self.R_k));
      end
      try
        self.C = args.C;
      catch
        self.C = eye(size(self.R_k));
      end
      try
        self.D = args.D;
      catch
        self.D = zeros(size(self.R_k));
      end
      
      try
        self.x_hat = args.x0;
      catch
        self.x_hat = zeros(size(self.R_k, 1), 1);
      end
    end
    
    function update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        x = args.x;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      try
        u = args.u;
      catch
        u = zeros(size(self.R_k, 1), 1);
      end
      
      A = self.A;
      x_hat = A * self.x_hat + self.B * u;
      
      self.P = A * self.P * A' + self.Q_k;    % covariance
      self.K = self.P * self.C' * inv(self.C * self.P * self.C' + self.R_k);
      
      err = x - (self.C * x_hat + self.D * u);
      x_adj = self.K * err;   % Calulate the measurement based adjustement
      self.x_hat = x_hat + x_adj;  % Combine the predicted state with the measurement adjustment
      
      % Update the coviance matrix
      self.P = (eye(size(self.R_k)) - self.K * self.C) * self.P;
    end
    
    function str = str(self)
      str = sprintf('%s', num2str(self.x_hat'));
    end
  end
end