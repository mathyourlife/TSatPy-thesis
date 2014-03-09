function PlotSensorLogFFT(logFile)
% Plots the sensor log's FFT

figure
[data, result]= readtext(logFile, ' ', '','','numeric');
for a=3:16
    a-2
    [freq, power, mode] = SensorFFT(data(1:end,2),data(1:end,a));
    subplot(4,4,a-2)
    plot(freq,power)
end
