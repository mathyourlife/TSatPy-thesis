classdef logProcessing
%LOGPROCESSING - Utility class for interacting with logs
%
%This class contains some common utilities for reading
%and analyzing buffer log files generated from the
%pnet communications.
  properties
  end

  methods
    function self = logProcessing(args)
      if (nargin == 0); args = struct; end

    end

    % Determine Sample Rate characteristics from the timestamp vector
    function [Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(timestamp)
      delta = zeros(size(timestamp,1)-1,1);
      for a = 2:size(timestamp,1)
        delta(a-1) = timestamp(a) - timestamp(a-1);
      end

      Hz_mean = 1/mean(delta);
      delta_mean = mean(delta);
      delta_stdev = std(delta);
    end

    %AUTO_CORRELATION - Display auto correlation for each sensor data
    %
    %Input:
    %  @log_name
    %    value - path from the current directory to the log file
    %    type  - char
    function auto_correlation(self, log_name)

      plot_title = sprintf('Autocorrelation of log %s',log_name);

      [data, result] = self.read_log(log_name);
      figure(1)

      f = {'css', 'accel', 'gyro', 'mag'};
      location = 1;
      for i=1:numel(f)
        for col = 1:size(data.(f(i)), 2)
          subplot(4, 4, location)
          [tau, R] = auto_correlation(data.(f{1})(:,col),false);
          plot(tau, R);
          hold on; grid on;
          index = find(abs(R) == max(abs(R)));
          title(sprintf('%s (Max %0.2f)', SensorName(i-2), R(index)));
          location = location + 1;
        end
      end
      hold off;

      suptitle(plot_title)
    end

    % READ_LOG - Read the contents of a log file into a variable
    %
    % Input:
    % @log_name
    %   value - Name of the file to read
    %   type  - char
    % @log_dir (optional)
    %   value   - Name of the directory to retrieve the file from
    %   default - ./logs
    %   type    - char
    %
    % Return:
    % @data
    %   value - matrix of values read from the file
    %   type  - matrix double
    % @result
    %   value - Information about the data read in from the file
    %   type  - struct
    %   @.min:
    %   value - minimum number of columns found in a line.
    %   type  - int
    %   @.max:
    %   value - number of columns in 'data', before removing empty columns.
    %   type  - int
    %   @.rows:
    %   value - number of rows in 'data', before removing empty rows.
    %   type  - int
    %   @.numberMask:
    %   value - true, if numeric conversion ('NaN' converted to NaN counts).
    %   type  - matrix logical
    %   @.number:
    %   value - number of numeric conversions ('NaN' converted to NaN counts).
    %   type  - int
    %   @.emptyMask:
    %   value - true, if empty item in file.
    %   type  - matrix logical
    %   @.empty:
    %   value - number of empty items in file.
    %   type  - int
    %   @.stringMask:
    %   value - true, if non-number and non-empty.
    %   type  - matrix logical
    %   @.string:
    %   value - number of non-number, non-empty items.
    %   type  - int
    %   @.quote:
    %   value - number of quotes.
    %   type  - int
    function [data, result] = read_log(self,log_name,log_dir)
      if nargin == 2; log_dir = './logs'; end

      log_name = sprintf('%s/%s',log_dir,log_name);
      [data_matrix, result] = readtext(log_name, ' ', '','','numeric');

      log_type = numel(data_matrix(1,:));
      data = struct;
      if (log_type == 14)
        % Sensor data only
        data.css = data_matrix(:, 1:6);
        data.accel = data_matrix(:, 7:10);
        data.gyro = data_matrix(:, 11);
        data.mag = data_matrix(:, 12:14);
      elseif (log_type == 15)
        % timestamp + Sensor data
        data.time = data_matrix(:, 1);
        data.css = data_matrix(:, 2:7);
        data.accel = data_matrix(:, 8:11);
        data.gyro = data_matrix(:, 12);
        data.mag = data_matrix(:, 13:15);
      elseif (log_type == 16)
        % logentry + timestamp + Sensor data
        data.line = data_matrix(:, 1);
        data.time = data_matrix(:, 2);
        data.css = data_matrix(:, 3:8);
        data.accel = data_matrix(:, 9:12);
        data.gyro = data_matrix(:, 13);
        data.mag = data_matrix(:, 14:16);
      end

    end

    % Plot the array of sensor data passed.
    function plot_sensors(self, log_name)

      [data, result] = self.read_log(log_name);
      data
      sim_time =  data(:,1) - data(1,1);
      css_data=   data(:,2:7);
      accel_data_n= [data(:,8) data(:,10)];
      accel_data_r= [data(:,9) data(:,11)];
      gyro_data=  data(:,12);
      mag_data =  data(:,13:15);

      figure( ...
        'Name','Sensor Plot', ...
        'Color',[0.95 0.95 0.95]);

      subplot(4,2,[1 3]);
      line(sim_time,css_data);
      grid on;
      legend(SensorName(1),SensorName(2),SensorName(3),SensorName(4), ...
        SensorName(5),SensorName(6),'Location','East');

      subplot(4,2,2);
      line(sim_time,accel_data_n);
      grid on;
      legend(SensorName(7),SensorName(9),'Location','East');

      subplot(4,2,4);
      line(sim_time,accel_data_r);
      grid on;
      legend(SensorName(8),SensorName(10),'Location','East');

      subplot(4,2,[5 7]);
      line(sim_time,gyro_data);
      grid on;
      legend(SensorName(11),'Location','East');

      subplot(4,2,[6 8]);
      line(sim_time,mag_data);
      grid on;
      legend(SensorName(12),SensorName(13),SensorName(14),'Location','East');
    end

  end
end