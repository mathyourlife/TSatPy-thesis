classdef bodyRateIntegral
  % bodyRate INTEGRAL class
  % 
  properties
    value
    w
  end
  
  methods
    % Class construction method
    function self = bodyRateIntegral(args)
      if (nargin == 0); args = struct; end
      
      self.w = integral();
      self = self.reset();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        br = args.value;
      catch
        error('Missing "value" argument in %s',mfilename())
      end
      
      args = struct; args.value = br.w;
      self.w = self.w.update(args);
      args = struct; args.w = self.w.sum;
      self.value = bodyRate(args);
    end
    
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.w = self.w.reset();
      args = struct; args.w = [0 0 0];
      self.value = bodyRate(args);
    end
  end
end