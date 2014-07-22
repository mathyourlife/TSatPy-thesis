classdef quaternionDerivative
  % QUATERNION DERIVATIVE class
  % 
  properties
    value
    vector
    scalar
  end
  
  methods
    % Class construction method
    function self = quaternionDerivative(args)
      if (nargin == 0); args = struct; end
      
      self.vector = derivative();
      self.scalar = derivative();
      self = self.reset();
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        q = args.value;
      catch
        error('Missing "value" argument in %s',mfilename())
      end
      
      args = struct; args.value = q.vector;
      self.vector = self.vector.update(args);
      args = struct; args.value = q.scalar;
      self.scalar = self.scalar.update(args);
      
      args = struct;
      args.vector = self.vector.rate;
      args.scalar = self.scalar.rate;
      self.value = quaternion(args);
    end
    
    function self = reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.vector = self.vector.reset();
      self.scalar = self.scalar.reset();
      args = struct;
      args.vector = [0 0 0];
      args.scalar = 0;
      self.value = quaternion(args);
    end
  end
end