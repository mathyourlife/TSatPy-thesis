classdef sensorPlot < tPlot
  properties
    
  end
  
  methods
    function self = sensorPlot(args)
      if (nargin == 0); args = struct; end
      
      self = self.newPlot(args);
    end
    
  end
end
    