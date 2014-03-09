[StableSpinTAMData, result]= readtext('sensor_log.txt', ' ', '','','numeric');
disp(sprintf('Samples: %d',result.rows));
% Plot raw data
plot(StableSpinTAMData(1:end, 14:16))
% Analyze time stamps
time = StableSpinTAMData(1:end,2);
[Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(time);
disp(sprintf('Mean Sample Rate: %0.4f Hz',Hz_mean));
disp(sprintf('Mean Delta T: %0.4f s',delta_mean));
disp(sprintf('Standard Deviation Delta T: %0.6f s',delta_stdev));
TAMData = StableSpinTAMData(1:end, 14:16);
points = 50;
movAvg = zeros(size(TAMData,1)-points+1,3);
for i=points:size(TAMData,1)
sum(1) = 0;
sum(2) = 0;
sum(3) = 0;
for j=i-points+1:i
sum(1) = sum(1) + TAMData(j,1);
sum(2) = sum(2) + TAMData(j,2);
sum(3) = sum(3) + TAMData(j,3);
end
movAvg(i-points+1,1) = sum(1) / points;
movAvg(i-points+1,2) = sum(2) / points;
movAvg(i-points+1,3) = sum(3) / points;
end
plot3(movAvg(:,1),movAvg(:,2),movAvg(:,3))
