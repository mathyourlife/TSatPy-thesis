
log_name = '180Hz.txt';
plot_title = 'Autocorrelation of Steady State Sensor Data with Sample Rate = 180Hz';

[data, result]= readtext(log_name, ' ', '','','numeric');
figure(1)

for i=3:16
    subplot(4,4,i-2)
    [tau,R]=autocorrelation(data(1:end,i),1);
    strMsg = SensorName(i-2);
    ylabel(strMsg)
end
hold off

suptitle(plot_title)
