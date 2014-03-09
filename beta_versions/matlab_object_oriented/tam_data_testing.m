function angle = tam_data_testing()
	
	global calibration_data
	
	disp('setup data for MAG calibration')
	
	% Get saved data from a calibration run
	log_data = mock().gen_random_tam_calibration_data;
	
	angle = smooth_data(log_data);
	
	calibration_data.volts.steady = angle.steady_data;
	calibration_data.volts.xpos = angle.xpos_data;
	calibration_data.volts.ypos = angle.ypos_data;
	calibration_data.volts.xneg = angle.xneg_data;
	calibration_data.volts.yneg = angle.yneg_data;
	
	return
	normals = calculate_normals(tam_data);
	
	plot_data(tam_data);
	
end

function angle = smooth_data(log_data)
	
	tam_data = struct;
	angle = struct;
	c = css();
	f = fields(log_data);
	for i=1:numel(f)
		tam_data.(f{i}) = struct;
		tam_data.(f{i}).css = log_data.(f{i})(:,3:8);
		tam_data.(f{i}).mag = log_data.(f{i})(:,14:16);
		for r=1:size(tam_data.(f{i}).css,1)
			args = struct; args.volts = tam_data.(f{i}).css(r,:);
			c = c.update(args);
			tam_data.(f{i}).angle(r,1) = round(c.theta / pi * 180);
		end
		angle.(f{i}) = [];
		for n=1:360
			data = [];
			for m=-20:20
				data = [data; tam_data.(f{i}).mag(tam_data.(f{i}).angle==mod(n + m,360),:)];
			end
			angle.(f{i})(n,:) = mean(data);
		end
	end
	
end

function normals = calculate_normals(tam_data)
	f = fields(tam_data);
	for i=1:numel(f)
		normals.(f{i}) = fitNormal(tam_data.(f{i})(:,14:16));
	end
end

function plot_data(tam_data)
	lims = NaN(2,3);
	colors = 'bgrkm';
	f = fields(tam_data);
	for i=1:numel(f)
		data = tam_data.(f{i})(:,14:16);
		
		% Add data to plot
		L=plot3(data(:,1),data(:,2),data(:,3),colors(i));
		if i == 1
			hold on
		end
		
		lims = adjust_limits(lims, data, data);
	end
	
	p=get(L,'parent');
	grid on
	
	set(p,'XLim',lims(:,1)','YLim',lims(:,2)','ZLim',lims(:,3)','DataAspectRatio',[1 1 1])
	hold off
end

function lims = adjust_limits(lims, min_data, max_data)
	lims(1,:) = min([lims(1,:); min_data]);
	lims(2,:) = max([lims(2,:); max_data]);
end

function test()
	
	lims(1,:) = min([lims(1,:); tam_data.steady_data(:,14:16)])
	lims(2,:) = max([lims(2,:); tam_data.steady_data(:,14:16)])
	
	data = tam_data.steady_data(:,14:16);
	
	n = fitNormal(data,false)';
	
	tam_data.steady_n = n;
	
	center = mean(data);
	val = [center; center + n];
	
	plot3(val(:,1),val(:,2),val(:,3),'b')
	
	for i = 1:3
		X = data;
		X(:,i) = 1;
		
		X_m = X' * X;
		if det(X_m) == 0
			can_solve(i) = 0;
			continue
		end
		can_solve(i) = 1;
		
		% Construct and normalize the normal vector
		coeff = (X_m)^-1 * X' * data(:,i);
		c_neg = -coeff;
		c_neg(i) = 1;
		coeff(i) = 1;
		n(:,i) = c_neg / norm(coeff)
		
	end
	
	if sum(can_solve) == 0
		error('Planar fit to the data caused a singular matrix.')
		return
	end
	
	disp('Calculating residuals for each fit')
	center = mean(data);
	off_center = [data(:,1)-center(1) data(:,2)-center(2) data(:,3)-center(3)];
	for i = 1:3
		if can_solve(i) == 0
			residual_sum(i) = NaN;
			continue
		end
		
		residuals = off_center * n(:,i);
		residual_sum(i) = sum(residuals .* residuals)
		
	end
	
	best_fit = find(residual_sum == min(residual_sum));
	
	n(:,best_fit)

end