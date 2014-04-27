function msg_data_out = FilterMovingAverage(msg_data_in,flag)

    persistent msg_data_history
    
    sensor_count = 14;
    sensor_lag = 20;
    
    if flag == 1;
        msg_data_history = zeros(sensor_lag, sensor_count);
        return;
    end
    
    for a = 1:sensor_lag-1
        for b = 1:sensor_count
            msg_data_history(a,b) = msg_data_history(a+1,b);
        end
    end
    
    for b = 1:sensor_count
        msg_data_history(sensor_lag,b) = msg_data_in(b+1);
    end
    
    msg_data_out(1) = msg_data_in(1);
    for b = 1:sensor_count
        dblSum = 0;
        for a = 1:sensor_lag
            dblSum = dblSum + msg_data_history(a,b);
        end
        msg_data_out(b+1) = dblSum/sensor_lag;
    end
    
    
    