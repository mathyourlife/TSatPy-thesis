[data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
for a=13:13
    a-2
    [freq, power, mode] = SensorFFT(data(1:end,2),data(1:end,a));
    %subplot(4,4,a-2)
    plot(freq,power)
end