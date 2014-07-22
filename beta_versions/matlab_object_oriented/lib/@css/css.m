classdef css < sensor
% CSS - Course Sun Sensor class
%
% This class extends the general sensors class
% and applies functionality and methods 
% specific to the sensor's geometry and 
% interpreting its readings.
  properties
    theta = 0
  end
  
  methods
    function self = css(args)
      if (nargin == 0); args = struct; end
      
      self.noise = 0.1;
    end
    
    function self = update(self,args)
      try
        self.volts = makeVec(args.volts);
      catch
        error('Missing "volts" argument in %s',mfilename())
      end
      
      self = self.calcTheta();
      self = self.updateState();
      
    end
    
    %THETA uses the input sensors to find the direction to the 
    %largest source of light.
    %   Inputs:  vector of 6 css voltages.  voltage(1) is assumed to be zero
    %   degrees.  An offset may be added to this code if a different zero is
    %   needed.
    %   
    %   Outputs:  Using a resultant force style analysis.  The resultant
    %   magnitude showing the strength of the signal and the resultant angle
    %   theta are returned.
    %
    function self = calcTheta(self)
      css_x=0;
      css_y=0;
      for n = 1:size(self.volts,1)
        css_x = css_x + cos((n-1)*pi()/3)*self.volts(n);
        css_y = css_y + sin((n-1)*pi()/3)*self.volts(n);
      end
      css_mag = (css_x^2+css_y^2)^0.5;
      css_theta = atan(css_y/css_x);
      if css_x < 0
        css_theta = css_theta+pi();
      end
      if css_theta < 0
        css_theta = css_theta + 2*pi();
      end
      self.theta = css_theta;
      if getConfig('debug')
        display(sprintf('CSS calculated theta to be %0.1f deg',rad2deg(css_theta)))
      end
      
    end
    
    function self = updateState(self)
      args = struct;
      args.vector = [0 0 1]';
      args.theta = self.theta;
      q = quaternion(args);
      
      args = struct; args.q = q;
      self.state = state(args);
    end
    
    function str = str(self)
      str = self.state.str();
    end
  end
end