
    sim_time =  simout(1:end,2)-simout(1,2);
    css_data=   simout(1:end,3:8);
    accel_data= simout(1:end,9:12);
    gyro_data=  simout(1:end,13);
    mag_data =  simout(1:end,14:16);

    subplot(2,2,1);
    line(sim_time,css_data);
    grid on;
    subplot(2,2,2);
    line(sim_time,accel_data);
    grid on;
    subplot(2,2,3);
    line(sim_time,gyro_data);
    grid on;
    subplot(2,2,4);
    line(sim_time,mag_data);
    grid on;

    subplot(2,2,1); legend('CSS1','CSS2','CSS3','CSS4','CSS5','CSS6','Location','East');
    subplot(2,2,2); legend('ACCEL1X','ACCEL1Y','ACCEL2X','ACCEL2Y','Location','East');
    subplot(2,2,3); legend('Gyro','Location','East');
    subplot(2,2,4); legend('MagX','MagY','MagZ','Location','East');
