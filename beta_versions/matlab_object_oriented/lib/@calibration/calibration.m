classdef calibration
  properties
    css
  end

  methods
    function self = calibration()

    end

    function calibrate_mag_from_logs(self)

      global tsat

      l = logProcessing();

      file = struct;
      file.steady = input('Steady file log name: logs/[save/steady_mag.log] ','s');
      if (strcmp(file.steady,''))
        file.steady = 'save/steady_mag.log';
      end
      file.xpos = input('Weight on the +x axis log name: logs/[save/xpos_mag.log] ','s');
      if (strcmp(file.xpos,''))
        file.xpos = 'save/xpos_mag.log';
      end
      file.ypos = input('Weight on the +y axis log name: logs/[save/ypos_mag.log] ','s');
      if (strcmp(file.ypos,''))
        file.ypos = 'save/ypos_mag.log';
      end
      file.xneg = input('Weight on the -x axis log name: logs/[save/xneg_mag.log] ','s');
      if (strcmp(file.xneg,''))
        file.xneg = 'save/xneg_mag.log';
      end
      file.yneg = input('Weight on the -y axis log name: logs/[save/yneg_mag.log] ','s');
      if (strcmp(file.yneg,''))
        file.yneg = 'save/yneg_mag.log';
      end

      log_data = struct;
      f = fields(file);
      for i = 1:numel(f)
        [log_data.(f{i}), result] = l.read_log(file.(f{i}));
      end

      global calibration_data
      calibration_data.volts = self.smooth_data(log_data);

    end

    function angle = smooth_data(self, log_data)

      tam_data = struct;
      angle = struct;
      c = css();
      f = fields(log_data);
      for i=1:numel(f)
        tam_data.(f{i}) = struct;
        tam_data.(f{i}).css = log_data.(f{i}).css;
        tam_data.(f{i}).mag = log_data.(f{i}).mag;
        for r=1:size(tam_data.(f{i}).css,1)
          args = struct; args.volts = tam_data.(f{i}).css(r,:);
          c = c.update(args);
          tam_data.(f{i}).angle(r,1) = round(c.theta / pi * 180);
        end
        angle.(f{i}) = [];
        for n=1:360
          data = [];
          for m=-20:20
            data = [data; tam_data.(f{i}).mag(tam_data.(f{i}).angle==mod(n + m,360),:)];
          end
          angle.(f{i})(n,:) = mean(data);
        end
      end

    end

    function MagneticFieldCalibration(self,TSsock)

      global tsat

      spin_up_voltage = 5;
      sample_rate = 40;
      collection_time = 60;
      stage = 0;
      while (stage < 99)

        if stage == 0
          reply = input('Ready to start calibration? (1 for yes, 0 for no) ');
          if reply == 1
             stage = stage + 1;
          end
          disp('Setting sensor log rate')
          [msg_num, msg_data] = SendCommandAndWait(33,sample_rate,133);

        elseif stage == 1

          [tsat.mag.calibration.steady_data, tsat.mag.calibration.steady_normal] = ...
            SpinUpToSteadyRateAndCollectData(spin_up_voltage,collection_time);
          stage = stage + 1

        elseif stage == 2

          tsat.mag.calibration.weight = input('Enter weight to hang in grams: ');
          tsat.mag.calibration.radius = input('Enter hanging radius in centimeters: ');
          stage = stage + 1;
        elseif stage == 3

          reply = input('Hang the weight on the body +x axis. Enter 1 when ready. ');
          if reply == 1
            stage = stage + 1;
          end

        elseif stage == 4

          [tsat.mag.calibration.xpos_data, tsat.mag.calibration.xpos_normal] = ...
            SpinUpToSteadyRateAndCollectData(spin_up_voltage,collection_time);
          figure
          normal = plotTAM3D(tsat.mag.calibration.steady_data(:,14:16),'k');
          hold on;
          normal = plotTAM3D(tsat.mag.calibration.xpos_data(:,14:16),'b');
          hold off;
          reply = sprintf('Angle between Stable and Pos X: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.xpos_normal)); disp(reply)
          stage = stage + 1

        elseif stage == 5

          reply = input('Hang the weight on the body +y axis. Enter 1 when ready. ');
          if reply == 1
             stage = stage + 1;
          end

        elseif stage == 6

          [tsat.mag.calibration.ypos_data, tsat.mag.calibration.ypos_normal] = ...
            SpinUpToSteadyRateAndCollectData(spin_up_voltage,collection_time);
          figure
          normal = plotTAM3D(tsat.mag.calibration.steady_data(:,14:16),'k');
          hold on;
          normal = plotTAM3D(tsat.mag.calibration.ypos_data(:,14:16),'g');
          hold off;
          reply = sprintf('Angle between Stable and Pos Y: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.ypos_normal)); disp(reply)
          stage = stage + 1
        elseif stage == 7

          reply = input('Hang the weight on the body -x axis. Enter 1 when ready. ');
          if reply == 1
             stage = stage + 1;
          end

        elseif stage == 8

          [tsat.mag.calibration.xneg_data, tsat.mag.calibration.xneg_normal] = ...
            SpinUpToSteadyRateAndCollectData(spin_up_voltage,collection_time);
          figure
          normal = plotTAM3D(tsat.mag.calibration.steady_data(:,14:16),'k');
          hold on;
          normal = plotTAM3D(tsat.mag.calibration.xneg_data(:,14:16),'r');
          hold off;
          reply = sprintf('Angle between Stable and Neg X: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.xneg_normal)); disp(reply)
          stage = stage + 1

        elseif stage == 9
          reply = input('Hang the weight on the body -y axis. Enter 1 when ready. ');
          if reply == 1
             stage = stage + 1;
          end

        elseif stage == 10
          [tsat.mag.calibration.yneg_data, tsat.mag.calibration.yneg_normal] = ...
            SpinUpToSteadyRateAndCollectData(spin_up_voltage,collection_time);
          figure
          normal = plotTAM3D(tsat.mag.calibration.steady_data(:,14:16),'k');
          hold on;
          normal = plotTAM3D(tsat.mag.calibration.yneg_data(:,14:16),'m');
          hold off;
          reply = sprintf('Angle between Stable and Neg Y: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.yneg_normal)); disp(reply)
          stage = stage + 1

        elseif stage == 11
          figure
          normal = plotTAM3D(tsat.mag.calibration.steady_data(:,14:16),'k');
          hold on;
          normal = plotTAM3D(tsat.mag.calibration.xpos_data(:,14:16),'b');
          normal = plotTAM3D(tsat.mag.calibration.ypos_data(:,14:16),'g');
          normal = plotTAM3D(tsat.mag.calibration.xneg_data(:,14:16),'r');
          normal = plotTAM3D(tsat.mag.calibration.yneg_data(:,14:16),'m');
          hold off;
          reply = sprintf('Angle between Stable and Pos X: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.xpos_normal)); disp(reply)
          reply = sprintf('Angle between Stable and Pos Y: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.ypos_normal)); disp(reply)
          reply = sprintf('Angle between Stable and Neg X: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.xneg_normal)); disp(reply)
          reply = sprintf('Angle between Stable and Neg Y: %0.2f deg', ...
            AngleBetweenVectors(tsat.mag.calibration.steady_normal, ...
              tsat.mag.calibration.yneg_normal)); disp(reply)
          stage = stage + 1;

        else
          stage = stage + 1;

        end
      end

    end
  end
end