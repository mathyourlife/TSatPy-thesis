function [coeff, eq] = fit_trig(data)
	
	a = NaN; b = NaN; c = NaN; d = NaN;
	eq = '%g * sin(%g * [1:1000] %+g) %+g';
	
	% Initialize
	a = fit_a(data, a, b, c, d);
	d = fit_d(data, a, b, c, d);
	b = fit_b(data, a, b, c, d);
	c = fit_c(data, a, b, c, d);
	
	for i = 1:10
		a = fit_a(data, a, b, c, d);
		c = fit_c(data, a, b, c, d);
		b = fit_b(data, a, b, c, d);
		d = fit_d(data, a, b, c, d);
	end
	
	eq = sprintf('%g * sin(%g * x %+g) %+g', a, b, c, d);
	plot([1:length(data)], data, 'bo');
	hold on;
	plot([1:length(data)], a * sin(b * [1:length(data)] + c) + d, 'r-', 'LineWidth', 3);
	hold off;
	
	coeff = [a, b, c, d];
end

function a = fit_a(data, a, b, c, d)
	if isnan(a)
		a = (max(data) - min(data)) / 2;
	else
		% check amplitude shift of +- 10%
		err = NaN;
		for a_fit = a*0.5:a*0.001:a*1.5
			fit_err = calc_fit_error(data, a_fit, b, c, d);
			if isnan(err) | (fit_err < err)
				err = fit_err;
				a = a_fit;
			end
		end
	end
end

function b = fit_b(data, a, b, c, d)
	if isnan(b)
		[freq, power, mode] = SensorFFT([1:length(data)]', data);
		b = mode * 2 * pi;
	else
		err = NaN;
		for b_fit = b*0.5:b*0.001:b*1.5
			fit_err = calc_fit_error(data, a, b_fit, c, d);
			if isnan(err) | (fit_err < err)
				err = fit_err;
				b = b_fit;
			end
		end
	end
end

function c = fit_c(data, a, b, c, d)
	% Fit shift
	err = NaN;
	for c_fit = 1:length(data)
		fit_err = calc_fit_error(data, a, b, c_fit, d);
		if isnan(err) | (fit_err < err)
			err = fit_err;
			c = c_fit;
		end
	end
end

function d = fit_d(data, a, b, c, d)
	if isnan(d)
		d = mean(data);
	else
		err = NaN;
		for d_fit = d*0.5:d*0.001:d*1.5
			fit_err = calc_fit_error(data, a, b, c, d_fit);
			if isnan(err) | (fit_err < err)
				err = fit_err;
				d = d_fit;
			end
		end
	end
end

function fit_err = calc_fit_error(data, a, b, c, d)
	fit_data = a * sin(b * [1:length(data)]' + c) + d;
	fit_err = fit_data - data;
	fit_err = sum(dot(fit_err, fit_err));
end