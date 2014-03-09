function SensorLogStats(logFile)
% Calculates statistics based off the designated sensor log

[data, result]= readtext(logFile, ' ', '','','numeric');

xbar = mean(data(1:end,3:end));
sigma = std(data(1:end,3:end));

[Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(data(1:end,2));
