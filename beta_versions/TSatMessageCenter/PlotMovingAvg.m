function PlotMovingAvg(Sensor_Num,Num_Points)
%Plot Nutation Detection

[data, result]= readtext('sensor_log.txt', ' ', '','','numeric');

data_column = Sensor_Num+2;

moving = zeros(1,Num_Points);
for a = 1:Num_Points-1
    moving(a+1) = data(a,data_column);
end
averaged = zeros(size(data,1)-Num_Points+1,1);

for a=Num_Points:size(data,1)
    moving_sum = 0;
    for b=1:Num_Points-1
        moving(b) = moving(b+1);
        moving_sum = moving_sum + moving(b);
    end
    moving(Num_Points) = data(a,data_column);
    moving_sum = moving_sum + moving(Num_Points);
    averaged(a-Num_Points+1) = moving_sum / Num_Points;
    
end

figure(2)
subplot(2,1,1)

% Plot all data against moving average
%plot(data(1:end,2)-data(1,2),data(1:end,data_column), ...
%    data(1+round(Num_Points/2): ...
%    size(averaged,1)+round(Num_Points/2),2)- ...
%    data(1,2),averaged)
%strMsg = sprintf('%d point moving average',Num_Points);
%legend(strcat('Nutation Detection (',SensorName(Sensor_Num),')'), strMsg)

%Plot just moving average
plot(data(1+round(Num_Points/2): ...
    size(averaged,1)+round(Num_Points/2),2)- ...
    data(1,2),averaged)
strMsg = sprintf(' (%d point moving average)',Num_Points);
legend(strcat(SensorName(Sensor_Num),' ',strMsg))


grid on
xlabel('Time (sec)')
ylabel('Sensor Reading (volts)')



[freq, power, mode] = SensorFFT(data(1:size(averaged,1),2),averaged);
subplot(2,1,2)
plot(freq,power)
grid on
index=find(power==max(power));
strMsg = sprintf('Max Power Found at %0.2f Hz',freq(index));
title(strMsg)
xlabel('Frequency (Hz)')
ylabel('FFT Magnitude')
