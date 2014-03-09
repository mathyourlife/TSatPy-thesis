function plot_sensors(data,tag)
% Plot the array of sensor data passed.

    if nargin == 1, tag = ''; end

    sim_time =  data(1:end,1)-data(1,1);
    css_data=   data(1:end,2:7);
    accel_data_n= [data(1:end,8) data(1:end,10)];
    accel_data_r= [data(1:end,9) data(1:end,11)];
    gyro_data=  data(1:end,12);
    mag_data =  data(1:end,13:15);

    if tag == ''
        figure( ...
            'Name','Sensor Plot', ...
            'Color',[0.95 0.95 0.95]);
    else
        figure( ...
            'Name','Sensor Plot', ...
            'Color',[0.95 0.95 0.95], ...
            'Tag',tag);
    end
        
    subplot(4,2,[1 3]);
    line(sim_time,css_data);
    grid on;
    legend(SensorName(1),SensorName(2),SensorName(3),SensorName(4),SensorName(5),SensorName(6),'Location','East');
    
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