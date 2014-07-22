classdef mag < sensor
%MAG - Magnetometer class
%
%This class extends the general sensors class
%and applies functionality and methods 
%specific to the sensor's geometry and 
%interpreting its readings.
  properties
  end
  
  methods
    function self = mag(args)
      if (nargin == 0); args = struct; end
      
      self.noise = 0.006;
    end
    
    function self = update(self,args)
      try
        self.volts = makeVec(args.volts);
      catch
        error('Missing "volts" argument in %s',mfilename())
      end
      
      self.state = state();
    end
    
    function str = str(self)
      str = self.state.str();
    end
  end
end