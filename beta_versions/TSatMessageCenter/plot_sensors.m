function plot_sensors(simout)
    sim_time =  simout(1:end,1)-simout(1,1);
    css_data=   simout(1:end,2:7);
    accel_data_r= [simout(1:end,9) simout(1:end,11)];
    accel_data_n= [simout(1:end,8) simout(1:end,10)];
    gyro_data=  simout(1:end,12);
    mag_data =  simout(1:end,13:15);

    figure
    subplot(4,2,[1 3]);
    line(sim_time,css_data);
    grid on;
    subplot(4,2,2);
    line(sim_time,accel_data_r);
    grid on;
    subplot(4,2,4);
    line(sim_time,accel_data_n);
    grid on;
    subplot(4,2,[5 7]);
    line(sim_time,gyro_data);
    grid on;
    subplot(4,2,[6 8]);
    line(sim_time,mag_data);
    grid on;

    subplot(4,2,[1 3]); legend(SensorName(1),SensorName(2),SensorName(3),SensorName(4),SensorName(5),SensorName(6),'Location','East');
    subplot(4,2,2); legend(SensorName(7),SensorName(8),'Location','East');
    subplot(4,2,4); legend(SensorName(9),SensorName(10),'ACCEL2Y','ACCEL2X','Location','East');
    subplot(4,2,[5 7]); legend(SensorName(11),'Location','East');
    subplot(4,2,[6 8]); legend(SensorName(12),SensorName(13),SensorName(14),'Location','East');
