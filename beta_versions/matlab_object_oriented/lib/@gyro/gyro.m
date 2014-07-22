classdef gyro < sensor
% GYRO - Gyroscope class
%
% This class extends the general sensors class
% and applies functionality and methods 
% specific to the sensor's geometry and 
% interpreting its readings.
  properties
  end
  
  methods
    function self = gyro(args)
      if (nargin == 0); args = struct; end
      
      %self.calibration.base = 0;
      %self.calibration.rate = 1;
    end
    
    function self = update(self,args)
      try
        self.volts = makeVec(args.volts);
      catch
        error('Missing "volts" argument in %s',mfilename())
      end
      
      self.state = state();
    end
    
    function self = set_calibration(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.calibration.base = args.base;
      catch
      end
      
      try
        self.calibration.rate = args.rate;
      catch
      end
      
    end
    
    function str = str(self)
      str = self.state.str();
    end
  end
end