classdef sensor
% SENSOR - Base class for all sensors on TSat
  properties
    volts
    state
    min = 0
    max = 6
    noise = 0
  end
  
  methods
    % This constructor function will be overloaded
    function self = sensor(args)
      
    end
  end
end