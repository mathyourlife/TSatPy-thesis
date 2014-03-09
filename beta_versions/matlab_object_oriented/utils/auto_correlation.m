% AUTO_CORRELATION - Auto Correlation
% Perform an auto correlation on the data provided
% and display the results in a plot.
% 
% Inputs:
% @data
%   value - Data to perform auto correlation on
%   type  - nx1 or 1xn matrix (nx1 vector preferred)
% @display_plot (optional default=false)
%   value - Should a plot be displayed?
%   type  - logical bool (true = display plot)
%
% Returns:
% @tau
%   value - Signal shift (x)
%   type  - (n*2-1)x1 vector size(@data)
% @R
%   value - Correlation value (y)
%   type  - (n*2-1)x1 double vector size(@data)
% @peak
%   value - Maximum absolute correlation value in @R
%   type  - (n*2-1)x1 double vector size(@data)
function [tau, R] = auto_correlation(data,display_plot)
	if (nargin == 1); display_plot = false; end
	
	data = makeVec(data);
	R = xcorr(data-mean(data));
	tau = [-(size(R)-1)/2:1:(size(R)-1)/2]';
	
	if display_plot
		plot(tau,R);
		hold on; grid on;
		index=find(abs(R)==max(abs(R)));
		title(sprintf('Stationary Autocorrelation (Max %0.2f)',R(index)))
		xlabel('Lag');
		hold off;
	end
	
end