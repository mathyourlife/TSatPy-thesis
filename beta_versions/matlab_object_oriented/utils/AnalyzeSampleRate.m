function [Hz_mean, delta_mean, delta_stdev] = AnalyzeSampleRate(timestamp)
	% Determine Sample Rate characteristics from the timestamp vector
	
	delta = zeros(size(timestamp,1)-1,1);
	for a = 2:size(timestamp,1)
		delta(a-1) = timestamp(a) - timestamp(a-1);
	end
	
	Hz_mean = 1/mean(delta);
	delta_mean = mean(delta);
	delta_stdev = std(delta);
	
end