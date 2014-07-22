classdef sensors < handle
  properties
    
    css
    mag
    gyro
    accel
    state
    
    lastUpdate
  end
  
  methods
    function self = sensors(args)
      if (nargin == 0); args = struct; end
      
      self.css = css();
      self.mag = mag();
      self.gyro = gyro();
      self.accel = accel();
      self.state = state();
      
      self.lastUpdate = NaN;
    end
    
    function self = update(self, args)
      if (nargin == 1); args = struct; end
      
      global t
      t_now = t.now();
      
      try
        v = makeVec(args.volts);
      catch
        error('Missing "volts" argument in %s',mfilename())
      end
      
      if (isstruct(v))
        css_v = v.css;
        accel_v = v.accel;
        gyro_v = v.gyro;
        mag_v = v.mag;
      else
        if (numel(v) == 14)
          % Sensor data only
          css_v = v(1:6);
          accel_v = v(7:10);
          gyro_v = v(11);
          mag_v = v(12:14);
        elseif (numel(v) == 15)
          % timestamp + Sensor data
          time = v(1);
          css_v = v(2:7);
          accel_v = v(8:11);
          gyro_v = v(12);
          mag_v = v(13:15);
        elseif (numel(v) == 16)
          % logentry + timestamp + Sensor data
          line = v(1);
          time = v(2);
          css_v = v(3:8);
          accel_v = v(9:12);
          gyro_v = v(13);
          mag_v = v(14:16);
        else
          return;
        end
      end
      
      if (~isnan(css_v))
        args = struct; args.volts = css_v;
        self.css = self.css.update(args);
      end
      
      if (~isnan(accel_v))
        args = struct; args.volts = accel_v;
        self.accel = self.accel.update(args);
      end
      
      if (~isnan(gyro_v))
        args = struct; args.volts = gyro_v;
        self.gyro = self.gyro.update(args);
      end
      
      if (~isnan(mag_v))
        args = struct; args.volts = mag_v;
        self.mag = self.mag.update(args);
      end
      
      % If there is no magnetometer data provided,
      % just use the css sensor state quaternion.
      if (isnan(mag_v))
        q = self.css.state.q;
      else
        q = self.update_quaternion();
      end
      w = self.update_body_rate(q, t_now);
      
      % Set last time he update was called
      self.lastUpdate = t_now;
      
      % Update the state
      self.state.q = q;
      self.state.w = w;
    end
    
    function w = update_body_rate(self, q, t_now)
      % Update the body rates using the previous state
      if isnan(self.lastUpdate)
        % First time an update call start with no body rates
        w = bodyRate();
      else
        % Find the change since last update
        dt = t_now - self.lastUpdate;
        if dt == 0
          % If time hasn't elapsed since last update, keep
          % the body rate from last time.
          w = self.state.w;
        else
          w = calculate_body_rate(self.state.q, q, dt);
          args = struct; args.w = w;
          w = bodyRate(args);
        end
      end
    end
    
    % Generate a composite state now that the
    % sensors have been updated.
    function q = update_quaternion(self)
      
      global calibration_data
      
      css_theta = self.css.theta;
      css_deg = round(css_theta * 180 / pi);
      if (css_deg == 0); css_deg = 360; end
      
      % Based on the css z-angle, pull the mag calibration data.
      flat = calibration_data.volts.steady(css_deg,:)';
      volt_offset = self.mag.volts - flat;
      
      xp = calibration_data.volts.xpos(css_deg,:)' - flat;
      yp = calibration_data.volts.ypos(css_deg,:)' - flat;
      xn = calibration_data.volts.xneg(css_deg,:)' - flat;
      yn = calibration_data.volts.yneg(css_deg,:)' - flat;
      
      %disp('====================================================');
      %disp(sprintf('v:    %+0.5f %+0.5f %+0.5f',self.mag.volts));
      %disp(sprintf('flat: %+0.5f %+0.5f %+0.5f',flat));
      %disp(sprintf('off:  %+0.5f %+0.5f %+0.5f',volt_offset));
      %disp(sprintf('xp:   %+0.5f %+0.5f %+0.5f',xp));
      %disp(sprintf('yp:   %+0.5f %+0.5f %+0.5f',yp));
      %disp(sprintf('xn:   %+0.5f %+0.5f %+0.5f',xn));
      %disp(sprintf('yn:   %+0.5f %+0.5f %+0.5f',yn));
      
      xpd = dot(volt_offset, xp);
      ypd = dot(volt_offset, yp);
      xnd = dot(volt_offset, xn);
      ynd = dot(volt_offset, yn);
      
      arr = sort([xpd ypd xnd ynd]);
      
      if (xpd == arr(4))
        first_vec = [xpd 0 0];
      elseif (ypd == arr(4))
        first_vec = [0 ypd 0];
      elseif (xnd == arr(4))
        first_vec = [-xnd 0 0];
      elseif (ynd == arr(4))
        first_vec = [0 -ynd 0];
      end
      
      if (xpd == arr(3))
        second_vec = [xpd 0 0];
      elseif (ypd == arr(3))
        second_vec = [0 ypd 0];
      elseif (xnd == arr(3))
        second_vec = [-xnd 0 0];
      elseif (ynd == arr(3))
        second_vec = [0 -ynd 0];
      end
      
      % Predicting the weight hangs down at vector
      vec = first_vec + second_vec;
      
      % Means that the nutation axis is along
      nutation_axis = cross(vec,[0 0 -1]);
      
      scale = norm(volt_offset) / norm(vec);
      
      args.vector = nutation_axis;
      args.theta = 0.001 * scale;
      if args.theta > 15/180*pi
        args.theta = 15/180*pi;
      end
      q_n = quaternion(args);
      
      q = q_n * self.css.state.q;
    end
    
    function str = str(self)
      str = self.state.str();
    end
  end
end