function [freq, power, mode] = SensorFFT(timestamp, sensor)
	
	[Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(timestamp);
	
	Y=fft(sensor);
	Y(1)=[];
	n=length(Y);
	power = abs(Y(1:floor(n/2))).^2;
	nyquist = 1/2;
	freq = (1:n/2)/(n/2)*nyquist*Hz_mean;
	
	index=find(power==max(power));
	mode = freq(index);
end