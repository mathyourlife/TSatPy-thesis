classdef truthModel < handle
%TRUTHMODEL class
%
%Model interactions with the experimental TableSat.
%This will start as a plant that accepts moments
%and should be improved to "accept" and "send"
%messages.
  properties
  end
  
  methods
    % Class construction method
    function self = truthModel(args)
      if (nargin == 0); args = struct; end
      
    end
    
    % This method takes the current state of the 
    % calss' plant and generates associated voltages
    % for the sensors.
    % Note:  Assumptions on sensor readings are 
    % based on the physical restriction that TSat 
    % can not flip upside down.
    function V = generate_voltages(self, args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      V_clean = struct;
      
      % Create sun sensor voltages based on attitude
      V_clean.css = self.css_voltage(s);
      
      % Create accelerometer voltages base on body rates
      V_clean.accel = zeros(4,1);
      
      % Create gyro voltage based on body rates
      V_clean.gyro = 0;
      
      % Create TAM volates based on attitude
      V_clean.mag = self.css_mag(s);
      
      % Add measurement noise to the voltages
      V = self.add_noise(V_clean);
      %V = V_clean;
    end
    
    function V_css = css_voltage(self, s)
      % Create sun sensor voltages based on attitude
      args = struct;
      args.points = [1 0 0;
        cos(-pi/3) sin(-pi/3) 0;
        cos(-2*pi/3) sin(-2*pi/3) 0;
        -1 0 0;
        cos(-4*pi/3) sin(-4*pi/3) 0;
        cos(-5*pi/3) sin(-5*pi/3) 0];
      
      pts = s.q.rotate_points(args);
      mag = 5.5;
      
      V_css = max(zeros(size(pts,1),1),pts(:,1)) * mag;
    end
    
    function V_mag = css_mag(self, s)
      
      global calibration_data
      
      [q_n, q_r] = s.q.decompose();
      
      [vector, theta] = q_r.toRotation();
      
      if dot(vector, [0 0 -1])
        theta = -theta;
      end
      
      angle = floor(theta / pi * 180);
      
      if angle <= -360
        angle = angle + 720;
      elseif angle <= 0
        angle = angle + 360;
      end
      
      flat = calibration_data.volts.steady(angle,:);
      x_pos = calibration_data.volts.xpos(angle,:) - flat;
      y_pos = calibration_data.volts.ypos(angle,:) - flat;
      x_neg = calibration_data.volts.xneg(angle,:) - flat;
      y_neg = calibration_data.volts.yneg(angle,:) - flat;
      
      [vector, theta] = q_n.toRotation();
      
      pt = cross(vector, [0 0 1]);
      
      scale = theta / (pi / 36);
      
      V_mag = flat';
      
      check = dot([1 0 0], pt);
      if check > 0
        V_mag = V_mag + (x_pos * check * scale)';
      end
      check = dot([0 1 0], pt);
      if check > 0
        V_mag = V_mag + (y_pos * check * scale)';
      end
      check = dot([-1 0 0], pt);
      if check > 0
        V_mag = V_mag + (x_neg * check * scale)';
      end
      check = dot([0 -1 0], pt);
      if check > 0
        V_mag = V_mag + (y_neg * check * scale)';
      end
      
    end
    
    % Add the specified level of measurement noise
    % to the generated voltages.  Measurement noise
    % is assumed to be normally distributed.
    function V = add_noise(self,V)
      
      global tsat
      
      % Loop through the fields in the Voltage structure
      % provided.  For each use the noise_std value to 
      % add the appropriate level of measurement noise.
      fields = fieldnames(V);
      for i=1:numel(fields)
        f = fields{i};
        noise = randn(size(V.(f))) * tsat.sensors.(f).noise;
        V.(f) = V.(f) + noise;
        
        % Reset any voltages to the max/min if they are 
        % outside the allowable limits for that sensor
        V.(f)(V.(f) < tsat.sensors.(f).min) = tsat.sensors.(f).min;
        V.(f)(V.(f) > tsat.sensors.(f).max) = tsat.sensors.(f).max;
      end
    end
    
    % First pass at accepting an input.  This 
    % should be expanded to accept a voltage
    function accept_moment(self,args)
      if (nargin == 1); args = struct; end
      
      try
        p_args.struct;
        p_args.M = args.M;
      catch
        error('Missing "M" argument in %s',mfilename())
      end
      self.plant.propagate(p_args);
      
    end
    
    % Reset the truth model
    function reset(self,args)
      if (nargin == 1); args = struct; end
      
      self.plant = self.plant.reset();
    end
  end
end