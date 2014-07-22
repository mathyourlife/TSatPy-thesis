classdef observerLuenberger
  % LUENBERGER OBSERVER correction class
  % 
  properties
    Kq
    Kw
    state
  end
  
  methods
    % Class construction method
    function self = observerLuenberger(args)
      if (nargin == 0); args = struct; end
      
      self = self.reset();
    end
    
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.Kq = quaternionGain();
      self.Kw = bodyRateGain();
      self.state = state();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      try
        p_s = args.plant_state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      args = struct; args.q = s.q; args.q_hat = self.state.q;
      q_e = quaternionError(args);
      
      q_adj = self.Kq * q_e;
      q_adj.normalize();
      
      q = p_s.q * q_adj.conj;
      
      w_e = s.w - self.state.w;
      w_adj = self.Kw * w_e;
      
      w = p_s.w + self.state.w + w_adj;
      
      args = struct; args.q = q; args.w = w;
      s = state(args);
      
      self.state = s;
    end
    
  end
end